import 'awareness_providers.dart';

class EmergencyScienceFact {
  final String action;
  final String reason;

  const EmergencyScienceFact({
    required this.action,
    required this.reason,
  });
}

class EmergencyScienceInfo {
  final String bodyMechanism;
  final List<EmergencyScienceFact> facts;
  final String mythBuster;

  const EmergencyScienceInfo({
    required this.bodyMechanism,
    required this.facts,
    required this.mythBuster,
  });
}

EmergencyScienceInfo? getEmergencyScience(
  String guideId,
  AwarenessLanguage language,
) {
  return language == AwarenessLanguage.hi
      ? _scienceDataHi[guideId]
      : _scienceDataEn[guideId];
}

const Map<String, EmergencyScienceInfo> _scienceDataEn = {
  'cpr_adult': EmergencyScienceInfo(
    bodyMechanism:
        'During cardiac arrest, the heart\'s electrical rhythm fails and blood stops flowing. Brain cells begin suffering irreversible damage within 4–6 minutes without oxygen.',
    facts: [
      EmergencyScienceFact(
        action: '5–6 cm chest compression depth',
        reason:
            'Compressing the sternum squeezes the heart against the spine, manually pumping oxygenated blood to the brain and heart muscle.',
      ),
      EmergencyScienceFact(
        action: 'Full chest recoil between pushes',
        reason:
            'Letting the chest rise completely creates negative pressure inside the thorax, drawing venous blood back into the heart for the next beat.',
      ),
      EmergencyScienceFact(
        action: '100–120 compressions per minute',
        reason:
            'This tempo maintains enough coronary and cerebral perfusion pressure without tiring the rescuer too quickly or under-filling the heart.',
      ),
      EmergencyScienceFact(
        action: 'Early AED shock',
        reason:
            'CPR buys time, but an AED resets chaotic electrical activity (ventricular fibrillation) so the heart can beat on its own again.',
      ),
    ],
    mythBuster:
        'You don\'t need to feel a pulse first — checking pulses under stress is unreliable and wastes critical seconds of brain oxygen.',
  ),
  'choking_adult': EmergencyScienceInfo(
    bodyMechanism:
        'A foreign object lodges in the larynx or trachea, blocking air from reaching the lungs. Oxygen reserves drop rapidly, leading to unconsciousness within minutes.',
    facts: [
      EmergencyScienceFact(
        action: '5 firm back blows',
        reason:
            'Sharp vibration between the shoulder blades creates sudden pressure spikes in the airway to dislodge objects.',
      ),
      EmergencyScienceFact(
        action: 'Abdominal thrusts above the navel',
        reason:
            'Pushing inward and upward forces the diaphragm up, compressing residual air in the lungs like a piston to pop the blockage out.',
      ),
    ],
    mythBuster:
        'Never do a blind finger sweep — the tongue and throat anatomy funnel objects deeper when pushed from above.',
  ),
  'stroke_fast': EmergencyScienceInfo(
    bodyMechanism:
        'An ischemic stroke blocks a brain artery with a clot, starving neurons of oxygen and glucose. Roughly 1.9 million neurons die every minute treatment is delayed.',
    facts: [
      EmergencyScienceFact(
        action: 'Checking Face, Arm, and Speech (FAST)',
        reason:
            'Motor and language areas are supplied by major cerebral arteries; sudden one-sided weakness or slurred speech pinpoints focal brain ischemia.',
      ),
      EmergencyScienceFact(
        action: 'Noting exact symptom onset time',
        reason:
            'Clot-busting drugs (thrombolytics) are only safe within a strict time window before damaged vessels risk bleeding.',
      ),
    ],
    mythBuster:
        'Do not give aspirin during a suspected stroke — roughly 15% of strokes are caused by bleeding (hemorrhagic), which aspirin worsens.',
  ),
  'severe_bleeding': EmergencyScienceInfo(
    bodyMechanism:
        'Losing large volumes of blood drops blood pressure, starving organs of oxygen (hemorrhagic shock). Platelets and fibrin need stillness and pressure to form a stable plug.',
    facts: [
      EmergencyScienceFact(
        action: 'Continuous direct pressure',
        reason:
            'Physical pressure flattens damaged vessels and slows blood flow enough for platelets and clotting factors to seal the tear.',
      ),
      EmergencyScienceFact(
        action: 'Layering fresh cloth over soaked gauze',
        reason:
            'Peeling off blood-soaked cloth rips away fragile fibrin clots that have already started sealing the wound.',
      ),
    ],
    mythBuster:
        'Keeping a bleeding person warm isn\'t just for comfort — hypothermia disables blood clotting enzymes and worsens shock.',
  ),
  'anaphylaxis': EmergencyScienceInfo(
    bodyMechanism:
        'An allergen triggers massive mast-cell release of histamine, causing blood vessels to leak fluid (dropping blood pressure) and airway tissues to swell shut.',
    facts: [
      EmergencyScienceFact(
        action: 'Epinephrine into the outer mid-thigh',
        reason:
            'Epinephrine constricts blood vessels (raising blood pressure) and relaxes airway smooth muscle within minutes; thigh muscle absorbs it fastest.',
      ),
      EmergencyScienceFact(
        action: 'Lying flat with legs raised (if not breathless)',
        reason:
            'Gravity helps return pooled blood from the legs to the heart and brain during severe blood pressure drops.',
      ),
    ],
    mythBuster:
        'Antihistamines take 30–60 minutes and do not reverse airway swelling or shock — only epinephrine treats anaphylaxis.',
  ),
  'burns_scalds': EmergencyScienceInfo(
    bodyMechanism:
        'Skin retains thermal energy after contact ends, continuing to cook deeper dermal cells and destroy micro-circulation.',
    facts: [
      EmergencyScienceFact(
        action: '20 minutes of cool running water',
        reason:
            'Running water conducts residual heat out of deep tissue layers, stopping progressive cell death and reducing scarring.',
      ),
      EmergencyScienceFact(
        action: 'Covering loosely with clean cling film',
        reason:
            'Exposing raw nerve endings to air causes intense pain; sterile cling film seals out bacteria without sticking to the wound.',
      ),
    ],
    mythBuster:
        'Ice causes sudden vasoconstriction (cutting off blood flow to healing tissue), and butter/toothpaste trap heat inside the burn.',
  ),
  'seizures_fainting': EmergencyScienceInfo(
    bodyMechanism:
        'A seizure is a temporary surge of synchronized electrical misfiring in the brain. Once it ends, muscles relax and airway reflexes can be sluggish.',
    facts: [
      EmergencyScienceFact(
        action: 'Rolling into the recovery position',
        reason:
            'Turning onto one side uses gravity to keep the tongue from falling back and lets saliva drain so the airway stays clear.',
      ),
      EmergencyScienceFact(
        action: 'Timing the seizure',
        reason:
            'Seizures lasting over 5 minutes (status epilepticus) deplete brain energy and require urgent IV medication to stop.',
      ),
    ],
    mythBuster:
        'It is anatomically impossible to swallow your tongue — forcing spoons or fingers into the mouth only breaks teeth or injures the jaw.',
  ),
  'heart_attack_signs': EmergencyScienceInfo(
    bodyMechanism:
        'A cholesterol plaque ruptures inside a coronary artery, forming a clot that blocks oxygen to heart muscle cells. Unlike cardiac arrest, the heart is still beating.',
    facts: [
      EmergencyScienceFact(
        action: 'Sitting calmly at rest',
        reason:
            'Physical exertion spikes heart rate and oxygen demand, accelerating heart muscle cell death while the artery is blocked.',
      ),
      EmergencyScienceFact(
        action: 'Chewing regular aspirin (if advised & safe)',
        reason:
            'Chewing absorbs aspirin rapidly through mouth tissues, irreversibly blocking platelets from growing the coronary clot further.',
      ),
    ],
    mythBuster:
        'Women, older adults, and diabetics often feel nausea, jaw/back pain, or sudden fatigue instead of classic crushing chest pain.',
  ),
  'infant_choking_cpr': EmergencyScienceInfo(
    bodyMechanism:
        'An infant\'s airway is narrow (about the width of their pinky finger) and easily blocked, while their liver and spleen sit lower and are less protected by ribs.',
    facts: [
      EmergencyScienceFact(
        action: 'Head lower than chest during back blows',
        reason:
            'Gravity assists each back blow in moving the object outward instead of deeper into the trachea.',
      ),
      EmergencyScienceFact(
        action: '2-finger chest thrusts instead of abdominal thrusts',
        reason:
            'Infant abdominal organs are fragile; compressing the sternum safely raises intrathoracic pressure without injuring the liver.',
      ),
    ],
    mythBuster:
        'In infants, cardiac arrest is most often caused by lack of oxygen (choking/breathing) — that\'s why gentle rescue breaths matter.',
  ),
  'asthma_attack': EmergencyScienceInfo(
    bodyMechanism:
        'Bronchial airways become inflamed, swollen, and wrapped in tightened smooth muscle, trapping stale air inside the lungs and making exhaling exhausting.',
    facts: [
      EmergencyScienceFact(
        action: 'Sitting upright leaning slightly forward',
        reason:
            'This tripod posture lets accessory chest and neck muscles assist breathing and gives the diaphragm maximum room.',
      ),
      EmergencyScienceFact(
        action: 'Spaced rescue inhaler puffs',
        reason:
            'Bronchodilator medicine relaxes airway smooth muscle within minutes; spacing puffs lets the first puff open passages for the next.',
      ),
    ],
    mythBuster:
        'Preventer (steroid) inhalers reduce inflammation over days and will not open constricted airways during an acute attack.',
  ),
  'diabetic_hypoglycemia': EmergencyScienceInfo(
    bodyMechanism:
        'Neurons rely almost exclusively on blood glucose for fuel. When glucose drops below 70 mg/dL, adrenaline surges (shaking/sweating) and brain function dims.',
    facts: [
      EmergencyScienceFact(
        action: '15 grams of pure simple sugar',
        reason:
            'Simple sugars (glucose tablets, juice) pass directly through the gut wall into the bloodstream within 10–15 minutes.',
      ),
      EmergencyScienceFact(
        action: 'Waiting 15 minutes before re-dosing',
        reason:
            'Digestion and blood transport take ~15 minutes; over-treating too fast causes rebound hyperglycemia later.',
      ),
    ],
    mythBuster:
        'Chocolate and ice cream contain fat that delays stomach emptying — they raise blood sugar too slowly in an emergency.',
  ),
  'snake_bite': EmergencyScienceInfo(
    bodyMechanism:
        'Most snake venoms enter the lymphatic system first before reaching the bloodstream. Lymph only circulates when skeletal muscles contract.',
    facts: [
      EmergencyScienceFact(
        action: 'Keeping the victim still and immobilizing the limb',
        reason:
            'Stopping muscle movement drastically slows lymphatic pumping, delaying venom from reaching vital organs.',
      ),
      EmergencyScienceFact(
        action: 'Removing rings and watches early',
        reason:
            'Venom enzymes cause rapid local swelling; tight metal jewelry can cut off circulation and act like an unintended tourniquet.',
      ),
    ],
    mythBuster:
        'Cutting or sucking the wound cannot remove venom bound to tissue — it only introduces bacteria and destroys local blood vessels.',
  ),
  'spinal_injury': EmergencyScienceInfo(
    bodyMechanism:
        'Fractured vertebrae can shift and pinch or sever the spinal cord, which carries nerve signals between the brain and the body.',
    facts: [
      EmergencyScienceFact(
        action: 'Holding head and neck in line with the spine',
        reason:
            'Manual stabilization prevents bone fragments from moving into the spinal canal during accidental head turns.',
      ),
      EmergencyScienceFact(
        action: 'Not removing a helmet',
        reason:
            'Pulling a tight helmet forces the neck to flex and twist, risking secondary spinal cord injury.',
      ),
    ],
    mythBuster:
        'If the person is not breathing, CPR still comes first — oxygen deprivation kills faster than cautious movement.',
  ),
};

const Map<String, EmergencyScienceInfo> _scienceDataHi = {
  'cpr_adult': EmergencyScienceInfo(
    bodyMechanism:
        'कार्डियक अरेस्ट में हृदय की विद्युत गतिविधि रुक जाती है और रक्त प्रवाह बंद हो जाता है। बिना ऑक्सीजन के 4–6 मिनट में मस्तिष्क कोशिकाओं को स्थायी क्षति शुरू हो जाती है।',
    facts: [
      EmergencyScienceFact(
        action: 'छाती को 5–6 सेमी गहरा दबाना',
        reason:
            'स्तन की हड्डी दबाने से हृदय रीढ़ के बीच दबता है, जिससे ऑक्सीजन युक्त रक्त मस्तिष्क और हृदय तक पंप होता है।',
      ),
      EmergencyScienceFact(
        action: 'हर दबाव के बाद छाती को पूरा ऊपर आने देना',
        reason:
            'छाती पूरी तरह उठने से अंदर नकारात्मक दबाव बनता है, जिससे अगली धड़कन के लिए हृदय में फिर से रक्त भरता है।',
      ),
      EmergencyScienceFact(
        action: '100–120 दबाव प्रति मिनट',
        reason:
            'यह गति मस्तिष्क और हृदय में पर्याप्त रक्त दबाव बनाए रखती है।',
      ),
      EmergencyScienceFact(
        action: 'जल्द AED शॉक',
        reason:
            'CPR समय बचाता है, जबकि AED अनियंत्रित विद्युत गतिविधि को रीसेट कर हृदय की सामान्य धड़कन वापस लाता है।',
      ),
    ],
    mythBuster:
        'पहले नाड़ी जांचने में समय न गंवाएं — तनाव में नाड़ी जांचना अक्सर गलत होता है और मस्तिष्क की ऑक्सीजन घटती है।',
  ),
  'choking_adult': EmergencyScienceInfo(
    bodyMechanism:
        'कोई वस्तु श्वासनली में फंसकर फेफड़ों तक हवा रोक देती है। ऑक्सीजन तेजी से गिरती है और कुछ ही मिनटों में बेहोशी आ सकती है।',
    facts: [
      EmergencyScienceFact(
        action: 'पीठ पर 5 तेज थपकियां',
        reason:
            'कंधों के बीच तेज कंपन से श्वासनली में अचानक दबाव बनता है जो फंसी वस्तु को ढीला करता है।',
      ),
      EmergencyScienceFact(
        action: 'नाभि के ऊपर पेट पर दबाव',
        reason:
            'अंदर-ऊपर दबाव डायाफ्राम को ऊपर धकेलता है और फेफड़ों की बची हवा से वस्तु को बाहर उछाल देता है।',
      ),
    ],
    mythBuster:
        'बिना देखे मुंह में उंगली न डालें — इससे फंसी वस्तु और नीचे धकेली जा सकती है।',
  ),
  'stroke_fast': EmergencyScienceInfo(
    bodyMechanism:
        'इस्केमिक स्ट्रोक में थक्का मस्तिष्क की धमनी को बंद कर देता है। इलाज में देरी के हर मिनट में लगभग 19 लाख न्यूरॉन्स नष्ट होते हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'चेहरा, हाथ और बोली (FAST) जांचना',
        reason:
            'मस्तिष्क के गति और भाषा केंद्र प्रमुख धमनियों पर निर्भर हैं; एक तरफ कमजोरी तुरंत स्ट्रोक का संकेत देती है।',
      ),
      EmergencyScienceFact(
        action: 'लक्षण शुरू होने का सटीक समय नोट करना',
        reason:
            'थक्का घोलने वाली दवाएं केवल एक सीमित समय सीमा के भीतर ही सुरक्षित रूप से दी जा सकती हैं।',
      ),
    ],
    mythBuster:
        'स्ट्रोक के संदेह में एस्पिरिन न दें — लगभग 15% स्ट्रोक रक्तस्राव से होते हैं, जिन्हें एस्पिरिन और बिगाड़ सकती है।',
  ),
  'severe_bleeding': EmergencyScienceInfo(
    bodyMechanism:
        'अधिक खून बहने से ब्लड प्रेशर गिरता है और अंगों को ऑक्सीजन नहीं मिलती (शॉक)। प्लेटलेट्स और फाइब्रिन को थक्का बनाने के लिए स्थिर दबाव चाहिए।',
    facts: [
      EmergencyScienceFact(
        action: 'लगातार सीधा दबाव',
        reason:
            'दबाव कटी रक्त वाहिकाओं को दबाकर खून की गति धीमी करता है ताकि थक्का घाव को सील कर सके।',
      ),
      EmergencyScienceFact(
        action: 'भीगी पट्टी के ऊपर नया कपड़ा रखना',
        reason:
            'भीगी पट्टी हटाने से पहले से बन रहा नाजुक फाइब्रिन थक्का उखड़ जाता है।',
      ),
    ],
    mythBuster:
        'घायल को गर्म रखना केवल आराम के लिए नहीं है — ठंड लगने (हाइपोथर्मिया) से खून जमाने वाले एंजाइम काम करना बंद कर देते हैं।',
  ),
  'anaphylaxis': EmergencyScienceInfo(
    bodyMechanism:
        'एलर्जी से मास्ट कोशिकाएं भारी मात्रा में हिस्टामाइन छोड़ती हैं, जिससे रक्त वाहिकाएं फैलती हैं (बीपी गिरता है) और श्वासनली में सूजन आ जाती है।',
    facts: [
      EmergencyScienceFact(
        action: 'बाहरी मध्य-जांघ में एपिनेफ्रिन',
        reason:
            'एपिनेफ्रिन रक्त वाहिकाओं को सिकोड़कर बीपी बढ़ाता है और मिनटों में श्वासनली की सूजन खोलता है।',
      ),
      EmergencyScienceFact(
        action: 'पैर ऊंचे करके लिटाना',
        reason:
            'गुरुत्वाकर्षण पैरों से रक्त को हृदय और मस्तिष्क की ओर लौटने में मदद करता है।',
      ),
    ],
    mythBuster:
        'एंटीहिस्टामाइन गोलियां असर करने में 30–60 मिनट लेती हैं और शॉक नहीं रोक सकतीं — केवल एपिनेफ्रिन ही जीवन बचाता है।',
  ),
  'burns_scalds': EmergencyScienceInfo(
    bodyMechanism:
        'आग या गर्म वस्तु से हटने के बाद भी त्वचा में गर्मी बनी रहती है, जो अंदरूनी कोशिकाओं को लगातार नुकसान पहुंचाती है।',
    facts: [
      EmergencyScienceFact(
        action: '20 मिनट तक ठंडा बहता पानी',
        reason:
            'बहता पानी त्वचा की गहरी परतों से गर्मी बाहर निकालकर कोशिका क्षति और निशान कम करता है।',
      ),
      EmergencyScienceFact(
        action: 'साफ क्लिंग फिल्म से हल्के से ढकना',
        reason:
            'खुली नसें हवा लगने पर तेज दर्द करती हैं; क्लिंग फिल्म बिना चिपके बैक्टीरिया से बचाती है।',
      ),
    ],
    mythBuster:
        'बर्फ रक्त प्रवाह रोककर नुकसान बढ़ाती है, और मक्खन/टूथपेस्ट गर्मी को अंदर कैद कर संक्रमण फैलाते हैं।',
  ),
  'seizures_fainting': EmergencyScienceInfo(
    bodyMechanism:
        'दौरा मस्तिष्क में अस्थायी असामान्य विद्युत गतिविधि के कारण होता है। दौरा रुकने के बाद मांसपेशियां ढीली पड़ जाती हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'रिकवरी पोजिशन (करवट) में लिटाना',
        reason:
            'करवट लेने से जीभ पीछे नहीं गिरती और लार बाहर निकल जाती है, जिससे सांस का रास्ता खुला रहता है।',
      ),
      EmergencyScienceFact(
        action: 'दौरे का समय नोट करना',
        reason:
            '5 मिनट से अधिक चलने वाले दौरे मस्तिष्क की ऊर्जा खत्म करते हैं और तुरंत मेडिकल दवा की जरूरत होती है।',
      ),
    ],
    mythBuster:
        'इंसान अपनी जीभ नहीं निगल सकता — मुंह में चम्मच या उंगली डालने से केवल दांत और जबड़ा टूटते हैं।',
  ),
  'heart_attack_signs': EmergencyScienceInfo(
    bodyMechanism:
        'कोरोनरी धमनी में थक्का जमने से हृदय की मांसपेशियों को ऑक्सीजन मिलना बंद हो जाता है। कार्डियक अरेस्ट के विपरीत, इसमें दिल अभी धड़क रहा होता है।',
    facts: [
      EmergencyScienceFact(
        action: 'आराम से शांत बैठना',
        reason:
            'चलने-फिरने से हृदय की ऑक्सीजन मांग बढ़ती है, जिससे बंद धमनी में मांसपेशी क्षति तेज होती है।',
      ),
      EmergencyScienceFact(
        action: 'एस्पिरिन चबाना (यदि सलाह दी जाए)',
        reason:
            'चबाने से एस्पिरिन मुंह से तेजी से घुलकर प्लेटलेट्स को थक्का बड़ा करने से रोकती है।',
      ),
    ],
    mythBuster:
        'महिलाओं, बुजुर्गों और मधुमेह रोगियों में सीने के तेज दर्द की जगह मतली, जबड़े/पीठ दर्द या थकान जैसे लक्षण दिख सकते हैं।',
  ),
  'infant_choking_cpr': EmergencyScienceInfo(
    bodyMechanism:
        'शिशु की श्वासनली बहुत पतली होती है और उनका लिवर व प्लीहा पसलियों से कम सुरक्षित होते हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'थपकियों के समय सिर छाती से नीचे रखना',
        reason:
            'गुरुत्वाकर्षण फंसी वस्तु को बाहर निकालने में मदद करता है।',
      ),
      EmergencyScienceFact(
        action: 'पेट की जगह 2-उंगली छाती दबाव',
        reason:
            'पेट दबाने से शिशु के लिवर को चोट लग सकती है; छाती का दबाव सुरक्षित रूप से हवा बाहर धकेलता है।',
      ),
    ],
    mythBuster:
        'शिशुओं में हृदय रुकने का मुख्य कारण ऑक्सीजन की कमी होता है, इसलिए हल्की बचाव फूंकें महत्वपूर्ण हैं।',
  ),
  'asthma_attack': EmergencyScienceInfo(
    bodyMechanism:
        'श्वसन नलिकाओं में सूजन और मांसपेशियों की जकड़न से हवा फेफड़ों में फंस जाती है और सांस छोड़ना कठिन हो जाता है।',
    facts: [
      EmergencyScienceFact(
        action: 'सीधे बैठकर हल्का आगे झुकना',
        reason:
            'यह स्थिति छाती और कंधे की सहायक मांसपेशियों को सांस लेने में मदद करती है।',
      ),
      EmergencyScienceFact(
        action: 'अंतराल पर रेस्क्यू इनहेलर पफ',
        reason:
            'दवा मिनटों में श्वासनली की जकड़न खोलती है; रुक-रुककर पफ देने से दवा फेफड़ों में गहराई तक पहुंचती है।',
      ),
    ],
    mythBuster:
        'प्रिवेंटर (स्टेरॉयड) इनहेलर दिनों में असर करते हैं — अचानक अटैक में केवल रेस्क्यू इनहेलर ही काम आता है।',
  ),
  'diabetic_hypoglycemia': EmergencyScienceInfo(
    bodyMechanism:
        'मस्तिष्क की कोशिकाएं ऊर्जा के लिए लगभग पूरी तरह ब्लड ग्लूकोज पर निर्भर होती हैं। 70 mg/dL से नीचे जाने पर एड्रेनालाईन बढ़ता है और मस्तिष्क सुस्त पड़ने लगता है।',
    facts: [
      EmergencyScienceFact(
        action: '15 ग्राम शुद्ध सरल शुगर',
        reason:
            'ग्लूकोज या जूस 10–15 मिनट में आंतों से सीधे खून में अवशोषित हो जाते हैं।',
      ),
      EmergencyScienceFact(
        action: 'दोबारा जांच से पहले 15 मिनट प्रतीक्षा',
        reason:
            'पाचन और रक्त में शुगर पहुंचने में लगभग 15 मिनट लगते हैं।',
      ),
    ],
    mythBuster:
        'चॉकलेट और आइसक्रीम में वसा होती है जो पेट खाली होने की गति धीमी करती है — ये आपातकाल में बहुत धीरे असर करते हैं।',
  ),
  'snake_bite': EmergencyScienceInfo(
    bodyMechanism:
        'अधिकांश सांपों का जहर पहले लसीका तंत्र (Lymphatic system) में जाता है, जो केवल मांसपेशियों के हिलने से चलता है।',
    facts: [
      EmergencyScienceFact(
        action: 'पीड़ित को स्थिर रखना और अंग न हिलाना',
        reason:
            'मांसपेशियों की गति रोकने से लसीका प्रवाह धीमा होता है और जहर महत्वपूर्ण अंगों तक देर से पहुंचता है।',
      ),
      EmergencyScienceFact(
        action: 'अंगूठी और घड़ी जल्दी उतारना',
        reason:
            'जहर से तेजी से सूजन आती है; तंग गहने रक्त प्रवाह रोक सकते हैं।',
      ),
    ],
    mythBuster:
        'घाव काटने या चूसने से ऊतकों में बंधा जहर बाहर नहीं निकलता — इससे केवल संक्रमण और नसों को नुकसान होता है।',
  ),
  'spinal_injury': EmergencyScienceInfo(
    bodyMechanism:
        'टूटी हुई रीढ़ की हड्डी खिसककर स्पाइनल कॉर्ड को दबा या काट सकती है, जो मस्तिष्क और शरीर के बीच तंत्रिका संकेत भेजती है।',
    facts: [
      EmergencyScienceFact(
        action: 'सिर और गर्दन को रीढ़ की सीध में स्थिर रखना',
        reason:
            'हाथों से स्थिर रखने से हड्डी के टुकड़े स्पाइनल कैनाल में जाने से बचते हैं।',
      ),
      EmergencyScienceFact(
        action: 'हेलमेट न उतारना',
        reason:
            'कसा हुआ हेलमेट खींचने से गर्दन मुड़ती है और रीढ़ की चोट बढ़ सकती है।',
      ),
    ],
    mythBuster:
        'यदि सांस बंद हो जाए, तो CPR फिर भी पहली प्राथमिकता है — ऑक्सीजन की कमी से मृत्यु अधिक तेजी से होती है।',
  ),
};
