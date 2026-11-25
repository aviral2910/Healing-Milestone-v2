import '../domain/emergency_guide_model.dart';
import 'awareness_providers.dart';
import 'emergency_guides_data_hi.dart';

List<EmergencyGuide> getEmergencyGuides(AwarenessLanguage language) {
  return language == AwarenessLanguage.hi
      ? emergencyGuidesDataHi
      : emergencyGuidesData;
}

const List<EmergencyGuide> emergencyGuidesData = [
  EmergencyGuide(
    id: 'cpr_adult',
    title: 'Adult CPR & AED',
    subtitle: 'Hands-only chest compressions & defibrillator basics',
    category: EmergencyCategory.cardiac,
    isCritical: true,
    hasMetronome: true,
    estimatedReadMinutes: 3,
    whenToCallEmergency:
        'Call emergency services immediately if the person is unresponsive and not breathing normally (or only gasping).',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Check Scene & Responsiveness',
        instruction:
            'Make sure the area is safe. Tap the person\'s shoulders firmly and shout, "Are you okay?"',
        voicePrompt:
            'Step 1. Make sure the area is safe. Tap their shoulders firmly and shout, are you okay?',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Call Emergency & Get an AED',
        instruction:
            'If there is no response and they are not breathing normally, call emergency services on speakerphone and ask someone to bring an AED if available.',
        voicePrompt:
            'Step 2. Call emergency services on speakerphone immediately and send someone for an A E D.',
        criticalNote: 'Do not leave the person alone if you have a phone.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Position Your Hands',
        instruction:
            'Place the person flat on their back on a firm surface. Put the heel of one hand on the center of the chest (lower half of breastbone), place your other hand on top, and interlock fingers.',
        voicePrompt:
            'Step 3. Place the person flat on their back. Put the heel of one hand on the center of the chest and interlock your other hand on top.',
      ),
      EmergencyStep(
        stepNumber: 4,
        title: 'Push Hard & Fast (100–120 BPM)',
        instruction:
            'Keep your arms straight and shoulders directly over your hands. Push down 5–6 cm (2–2.4 inches) at 100–120 compressions per minute. Let the chest rise completely after each push.',
        voicePrompt:
            'Step 4. Push hard and fast in the center of the chest, 100 to 120 beats per minute. Let the chest rise completely between pushes.',
        criticalNote: 'Use the built-in 110 BPM CPR Coach in this app to keep pace.',
      ),
      EmergencyStep(
        stepNumber: 5,
        title: 'Use the AED as Soon as It Arrives',
        instruction:
            'Turn on the AED and follow its voice prompts. Apply pads to bare, dry chest. Stand clear while it analyzes rhythm or delivers a shock, then resume compressions immediately.',
        voicePrompt:
            'Step 5. Turn on the A E D, place pads on bare dry chest, stand clear during analysis, and resume compressions right after.',
      ),
      EmergencyStep(
        stepNumber: 6,
        title: 'Continue Until Help Takes Over',
        instruction:
            'Do not stop compressions unless the person shows clear signs of life (breathing normally/moving) or paramedics take over. Swap rescuers every 2 minutes if possible.',
        voicePrompt:
            'Step 6. Continue compressions without stopping until the person breathes normally or emergency responders take over.',
      ),
    ],
    doNots: [
      'Do not delay compressions to check for a pulse if you are unsure.',
      'Do not lean on the chest between compressions — allow full chest recoil.',
      'Do not place AED pads over medication patches or wet skin without wiping first.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'What is the very first thing you should do before approaching an unresponsive person?',
        options: [
          'Start chest compressions immediately',
          'Check that the scene is safe, then tap shoulders and shout',
          'Give them water to wake them up',
        ],
        correctIndex: 1,
        explanation: 'Always ensure the area is safe first so you do not become a second victim, then check responsiveness.',
      ),
      EmergencyQuizQuestion(
        question: 'If the person is unresponsive and not breathing normally, what should you do next?',
        options: [
          'Wait 5 minutes to see if they wake up',
          'Call emergency services on speakerphone and send someone for an AED',
          'Leave them alone to search for a clinic',
        ],
        correctIndex: 1,
        explanation: 'Calling emergency services on speakerphone lets you get help on the way without delaying CPR.',
      ),
      EmergencyQuizQuestion(
        question: 'Where should you place your hands for adult chest compressions?',
        options: [
          'On the upper abdomen just above the navel',
          'On the center of the chest (lower half of the breastbone)',
          'Over the left side of the ribs',
        ],
        correctIndex: 1,
        explanation: 'The heel of one hand goes on the center of the chest with the other hand interlocked on top.',
      ),
      EmergencyQuizQuestion(
        question: 'What is the recommended chest compression rate and depth for adult CPR?',
        options: [
          '60–80/min at 2 cm depth',
          '100–120/min at 5–6 cm depth with full chest recoil',
          '140–160/min without letting the chest rise',
        ],
        correctIndex: 1,
        explanation: '100–120 compressions per minute at 5–6 cm depth with full recoil maximizes blood flow.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do when the AED is analyzing or delivering a shock?',
        options: [
          'Keep your hands on the chest',
          'Stand completely clear and resume compressions right after',
          'Turn off the AED before it shocks',
        ],
        correctIndex: 1,
        explanation: 'No one should touch the person during AED analysis or shock delivery; resume compressions immediately after.',
      ),
      EmergencyQuizQuestion(
        question: 'When should you stop CPR compressions?',
        options: [
          'After 1 minute if they haven\'t woken up',
          'Only when the person shows clear signs of life or paramedics take over',
          'As soon as your arms feel slightly tired',
        ],
        correctIndex: 1,
        explanation: 'Continue CPR uninterrupted (swapping rescuers every 2 minutes if available) until help takes over or normal breathing returns.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'choking_adult',
    title: 'Choking (Heimlich & Back Blows)',
    subtitle: 'Clearing a blocked airway in a conscious adult or child',
    category: EmergencyCategory.breathing,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services if the person cannot cough, speak, or breathe, or if they become unconscious.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Assess Severity',
        instruction:
            'Ask, "Are you choking?" If they can cough forcefully, encourage them to keep coughing. If they cannot speak, cough, or breathe, act immediately.',
        voicePrompt:
            'Step 1. Ask if they are choking. If they can cough, let them keep coughing. If they cannot speak or breathe, act now.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Give 5 Firm Back Blows',
        instruction:
            'Stand to the side and slightly behind. Support their chest with one hand, lean them forward, and deliver 5 sharp blows between the shoulder blades with the heel of your hand.',
        voicePrompt:
            'Step 2. Lean the person forward and give 5 firm back blows between the shoulder blades with the heel of your hand.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Give 5 Abdominal Thrusts',
        instruction:
            'Stand behind them, wrap your arms around their waist, make a fist just above the navel, grasp it with your other hand, and pull inward and upward sharply 5 times.',
        voicePrompt:
            'Step 3. Stand behind them, place a fist just above the belly button, and pull inward and upward 5 times.',
        criticalNote:
            'For pregnant individuals or people you cannot reach around, perform chest thrusts instead of abdominal thrusts.',
      ),
      EmergencyStep(
        stepNumber: 4,
        title: 'Alternate 5 & 5 Until Clear',
        instruction:
            'Continue alternating 5 back blows and 5 abdominal thrusts until the object is expelled or emergency help arrives. If they collapse, lower them to the floor and start CPR.',
        voicePrompt:
            'Step 4. Alternate 5 back blows and 5 abdominal thrusts until the airway clears. If they collapse, start C P R.',
      ),
    ],
    doNots: [
      'Do not perform blind finger sweeps in the mouth — you can push the object deeper.',
      'Do not slap the back of someone who is coughing forcefully and clearing it themselves.',
      'Do not use abdominal thrusts on infants under 1 year old (use infant back blows & chest thrusts).',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'If a choking person is coughing forcefully, what should you do?',
        options: [
          'Immediately perform abdominal thrusts',
          'Encourage them to keep coughing without interfering',
          'Reach into their throat with your fingers',
        ],
        correctIndex: 1,
        explanation: 'A strong cough is the most effective way to clear a partial blockage.',
      ),
      EmergencyQuizQuestion(
        question: 'Where should you deliver the 5 back blows for severe choking?',
        options: [
          'On the lower back',
          'Between the shoulder blades with the heel of your hand',
          'On the back of the neck',
        ],
        correctIndex: 1,
        explanation: 'Lean the person forward and strike firmly between the shoulder blades.',
      ),
      EmergencyQuizQuestion(
        question: 'Where should you place your fist for abdominal thrusts in a conscious adult?',
        options: [
          'On the upper sternum',
          'Just above the navel (belly button), below the ribcage',
          'Directly over the lower ribs',
        ],
        correctIndex: 1,
        explanation: 'Placing the fist just above the navel and pulling inward and upward creates upward pressure to expel the object.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do if a choking person becomes unconscious and collapses?',
        options: [
          'Keep trying standing back blows',
          'Lower them to the floor, call emergency, and start CPR',
          'Give them sips of water',
        ],
        correctIndex: 1,
        explanation: 'Once unconscious, lower them safely to the floor and begin CPR immediately.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'stroke_fast',
    title: 'Stroke Recognition (FAST)',
    subtitle: 'Spot warning signs early — every minute saves brain cells',
    category: EmergencyCategory.neurological,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services IMMEDIATELY if ANY single FAST sign appears, even if symptoms disappear after a few minutes.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'F — Face Drooping',
        instruction:
            'Ask the person to smile. Check if one side of the face droops or feels numb.',
        voicePrompt:
            'F for Face. Ask the person to smile. Does one side of the face droop?',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'A — Arm Weakness',
        instruction:
            'Ask them to raise both arms. Check if one arm drifts downward or cannot be lifted.',
        voicePrompt:
            'A for Arms. Ask them to raise both arms. Does one arm drift downward?',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'S — Speech Difficulty',
        instruction:
            'Ask them to repeat a simple sentence like "The sky is blue." Listen for slurred, garbled, or hard-to-understand speech.',
        voicePrompt:
            'S for Speech. Ask them to repeat a simple sentence. Is their speech slurred or strange?',
      ),
      EmergencyStep(
        stepNumber: 4,
        title: 'T — Time to Call & Note Onset',
        instruction:
            'Call emergency services right away. Note the exact time symptoms started (or when the person was last seen normal) — doctors need this for clot-busting treatment.',
        voicePrompt:
            'T for Time. Call emergency services immediately and note the exact time symptoms started.',
        criticalNote: 'Do not let the person drive themselves to the hospital.',
      ),
    ],
    doNots: [
      'Do not give food, water, or medication (including aspirin) — stroke can affect swallowing or be caused by bleeding.',
      'Do not wait to "see if it passes" — clot treatments have strict time windows.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'In FAST, what does "F" stand for and how do you check it?',
        options: [
          'Fever — feel their forehead',
          'Face drooping — ask the person to smile',
          'Fainting — check their pulse',
        ],
        correctIndex: 1,
        explanation: 'Asking the person to smile quickly reveals facial asymmetry or drooping on one side.',
      ),
      EmergencyQuizQuestion(
        question: 'How do you check for "A" (Arm weakness) in FAST?',
        options: [
          'Ask them to squeeze your hand as hard as possible only',
          'Ask them to raise both arms and watch if one drifts downward',
          'Ask them to do push-ups',
        ],
        correctIndex: 1,
        explanation: 'If one arm drifts downward or cannot be lifted, it is a key stroke warning sign.',
      ),
      EmergencyQuizQuestion(
        question: 'What does "S" check in FAST?',
        options: [
          'Skin color',
          'Speech difficulty — slurred or strange speech when repeating a simple sentence',
          'Sweating',
        ],
        correctIndex: 1,
        explanation: 'Slurred, garbled, or missing words when repeating a simple phrase indicates speech impairment.',
      ),
      EmergencyQuizQuestion(
        question: 'Why is noting the exact time stroke symptoms started ("T") critical?',
        options: [
          'It determines eligibility for time-sensitive clot-busting treatment',
          'It is only needed for billing',
          'It tells paramedics which ambulance to send',
        ],
        correctIndex: 0,
        explanation: 'Clot-busting medications can only be safely administered within a strict window from symptom onset.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'severe_bleeding',
    title: 'Severe Bleeding Control',
    subtitle: 'Stop life-threatening blood loss safely',
    category: EmergencyCategory.bleeding,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services for spurting blood, blood that won\'t stop after 10 minutes of firm pressure, deep wounds, or signs of shock.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Protect Yourself & Expose Wound',
        instruction:
            'Wear disposable gloves if available. Cut or move clothing away so you can clearly see where the bleeding is coming from.',
        voicePrompt:
            'Step 1. Put on gloves if available and expose the wound so you can see the bleeding clearly.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Apply Firm, Direct Pressure',
        instruction:
            'Place a clean cloth, sterile gauze, or T-shirt directly over the wound and press down firmly with both hands. Maintain continuous pressure.',
        voicePrompt:
            'Step 2. Place a clean cloth directly on the wound and press down firmly with continuous pressure.',
        criticalNote:
            'If blood soaks through, add MORE cloth on top — do not remove the first layer.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Keep the Person Warm & Calm',
        instruction:
            'Have the person lie flat. Cover them with a blanket or jacket to prevent shock while maintaining pressure on the wound.',
        voicePrompt:
            'Step 3. Have the person lie down and cover them to keep warm while holding pressure.',
      ),
      EmergencyStep(
        stepNumber: 4,
        title: 'Use a Tourniquet Only for Life-Threatening Limb Bleeds',
        instruction:
            'If bleeding from an arm or leg is severe and direct pressure fails, apply a commercial tourniquet 5–7 cm (2–3 inches) above the wound (not on a joint) and tighten until bleeding stops. Note the time applied.',
        voicePrompt:
            'Step 4. For severe limb bleeding that does not stop with pressure, apply a tourniquet 2 to 3 inches above the wound and note the time.',
      ),
    ],
    doNots: [
      'Do not remove blood-soaked gauze — it disrupts clotting. Layer fresh gauze on top.',
      'Do not pull out embedded objects (glass, metal); pack around them instead.',
      'Do not loosen a tourniquet once applied — leave that to emergency doctors.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'Why should you expose the wound before applying pressure?',
        options: [
          'So you can see the exact source of bleeding and apply direct pressure accurately',
          'So the wound dries faster in the air',
          'To wash it with soap first',
        ],
        correctIndex: 0,
        explanation: 'Exposing the wound ensures your pressure is directly over the bleeding vessel, not absorbed by bulky clothing.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do if a bandage becomes soaked with blood?',
        options: [
          'Peel it off and replace it with a dry bandage',
          'Leave it in place and add more clean cloth/gauze on top',
          'Rinse the wound with cold water',
        ],
        correctIndex: 1,
        explanation: 'Removing the soaked layer tears away forming blood clots. Always layer fresh cloth on top.',
      ),
      EmergencyQuizQuestion(
        question: 'Why should a severely bleeding person lie flat and stay warm?',
        options: [
          'To help prevent shock',
          'To make it easier for them to sleep',
          'To increase blood pressure in the wound',
        ],
        correctIndex: 0,
        explanation: 'Lying flat and conserving body heat helps prevent life-threatening hemorrhagic shock.',
      ),
      EmergencyQuizQuestion(
        question: 'Where should a tourniquet be placed if direct pressure fails on a limb?',
        options: [
          'Directly over the wound or joint',
          '5–7 cm (2–3 inches) above the wound, never on a joint',
          'Below the wound',
        ],
        correctIndex: 1,
        explanation: 'A tourniquet goes 2–3 inches above the bleeding site (closer to the heart) and never directly over a joint.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'anaphylaxis',
    title: 'Severe Allergic Reaction (Anaphylaxis)',
    subtitle: 'Recognizing airway swelling & using an epinephrine auto-injector',
    category: EmergencyCategory.allergy,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services immediately if someone has trouble breathing, throat/tongue swelling, dizziness, or widespread hives after an allergen exposure.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Spot the Warning Signs',
        instruction:
            'Look for difficulty breathing, wheezing, swollen lips/tongue, dizziness, vomiting, or sudden hives after food, medicine, or an insect sting.',
        voicePrompt:
            'Step 1. Check for trouble breathing, swollen lips or tongue, dizziness, or hives.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Use Epinephrine (EpiPen) Immediately',
        instruction:
            'If they carry an epinephrine auto-injector, remove the safety cap and press the orange/needle tip firmly into the outer mid-thigh (even through clothing) for 3–10 seconds as directed.',
        voicePrompt:
            'Step 2. Press the epinephrine injector firmly against the outer mid-thigh and hold as directed.',
        criticalNote: 'When in doubt during severe symptoms, give epinephrine first.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Position Safely & Call Emergency',
        instruction:
            'Call emergency services even if symptoms improve. Have them lie flat with legs raised (or sit upright if breathing is hard). A second dose may be needed after 5–15 minutes if symptoms persist.',
        voicePrompt:
            'Step 3. Call emergency services. Keep the person lying flat, or sitting up if breathing is difficult.',
      ),
    ],
    doNots: [
      'Do not rely on antihistamines alone for breathing trouble or throat swelling.',
      'Do not make the person stand up or walk around suddenly if they feel dizzy.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'Which signs indicate a life-threatening allergic reaction (anaphylaxis)?',
        options: [
          'Mild sneezing only',
          'Trouble breathing, swollen lips/tongue, dizziness, or widespread hives',
          'A small mosquito bite itch',
        ],
        correctIndex: 1,
        explanation: 'Airway swelling, breathing difficulty, or sudden dizziness signal anaphylaxis requiring immediate epinephrine.',
      ),
      EmergencyQuizQuestion(
        question: 'Where should an epinephrine auto-injector be administered?',
        options: [
          'Into a vein in the arm',
          'Into the outer mid-thigh muscle',
          'Into the stomach',
        ],
        correctIndex: 1,
        explanation: 'The outer mid-thigh muscle absorbs epinephrine rapidly and safely, even through clothing.',
      ),
      EmergencyQuizQuestion(
        question: 'After giving epinephrine and symptoms start improving, what should you still do?',
        options: [
          'Skip calling emergency services',
          'Call emergency services anyway and keep them lying flat (or sitting if breathing is hard)',
          'Have them stand up and walk around',
        ],
        correctIndex: 1,
        explanation: 'Biphasic reactions can cause symptoms to return; medical monitoring is always required.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'burns_scalds',
    title: 'Burns & Scalds First Aid',
    subtitle: 'Immediate cooling & protecting damaged skin',
    category: EmergencyCategory.burns,
    isCritical: false,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services for burns larger than the person\'s palm, burns on the face/hands/groin/joints, electrical/chemical burns, or if the victim is a child/elderly.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Stop the Burning & Cool with Running Water',
        instruction:
            'Move away from the heat source. Hold the burn under cool (not ice-cold) running tap water for at least 20 minutes.',
        voicePrompt:
            'Step 1. Cool the burn under cool running water for at least 20 minutes.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Remove Tight Items Gently',
        instruction:
            'While cooling, carefully remove rings, watches, or loose clothing near the area before swelling starts — unless fabric is stuck to the burn.',
        voicePrompt:
            'Step 2. Gently remove rings or watches before swelling begins, unless clothing is stuck to the skin.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Cover Loosely',
        instruction:
            'After cooling, cover the burn loosely with clean plastic wrap (cling film) or a sterile, non-fluffy dressing to prevent infection.',
        voicePrompt:
            'Step 3. Cover the burn loosely with clean cling film or a sterile non-fluffy dressing.',
      ),
    ],
    doNots: [
      'Do not apply ice, butter, toothpaste, oil, or turmeric — they trap heat and cause infection.',
      'Do not pop blisters.',
      'Do not peel off clothing that is melted or stuck to the skin.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'How long should you cool a burn under cool running water?',
        options: [
          '1–2 minutes',
          'At least 20 minutes',
          'Pack it in ice for 5 minutes',
        ],
        correctIndex: 1,
        explanation: '20 minutes of cool running water draws heat out of deeper skin layers and reduces scarring.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do if clothing is melted or stuck to the burn?',
        options: [
          'Peel it off quickly',
          'Leave the stuck fabric alone and cool over it',
          'Scrub it off with soap',
        ],
        correctIndex: 1,
        explanation: 'Pulling stuck fabric tears away damaged skin and worsens injury.',
      ),
      EmergencyQuizQuestion(
        question: 'What is the safest way to cover a burn after cooling it?',
        options: [
          'Apply butter or toothpaste',
          'Cover loosely with clean cling film or a sterile non-fluffy dressing',
          'Wrap tightly with cotton wool',
        ],
        correctIndex: 1,
        explanation: 'Clean cling film or a sterile non-fluffy dressing protects the burn without sticking.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'seizures_fainting',
    title: 'Seizures & Fainting',
    subtitle: 'Protecting the head & using the recovery position',
    category: EmergencyCategory.neurological,
    isCritical: false,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services if a seizure lasts more than 5 minutes, repeats, happens in water, causes injury, or if it is the person\'s first-ever seizure.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Keep Calm & Time the Seizure',
        instruction:
            'Clear hard or sharp objects away from the person. Cushion their head with a folded jacket or pillow, and check the clock to time the episode.',
        voicePrompt:
            'Step 1. Clear sharp objects away, cushion their head, and note the time the seizure starts.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Turn to the Recovery Position',
        instruction:
            'Once jerking stops (or if they are breathing and unconscious), gently roll them onto one side with their mouth angled slightly downward so fluids can drain.',
        voicePrompt:
            'Step 2. Once movement stops, gently roll them onto their side in the recovery position.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Stay Until Fully Alert',
        instruction:
            'Speak calmly and reassure them as they wake up. Do not offer water or food until they are completely alert.',
        voicePrompt:
            'Step 3. Stay with them and speak calmly until they are fully alert.',
      ),
    ],
    doNots: [
      'Do not put anything (fingers, spoons, cloth) in their mouth — they cannot swallow their tongue.',
      'Do not hold them down or restrain their movements.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'What should you do during an active seizure?',
        options: [
          'Put a spoon in their mouth to protect their tongue',
          'Clear hard objects away, cushion their head, and time the seizure',
          'Hold their arms and legs down firmly',
        ],
        correctIndex: 1,
        explanation: 'Never put anything in the mouth or restrain movements; protect the head and time the episode.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do once the jerking stops and the person is breathing?',
        options: [
          'Leave them flat on their back',
          'Gently roll them onto their side into the recovery position',
          'Give them a glass of water immediately',
        ],
        correctIndex: 1,
        explanation: 'The recovery position keeps the airway open and lets saliva or fluids drain safely.',
      ),
      EmergencyQuizQuestion(
        question: 'When should you offer food or water after a seizure?',
        options: [
          'Right as the jerking stops',
          'Only after they are completely awake and alert',
          'While they are still confused',
        ],
        correctIndex: 1,
        explanation: 'Offering food or water before full alertness risks choking.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'heart_attack_signs',
    title: 'Heart Attack Warning Signs',
    subtitle: 'Recognize symptoms early before cardiac arrest happens',
    category: EmergencyCategory.cardiac,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services immediately if chest pressure, squeezing, or discomfort lasts more than a few minutes or spreads to the arm, neck, jaw, or back.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Recognize Classic & Atypical Signs',
        instruction:
            'Chest pressure/tightness, pain spreading to left arm, jaw, neck, or upper back, shortness of breath, cold sweat, nausea, or sudden lightheadedness.',
        voicePrompt:
            'Step 1. Watch for chest pressure, pain in the arm, jaw, or back, shortness of breath, cold sweat, or nausea.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Call Emergency & Rest',
        instruction:
            'Call emergency services immediately. Have the person sit down in a comfortable, semi-upright position and loosen tight clothing.',
        voicePrompt:
            'Step 2. Call emergency services. Have the person sit calmly and loosen tight clothing.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Aspirin (Only If Safe & Not Allergic)',
        instruction:
            'If emergency dispatch advises and the person has no aspirin allergy or bleeding risk, have them chew one regular (300–325 mg) aspirin slowly.',
        voicePrompt:
            'Step 3. If advised by dispatch and not allergic, they may chew one regular aspirin.',
        criticalNote:
            'If they collapse and stop breathing normally, switch immediately to Adult CPR.',
      ),
    ],
    doNots: [
      'Do not let the person drive themselves to the hospital.',
      'Do not ignore mild or atypical symptoms (especially in women, older adults, and diabetics).',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'Which of these can be a heart attack symptom besides chest pain?',
        options: [
          'Pain in the jaw, neck, back, or arm, cold sweat, nausea, or shortness of breath',
          'Only sharp pain in the toes',
          'Only a mild headache',
        ],
        correctIndex: 0,
        explanation: 'Heart attacks often present with radiating pain, shortness of breath, cold sweat, or nausea.',
      ),
      EmergencyQuizQuestion(
        question: 'What is the safest position for a conscious person with suspected heart attack symptoms?',
        options: [
          'Walking around slowly',
          'Sitting calmly at rest in a comfortable position while waiting for an ambulance',
          'Driving themselves to the nearest clinic',
        ],
        correctIndex: 1,
        explanation: 'Resting reduces the heart\'s oxygen demand while waiting for paramedics.',
      ),
      EmergencyQuizQuestion(
        question: 'If a heart attack patient collapses and stops breathing normally, what must you do?',
        options: [
          'Wait for them to wake up',
          'Switch immediately to Adult CPR',
          'Give them another aspirin',
        ],
        correctIndex: 1,
        explanation: 'If they become unresponsive and stop breathing normally, cardiac arrest has occurred — start CPR immediately.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'infant_choking_cpr',
    title: 'Infant Choking & CPR (Under 1 Yr)',
    subtitle: 'Safe back blows, chest thrusts & 2-finger infant CPR',
    category: EmergencyCategory.breathing,
    isCritical: true,
    estimatedReadMinutes: 3,
    whenToCallEmergency:
        'Call emergency services immediately if a baby cannot cry, cough, or breathe, turns blue, or becomes unresponsive.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Give 5 Infant Back Blows',
        instruction:
            'Lay the baby face-down along your forearm, supporting the jaw/head (keep head lower than chest). Give 5 firm back blows between the shoulder blades with the heel of your hand.',
        voicePrompt:
            'Step 1. Hold the baby face down on your forearm supporting the jaw, and give 5 firm back blows between the shoulder blades.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Give 5 Chest Thrusts',
        instruction:
            'Turn the baby face-up on your other forearm, still supporting the head. Place 2 fingers on the center of the chest just below the nipple line and press down 5 times (about 4 cm deep).',
        voicePrompt:
            'Step 2. Turn the baby face up supporting the head, and give 5 chest thrusts with 2 fingers just below the nipple line.',
        criticalNote: 'NEVER use abdominal thrusts (Heimlich) on an infant.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'If Unresponsive, Start Infant CPR',
        instruction:
            'Place the baby on a firm flat surface. Give 30 gentle 2-finger compressions (4 cm deep, 100–120/min) followed by 2 gentle puffs of air covering both mouth and nose.',
        voicePrompt:
            'Step 3. If unresponsive, give 30 two-finger chest compressions on a firm surface, followed by 2 gentle puffs over mouth and nose.',
      ),
    ],
    doNots: [
      'Do not perform abdominal thrusts on an infant under 1 year old.',
      'Do not do blind finger sweeps inside the baby\'s mouth.',
      'Do not shake the baby.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'How should you position a choking infant for back blows?',
        options: [
          'Sitting upright on your lap',
          'Face-down along your forearm with the head supported and lower than the chest',
          'Flat on their back',
        ],
        correctIndex: 1,
        explanation: 'Gravity helps dislodge the object while supporting the jaw keeps the airway open.',
      ),
      EmergencyQuizQuestion(
        question: 'What replaces abdominal thrusts for a conscious choking infant?',
        options: [
          '5 chest thrusts using 2 fingers just below the nipple line',
          '5 hard abdominal pushes',
          'Hanging the baby upside down by the feet',
        ],
        correctIndex: 0,
        explanation: 'Abdominal thrusts can injure an infant\'s liver; always use 2-finger chest thrusts.',
      ),
      EmergencyQuizQuestion(
        question: 'How deep should chest compressions be during infant CPR?',
        options: [
          'About 4 cm (1.5 inches) using 2 fingers',
          '10 cm using both hands',
          '1 cm using one thumb lightly',
        ],
        correctIndex: 0,
        explanation: 'Compress about one-third the depth of the chest (~4 cm) at 100–120 per minute.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'asthma_attack',
    title: 'Severe Asthma Attack',
    subtitle: 'Airway positioning & rescue inhaler steps',
    category: EmergencyCategory.breathing,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services if the rescue inhaler gives no relief after 10 minutes, the person cannot speak full sentences, or lips/fingernails turn bluish.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Sit Upright & Stay Calm',
        instruction:
            'Help the person sit upright (leaning slightly forward helps breathing). Loosen tight collars and speak calmly — panic worsens airway tightness.',
        voicePrompt:
            'Step 1. Help the person sit upright and stay calm. Loosen tight clothing.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Give Rescue Inhaler (Salbutamol / Albuterol)',
        instruction:
            'Shake the blue/rescue inhaler. Give 1 puff (ideally through a spacer), have them take 4 slow breaths, wait 1 minute, and repeat up to 4 puffs if needed.',
        voicePrompt:
            'Step 2. Shake the rescue inhaler and give 1 puff, then 4 slow breaths. Wait 1 minute between puffs up to 4 puffs.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Monitor & Repeat or Call SOS',
        instruction:
            'If breathing does not improve after 4 minutes, repeat 4 more puffs and call emergency services immediately. Continue 4 puffs every 4 minutes while waiting for paramedics.',
        voicePrompt:
            'Step 3. If no improvement after 4 minutes, call emergency services and continue 4 puffs every 4 minutes until help arrives.',
      ),
    ],
    doNots: [
      'Do not force the person to lie flat — it makes breathing harder.',
      'Do not use a preventer (steroid) inhaler instead of the quick-relief rescue inhaler.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'What is the best body position for someone having an asthma attack?',
        options: [
          'Lying flat on their back',
          'Sitting upright (or leaning slightly forward)',
          'Lying face-down',
        ],
        correctIndex: 1,
        explanation: 'Sitting upright allows the lungs and diaphragm to expand maximally.',
      ),
      EmergencyQuizQuestion(
        question: 'How should rescue inhaler puffs be given during an attack?',
        options: [
          '4 puffs all at once in one breath',
          '1 puff at a time with 4 slow breaths, waiting about 1 minute between puffs',
          'Only after eating food',
        ],
        correctIndex: 1,
        explanation: 'Spacing puffs with slow breaths (especially via a spacer) delivers medicine deeper into the airways.',
      ),
      EmergencyQuizQuestion(
        question: 'When should you call emergency services during an asthma attack?',
        options: [
          'Only after 1 hour',
          'If there is no relief after 4–10 minutes, or they cannot speak full sentences',
          'Never, asthma always resolves on its own',
        ],
        correctIndex: 1,
        explanation: 'Lack of response to rescue puffs or difficulty speaking signals a life-threatening asthma flare.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'diabetic_hypoglycemia',
    title: 'Low Blood Sugar (Hypoglycemia)',
    subtitle: 'The 15-gram fast sugar rule for diabetic emergencies',
    category: EmergencyCategory.neurological,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services immediately if the person is unconscious, having a seizure, or too confused to swallow safely.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Spot Low Blood Sugar Signs',
        instruction:
            'Look for shakiness, cold sweat, sudden irritability/confusion, slurred speech, dizziness, or blood glucose below 70 mg/dL (3.9 mmol/L).',
        voicePrompt:
            'Step 1. Check for shakiness, cold sweat, confusion, or dizziness.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'If Conscious: Give 15g Fast Sugar',
        instruction:
            'If awake and able to swallow, give 15g of fast-acting carbs: 3–4 glucose tablets, half a cup (120 ml) of fruit juice/regular soda, or 1 tablespoon of honey/sugar.',
        voicePrompt:
            'Step 2. If awake and able to swallow, give 15 grams of fast sugar like half a cup of fruit juice or 3 glucose tablets.',
        criticalNote: 'Avoid chocolate or fatty foods — fat slows sugar absorption.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Wait 15 Minutes & Recheck',
        instruction:
            'Wait 15 minutes and recheck blood sugar or symptoms. Repeat 15g sugar if still below 70 mg/dL. If they become unconscious, place in recovery position and call emergency.',
        voicePrompt:
            'Step 3. Wait 15 minutes and recheck. If they become unconscious, place them on their side and call emergency.',
      ),
    ],
    doNots: [
      'Do not put food, juice, or glucose gel into the mouth of an unconscious person — choking hazard.',
      'Do not give insulin during suspected low blood sugar.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'Which symptom commonly signals low blood sugar (hypoglycemia)?',
        options: [
          'Shakiness, cold sweat, dizziness, and sudden confusion',
          'High fever and joint rash',
          'Slowly worsening knee pain over weeks',
        ],
        correctIndex: 0,
        explanation: 'Low blood sugar triggers adrenaline (sweating, shaking) and brain fuel deprivation (confusion).',
      ),
      EmergencyQuizQuestion(
        question: 'What is the best fast-acting sugar for a conscious person with low blood sugar?',
        options: [
          'A chocolate bar or cheese sandwich',
          'Half a cup of fruit juice, regular soda, or 3–4 glucose tablets',
          'Diet soda',
        ],
        correctIndex: 1,
        explanation: 'Pure simple sugars raise blood glucose rapidly; fat in chocolate slows absorption, and diet soda has no sugar.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do if the person with low blood sugar becomes unconscious?',
        options: [
          'Pour fruit juice into their mouth',
          'Place them in the recovery position and call emergency services immediately',
          'Give them an insulin shot',
        ],
        correctIndex: 1,
        explanation: 'Never give fluids by mouth to an unconscious person; protect their airway and call for urgent medical help.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'snake_bite',
    title: 'Snake Bite First Aid',
    subtitle: 'Immobilize the limb & avoid harmful myths',
    category: EmergencyCategory.bleeding,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services or transport to the nearest hospital with antivenom IMMEDIATELY — even if the bite looks minor or painless.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Move Away & Keep the Victim Calm',
        instruction:
            'Move out of the snake\'s striking range. Have the person lie still and stay calm — panic and movement speed up venom spread.',
        voicePrompt:
            'Step 1. Move to safety and keep the person completely calm and still.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Remove Tight Items & Immobilize Limb',
        instruction:
            'Remove rings, watches, or tight shoes before swelling begins. Splint or immobilize the bitten limb and keep it at or slightly below heart level.',
        voicePrompt:
            'Step 2. Remove rings or watches before swelling starts, and keep the bitten limb still at or below heart level.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Cover Lightly & Transport Urgently',
        instruction:
            'Cover the bite loosely with a clean dry dressing. Do not try to catch or kill the snake; note its general appearance from a safe distance if possible and get to a hospital.',
        voicePrompt:
            'Step 3. Cover the bite loosely with a clean cloth and get the person to a hospital with antivenom right away.',
      ),
    ],
    doNots: [
      'Do not cut the wound or try to suck out venom.',
      'Do not tie a tight tourniquet — it can cause severe tissue death and amputation.',
      'Do not apply ice, electric shocks, or herbal pastes.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'Why must a snakebite victim stay calm and avoid walking?',
        options: [
          'Movement and high heart rate pump venom through the body faster',
          'Walking makes it harder for doctors to find the bite',
          'It prevents sunburn',
        ],
        correctIndex: 0,
        explanation: 'Muscle contraction and elevated heart rate accelerate lymphatic and bloodstream venom spread.',
      ),
      EmergencyQuizQuestion(
        question: 'How should the bitten arm or leg be positioned?',
        options: [
          'Raised high above the head',
          'Immobilized and kept at or slightly below heart level',
          'Massaged vigorously',
        ],
        correctIndex: 1,
        explanation: 'Immobilizing the limb at or below heart level slows systemic venom absorption.',
      ),
      EmergencyQuizQuestion(
        question: 'Which common snakebite myth actually causes severe harm?',
        options: [
          'Removing rings before swelling',
          'Cutting the wound, sucking venom, or tying a tight tourniquet',
          'Going straight to a hospital',
        ],
        correctIndex: 1,
        explanation: 'Cutting, sucking, and tight tourniquets do not remove venom and frequently cause infection or limb loss.',
      ),
    ],
  ),
  EmergencyGuide(
    id: 'spinal_injury',
    title: 'Head, Neck & Spinal Injury',
    subtitle: 'Preventing paralysis after falls or road accidents',
    category: EmergencyCategory.neurological,
    isCritical: true,
    estimatedReadMinutes: 2,
    whenToCallEmergency:
        'Call emergency services after any high-impact fall, road accident, diving injury, or if the person has neck/back pain, numbness, or confusion.',
    steps: [
      EmergencyStep(
        stepNumber: 1,
        title: 'Do Not Move the Person',
        instruction:
            'Unless there is immediate danger (fire, traffic, drowning), keep the person completely still in the exact position you found them.',
        voicePrompt:
            'Step 1. Do not move the person unless there is immediate danger like fire or traffic.',
      ),
      EmergencyStep(
        stepNumber: 2,
        title: 'Stabilize the Head & Neck',
        instruction:
            'Kneel behind their head, place your hands gently on both sides of their head/ears, and hold it steady in line with the spine until paramedics arrive.',
        voicePrompt:
            'Step 2. Hold the head gently steady on both sides in line with the spine until help arrives.',
        criticalNote: 'Do not remove a motorcycle helmet unless trained or airway is blocked.',
      ),
      EmergencyStep(
        stepNumber: 3,
        title: 'Check Breathing Without Twisting',
        instruction:
            'Monitor breathing and consciousness. If they stop breathing normally, start CPR while minimizing neck movement.',
        voicePrompt:
            'Step 3. Watch their breathing. If they stop breathing normally, start chest compressions carefully.',
      ),
    ],
    doNots: [
      'Do not lift, sit up, or drag an accident victim unless in life-threatening danger.',
      'Do not remove a helmet or bend the neck forward/sideways.',
    ],
    quizzes: [
      EmergencyQuizQuestion(
        question: 'When is it okay to move someone with a suspected spinal injury?',
        options: [
          'To make them more comfortable on a sofa',
          'Only if they are in immediate life-threatening danger (such as fire or oncoming traffic)',
          'Always move them into a car to drive to a clinic',
        ],
        correctIndex: 1,
        explanation: 'Moving an unstable spine can cause permanent paralysis; only move for immediate life threats.',
      ),
      EmergencyQuizQuestion(
        question: 'How should you stabilize the head and neck while waiting for paramedics?',
        options: [
          'Prop a thick pillow under their neck',
          'Hold both sides of the head gently in line with the spine',
          'Turn their head to the side',
        ],
        correctIndex: 1,
        explanation: 'Manual in-line stabilization prevents accidental twisting of the cervical spine.',
      ),
      EmergencyQuizQuestion(
        question: 'What should you do if a suspected spinal injury victim stops breathing normally?',
        options: [
          'Wait for paramedics before touching them',
          'Start CPR immediately while minimizing neck movement',
          'Sit them upright',
        ],
        correctIndex: 1,
        explanation: 'Life comes before limb/spine — if they are not breathing normally, CPR is essential.',
      ),
    ],
  ),
];
