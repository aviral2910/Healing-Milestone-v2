import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_story_service.g.dart';

class AiStoryService {
  final GenerativeModel _model;

  AiStoryService()
      : _model = FirebaseAI.agentPlatform(location: 'us-central1').generativeModel(
          model: 'gemini-2.5-flash',
          generationConfig: GenerationConfig(
            temperature: 0.8,
            maxOutputTokens: 8192,
            responseMimeType: 'application/json',
          ),
          safetySettings: [
            SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium, HarmBlockMethod.probability),
            SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium, HarmBlockMethod.probability),
            SafetySetting(
                HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, HarmBlockMethod.probability),
            SafetySetting(
                HarmCategory.dangerousContent, HarmBlockThreshold.medium, HarmBlockMethod.probability),
          ],
        );

  Future<Map<String, String>> generateStoryFromAnswers({
    required String contextInfo,
    required String struggle,
    required String turningPoint,
    required String hope,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    print('DEBUG User ID: ${user?.uid}');
    
    // Remote Config Setup
    final remoteConfig = FirebaseRemoteConfig.instance;
    
    const String defaultPrompt = '''
You are an empathetic ghostwriter for a platform where people share stories about their healing journeys, traumas, and major life milestones. Your job is to take the user's rough notes and turn them into a cohesive, engaging, and emotionally authentic story.

CRITICAL INSTRUCTIONS:
- STRICTLY stick to the information provided by the user. 
- DO NOT invent any events, characters, conversations, settings, or backstory that the user did not explicitly mention.
- Do NOT hallucinate details to make it longer.
- DO write beautifully, organizing their exact points into a flowing narrative.
- Use accessible, everyday language that is easy to read. Do not use overly complex or flowery vocabulary, but DO preserve and use the exact specific words and phrasing the user provided.
- You can write multiple paragraphs to give the story emotional depth, but every single fact must come directly from their notes.
- Keep it in the first person ("I"). Keep their authentic tone.

The story should flow naturally through:
1. The background and the hardest part.
2. The turning point or the work it took.
3. The milestone achieved and a message of hope.

You must return your response as a valid JSON object matching exactly this structure:
{
  "title": "A captivating and deeply moving title for the story",
  "content": "The full, rich, detailed, and expansive story body..."
}
''';

    await remoteConfig.setDefaults({
      'ai_story_system_prompt': defaultPrompt,
    });
    
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print('DEBUG: Failed to fetch remote config: $e');
    }

    final systemPrompt = remoteConfig.getString('ai_story_system_prompt');

    final prompt = '''
$systemPrompt

User's notes:
- Background context: $contextInfo
- The hardest part: $struggle
- Turning point or start of healing: $turningPoint
- Message of hope: $hope
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '{}';
      
      try {
        final decoded = jsonDecode(text) as Map<String, dynamic>;
        return {
          'title': decoded['title']?.toString() ?? '',
          'content': decoded['content']?.toString() ?? 'Unable to generate story content at this time.',
        };
      } catch (e) {
        // Fallback if parsing fails
        return {
          'title': '',
          'content': text,
        };
      }
    } catch (e) {
      print('Error generating story: $e');
      throw Exception('Failed to generate story. Please try again.');
    }
  }
}

@riverpod
AiStoryService aiStoryService(Ref ref) {
  return AiStoryService();
}
