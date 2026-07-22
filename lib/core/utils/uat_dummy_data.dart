import 'dart:math';

class UatDummyData {
  static final Random _random = Random();

  static final List<Map<String, dynamic>> _dummyPosts = _generateDummyPosts();

  static List<Map<String, dynamic>> _generateDummyPosts() {
    final topics = [
      {
        'title': 'My Journey to Recovery: Celebrating Six Months Cancer-Free',
        'tags': [
          'cancerfree',
          'remission',
          'healingjourney',
          'survivor',
          'milestone'
        ]
      },
      {
        'title': 'Finding Peace After a Heart Attack: My New Normal',
        'tags': [
          'hearthealth',
          'cardiacrehab',
          'healthylifestyle',
          'recovery',
          'milestone'
        ]
      },
      {
        'title': 'The Road to Mental Wellness: One Step at a Time',
        'tags': [
          'mentalhealth',
          'depressionrecovery',
          'therapyworks',
          'recovery'
        ]
      },
      {
        'title':
            'A Decade of Healing: The 10-Minute Deep Dive into Chronic Illness',
        'tags': [
          'chronicillness',
          'spoonie',
          'healthjourney',
          'advocacy',
          'longread'
        ]
      },
      {
        'title': 'Overcoming Anxiety: A Decade Long Battle',
        'tags': ['anxiety', 'mentalhealth', 'longread']
      },
      {
        'title': 'My Journey with Rheumatoid Arthritis',
        'tags': ['ra', 'chronicillness', 'spoonie']
      },
      {
        'title': 'Navigating Life with Bipolar Disorder',
        'tags': ['bipolar', 'mentalhealth', 'recovery']
      },
      {
        'title': 'Surviving and Thriving After a Stroke',
        'tags': ['stroke', 'recovery', 'survivor']
      },
      {
        'title': 'The Reality of Living with Lupus',
        'tags': ['lupus', 'autoimmune', 'chronicpain']
      },
      {
        'title': 'Finding My Voice After Trauma',
        'tags': ['trauma', 'ptsd', 'healing']
      },
      {
        'title': 'Living with Multiple Sclerosis',
        'tags': ['ms', 'multiplesclerosis', 'chronicillness']
      },
      {
        'title': 'The Hidden Struggles of Endometriosis',
        'tags': ['endo', 'womenshealth', 'chronicpain']
      },
      {
        'title': 'My Life After a Spinal Cord Injury',
        'tags': ['sci', 'recovery', 'milestone']
      },
      {
        'title': 'Rebuilding Life After Severe Burnout',
        'tags': ['burnout', 'mentalhealth', 'healing']
      },
    ];

    final intros = [
      'It’s been an incredible journey over the last several months. From the moment I was first diagnosed, everything felt overwhelming and uncertain. There were days when getting out of bed felt like a monumental task, and times when the treatment took everything out of me. The hospital visits blurred together into a seemingly endless routine of waiting rooms, IV drips, and sympathetic glances from nurses who had seen it all before. But with the unwavering support of my family, my incredible medical team, and the stories shared by this community, I found the strength to keep fighting.',
      'Years ago, my life changed forever when I suffered a major health crisis. I thought I was invincible, but stress and poor habits caught up with me. The recovery process was the hardest thing I\'ve ever gone through, both physically and emotionally. The fear of another event hovered over me like a dark cloud for months, paralyzing me from doing even the simplest of tasks like lifting groceries or walking up a flight of stairs.',
      'Taking the first step toward treatment was a decision that took me years to make. I let stigma and fear hold me back, convinced that I just needed to "try harder" or that I could exercise and meditate my way out of a chemical imbalance in my body. I hit rock bottom, unable to leave my apartment or answer messages from friends, and finally sought professional help.',
      'When you are diagnosed with a lifelong chronic condition, your entire perception of time and future alters instantly. This story is meant to be a deep dive into the realities of living with a chronic condition over the course of a decade. It isn\'t a neat, linear story of sickness to health, but rather a complex, winding road of adaptation, grief, resilience, and ultimately, a profound transformation of self.',
      'The beginning is always the hardest part. You are thrust into a medical system that speaks a language you don\'t understand, filled with acronyms, specialists, and endless waiting rooms. For the first two years, my life was entirely consumed by my illness. I was tracking symptoms meticulously, researching experimental treatments late into the night, and desperately trying to find a "cure" that didn\'t exist. I was fighting a war against my own body, and I was losing.'
    ];

    final bodies = [
      'The turning point came not from a miraculous new drug, although medical advancements certainly helped stabilize me, but from a profound psychological shift. I realized that viewing my body as an enemy was an exhausting and ultimately futile endeavor. My body wasn\'t trying to destroy me; it was simply broken and doing its best to survive under incredibly difficult circumstances. This shift from antagonism to compassion changed everything. I started listening to my body\'s signals rather than trying to suppress them. When I was tired, I rested without guilt. When I was in pain, I nurtured myself instead of getting angry. This radical acceptance didn\'t cure the physical symptoms, but it completely cured the psychological suffering that accompanied them.',
      'Navigating the social landscape of a chronic condition is a uniquely challenging experience. Socializing typically revolves around boundless energy, late nights, and physical endurance. I had none of those things. I had to learn how to advocate for my needs in a society that values constant hustle. I lost friends who didn\'t understand why I couldn\'t go out, and I felt profound isolation watching my peers hit milestones while my biggest accomplishment for the week was simply taking a shower. However, this isolation also acted as a filter, removing superficial relationships and leaving only those with deep, genuine empathy. The friends who stayed, who came over to watch movies when I couldn\'t leave the house, who never made me feel guilty for canceling plans at the last minute—those are the relationships that sustained me.',
      'Over the years, I\'ve also had to navigate the complex world of the medical establishment. Being a professional patient is practically a full-time job. I\'ve learned how to read my own lab results, how to politely but firmly push back against doctors who dismiss my symptoms, and how to coordinate care between multiple specialists who rarely communicate with each other. It\'s a broken system, and it requires an enormous amount of self-advocacy. I\'ve cried in doctor\'s offices out of sheer frustration, and I\'ve celebrated when a new specialist finally validated what I had been feeling for years. To anyone just starting this journey: trust your gut. You know your body better than anyone else in the world. Do not let anyone gaslight you into believing your pain isn\'t real.',
      'The psychological toll of surviving a near-death experience cannot be overstated. For the first six months, every palpitation, every slight twinge sent me into a full-blown panic attack. I was convinced my body was a ticking time bomb. I ended up in the emergency room three times for what turned out to be severe anxiety, not physical issues. It was exhausting. I finally realized that my physical body was healing faster than my mind, and I needed professional help. I began seeing a therapist specializing in medical trauma. Through cognitive behavioral therapy, I learned to separate irrational fear from genuine medical symptoms. I learned grounding techniques to use when the panic set in, and slowly, the grip of fear began to loosen. I realized that living in constant fear of dying was preventing me from actually living the life I had been given back.',
      'Part of reclaiming my life was completely redefining my relationship with work. Before the crisis, I was a chronic overachiever. I worked late, skipped lunches, and checked emails on weekends. My identity was entirely wrapped up in my career title. When I was forced to take three months off to recover, I experienced a severe identity crisis. Who was I if not the reliable, hard-working employee? The time away forced me to confront the toxic nature of my ambition. I realized that the stress of my job had literally broken me. When I returned, I set rigid boundaries. I now leave the office at 5 PM sharp. I do not have work email on my phone. And I have discovered hobbies that bring me immense joy—gardening, woodworking, and spending quality time with my family. My career is now just a way to fund my life, rather than the singular purpose of my life.',
      'Rebuilding my life meant setting incredibly small, manageable goals at first. When brushing my teeth felt like climbing Mount Everest, I celebrated just putting the toothpaste on the brush. I learned to measure success not by societal milestones, but by my own internal barometer of wellness. Some days, success was simply taking a shower. Other days, it was going for a ten-minute walk. Slowly, the capacity for bigger goals returned. I started volunteering at a local animal shelter, finding profound purpose in caring for creatures who needed me. Finding purpose outside of myself was a critical turning point in my recovery.',
      'Navigating relapses has been the hardest part of the maintenance phase. There are still days when the heavy blanket of despair drops over me without warning. The panic that I am back at square one is overwhelming. But the difference now is that I have a toolkit. I know to immediately reach out to my therapist, to communicate with my support network, and to double down on my self-care routines. I know that the feelings are temporary, even when they feel permanent. I am no longer terrified of my own mind. I am the captain of my ship, and while the storms still come, I know how to navigate the waves without capsizing.',
      'The process of returning to a normal routine has been one of the most unexpected challenges. People assume that once you finish treatment, everything just snaps back to how it was before. But the truth is, you are fundamentally changed. The person who entered the hospital doors on day one is not the same person who walked out. I had to rediscover my identity outside of being a \'patient\'. Going back to work was terrifying. I worried about my stamina, my concentration, and how my colleagues would treat me. I decided to be open about my limitations and to my surprise, my workplace was incredibly accommodating. I learned that vulnerability is not a weakness; it\'s a strength that allows others to support you properly.',
      'Nutrition played a massive role in my ongoing recovery. During treatment, I could barely keep anything down, let alone focus on a balanced diet. Once my appetite returned, I worked with a dietitian to rebuild my body. We focused on anti-inflammatory foods, lean proteins, and an abundance of vegetables. It wasn\'t about losing weight or looking a certain way; it was about giving my body the raw materials it desperately needed to repair the cellular damage caused by months of harsh chemicals. Cooking became a therapeutic ritual for me. Chopping vegetables and simmering soups became a way to actively participate in my own healing, taking back control of a body that had felt entirely out of my control for so long.',
      'We must also discuss the financial impact of chronic illness. It is a topic often swept under the rug due to shame, but it is a harsh reality. The out-of-pocket costs, the loss of income from missed work, the inability to work full-time—these factors create a heavy burden. I had to learn how to budget meticulously, how to swallow my pride and ask for help when I needed it, and how to find creative ways to generate income that accommodated my unpredictable health. It required a complete restructuring of my financial goals and expectations. But again, it taught me resourcefulness and resilience.'
    ];

    final conclusions = [
      'The most beautiful part of this terrifying ordeal has been the profound sense of gratitude that has taken root in my soul. When you come that close to losing everything, the small things become magnificent. The taste of a perfectly ripe peach, the sound of rain against the window, the warmth of my spouse\'s hand in mine—these everyday miracles now bring me to tears. I don\'t take a single breath for granted. My crisis was a brutal wake-up call, but it was also a second chance. It forced me to stop sleepwalking through my existence and start truly living. To my fellow survivors, I know the road is long and frightening, but there is so much beauty waiting for you on the other side of fear. Keep walking, keep breathing, and keep trusting the resilience of your amazing body.',
      'As I look back on the past ten years, I feel an overwhelming sense of pride. I didn\'t just survive; I adapted, I learned, and I grew. I want to share this long, winding narrative because I know how incredibly lonely the beginning of a chronic illness journey can be. You feel like your life is over before it\'s even begun. But I promise you, it is not. It will be different, absolutely. It will be harder in ways you can\'t yet imagine. But it can also be richer, deeper, and more meaningful. You will discover a strength within yourself that you never knew existed. You will learn to appreciate the good days with a ferocity that healthy people will never understand. So keep going. Keep advocating for yourself. Keep seeking out community. And above all, keep treating yourself with the immense compassion and grace you deserve.',
      'Ultimately, this decade has been a masterclass in impermanence. My health fluctuates, my abilities change from day to day, and I have learned to surrender to that ebb and flow. I no longer try to force my body to adhere to a rigid schedule. I ride the waves. When the tide is high, I accomplish what I can. When the tide is low, I rest without guilt. This fluidity has brought a profound sense of peace into my life. I am no longer fighting a war; I am navigating an ever-changing landscape. And in this landscape, there is still immense beauty to be found.',
      'Looking ahead, my goals have completely shifted. I used to be obsessed with climbing the corporate ladder and accumulating material things. Now, my priorities are entirely centered around health, experiences, and time spent with loved ones. I want to travel more, learn new skills just for the joy of learning, and advocate for better patient care in my local community. I want to make sure the time I fought so hard to secure is spent meaningfully. To anyone standing at the beginning of this terrifying path, please know this: it is going to be incredibly hard, but you are capable of enduring hard things. Lean on your support system, advocate fiercely for your health, and never lose sight of the light at the end of the tunnel. You are not alone.',
      'To anyone reading this from the depths of the dark place, please hold on. The dawn is coming, I promise you. It takes time, patience, and professional help, but you can build a life that feels good to live in again. The illness took a lot from me, but it also gave me a profound depth of empathy, an unshakeable resilience, and a laser focus on what truly matters in life. I no longer sweat the small stuff because I\'ve faced the big stuff and survived.'
    ];

    final List<Map<String, dynamic>> generatedPosts = [];
    final rand = Random(42); // fixed seed for consistent dummy data

    for (var topic in topics) {
      String content = intros[rand.nextInt(intros.length)] + '\n\n';

      // Select 6 to 10 random body paragraphs to make the reading time around 6-10 minutes.
      // Average paragraph is about 150 words. To get 1200-2000 words, we need about 8-12 paragraphs total.
      // 1 intro + 1 conclusion = 2 paragraphs. So we need 7 to 11 body paragraphs.
      int numBodies = 7 + rand.nextInt(5);
      for (int i = 0; i < numBodies; i++) {
        // Occasionally repeat or mix paragraphs to get length, it's just dummy data
        content += bodies[rand.nextInt(bodies.length)] + '\n\n';
      }

      content += conclusions[rand.nextInt(conclusions.length)];

      generatedPosts.add({
        'title': topic['title'],
        'content': content,
        'tags': topic['tags'],
      });
    }

    return generatedPosts;
  }

  /// Returns a random dummy post containing a 'title', 'content', and 'tags' list.
  static Map<String, dynamic> getRandomPost() {
    return _dummyPosts[_random.nextInt(_dummyPosts.length)];
  }

  /// Returns all dummy posts.
  static List<Map<String, dynamic>> getAllPosts() {
    return _dummyPosts;
  }
}
