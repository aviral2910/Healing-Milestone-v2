import '../domain/emergency_guide_model.dart';

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
    quiz: EmergencyQuizQuestion(
      question:
          'What is the recommended chest compression rate for adult CPR?',
      options: [
        '60–80 compressions per minute',
        '100–120 compressions per minute',
        '140–160 compressions per minute',
      ],
      correctIndex: 1,
      explanation:
          '100–120 compressions per minute (about 2 pushes per second) maintains blood flow to the brain and heart.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question:
          'Where should you place your fist for abdominal thrusts in a conscious adult?',
      options: [
        'On the upper sternum (collarbone area)',
        'Just above the navel (belly button), below the ribcage',
        'Directly over the lower ribs',
      ],
      correctIndex: 1,
      explanation:
          'Placing the fist just above the navel and pulling inward and upward creates upward diaphragm pressure to expel the blockage.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question: 'Why is noting the exact time stroke symptoms started critical?',
      options: [
        'It helps determine eligibility for time-sensitive clot-busting treatment',
        'It is only needed for insurance paperwork',
        'It tells paramedics which hospital is closest',
      ],
      correctIndex: 0,
      explanation:
          'Thrombolytic (clot-busting) medications can only be safely given within a specific window from symptom onset.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question:
          'What should you do if a bandage becomes soaked with blood while applying pressure?',
      options: [
        'Peel it off and replace it with a dry bandage',
        'Leave it in place and add more gauze/cloth on top',
        'Rinse the wound with cold water',
      ],
      correctIndex: 1,
      explanation:
          'Removing the soaked layer tears away forming blood clots. Always stack additional clean cloth on top and keep pressing.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question: 'Where should an epinephrine auto-injector be administered?',
      options: [
        'Into a vein in the arm',
        'Into the outer mid-thigh muscle',
        'Into the stomach',
      ],
      correctIndex: 1,
      explanation:
          'The outer mid-thigh muscle absorbs epinephrine rapidly and safely, even through light clothing.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question: 'How long should you cool a burn under cool running water?',
      options: [
        '1–2 minutes',
        'At least 20 minutes',
        'Pack it in ice for 5 minutes',
      ],
      correctIndex: 1,
      explanation:
          '20 minutes of cool running water draws heat out of deeper skin layers and reduces scarring.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question: 'When should you call emergency services for a seizure?',
      options: [
        'If it lasts longer than 5 minutes or it is their first seizure',
        'Only if they wake up tired',
        'Never, seizures always stop on their own',
      ],
      correctIndex: 0,
      explanation:
          'A seizure lasting over 5 minutes (status epilepticus) or a first-time seizure requires urgent medical evaluation.',
    ),
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
    quiz: EmergencyQuizQuestion(
      question:
          'What is the safest position for a conscious person having suspected heart attack symptoms?',
      options: [
        'Walking around slowly to ease chest tightness',
        'Sitting calmly at rest in a comfortable position while waiting for an ambulance',
        'Driving themselves to the nearest clinic',
      ],
      correctIndex: 1,
      explanation:
          'Resting reduces the heart\'s oxygen demand while waiting for paramedics who can treat cardiac arrest en route.',
    ),
  ),
];
