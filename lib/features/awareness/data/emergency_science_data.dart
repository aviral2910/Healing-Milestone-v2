import 'awareness_providers.dart';
import 'emergency_science_clinical_data.dart';

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
  final String reference;

  const EmergencyScienceInfo({
    required this.bodyMechanism,
    required this.facts,
    required this.mythBuster,
    this.reference = 'AHA / Red Cross / WHO First-Aid Guidelines',
  });
}

EmergencyScienceInfo? getEmergencyScience(
  String guideId,
  AwarenessLanguage language, {
  ScienceDepth depth = ScienceDepth.simple,
}) {
  if (depth == ScienceDepth.clinical) {
    return language == AwarenessLanguage.hi
        ? clinicalScienceDataHi[guideId]
        : clinicalScienceDataEn[guideId];
  }
  return language == AwarenessLanguage.hi
      ? _scienceDataHi[guideId]
      : _scienceDataEn[guideId];
}

const Map<String, EmergencyScienceInfo> _scienceDataEn = {
  'cpr_adult': EmergencyScienceInfo(
    bodyMechanism:
        'Think of your heart as a pump that pushes fresh oxygen-rich blood to your brain every second. During cardiac arrest, that pump suddenly stops. Without fresh blood, brain cells start getting permanently hurt in just 4 to 6 minutes — often before an ambulance can arrive.',
    facts: [
      EmergencyScienceFact(
        action: 'Why push 5–6 cm deep on the chest?',
        reason:
            'Your heart sits right behind the middle breastbone and in front of your backbone. When you push down firmly, you literally squeeze the heart between those two bones — acting as a manual pump that sends blood up to the brain.',
      ),
      EmergencyScienceFact(
        action: 'Why let the chest rise all the way back up?',
        reason:
            'When you release your hands, the chest springs back like a sponge. That creates gentle suction inside the chest that pulls fresh blood back into the heart so your next push actually has blood to pump.',
      ),
      EmergencyScienceFact(
        action: 'Why 100–120 pushes every minute?',
        reason:
            'Pushing too slow lets blood pressure drop to zero between beats. Pushing too fast doesn\'t give the heart time to refill. Around 2 pushes per second hits the sweet spot that keeps the brain alive.',
      ),
      EmergencyScienceFact(
        action: 'Why use an AED machine as soon as it arrives?',
        reason:
            'CPR keeps blood moving, like keeping a car rolling, while the AED is the key that restarts the engine. It gives a controlled electric reset so the heart can beat on its own again.',
      ),
    ],
    mythBuster:
        'You don\'t need to check for a pulse first — even trained doctors struggle to feel a weak pulse in a panic, and every wasted second costs the brain oxygen.',
  ),
  'choking_adult': EmergencyScienceInfo(
    bodyMechanism:
        'Food or a small object gets stuck in the windpipe — the narrow tube that carries air to your lungs. Because air can\'t get in or out, oxygen in the blood drops fast, and a person can pass out within a couple of minutes.',
    facts: [
      EmergencyScienceFact(
        action: 'Why lean them forward and hit between the shoulder blades?',
        reason:
            'Leaning forward uses gravity so the object falls toward the mouth instead of deeper down. Sharp blows send a shockwave through the chest that shakes the stuck piece loose.',
      ),
      EmergencyScienceFact(
        action: 'Why pull inward and upward just above the belly button?',
        reason:
            'Even when you\'re choking, there is still trapped air inside your lungs. Pulling up under the ribs pushes the breathing muscle upward, squeezing that trapped air like a pop-gun to blast the object out.',
      ),
    ],
    mythBuster:
        'Never poke your fingers blindly into someone\'s throat — the shape of the tongue and throat easily pushes a stuck piece of food even deeper down, like pushing a cork into a bottle.',
  ),
  'stroke_fast': EmergencyScienceInfo(
    bodyMechanism:
        'Your brain needs a constant flow of blood like a city needs electricity. In most strokes, a tiny blood clot blocks one of the brain\'s blood pipes. Every minute that pipe stays blocked, nearly 2 million brain cells starve and die.',
    facts: [
      EmergencyScienceFact(
        action: 'Why check Face, Arm, and Speech (FAST)?',
        reason:
            'Different sides of the brain control your smile, your arms, and your speech. When blood stops reaching one spot, those exact abilities suddenly stop working — usually on one side of the body.',
      ),
      EmergencyScienceFact(
        action: 'Why write down the exact time symptoms started?',
        reason:
            'Hospital doctors have special medicines that can dissolve the clot and restore blood flow — but those medicines are only safe if given within a few hours of when symptoms first began.',
      ),
    ],
    mythBuster:
        'Never give aspirin during a suspected stroke — about 1 in 7 strokes happen because a blood vessel burst and is bleeding inside the brain, and aspirin makes bleeding much worse.',
  ),
  'severe_bleeding': EmergencyScienceInfo(
    bodyMechanism:
        'Your body only has about 5 liters of blood to carry oxygen everywhere. If too much leaks out quickly, blood pressure crashes and organs start shutting down. Your blood has natural "repair glue" (clotting cells), but it needs stillness and pressure to seal a tear.',
    facts: [
      EmergencyScienceFact(
        action: 'Why press hard and steadily right on the wound?',
        reason:
            'Pressing firmly pinches the torn blood pipes shut — just like stepping on a leaking garden hose — slowing the flow enough for your body\'s natural repair glue to form a plug.',
      ),
      EmergencyScienceFact(
        action: 'Why stack new cloth on top instead of removing soaked cloth?',
        reason:
            'That soaked cloth is already stuck to the fresh, jelly-like plug your body is building. Ripping it off tears the plug right open and makes bleeding start all over again.',
      ),
    ],
    mythBuster:
        'Covering a bleeding person with a blanket isn\'t just for comfort — when the body gets cold, its natural blood-clotting glue stops working properly.',
  ),
  'anaphylaxis': EmergencyScienceInfo(
    bodyMechanism:
        'In a severe allergy, the body\'s defense system overreacts to a harmless food, medicine, or sting. It floods the body with emergency chemicals that make blood pipes leaky (causing blood pressure to crash) and make the throat swell up like a puffed-up balloon.',
    facts: [
      EmergencyScienceFact(
        action: 'Why inject epinephrine into the outer mid-thigh?',
        reason:
            'The outer thigh has a big muscle with lots of blood flow, so the medicine enters your body in seconds. Epinephrine quickly shrinks the swollen throat and tightens leaky blood pipes to bring blood pressure back up.',
      ),
      EmergencyScienceFact(
        action: 'Why lie flat with legs slightly raised?',
        reason:
            'When blood pressure drops, blood pools in the legs. Raising the legs lets gravity help send that blood back up to the heart and brain so the person doesn\'t faint.',
      ),
    ],
    mythBuster:
        'Regular allergy pills (like Cetirizine) take 30 to 60 minutes to work and cannot open a swollen airway — only an epinephrine shot acts fast enough to save a life.',
  ),
  'burns_scalds': EmergencyScienceInfo(
    bodyMechanism:
        'Think of a burn like a hot metal pan taken off the stove — even after you turn off the flame, the pan stays hot and keeps cooking anything touching it. Skin holds onto heat the same way, continuing to damage deeper healthy layers for minutes.',
    facts: [
      EmergencyScienceFact(
        action: 'Why hold under cool running water for 20 full minutes?',
        reason:
            'A quick splash only cools the top surface. Twenty minutes of cool (not icy) running water pulls trapped heat all the way out of the deeper skin layers, stopping further damage and reducing scars.',
      ),
      EmergencyScienceFact(
        action: 'Why cover loosely with clean plastic wrap (cling film)?',
        reason:
            'Burned skin has exposed, raw nerve endings — even air blowing over it hurts terribly. Clean plastic wrap shields those nerves from air and germs without sticking to the wet burn.',
      ),
    ],
    mythBuster:
        'Never put ice, butter, oil, or toothpaste on a burn: ice freezes and kills fragile skin, while butter and toothpaste trap the heat inside and cause infection.',
  ),
  'seizures_fainting': EmergencyScienceInfo(
    bodyMechanism:
        'Your brain runs on tiny electrical signals. A seizure is like a sudden, temporary electrical storm where too many brain signals fire at once, making the body stiffen or shake. Once the storm passes, the brain feels exhausted and muscles go limp.',
    facts: [
      EmergencyScienceFact(
        action: 'Why roll them onto their side once shaking stops?',
        reason:
            'When someone is limp and unconscious on their back, their tongue can relax backward and block breathing, or saliva can pool in the throat. Turning them on their side lets gravity keep the airway open and fluids drain out.',
      ),
      EmergencyScienceFact(
        action: 'Why check the clock and time the seizure?',
        reason:
            'Most seizures stop on their own in 1 to 2 minutes. If the electrical storm lasts longer than 5 minutes, the brain runs out of energy and needs urgent hospital medicine to stop it.',
      ),
    ],
    mythBuster:
        'It is physically impossible for someone to swallow their own tongue. Forcing a spoon, cloth, or your fingers into their mouth only breaks their teeth or hurts their jaw.',
  ),
  'heart_attack_signs': EmergencyScienceInfo(
    bodyMechanism:
        'A heart attack is a "plumbing problem" — a fatty buildup inside a heart blood pipe cracks, and a blood clot blocks fresh oxygen from reaching part of the heart muscle. Unlike cardiac arrest, the heart is usually still beating, so fast action saves heart muscle.',
    facts: [
      EmergencyScienceFact(
        action: 'Why must the person sit still and not walk around?',
        reason:
            'Walking or climbing stairs makes the heart beat faster and demand more oxygen — which is dangerous when the pipe feeding the heart is blocked. Sitting still protects the heart muscle.',
      ),
      EmergencyScienceFact(
        action: 'Why chew (not swallow) a regular aspirin if advised?',
        reason:
            'Chewing lets the aspirin melt quickly through the lining of the mouth into the blood, stopping blood cells from clumping together and making the clot bigger.',
      ),
    ],
    mythBuster:
        'Heart attacks don\'t always feel like a movie-style clutching chest pain — women, older adults, and people with diabetes often feel indigestion, jaw/back ache, cold sweat, or sudden exhaustion.',
  ),
  'infant_choking_cpr': EmergencyScienceInfo(
    bodyMechanism:
        'A baby\'s windpipe is as narrow as a drinking straw, so even a tiny piece of food can block it. Also, a baby\'s ribs are soft and don\'t protect their belly organs (like the liver) the way adult ribs do.',
    facts: [
      EmergencyScienceFact(
        action: 'Why hold the baby\'s head lower than their chest?',
        reason:
            'Tilting the baby downward lets gravity work on your side so each back blow helps the stuck object slide out toward the mouth.',
      ),
      EmergencyScienceFact(
        action: 'Why use 2 fingers on the chest instead of belly pushes?',
        reason:
            'Squeezing a baby\'s soft belly can bruise or tear their liver. Gentle 2-finger pushes on the center of the chest safely push air out of the lungs without harming belly organs.',
      ),
    ],
    mythBuster:
        'In babies, the heart almost never stops on its own — it usually stops because they couldn\'t breathe first. That is why gentle rescue puffs of air matter so much in infant CPR.',
  ),
  'asthma_attack': EmergencyScienceInfo(
    bodyMechanism:
        'During an asthma attack, the tiny air tubes inside the lungs swell up, fill with thick mucus, and get squeezed tight by surrounding muscles — making breathing feel like trying to breathe through a pinched straw.',
    facts: [
      EmergencyScienceFact(
        action: 'Why sit upright and lean slightly forward?',
        reason:
            'Lying flat presses your belly against your lungs. Sitting upright and leaning slightly forward opens up the chest and lets your shoulder and neck muscles help pull air in.',
      ),
      EmergencyScienceFact(
        action: 'Why take 1 puff at a time with slow breaths in between?',
        reason:
            'Rescue inhaler medicine relaxes the squeezed muscles around the air tubes within minutes. Spacing the puffs lets the first puff open the tubes slightly so the next puff reaches even deeper.',
      ),
    ],
    mythBuster:
        'Daily "preventer" inhalers only calm swelling slowly over days and will not open tight airways during a sudden attack — always use the quick-relief rescue inhaler.',
  ),
  'diabetic_hypoglycemia': EmergencyScienceInfo(
    bodyMechanism:
        'Sugar (glucose) is the main fuel your brain runs on every second. When blood sugar drops too low, the brain sends out alarm signals (causing shaking and cold sweat) and then starts slowing down (causing confusion or fainting).',
    facts: [
      EmergencyScienceFact(
        action: 'Why give 15 grams of plain, fast sugar (juice or glucose)?',
        reason:
            'Simple liquid sugar doesn\'t need heavy digestion — it passes straight through the stomach wall into the blood in about 10 to 15 minutes to refuel the brain.',
      ),
      EmergencyScienceFact(
        action: 'Why wait 15 minutes before giving more sugar?',
        reason:
            'It takes about 15 minutes for the sugar you just gave to show up in the blood. Giving too much too fast can cause blood sugar to spike way too high later.',
      ),
    ],
    mythBuster:
        'Chocolate, biscuits, and ice cream are poor choices in a low-sugar emergency — their fat slows down the stomach and delays the sugar from reaching the brain.',
  ),
  'snake_bite': EmergencyScienceInfo(
    bodyMechanism:
        'Most snake venom doesn\'t shoot straight into fast blood veins — it enters slow fluid channels right under the skin. Those slow channels only pump fluid forward when your muscles move and squeeze them.',
    facts: [
      EmergencyScienceFact(
        action: 'Why keep the person completely still and splint the limb?',
        reason:
            'If the person walks or panics, moving muscles pump venom straight toward the heart and lungs. Keeping the limb completely still slows that pump down and buys crucial hours to reach a hospital.',
      ),
      EmergencyScienceFact(
        action: 'Why remove rings, bangles, and watches right away?',
        reason:
            'Snake venom causes the bitten arm or leg to swell up fast. Metal rings or tight bands can trap blood and crush skin as the limb swells.',
      ),
    ],
    mythBuster:
        'Cutting the bite or trying to suck out venom with your mouth does not work — venom binds to tissue immediately, and cutting only causes severe infection and extra bleeding.',
  ),
  'spinal_injury': EmergencyScienceInfo(
    bodyMechanism:
        'Your backbone is a stack of protective rings guarding the spinal cord — the main electrical cable connecting your brain to your arms and legs. After a heavy fall or crash, one of those rings may be cracked and loose.',
    facts: [
      EmergencyScienceFact(
        action: 'Why hold the head and neck completely still in a straight line?',
        reason:
            'If a cracked neck bone shifts or twists even a little, its sharp edge can pinch or cut the delicate nerve cable inside, which can cause permanent paralysis.',
      ),
      EmergencyScienceFact(
        action: 'Why leave a motorcycle helmet on?',
        reason:
            'Pulling a tight helmet off forces the head and neck to bend and twist. Paramedics have special techniques to remove helmets safely without moving the neck.',
      ),
    ],
    mythBuster:
        'If an accident victim stops breathing, saving their life with CPR still comes first — lack of oxygen kills in minutes, so carefully start CPR rather than waiting.',
  ),
};

const Map<String, EmergencyScienceInfo> _scienceDataHi = {
  'cpr_adult': EmergencyScienceInfo(
    bodyMechanism:
        'अपने दिल को एक पंप की तरह समझें जो हर सेकंड दिमाग तक ताज़ा ऑक्सीजन वाला खून पहुंचाता है। कार्डियक अरेस्ट में यह पंप अचानक रुक जाता है। बिना ताज़े खून के सिर्फ 4 से 6 मिनट में दिमाग की कोशिकाओं को स्थायी नुकसान शुरू हो जाता है — अक्सर एम्बुलेंस पहुंचने से पहले ही।',
    facts: [
      EmergencyScienceFact(
        action: 'छाती को 5–6 सेमी गहरा क्यों दबाते हैं?',
        reason:
            'आपका दिल बीच वाली छाती की हड्डी और रीढ़ की हड्डी के बीच स्थित होता है। जब आप मजबूती से नीचे दबाते हैं, तो दिल इन दोनों हड्डियों के बीच दबता है और हाथ से पंप की तरह दिमाग तक खून भेजता है।',
      ),
      EmergencyScienceFact(
        action: 'हर दबाव के बाद छाती को पूरा ऊपर क्यों आने दें?',
        reason:
            'हाथ ढीला छोड़ने पर छाती स्पंज की तरह वापस ऊपर उठती है। इससे अंदर हल्का खिंचाव बनता है जो अगले दबाव के लिए दिल में फिर से खून भर देता है।',
      ),
      EmergencyScienceFact(
        action: 'हर मिनट 100–120 दबाव क्यों?',
        reason:
            'बहुत धीरे दबाने से खून का दबाव गिर जाता है और बहुत तेज दबाने से दिल को दोबारा भरने का समय नहीं मिलता। एक सेकंड में लगभग 2 दबाव सबसे सही गति है।',
      ),
      EmergencyScienceFact(
        action: 'AED मशीन आते ही उपयोग क्यों करें?',
        reason:
            'CPR खून को चलाए रखता है (जैसे कार को धक्का देकर चलाना), जबकि AED इंजन को दोबारा स्टार्ट करने की चाबी है — यह दिल की धड़कन को फिर से सामान्य लय में लाता है।',
      ),
    ],
    mythBuster:
        'पहले नाड़ी (पल्स) ढूंढने में समय बर्बाद न करें — घबराहट में कमजोर नाड़ी महसूस करना बहुत कठिन होता है और हर सेकंड दिमाग की ऑक्सीजन कम होती जाती है।',
  ),
  'choking_adult': EmergencyScienceInfo(
    bodyMechanism:
        'खाने का टुकड़ा या कोई छोटी चीज़ सांस की नली में फंस जाती है, जिससे फेफड़ों तक हवा जाना बंद हो जाता है। खून में ऑक्सीजन तेजी से गिरती है और कुछ ही मिनटों में व्यक्ति बेहोश हो सकता है।',
    facts: [
      EmergencyScienceFact(
        action: 'आगे झुकाकर कंधों के बीच क्यों थपथपाते हैं?',
        reason:
            'आगे झुकने से गुरुत्वाकर्षण मदद करता है ताकि फंसी चीज़ नीचे जाने की बजाय मुंह की ओर आए। तेज थपकी से छाती में कंपन होता है जो अटके टुकड़े को हिला देता है।',
      ),
      EmergencyScienceFact(
        action: 'नाभि के ऊपर अंदर-ऊपर की ओर क्यों दबाते हैं?',
        reason:
            'गला घुटने पर भी फेफड़ों में थोड़ी हवा बची रहती है। पसलियों के नीचे ऊपर की ओर दबाने से सांस की मांसपेशी ऊपर उठती है और फंसी हुई हवा पिचकारी की तरह उस टुकड़े को बाहर फेंक देती है।',
      ),
    ],
    mythBuster:
        'बिना देखे गले में उंगली कभी न डालें — जीभ और गले की बनावट ऐसी होती है कि ऊपर से धक्का देने पर फंसी चीज़ बोतल के कॉर्क की तरह और अंदर चली जाती है।',
  ),
  'stroke_fast': EmergencyScienceInfo(
    bodyMechanism:
        'दिमाग को लगातार खून चाहिए, जैसे किसी शहर को बिजली। ज़्यादातर स्ट्रोक में खून का एक छोटा थक्का दिमाग की किसी नस को बंद कर देता है। जितनी देर यह नस बंद रहती है, हर मिनट लगभग 20 लाख दिमाग की कोशिकाएं दम तोड़ने लगती हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'चेहरा, हाथ और बोली (FAST) क्यों जांचते हैं?',
        reason:
            'दिमाग के अलग-अलग हिस्से आपकी मुस्कान, हाथ उठाने और बोलने को नियंत्रित करते हैं। जब किसी हिस्से में खून रुकता है, तो शरीर के एक तरफ ये काम अचानक रुक जाते हैं।',
      ),
      EmergencyScienceFact(
        action: 'लक्षण शुरू होने का सटीक समय क्यों लिखते हैं?',
        reason:
            'अस्पताल में थक्का घोलने वाली विशेष दवाएं होती हैं — लेकिन वे दवाएं लक्षण शुरू होने के कुछ ही घंटों के भीतर सुरक्षित रूप से दी जा सकती हैं।',
      ),
    ],
    mythBuster:
        'स्ट्रोक के संदेह में एस्पिरिन न दें — लगभग 7 में से 1 स्ट्रोक दिमाग के अंदर नस फटने (खून बहने) से होता है, और एस्पिरिन उस रक्तस्राव को और बढ़ा देती है।',
  ),
  'severe_bleeding': EmergencyScienceInfo(
    bodyMechanism:
        'शरीर में लगभग 5 लीटर ही खून होता है जो हर अंग तक ऑक्सीजन ले जाता है। बहुत सारा खून जल्दी बह जाने से ब्लड प्रेशर गिर जाता है और अंग काम करना बंद करने लगते हैं। खून में प्राकृतिक "मरम्मत गोंद" (थक्का) होता है, लेकिन उसे काम करने के लिए शांति और दबाव चाहिए।',
    facts: [
      EmergencyScienceFact(
        action: 'घाव पर सीधा और मजबूत दबाव क्यों डालते हैं?',
        reason:
            'मजबूत दबाव फटी हुई नसों को पिचकाकर बंद कर देता है — ठीक वैसे ही जैसे बहते पाइप पर पैर रखकर पानी रोकते हैं — ताकि शरीर का प्राकृतिक थक्का घाव को सील कर सके।',
      ),
      EmergencyScienceFact(
        action: 'भीगे कपड़े को हटाए बिना ऊपर नया कपड़ा क्यों रखते हैं?',
        reason:
            'खून से भीगा कपड़ा उस ताज़े, जेली जैसे थक्के से चिपक चुका होता है जो घाव को बंद कर रहा है। उसे उखाड़ने से थक्का टूट जाता है और खून फिर बहने लगता है।',
      ),
    ],
    mythBuster:
        'घायल को कंबल से ढकना सिर्फ आराम के लिए नहीं है — शरीर ठंडा पड़ने पर खून जमाने वाला प्राकृतिक तंत्र ठीक से काम करना बंद कर देता है।',
  ),
  'anaphylaxis': EmergencyScienceInfo(
    bodyMechanism:
        'गंभीर एलर्जी में शरीर की सुरक्षा प्रणाली किसी सामान्य भोजन, दवा या डंक पर ज़रूरत से ज़्यादा प्रतिक्रिया करती है। इससे ऐसे रसायन निकलते हैं जो नसों को ढीला कर देते हैं (जिससे बीपी गिर जाता है) और गले को गुब्बारे की तरह फुला देते हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'जांघ के बाहरी हिस्से में एपिनेफ्रिन क्यों लगाते हैं?',
        reason:
            'जांघ के बाहरी हिस्से की बड़ी मांसपेशी में खून का बहाव बहुत तेज होता है, जिससे दवा सेकंडों में शरीर में पहुंचती है, गले की सूजन घटाती है और बीपी को वापस संभालती है।',
      ),
      EmergencyScienceFact(
        action: 'पैर थोड़ा ऊपर उठाकर सीधा क्यों लिटाते हैं?',
        reason:
            'बीपी गिरने पर खून पैरों में जमा होने लगता है। पैर ऊपर करने से गुरुत्वाकर्षण खून को दिल और दिमाग की ओर वापस भेजने में मदद करता है।',
      ),
    ],
    mythBuster:
        'सामान्य एलर्जी की गोलियां असर करने में 30 से 60 मिनट लेती हैं और सूजे हुए गले को नहीं खोल सकतीं — केवल एपिनेफ्रिन इंजेक्शन ही तुरंत जान बचाता है।',
  ),
  'burns_scalds': EmergencyScienceInfo(
    bodyMechanism:
        'जली हुई त्वचा को उस गर्म तवे की तरह समझें जिसे चूल्हे से उतार दिया गया हो — आग बंद होने के बाद भी तवा गर्म रहता है और अंदर पकाता रहता है। त्वचा भी गर्मी को अंदर रोक लेती है और मिनटों तक अंदरूनी परतों को नुकसान पहुंचाती रहती है।',
    facts: [
      EmergencyScienceFact(
        action: 'पूरे 20 मिनट तक ठंडे बहते पानी में क्यों रखते हैं?',
        reason:
            'थोड़ा सा पानी डालने से केवल ऊपरी सतह ठंडी होती है। 20 मिनट तक बहता सामान्य ठंडा पानी अंदर फंसी सारी गर्मी को बाहर खींच लेता है, जिससे घाव गहरा नहीं होता और निशान कम पड़ते हैं।',
      ),
      EmergencyScienceFact(
        action: 'साफ क्लिंग फिल्म से हल्के से क्यों ढकते हैं?',
        reason:
            'जली त्वचा की खुली नसों पर हवा लगने से भी बहुत दर्द होता है। साफ क्लिंग फिल्म बिना चिपके हवा और कीटाणुओं को दूर रखती है।',
      ),
    ],
    mythBuster:
        'बर्फ, मक्खन, तेल या टूथपेस्ट कभी न लगाएं: बर्फ नाजुक त्वचा को जमाकर नष्ट करती है, जबकि मक्खन और टूथपेस्ट गर्मी को अंदर कैद कर संक्रमण फैलाते हैं।',
  ),
  'seizures_fainting': EmergencyScienceInfo(
    bodyMechanism:
        'हमारा दिमाग हल्के बिजली के संकेतों से चलता है। दौरा दिमाग में आए एक छोटे बिजली के तूफ़ान जैसा होता है, जिसमें बहुत सारे संकेत एक साथ निकलते हैं और शरीर कांपने लगता है। तूफ़ान थमने पर दिमाग थक जाता है और शरीर ढीला पड़ जाता है।',
    facts: [
      EmergencyScienceFact(
        action: 'झटके रुकने पर करवट (Recovery Position) क्यों लिटाते हैं?',
        reason:
            'बेहोशी में पीठ के बल लेटने पर जीभ पीछे गिरकर सांस रोक सकती है या लार गले में अटक सकती है। करवट करने से गुरुत्वाकर्षण सांस का रास्ता खुला रखता है।',
      ),
      EmergencyScienceFact(
        action: 'घड़ी देखकर दौरे का समय क्यों गिनते हैं?',
        reason:
            'ज़्यादातर दौरे 1–2 मिनट में खुद रुक जाते हैं। यदि यह 5 मिनट से ज़्यादा चले, तो दिमाग की ऊर्जा खत्म होने लगती है और अस्पताल की दवा ज़रूरी हो जाती है।',
      ),
    ],
    mythBuster:
        'कोई इंसान अपनी जीभ कभी नहीं निगल सकता। मुंह में चम्मच, कपड़ा या उंगली डालने से केवल दांत टूटते हैं या जबड़े में चोट लगती है।',
  ),
  'heart_attack_signs': EmergencyScienceInfo(
    bodyMechanism:
        'हार्ट अटैक एक "पाइपलाइन जाम" की समस्या है — दिल को खून देने वाली नस में जमी चर्बी चटक जाती है और वहां थक्का बन जाता है। इसमें दिल अभी धड़क रहा होता है, इसलिए जल्दी मदद मिलने पर दिल की मांसपेशी को बचाया जा सकता है।',
    facts: [
      EmergencyScienceFact(
        action: 'व्यक्ति को शांत बैठाना और चलने न देना क्यों ज़रूरी है?',
        reason:
            'चलने या सीढ़ियां चढ़ने से दिल तेजी से धड़कता है और उसे ज़्यादा ऑक्सीजन चाहिए होती है — जो बंद नस में बेहद खतरनाक है। शांत बैठने से दिल सुरक्षित रहता है।',
      ),
      EmergencyScienceFact(
        action: 'सलाह मिलने पर एस्पिरिन निगलने की जगह चबाने को क्यों कहते हैं?',
        reason:
            'चबाने से एस्पिरिन मुंह की झिल्ली से ही तेजी से खून में मिल जाती है और खून के थक्के को और बड़ा होने से रोकती है।',
      ),
    ],
    mythBuster:
        'हार्ट अटैक में हमेशा फिल्मों जैसा सीने का तेज दर्द नहीं होता — महिलाओं, बुजुर्गों और डायबिटीज वाले लोगों में गैस जैसा भारीपन, जबड़े/पीठ में दर्द, ठंडा पसीना या अचानक थकान हो सकती है।',
  ),
  'infant_choking_cpr': EmergencyScienceInfo(
    bodyMechanism:
        'शिशु की सांस की नली पीने के स्ट्रॉ जितनी पतली होती है, इसलिए छोटा सा टुकड़ा भी उसे बंद कर सकता है। साथ ही, शिशु की पसलियां मुलायम होती हैं और पेट के अंगों (जैसे लिवर) को पूरी तरह ढक नहीं पातीं।',
    facts: [
      EmergencyScienceFact(
        action: 'थपकी देते समय शिशु का सिर छाती से नीचे क्यों रखते हैं?',
        reason:
            'नीचे झुकाने से गुरुत्वाकर्षण मदद करता है ताकि हर थपकी पर फंसी चीज़ आसानी से बाहर की ओर फिसल सके।',
      ),
      EmergencyScienceFact(
        action: 'पेट की जगह छाती पर 2 उंगलियों से दबाव क्यों देते हैं?',
        reason:
            'शिशु के नरम पेट को दबाने से लिवर को चोट लग सकती है। छाती के बीच 2 उंगलियों का हल्का दबाव सुरक्षित रूप से फेफड़ों की हवा से रुकावट बाहर निकालता है।',
      ),
    ],
    mythBuster:
        'शिशुओं में दिल अपने आप कम ही रुकता है — अक्सर यह सांस रुकने के कारण होता है। इसलिए शिशु CPR में हल्की बचाव फूंकें बहुत महत्वपूर्ण होती हैं।',
  ),
  'asthma_attack': EmergencyScienceInfo(
    bodyMechanism:
        'अस्थमा अटैक में फेफड़ों की छोटी हवा की नलियां सूज जाती हैं, उनमें बलगम भर जाता है और बाहर की मांसपेशियां उन्हें कसकर दबा देती हैं — जिससे सांस लेना वैसा लगता है जैसे किसी पिचके हुए स्ट्रॉ से हवा खींच रहे हों।',
    facts: [
      EmergencyScienceFact(
        action: 'सीधे बैठकर हल्का आगे क्यों झुकते हैं?',
        reason:
            'सीधे लेटने से पेट फेफड़ों पर दबाव डालता है। सीधे बैठकर हल्का आगे झुकने से फेफड़ों को फैलने की पूरी जगह मिलती है और कंधे की मांसपेशियां भी मदद करती हैं।',
      ),
      EmergencyScienceFact(
        action: 'हर पफ के बीच रुककर धीमी सांस क्यों लेते हैं?',
        reason:
            'रेस्क्यू इनहेलर नलियों की जकड़न को मिनटों में खोलता है। अंतराल रखकर पफ लेने से पहला पफ रास्ता थोड़ा खोलता है ताकि अगला पफ फेफड़ों में और अंदर तक जा सके।',
      ),
    ],
    mythBuster:
        'रोज़ाना लेने वाला प्रिवेंटर इनहेलर सूजन को धीरे-धीरे कई दिनों में कम करता है — अचानक अटैक में हमेशा तुरंत राहत वाला रेस्क्यू इनहेलर ही काम आता है।',
  ),
  'diabetic_hypoglycemia': EmergencyScienceInfo(
    bodyMechanism:
        'शुगर (ग्लूकोज) हमारे दिमाग का मुख्य ईंधन है। जब खून में शुगर बहुत कम हो जाती है, तो शरीर खतरे की घंटी बजाता है (कंपकंपी और ठंडा पसीना), और फिर दिमाग की शक्ति कम होने लगती है (भ्रम या बेहोशी)।',
    facts: [
      EmergencyScienceFact(
        action: '15 ग्राम सादा, तेज शुगर (जूस या ग्लूकोज) क्यों देते हैं?',
        reason:
            'तरल और सरल शुगर को पचने में समय नहीं लगता — यह 10 से 15 मिनट में सीधे पेट से खून में पहुंचकर दिमाग को दोबारा ईंधन दे देती है।',
      ),
      EmergencyScienceFact(
        action: 'दोबारा शुगर देने से पहले 15 मिनट इंतज़ार क्यों करते हैं?',
        reason:
            'दी गई शुगर को खून में दिखने में लगभग 15 मिनट लगते हैं। जल्दी-जल्दी ज़्यादा मीठा देने से बाद में शुगर बहुत अधिक बढ़ सकती है।',
      ),
    ],
    mythBuster:
        'चॉकलेट, बिस्कुट या आइसक्रीम में चिकनाई (फैट) होती है जो पेट में पचने की गति धीमी कर देती है — ये कम शुगर की आपात स्थिति में बहुत देर से असर करते हैं।',
  ),
  'snake_bite': EmergencyScienceInfo(
    bodyMechanism:
        'ज़्यादातर सांपों का जहर सीधे तेज़ खून की नसों में नहीं, बल्कि त्वचा के नीचे धीमी बहने वाली पानी जैसी नलियों में जाता है। वे नलियां तभी आगे बढ़ती हैं जब आपकी मांसपेशियां हिलती हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'पीड़ित को बिल्कुल स्थिर रखना और अंग न हिलाना क्यों ज़रूरी है?',
        reason:
            'चलने या घबराने से मांसपेशियां पंप की तरह जहर को दिल और फेफड़ों की ओर धकेलती हैं। अंग को स्थिर रखने से जहर का फैलना बहुत धीमा हो जाता है और अस्पताल पहुंचने का कीमती समय मिल जाता है।',
      ),
      EmergencyScienceFact(
        action: 'अंगूठी, चूड़ियां और घड़ी तुरंत क्यों उतारनी चाहिए?',
        reason:
            'सांप के जहर से काटे गए हिस्से में तेजी से सूजन आती है। तंग गहने सूजन के साथ खून का बहाव रोक सकते हैं।',
      ),
    ],
    mythBuster:
        'घाव को ब्लेड से काटना या मुंह से जहर चूसना बेअसर है — जहर तुरंत ऊतकों में घुल जाता है, और काटने से केवल गंभीर संक्रमण और अधिक रक्तस्राव होता है।',
  ),
  'spinal_injury': EmergencyScienceInfo(
    bodyMechanism:
        'हमारी रीढ़ की हड्डी सुरक्षा छल्लों की एक श्रृंखला है जिसके अंदर मुख्य नसों का केबल (स्पाइनल कॉर्ड) होता है — यही दिमाग से हाथ-पैरों तक संदेश पहुंचाता है। तेज गिरने या एक्सीडेंट के बाद इनमें से कोई छल्ला चटककर ढीला हो सकता है।',
    facts: [
      EmergencyScienceFact(
        action: 'सिर और गर्दन को सीधी रेखा में स्थिर क्यों पकड़े रहते हैं?',
        reason:
            'यदि चटकी हुई हड्डी ज़रा भी खिसकती या मुड़ती है, तो उसका नुकीला किनारा अंदर के नसों के केबल को दबा या काट सकता है, जिससे स्थायी लकवा हो सकता है।',
      ),
      EmergencyScienceFact(
        action: 'बाइक हेलमेट क्यों नहीं उतारना चाहिए?',
        reason:
            'कसा हुआ हेलमेट खींचने से गर्दन झटके से मुड़ती है। मेडिकल टीम बिना गर्दन हिलाए हेलमेट उतारने के विशेष तरीके जानती है।',
      ),
    ],
    mythBuster:
        'यदि घायल की सांस बंद हो जाए, तो जान बचाने के लिए सावधानी से CPR शुरू करना फिर भी पहली प्राथमिकता है — ऑक्सीजन की कमी कुछ ही मिनटों में जान ले सकती है।',
  ),
};
