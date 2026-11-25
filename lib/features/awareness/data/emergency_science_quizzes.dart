import '../domain/emergency_guide_model.dart';
import 'awareness_providers.dart';

List<EmergencyQuizQuestion> getScienceQuizzes(
  String guideId,
  AwarenessLanguage language,
) {
  final map =
      language == AwarenessLanguage.hi ? _scienceQuizzesHi : _scienceQuizzesEn;
  return map[guideId] ?? const [];
}

const Map<String, List<EmergencyQuizQuestion>> _scienceQuizzesEn = {
  'cpr_adult': [
    EmergencyQuizQuestion(
      question: 'Why is it critical to let the chest rise completely between CPR pushes?',
      options: [
        'It gives the rescuer\'s wrists a break',
        'It creates gentle suction inside the chest so the heart refills with blood',
        'It prevents the AED pads from peeling off',
      ],
      correctIndex: 1,
      explanation:
          'Full chest recoil creates negative pressure inside the chest, pulling fresh blood back into the heart for the next compression.',
    ),
    EmergencyQuizQuestion(
      question: 'Why does CPR push blood even when the heart has stopped?',
      options: [
        'Pressing the breastbone squeezes the heart between the breastbone and backbone',
        'It forces air directly into the bloodstream',
        'It shocks the heart muscle mechanically',
      ],
      correctIndex: 0,
      explanation:
          'Firm compressions squeeze the heart between the sternum and spine, acting as a manual pump to send oxygenated blood to the brain.',
    ),
  ],
  'choking_adult': [
    EmergencyQuizQuestion(
      question: 'Why do abdominal thrusts work even when a person cannot breathe in?',
      options: [
        'They push residual trapped air in the lungs upward like a piston to pop the object out',
        'They relax the throat muscles instantly',
        'They push food down into the stomach',
      ],
      correctIndex: 0,
      explanation:
          'There is always trapped air inside the lungs; pushing upward beneath the ribs compresses it to expel the blockage.',
    ),
  ],
  'stroke_fast': [
    EmergencyQuizQuestion(
      question: 'Why should you NEVER give aspirin during a suspected stroke before a hospital scan?',
      options: [
        'Aspirin causes drowsiness',
        'About 1 in 7 strokes are caused by bleeding in the brain, which aspirin worsens',
        'Aspirin slows down ambulance response',
      ],
      correctIndex: 1,
      explanation:
          'Only a CT scan can tell a clot stroke apart from a bleeding stroke; aspirin thins blood and worsens brain bleeding.',
    ),
  ],
  'severe_bleeding': [
    EmergencyQuizQuestion(
      question: 'Why does keeping a severely bleeding person warm with a blanket help stop bleeding?',
      options: [
        'When the body gets cold, its natural blood-clotting glue stops working properly',
        'Warmth dries the blood on the skin faster',
        'It keeps the person from moving their arms',
      ],
      correctIndex: 0,
      explanation:
          'Hypothermia impairs blood-clotting enzymes and worsens shock, making bleeding harder to control.',
    ),
  ],
  'anaphylaxis': [
    EmergencyQuizQuestion(
      question: 'Why do regular allergy pills NOT work in anaphylaxis?',
      options: [
        'They take 30–60 minutes to act and cannot reverse airway swelling or crashing blood pressure',
        'They only work on skin rashes',
        'They cannot be swallowed with water',
      ],
      correctIndex: 0,
      explanation:
          'Only epinephrine acts within minutes to shrink swollen airways and tighten leaky blood vessels.',
    ),
  ],
  'burns_scalds': [
    EmergencyQuizQuestion(
      question: 'Why is ice harmful when placed on a burn?',
      options: [
        'Ice melts too fast',
        'Extreme cold constricts blood vessels and kills fragile, healing skin tissue',
        'Ice causes blisters to grow bigger immediately',
      ],
      correctIndex: 1,
      explanation:
          'Cool (not icy) running water draws trapped heat out gently without cutting off blood supply to damaged skin.',
    ),
  ],
  'seizures_fainting': [
    EmergencyQuizQuestion(
      question: 'Why does rolling someone onto their side after a seizure protect their breathing?',
      options: [
        'Gravity keeps the tongue from falling backward and lets saliva drain out',
        'It stops the brain\'s electrical storm faster',
        'It lowers blood pressure',
      ],
      correctIndex: 0,
      explanation:
          'After a seizure, muscles go limp; the recovery position prevents the tongue or fluids from blocking the airway.',
    ),
  ],
  'heart_attack_signs': [
    EmergencyQuizQuestion(
      question: 'Why is chewing a regular aspirin recommended over swallowing it whole (when advised)?',
      options: [
        'It tastes better',
        'Chewing absorbs aspirin fast through mouth tissues to stop platelets from growing the clot',
        'Swallowing takes 5 hours',
      ],
      correctIndex: 1,
      explanation:
          'Chewing speeds absorption into the bloodstream, slowing clot growth inside the blocked heart artery.',
    ),
  ],
  'infant_choking_cpr': [
    EmergencyQuizQuestion(
      question: 'Why should you NEVER perform abdominal thrusts on an infant under 1 year old?',
      options: [
        'Their ribs don\'t fully protect soft belly organs like the liver, which can be injured',
        'Infants cannot swallow objects',
        'It makes them cry too loudly',
      ],
      correctIndex: 0,
      explanation:
          'An infant\'s liver sits lower and less protected; 2-finger chest thrusts safely raise chest pressure instead.',
    ),
  ],
  'asthma_attack': [
    EmergencyQuizQuestion(
      question: 'Why do daily "preventer" inhalers not help during a sudden asthma attack?',
      options: [
        'They reduce airway swelling slowly over days rather than relaxing tight airway muscles in minutes',
        'They only work at night',
        'They are meant for allergies only',
      ],
      correctIndex: 0,
      explanation:
          'Quick-relief rescue inhalers relax squeezed airway muscles within minutes, whereas steroid preventers act slowly.',
    ),
  ],
  'diabetic_hypoglycemia': [
    EmergencyQuizQuestion(
      question: 'Why are chocolate and biscuits poor choices for treating sudden low blood sugar?',
      options: [
        'They have no sugar',
        'Their fat slows stomach emptying, delaying sugar from reaching the brain',
        'They cause immediate dehydration',
      ],
      correctIndex: 1,
      explanation:
          'Pure simple sugars (juice or glucose tablets) enter the blood in 10–15 minutes without fat slowing digestion.',
    ),
  ],
  'snake_bite': [
    EmergencyQuizQuestion(
      question: 'How does most snake venom travel through the body right after a bite?',
      options: [
        'Through slow under-skin fluid channels (lymphatics) that pump when muscles move',
        'Directly through bones',
        'Only when the victim drinks water',
      ],
      correctIndex: 0,
      explanation:
          'Because muscle movement pumps lymphatic fluid, keeping the limb completely still dramatically slows venom spread.',
    ),
  ],
  'spinal_injury': [
    EmergencyQuizQuestion(
      question: 'Why should an untrained bystander leave a motorcycle helmet on after a crash?',
      options: [
        'Pulling a tight helmet off forces the neck to bend and twist, risking spinal cord damage',
        'Helmets keep the ears warm',
        'Paramedics need the helmet for insurance',
      ],
      correctIndex: 0,
      explanation:
          'Uncontrolled neck twisting can shift a cracked vertebra into the spinal cord.',
    ),
  ],
};

const Map<String, List<EmergencyQuizQuestion>> _scienceQuizzesHi = {
  'cpr_adult': [
    EmergencyQuizQuestion(
      question: 'CPR में हर दबाव के बाद छाती को पूरा ऊपर आने देना क्यों ज़रूरी है?',
      options: [
        'इससे मदद करने वाले के हाथों को आराम मिलता है',
        'इससे छाती में हल्का खिंचाव बनता है ताकि दिल में फिर से खून भर सके',
        'इससे AED पैड चिपके रहते हैं',
      ],
      correctIndex: 1,
      explanation:
          'छाती पूरा उठने से अंदर नकारात्मक दबाव बनता है जो अगले दबाव के लिए दिल में ताज़ा खून खींचता है।',
    ),
    EmergencyQuizQuestion(
      question: 'जब दिल रुक चुका होता है, तब भी CPR खून को कैसे चलाता है?',
      options: [
        'छाती की हड्डी दबाने से दिल छाती और रीढ़ की हड्डी के बीच दबकर पंप की तरह काम करता है',
        'यह सीधे खून में हवा भरता है',
        'यह दिल को हल्का करंट देता है',
      ],
      correctIndex: 0,
      explanation:
          'मजबूत दबाव दिल को दोनों हड्डियों के बीच दबाकर दिमाग तक ऑक्सीजन युक्त खून पहुंचाता है।',
    ),
  ],
  'choking_adult': [
    EmergencyQuizQuestion(
      question: 'सांस न ले पाने पर भी पेट के दबाव (Abdominal Thrusts) कैसे काम करते हैं?',
      options: [
        'ये फेफड़ों में फंसी बची हुई हवा को ऊपर धकेलकर अटकी चीज़ बाहर फेंकते हैं',
        'ये गले की मांसपेशियों को तुरंत ढीला कर देते हैं',
        'ये खाने को पेट में नीचे धकेलते हैं',
      ],
      correctIndex: 0,
      explanation:
          'पसलियों के नीचे ऊपर की ओर दबाव फेफड़ों की बची हवा को पिचकारी की तरह इस्तेमाल कर रुकावट बाहर निकालता है।',
    ),
  ],
  'stroke_fast': [
    EmergencyQuizQuestion(
      question: 'अस्पताल में स्कैन से पहले संदिग्ध स्ट्रोक में एस्पिरिन क्यों नहीं देनी चाहिए?',
      options: [
        'एस्पिरिन से नींद आती है',
        'लगभग 7 में से 1 स्ट्रोक दिमाग में नस फटने (रक्तस्राव) से होता है, जिसे एस्पिरिन बढ़ा देती है',
        'इससे एम्बुलेंस देर से आती है',
      ],
      correctIndex: 1,
      explanation:
          'केवल CT स्कैन ही बता सकता है कि स्ट्रोक थक्के से है या रक्तस्राव से; रक्तस्राव में एस्पिरिन घातक हो सकती है।',
    ),
  ],
  'severe_bleeding': [
    EmergencyQuizQuestion(
      question: 'गंभीर रक्तस्राव में घायल को कंबल से गर्म रखना खून रोकने में कैसे मदद करता है?',
      options: [
        'शरीर ठंडा पड़ने पर खून जमाने वाला प्राकृतिक तंत्र ठीक से काम करना बंद कर देता है',
        'गर्मी से त्वचा पर खून जल्दी सूखता है',
        'इससे व्यक्ति हाथ नहीं हिला पाता',
      ],
      correctIndex: 0,
      explanation:
          'ठंड (हाइपोथर्मिया) खून जमाने वाले एंजाइमों को निष्क्रिय कर देती है और शॉक बढ़ाती है।',
    ),
  ],
  'anaphylaxis': [
    EmergencyQuizQuestion(
      question: 'गंभीर एलर्जी (एनाफिलेक्सिस) में सामान्य एलर्जी की गोलियां काम क्यों नहीं आतीं?',
      options: [
        'वे असर करने में 30–60 मिनट लेती हैं और सूजे गले या गिरते बीपी को नहीं संभाल सकतीं',
        'वे केवल त्वचा की खुजली पर काम करती हैं',
        'उन्हें पानी से नहीं लिया जा सकता',
      ],
      correctIndex: 0,
      explanation:
          'केवल एपिनेफ्रिन ही मिनटों में श्वासनली की सूजन घटाता है और बीपी वापस लाता है।',
    ),
  ],
  'burns_scalds': [
    EmergencyQuizQuestion(
      question: 'जली हुई त्वचा पर बर्फ लगाना नुकसानदायक क्यों है?',
      options: [
        'बर्फ जल्दी पिघल जाती है',
        'अत्यधिक ठंड रक्त वाहिकाओं को सिकोड़कर नाजुक त्वचा कोशिकाओं को नष्ट कर देती है',
        'बर्फ से फफोले तुरंत बड़े हो जाते हैं',
      ],
      correctIndex: 1,
      explanation:
          'सामान्य ठंडा बहता पानी बिना रक्त प्रवाह रोके अंदर की गर्मी बाहर निकालता है।',
    ),
  ],
  'seizures_fainting': [
    EmergencyQuizQuestion(
      question: 'दौरे के बाद व्यक्ति को करवट (Recovery Position) लिटाना सांस की सुरक्षा कैसे करता है?',
      options: [
        'गुरुत्वाकर्षण जीभ को पीछे गिरने से रोकता है और लार को बाहर निकलने देता है',
        'यह दिमाग के बिजली के तूफ़ान को जल्दी रोकता है',
        'यह ब्लड प्रेशर कम करता है',
      ],
      correctIndex: 0,
      explanation:
          'दौरे के बाद मांसपेशियां ढीली पड़ जाती हैं; करवट रखने से श्वासनली खुली रहती है।',
    ),
  ],
  'heart_attack_signs': [
    EmergencyQuizQuestion(
      question: 'सलाह मिलने पर एस्पिरिन निगलने के बजाय चबाने को क्यों कहा जाता है?',
      options: [
        'इसका स्वाद बेहतर होता है',
        'चबाने से दवा मुंह की झिल्ली से तेजी से खून में मिलकर थक्के को बढ़ने से रोकती है',
        'निगलने में 5 घंटे लगते हैं',
      ],
      correctIndex: 1,
      explanation:
          'चबाने से एस्पिरिन तुरंत रक्त में अवशोषित होकर प्लेटलेट्स को चिपकने से रोकती है।',
    ),
  ],
  'infant_choking_cpr': [
    EmergencyQuizQuestion(
      question: '1 वर्ष से कम उम्र के शिशु के पेट पर दबाव (Abdominal Thrusts) क्यों नहीं देना चाहिए?',
      options: [
        'उनकी मुलायम पसलियां लिवर जैसे नाजुक पेट के अंगों की पूरी रक्षा नहीं कर पातीं',
        'शिशु कुछ निगल नहीं सकते',
        'इससे वे जोर से रोते हैं',
      ],
      correctIndex: 0,
      explanation:
          'पेट दबाने से शिशु के लिवर को चोट लग सकती है; इसलिए 2-उंगली छाती दबाव सुरक्षित है।',
    ),
  ],
  'asthma_attack': [
    EmergencyQuizQuestion(
      question: 'अचानक अस्थमा अटैक में रोज़ाना वाला "प्रिवेंटर" इनहेलर काम क्यों नहीं आता?',
      options: [
        'वह सूजन को दिनों में धीरे-धीरे कम करता है, मिनटों में जकड़ी नलियों को नहीं खोल सकता',
        'वह केवल रात में काम करता है',
        'वह केवल एलर्जी के लिए होता है',
      ],
      correctIndex: 0,
      explanation:
          'अचानक अटैक में केवल रेस्क्यू इनहेलर ही मिनटों में श्वासनली की मांसपेशियों को ढीला करता है।',
    ),
  ],
  'diabetic_hypoglycemia': [
    EmergencyQuizQuestion(
      question: 'अचानक लो ब्लड शुगर में चॉकलेट और बिस्कुट अच्छे विकल्प क्यों नहीं हैं?',
      options: [
        'उनमें शुगर नहीं होती',
        'उनमें मौजूद चिकनाई (फैट) पेट खाली होने की गति धीमी कर शुगर को खून में देरी से पहुंचाती है',
        'उनसे तुरंत पानी की कमी हो जाती है',
      ],
      correctIndex: 1,
      explanation:
          'सादा जूस या ग्लूकोज टैबलेट बिना वसा के 10–15 मिनट में सीधे खून में पहुंचते हैं।',
    ),
  ],
  'snake_bite': [
    EmergencyQuizQuestion(
      question: 'काटने के तुरंत बाद अधिकांश सांपों का जहर शरीर में कैसे फैलता है?',
      options: [
        'त्वचा के नीचे धीमी लसीका नलियों (Lymphatics) से जो मांसपेशियों के हिलने पर पंप होती हैं',
        'सीधे हड्डियों के माध्यम से',
        'केवल पानी पीने पर',
      ],
      correctIndex: 0,
      explanation:
          'मांसपेशियां हिलने से लसीका द्रव आगे बढ़ता है, इसलिए अंग को स्थिर रखने से जहर बहुत धीरे फैलता है।',
    ),
  ],
  'spinal_injury': [
    EmergencyQuizQuestion(
      question: 'दुर्घटना के बाद अप्रशिक्षित व्यक्ति को बाइक हेलमेट क्यों नहीं उतारना चाहिए?',
      options: [
        'कसा हुआ हेलमेट खींचने से गर्दन मुड़ सकती है और रीढ़ की नस को गंभीर नुकसान हो सकता है',
        'हेलमेट कान गर्म रखता है',
        'बीमा के लिए हेलमेट ज़रूरी होता है',
      ],
      correctIndex: 0,
      explanation:
          'बिना प्रशिक्षण हेलमेट उतारने से गर्दन की चटकी हड्डी खिसककर स्पाइनल कॉर्ड को दबा सकती है।',
    ),
  ],
};
