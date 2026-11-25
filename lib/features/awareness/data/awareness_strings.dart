import '../domain/emergency_guide_model.dart';
import 'awareness_providers.dart';

class AwarenessStrings {
  final AwarenessLanguage language;

  const AwarenessStrings(this.language);

  bool get isHi => language == AwarenessLanguage.hi;

  String get searchHint => isHi
      ? 'आपातकालीन गाइड खोजें (CPR, जलना, अस्थमा...)'
      : 'Search emergencies (CPR, burns, asthma...)';

  String get cprCoach => isHi ? 'CPR कोच' : 'CPR Coach';
  String get disclaimer => isHi
      ? 'AHA, WHO और Red Cross दिशानिर्देशों पर आधारित। केवल शैक्षिक और आपातकालीन संदर्भ के लिए — पेशेवर चिकित्सा देखभाल का विकल्प नहीं।'
      : 'Based on AHA, WHO & Red Cross guidelines. For educational & emergency reference only; not a substitute for professional medical care.';

  String get firstAidTitle =>
      isHi ? 'प्राथमिक चिकित्सा और आपातकाल' : 'First-Aid & Emergency';

  String guidesCount(int count) => isHi ? '$count गाइड' : '$count guides';

  String noGuidesFound(String query) => isHi
      ? '"$query" के लिए कोई आपातकालीन गाइड नहीं मिला।'
      : 'No emergency guides found for "$query".';

  String get emergencyRegionTitle =>
      isHi ? 'आपातकालीन नंबर और क्षेत्र' : 'Emergency Number & Region';
  String get emergencyRegionSubtitle => isHi
      ? 'अपने क्षेत्र का स्थानीय आपातकालीन नंबर चुनें।'
      : 'Choose the local emergency number for your area.';
  String get customNumberHint =>
      isHi ? 'या कस्टम नंबर दर्ज करें...' : 'Or enter custom number...';
  String get save => isHi ? 'सहेजें' : 'Save';

  // Detail Screen
  String stepsSubtitle(int count) => isHi
      ? '$count चरण • हैंड्स-फ़्री वॉइस तैयार'
      : '$count steps • Hands-free voice ready';
  String get startHandsFree =>
      isHi ? 'हैंड्स-फ़्री गाइड शुरू करें' : 'Start Hands-Free Guide';
  String get openCprCoach =>
      isHi ? '110 BPM CPR कोच खोलें' : 'Open 110 BPM CPR Coach';
  String get stepsHeading => isHi ? 'चरण' : 'Steps';
  String get tapStepHint =>
      isHi ? 'हैंड्स-फ़्री के लिए टैप करें' : 'Tap step for hands-free';
  String get avoidMistakes =>
      isHi ? 'ये गलतियाँ न करें' : 'Avoid These Mistakes';
  String get testYourself => isHi ? 'अपना परीक्षण करें' : 'Test Yourself';
  String get testPassed => isHi ? 'परीक्षा उत्तीर्ण' : 'Test Passed';
  String quizSummary(int count) => isHi
      ? '$count प्रश्न • पास होने के लिए 100% आवश्यक'
      : '$count questions • 100% required';
  String get start => isHi ? 'शुरू करें' : 'Start';
  String get retake => isHi ? 'फिर से दें' : 'Retake';
  String get retakeTest => isHi ? 'परीक्षा फिर से दें' : 'Retake Test';
  String get passedBadge =>
      isHi ? '100% उत्तीर्ण • अभ्यास पूर्ण' : '100% Passed • Practiced';
  String get whyItWorks =>
      isHi ? 'यह कैसे काम करता है' : 'Why It Works';
  String get whyItWorksSubtitle =>
      isHi ? 'इसके पीछे का विज्ञान और जीवविज्ञान जानें' : 'Science & biology behind these steps';
  String get learnWhy => isHi ? 'जानें' : 'Read';
  String get whatsHappeningInBody =>
      isHi ? 'शरीर में क्या हो रहा है' : 'What\'s Happening in the Body';
  String get whyEachStepWorks =>
      isHi ? 'हर कदम क्यों काम करता है' : 'Why Each Action Works';
  String get mythBuster => isHi ? 'भ्रम बनाम विज्ञान' : 'Myth Buster';
  String get simpleMode => isHi ? 'सरल भाषा' : 'Simple';
  String get clinicalMode => isHi ? 'चिकित्सीय' : 'Clinical';
  String get guidelinesRef =>
      isHi ? 'दिशानिर्देश और संदर्भ' : 'Guidelines & References';

  // Hands-Free Screen
  String stepOf(int current, int total) =>
      isHi ? 'चरण $current / $total' : 'STEP $current OF $total';
  String get handsFreeSpeaking =>
      isHi ? 'हैंड्स-फ़्री बोल रहा है' : 'Hands-Free Speaking';
  String get paused => isHi ? 'रुका हुआ' : 'Paused';
  String get pauseVoice => isHi ? 'आवाज़ रोकें' : 'Pause Voice';
  String get resumeVoice => isHi ? 'आवाज़ जारी रखें' : 'Resume Voice';
  String get switchToCpr =>
      isHi ? '110 BPM CPR कोच पर जाएँ' : 'Switch to 110 BPM CPR Coach';

  // Quiz Screen
  String testTitle(String title) => isHi ? 'परीक्षण: $title' : 'Test: $title';
  String questionOf(int current, int total) =>
      isHi ? 'प्रश्न $current / $total' : 'QUESTION $current OF $total';
  String scoreLabel(int score, int total) =>
      isHi ? 'अंक: $score/$total' : 'Score: $score/$total';
  String get nextQuestion => isHi ? 'अगला प्रश्न' : 'Next Question';
  String get seeResults => isHi ? 'परिणाम देखें' : 'See Results';
  String get passedHeading => isHi ? 'परीक्षा उत्तीर्ण!' : 'Test Passed!';
  String get almostThereHeading => isHi ? 'लगभग हो गया' : 'Almost There';
  String resultScore(int score, int total) => isHi
      ? 'आपने $total में से $score प्रश्नों के सही उत्तर दिए।'
      : 'You answered $score of $total questions correctly.';
  String get passedDesc => isHi
      ? 'बहुत बढ़िया! यह आपातकालीन गाइड अब अभ्यास के रूप में चिह्नित है।'
      : 'Great job! This emergency guide is now marked as practiced.';
  String failDesc(int total) => isHi
      ? 'इस गाइड को पास करने के लिए सभी $total प्रश्नों का सही उत्तर देना आवश्यक है।'
      : 'All $total questions must be answered correctly to pass this guide.';
  String get done => isHi ? 'पूर्ण' : 'Done';
  String get retryTest => isHi ? 'पुनः प्रयास करें' : 'Retry Test';
  String get reviewSteps =>
      isHi ? 'चरण फिर से देखें' : 'Review Steps Again';

  // CPR Coach
  String get handsOnly => isHi ? 'केवल हाथ (Hands-Only)' : 'Hands-Only';
  String get breaths302 => isHi ? '30:2 श्वास' : '30:2 Breaths';
  String get continuousDesc => isHi
      ? 'लगातार दबाव • कोई विराम नहीं'
      : 'Continuous compressions • No pauses';
  String get breaths302Desc => isHi
      ? '30 दबाव • 2 बचाव श्वास के लिए 5 सेकंड का विराम'
      : '30 compressions • Pauses 5s for 2 rescue breaths';
  String get tapToStart => isHi ? 'शुरू करने के लिए टैप करें' : 'TAP TO START';
  String get push => isHi ? 'दबाएँ' : 'PUSH';
  String get twoBreaths => isHi ? '2 श्वास' : '2 BREATHS';
  String get giveTwoBreaths =>
      isHi ? '2 हल्की बचाव श्वास दें' : 'Give 2 gentle breaths';
  String get startBeat =>
      isHi ? '110 BPM बीट शुरू करें' : 'Start 110 BPM Beat';
  String get pauseCpr => isHi ? 'CPR कोच रोकें' : 'Pause CPR Coach';
  String get beatSound => isHi ? 'बीट ध्वनि' : 'Beat Sound';
  String get voice => isHi ? 'आवाज़' : 'Voice';
  String get haptics => isHi ? 'कंपन' : 'Haptics';

  String categoryLabel(EmergencyCategory category) {
    if (!isHi) return category.label;
    switch (category) {
      case EmergencyCategory.cardiac:
        return 'हृदय और CPR';
      case EmergencyCategory.breathing:
        return 'श्वसन और घुटन';
      case EmergencyCategory.bleeding:
        return 'रक्तस्राव और चोट';
      case EmergencyCategory.neurological:
        return 'स्ट्रोक और दौरे';
      case EmergencyCategory.burns:
        return 'जलना और झुलसना';
      case EmergencyCategory.allergy:
        return 'एलर्जी';
    }
  }
}
