import 'emergency_science_data.dart';

const Map<String, EmergencyScienceInfo> clinicalScienceDataEn = {
  'cpr_adult': EmergencyScienceInfo(
    bodyMechanism:
        'Cardiac arrest (commonly triggered by ventricular fibrillation or pulseless VT) halts cardiac output. Without perfusion, cerebral ATP depletes within 4–6 minutes, causing irreversible hypoxic-ischemic encephalopathy.',
    facts: [
      EmergencyScienceFact(
        action: '5–6 cm sternal compression depth',
        reason:
            'Generates intrathoracic pressure and direct cardiac compression between the sternum and thoracic vertebrae, producing ~25–30% of normal cardiac output and sustaining coronary perfusion pressure (CPP ≥15 mmHg).',
      ),
      EmergencyScienceFact(
        action: 'Complete chest wall recoil',
        reason:
            'Negative intrathoracic pressure during passive decompression drives venous return to the right atrium and ventricular filling prior to the next systole.',
      ),
      EmergencyScienceFact(
        action: '100–120 compressions/min & early defibrillation',
        reason:
            'Balances stroke volume and diastolic filling time; biphasic AED defibrillation depolarizes chaotic myocardial cells simultaneously so the SA node can resume organized sinus rhythm.',
      ),
    ],
    mythBuster:
        'Lay rescuers should not delay CPR for carotid pulse palpation — pulse checks have <55% sensitivity under stress and significantly increase no-flow time.',
    reference: 'American Heart Association (AHA) & ERC Adult BLS Guidelines',
  ),
  'choking_adult': EmergencyScienceInfo(
    bodyMechanism:
        'Complete supraglottic or laryngeal foreign-body airway obstruction (FBAO) prevents alveolar ventilation, causing rapid arterial hypoxemia, hypercapnia, and hypoxic arrest.',
    facts: [
      EmergencyScienceFact(
        action: '5 interscapular back blows',
        reason:
            'Creates abrupt intrathoracic pressure transients and mechanical vibration along the tracheobronchial tree to dislodge the impacted bolus.',
      ),
      EmergencyScienceFact(
        action: 'Subdiaphragmatic abdominal thrusts',
        reason:
            'Elevates the diaphragm rapidly, compressing residual lung volume (FRC + RV) to generate an artificial cough peak expiratory pressure.',
      ),
    ],
    mythBuster:
        'Blind digital sweeps risk impacting the foreign body further into the glottic aperture or causing mucosal trauma.',
    reference: 'AHA & Red Cross Airway Obstruction First-Aid Protocol',
  ),
  'stroke_fast': EmergencyScienceInfo(
    bodyMechanism:
        'Acute ischemic stroke (~85% of cases) occludes a cerebral artery, creating an infarcted core surrounded by an electrically silent but potentially salvageable ischemic penumbra (~1.9 million neurons lost/min).',
    facts: [
      EmergencyScienceFact(
        action: 'FAST neurological screen',
        reason:
            'Detects focal motor cortex, corticobulbar, or Broca/Wernicke territory deficits corresponding to middle or anterior cerebral artery occlusion.',
      ),
      EmergencyScienceFact(
        action: 'Documenting Last Known Well (LKW) time',
        reason:
            'Determines eligibility for IV thrombolysis (alteplase/tenecteplase within 4.5h) or mechanical thrombectomy (up to 24h with perfusion imaging).',
      ),
    ],
    mythBuster:
        'Antiplatelets (aspirin) are contraindicated pre-CT because ~15% of strokes are intracerebral or subarachnoid hemorrhages.',
    reference: 'AHA/ASA Acute Ischemic Stroke Guidelines',
  ),
  'severe_bleeding': EmergencyScienceInfo(
    bodyMechanism:
        'Acute loss of >15–30% circulating blood volume precipitates hypovolemic/hemorrhagic shock, tissue hypoperfusion, lactic acidosis, and the lethal triad (hypothermia, acidosis, coagulopathy).',
    facts: [
      EmergencyScienceFact(
        action: 'Sustained direct pressure & hemostatic layering',
        reason:
            'Reduces transmural vascular pressure to allow primary platelet aggregation and secondary fibrin cross-linking without shearing fragile clots.',
      ),
      EmergencyScienceFact(
        action: 'Proximal tourniquet for refractory extremity hemorrhage',
        reason:
            'Occludes arterial inflow proximal to the injury when direct pressure fails; noting application time prevents prolonged ischemic rhabdomyolysis.',
      ),
    ],
    mythBuster:
        'Hypothermia (<35°C) impairs coagulation cascade enzyme kinetics and platelet function — active warming is hemostatically critical.',
    reference: 'ACS Stop the Bleed & Prehospital Trauma Life Support (PHTLS)',
  ),
  'anaphylaxis': EmergencyScienceInfo(
    bodyMechanism:
        'IgE-mediated mast cell and basophil degranulation releases histamine, tryptase, and leukotrienes, inducing systemic vasodilation, capillary leak (distributive shock), and laryngeal/bronchial edema.',
    facts: [
      EmergencyScienceFact(
        action: 'IM epinephrine in the anterolateral vastus lateralis',
        reason:
            'α1-adrenergic agonism restores systemic vascular resistance and reverses mucosal edema; β2-agonism bronchodilates; vastus lateralis provides peak plasma levels in ~8 min.',
      ),
      EmergencyScienceFact(
        action: 'Supine positioning with lower-extremity elevation',
        reason:
            'Prevents "empty ventricle syndrome" and sudden cardiovascular collapse caused by orthostatic venous pooling during distributive shock.',
      ),
    ],
    mythBuster:
        'H1/H2 antihistamines and corticosteroids have slow onset and do not reverse bronchospasm or distributive shock.',
    reference: 'World Allergy Organization (WAO) Anaphylaxis Guidelines',
  ),
  'burns_scalds': EmergencyScienceInfo(
    bodyMechanism:
        'Thermal injury transfers latent heat into the dermis, causing coagulative necrosis in the zone of coagulation surrounded by a vulnerable zone of stasis where microthrombosis can deepen the burn.',
    facts: [
      EmergencyScienceFact(
        action: '20 minutes of cool (12–18°C) running water',
        reason:
            'Dissipates retained dermal heat, preserves microcirculation in the zone of stasis, and limits inflammatory mediator release.',
      ),
      EmergencyScienceFact(
        action: 'Polyvinyl chloride cling-film dressing',
        reason:
            'Protects exposed C-fiber nociceptors from air currents, reduces evaporative fluid loss, and forms an impermeable barrier against nosocomial pathogens.',
      ),
    ],
    mythBuster:
        'Ice induces intense peripheral vasoconstriction, worsening dermal ischemia in the zone of stasis.',
    reference: 'International Society for Burn Injuries (ISBI) & ANZBA',
  ),
  'seizures_fainting': EmergencyScienceInfo(
    bodyMechanism:
        'A generalized tonic-clonic seizure results from paroxysmal hypersynchronous cortical discharges, followed by a postictal phase of neuronal exhaustion, hypotonia, and depressed airway reflexes.',
    facts: [
      EmergencyScienceFact(
        action: 'Lateral recovery positioning post-ictally',
        reason:
            'Prevents posterior tongue displacement and passive aspiration of oral secretions or emesis during postictal obtundation.',
      ),
      EmergencyScienceFact(
        action: 'Monitoring duration (>5 min threshold)',
        reason:
            'Seizures exceeding 5 minutes meet operational criteria for status epilepticus, risking excitotoxic neuronal injury and requiring IV benzodiazepines.',
      ),
    ],
    mythBuster:
        'Inserting oral objects does not prevent tongue biting (which occurs at tonic onset) and risks dental fracture or airway obstruction.',
    reference: 'International League Against Epilepsy (ILAE) & Epilepsy Foundation',
  ),
  'heart_attack_signs': EmergencyScienceInfo(
    bodyMechanism:
        'Acute coronary syndrome (ACS) arises from atherosclerotic plaque rupture and intracoronary thrombus formation, causing myocardial ischemia and progressive necrosis from subendocardium outward.',
    facts: [
      EmergencyScienceFact(
        action: 'Physical rest in semi-Fowler position',
        reason:
            'Minimizes sympathetic tone, heart rate, and myocardial oxygen consumption (MVO2) distal to the occluded coronary artery.',
      ),
      EmergencyScienceFact(
        action: 'Chewed non-enteric-coated aspirin (300–325 mg)',
        reason:
            'Buccal absorption rapidly achieves irreversible COX-1 acetylation in platelets, inhibiting thromboxane A2-mediated thrombus propagation.',
      ),
    ],
    mythBuster:
        'Diabetic autonomic neuropathy and sex-specific presentation frequently mask angina as epigastric discomfort, dyspnea, or diaphoresis.',
    reference: 'AHA/ACC Acute Coronary Syndromes Guidelines',
  ),
  'infant_choking_cpr': EmergencyScienceInfo(
    bodyMechanism:
        'Infants have a small-caliber airway (prone to complete obstruction by edema/solids), a prominent occiput, and a relatively large, unprotected liver extending below the costal margin.',
    facts: [
      EmergencyScienceFact(
        action: 'Head-down prone positioning for back blows',
        reason:
            'Combines gravitational drainage with percussive thoracic pressure spikes to clear subglottic obstructions.',
      ),
      EmergencyScienceFact(
        action: '2-finger sternal thrusts instead of abdominal thrusts',
        reason:
            'Avoids hepatic or splenic laceration beneath the compliant infant ribcage while generating sufficient intrathoracic expulsion pressure.',
      ),
    ],
    mythBuster:
        'Pediatric cardiac arrest is predominantly asphyxial rather than primary arrhythmic — early ventilation alongside compressions is essential.',
    reference: 'AHA Pediatric Basic Life Support (PBLS) Guidelines',
  ),
  'asthma_attack': EmergencyScienceInfo(
    bodyMechanism:
        'Acute asthma exacerbation involves bronchospasm, airway mucosal edema, and mucus plugging, causing severe expiratory flow limitation, air trapping (dynamic hyperinflation), and ventilation-perfusion mismatch.',
    facts: [
      EmergencyScienceFact(
        action: 'Upright tripod posture',
        reason:
            'Recruits accessory inspiratory muscles (sternocleidomastoid, scalenes) and optimizes diaphragmatic excursion.',
      ),
      EmergencyScienceFact(
        action: 'Titrated short-acting β2-agonist (SABA) puffs',
        reason:
            'Activates bronchial smooth-muscle β2 receptors, increasing cAMP to induce bronchodilation; sequential puffs progressively improve distal aerosol deposition.',
      ),
    ],
    mythBuster:
        'Inhaled corticosteroids (ICS) act via genomic anti-inflammatory pathways over days and provide no acute bronchodilation.',
    reference: 'GINA (Global Initiative for Asthma) Acute Care Guidelines',
  ),
  'diabetic_hypoglycemia': EmergencyScienceInfo(
    bodyMechanism:
        'Brain tissue lacks significant glycogen stores and depends on continuous glucose transport. Levels <70 mg/dL trigger autonomic counter-regulation (epinephrine) followed by neuroglycopenia (<54 mg/dL).',
    facts: [
      EmergencyScienceFact(
        action: '15 g rapid-acting simple carbohydrate',
        reason:
            'Monosaccharides/disaccharides undergo rapid intestinal absorption via SGLT1/GLUT2, restoring euglycemia within 10–15 minutes.',
      ),
      EmergencyScienceFact(
        action: '15-minute recheck interval',
        reason:
            'Accounts for gastric emptying and capillary-venous equilibration lag, preventing iatrogenic rebound hyperglycemia.',
      ),
    ],
    mythBuster:
        'Lipid-rich snacks delay gastric emptying via cholecystokinin release, blunting the acute glycemic rise needed in neuroglycopenia.',
    reference: 'American Diabetes Association (ADA) Standards of Care',
  ),
  'snake_bite': EmergencyScienceInfo(
    bodyMechanism:
        'Most snake venoms (hemotoxins, neurotoxins, cytotoxins) have high molecular weights and are initially absorbed via subcutaneous lymphatic channels rather than direct venous entry.',
    facts: [
      EmergencyScienceFact(
        action: 'Strict immobilization & splinting at/below heart level',
        reason:
            'Eliminates skeletal-muscle pumping of lymphatic vessels, markedly delaying systemic envenomation and neurotoxic/coagulopathic progression.',
      ),
      EmergencyScienceFact(
        action: 'Early removal of constrictive jewelry',
        reason:
            'Metalloproteinases and phospholipases cause rapid capillary leak and compartment edema, risking circumferential tourniquet ischemia.',
      ),
    ],
    mythBuster:
        'Incision and suction remove negligible venom while increasing secondary bacterial infection, tissue necrosis, and hemorrhage.',
    reference: 'WHO Guidelines for the Management of Snakebites',
  ),
  'spinal_injury': EmergencyScienceInfo(
    bodyMechanism:
        'High-energy axial loading, hyperflexion, or rotation can destabilize cervical/thoracolumbar vertebrae, risking primary mechanical cord compression or secondary ischemic cord injury.',
    facts: [
      EmergencyScienceFact(
        action: 'Manual in-line stabilization (MILS)',
        reason:
            'Maintains neutral anatomic alignment of the cervical spine, preventing bony fragments from encroaching on the spinal canal.',
      ),
      EmergencyScienceFact(
        action: 'Leaving motorcycle helmets in place',
        reason:
            'Unassisted helmet removal induces uncontrolled cervical flexion/extension; trained two-person removal is required if airway access is needed.',
      ),
    ],
    mythBuster:
        'Airway and circulation always supersede spinal precautions — hypoxic arrest occurs within minutes if CPR or airway opening is withheld.',
    reference: 'ATLS & Prehospital Spinal Motion Restriction Guidelines',
  ),
};

const Map<String, EmergencyScienceInfo> clinicalScienceDataHi = {
  'cpr_adult': EmergencyScienceInfo(
    bodyMechanism:
        'कार्डियक अरेस्ट (अक्सर वेंट्रिकुलर फाइब्रिलेशन या पल्सलेस VT से) में कार्डियक आउटपुट रुक जाता है। बिना परफ्यूजन के 4–6 मिनट में सेरेब्रल ATP समाप्त होकर अपरिवर्तनीय हाइपोक्सिक-इस्केमिक क्षति होती है।',
    facts: [
      EmergencyScienceFact(
        action: '5–6 सेमी स्टर्नल कम्प्रेशन गहराई',
        reason:
            'इंट्राथोरैसिक दबाव और स्टर्नम-रीढ़ के बीच सीधा हृदय दबाव उत्पन्न कर सामान्य कार्डियक आउटपुट का ~25–30% प्रदान करता है और कोरोनरी परफ्यूजन प्रेशर (CPP ≥15 mmHg) बनाए रखता है।',
      ),
      EmergencyScienceFact(
        action: 'पूर्ण चेस्ट रिकॉइल',
        reason:
            'निष्क्रिय विस्तार से बनने वाला नकारात्मक इंट्राथोरैसिक दबाव दाएं एट्रियम में वीनस रिटर्न और अगली सिस्टोल के लिए वेंट्रिकुलर फिलिंग बढ़ाता है।',
      ),
      EmergencyScienceFact(
        action: '100–120 दबाव/मिनट और प्रारंभिक डिफिब्रिलेशन',
        reason:
            'स्ट्रोक वॉल्यूम और डायस्टोलिक फिलिंग का संतुलन रखता है; बाइफेज़िक AED मायोकार्डियल कोशिकाओं को एक साथ डीपोलराइज कर साइनस रिदम बहाल करता है।',
      ),
    ],
    mythBuster:
        'गैर-चिकित्सकीय बचावकर्ता को कैरोटिड पल्स जांचने में समय नहीं गंवाना चाहिए — तनाव में इसकी सटीकता 55% से कम होती है।',
    reference: 'American Heart Association (AHA) & ERC Adult BLS Guidelines',
  ),
  'choking_adult': EmergencyScienceInfo(
    bodyMechanism:
        'पूर्ण सुप्राग्लोटिक या लैरिंजियल फॉरेन-बॉडी ऑब्स्ट्रक्शन (FBAO) एल्वियोलर वेंटिलेशन को रोकता है, जिससे तीव्र हाइपोक्सीमिया, हाइपरकैप्निया और हाइपोक्सिक अरेस्ट होता है।',
    facts: [
      EmergencyScienceFact(
        action: '5 इंटरस्कैपुलर बैक ब्लोज़',
        reason:
            'इंट्राथोरैसिक दबाव में अचानक उछाल और यांत्रिक कंपन उत्पन्न कर फंसी वस्तु को ढीला करता है।',
      ),
      EmergencyScienceFact(
        action: 'सबडायफ्राग्मैटिक एब्डॉमिनल थ्रस्ट्स',
        reason:
            'डायाफ्राम को तेजी से ऊपर उठाकर अवशिष्ट फेफड़ों की हवा (FRC + RV) को संपीड़ित करता है और कृत्रिम खांसी जैसा निष्कासन दबाव बनाता है।',
      ),
    ],
    mythBuster:
        'ब्लाइंड डिजिटल स्वीप वस्तु को ग्लोटिक एपर्चर में और गहराई तक धकेल सकता है।',
    reference: 'AHA & Red Cross Airway Obstruction First-Aid Protocol',
  ),
  'stroke_fast': EmergencyScienceInfo(
    bodyMechanism:
        'एक्यूट इस्केमिक स्ट्रोक (~85% मामले) सेरेब्रल धमनी को बंद कर इन्फार्क्ट कोर और उसके चारों ओर इस्केमिक पेनम्ब्रा बनाता है (~19 लाख न्यूरॉन्स/मिनट क्षति)।',
    facts: [
      EmergencyScienceFact(
        action: 'FAST न्यूरोलॉजिकल स्क्रीनिंग',
        reason:
            'मध्य या अग्र सेरेब्रल धमनी अवरोध से जुड़े फोकल मोटर कॉर्टेक्स, कॉर्टिकोबल्बार या भाषा क्षेत्र के दोषों की तुरंत पहचान करता है।',
      ),
      EmergencyScienceFact(
        action: 'Last Known Well (LKW) समय नोट करना',
        reason:
            'IV थ्रोम्बोलाइसिस (4.5 घंटे के भीतर) या मैकेनिकल थ्रोम्बेक्टॉमी (24 घंटे तक) की पात्रता निर्धारित करता है।',
      ),
    ],
    mythBuster:
        'CT स्कैन से पहले एस्पिरिन वर्जित है क्योंकि ~15% स्ट्रोक इंट्रासेरेब्रल या सबअरैक्नॉइड रक्तस्राव के कारण होते हैं।',
    reference: 'AHA/ASA Acute Ischemic Stroke Guidelines',
  ),
  'severe_bleeding': EmergencyScienceInfo(
    bodyMechanism:
        '>15–30% रक्त की हानि हाइपोवोलेमिक/हेमोरेजिक शॉक, ऊतक हाइपोपरफ्यूजन, लैक्टिक एसिडोसिस और घातक ट्रायड (हाइपोथर्मिया, एसिडोसिस, कोएगुलोपैथी) उत्पन्न करती है।',
    facts: [
      EmergencyScienceFact(
        action: 'निरंतर सीधा दबाव और हीमोस्टैटिक लेयरिंग',
        reason:
            'ट्रांसम्यूरल वैस्कुलर प्रेशर घटाकर प्राथमिक प्लेटलेट एग्रीगेशन और द्वितीयक फाइब्रिन क्रॉस-लिंकिंग को सुरक्षित रखता है।',
      ),
      EmergencyScienceFact(
        action: 'अनियंत्रित अंग रक्तस्राव में प्रॉक्सिमल टूर्निकेट',
        reason:
            'सीधे दबाव के विफल होने पर धमनी प्रवाह को अवरुद्ध करता है; समय नोट करना इस्केमिक रैबडोमायोलिसिस से बचाता है।',
      ),
    ],
    mythBuster:
        'हाइपोथर्मिया (<35°C) कोएगुलेशन कैस्केड एंजाइम्स और प्लेटलेट कार्य को बाधित करता है — शरीर को गर्म रखना आवश्यक है।',
    reference: 'ACS Stop the Bleed & Prehospital Trauma Life Support (PHTLS)',
  ),
  'anaphylaxis': EmergencyScienceInfo(
    bodyMechanism:
        'IgE-मध्यस्थ मास्ट सेल और बेसोफिल डीग्रेनुलेशन से हिस्टामाइन व ल्यूकोट्रिएन्स निकलते हैं, जिससे सिस्टमिक वैसोडायलेशन, कैपिलरी लीक (डिस्ट्रीब्यूटिव शॉक) और लैरिंजियल एडिमा होता है।',
    facts: [
      EmergencyScienceFact(
        action: 'एंटेरोलेटरल वास्टस लेटरलिस में IM एपिनेफ्रिन',
        reason:
            'α1-एड्रीनर्जिक क्रिया वैस्कुलर रेजिस्टेंस बढ़ाती है और सूजन घटाती है; β2-क्रिया ब्रोंकोडायलेशन करती है (~8 मिनट में पीक प्लाज्मा स्तर)।',
      ),
      EmergencyScienceFact(
        action: 'पैर ऊंचे कर सुपाइन स्थिति',
        reason:
            'डिस्ट्रीब्यूटिव शॉक में ऑर्थोस्टैटिक वीनस पूलिंग और "एम्प्टी वेंट्रिकल सिंड्रोम" से होने वाले कोलैप्स को रोकता है।',
      ),
    ],
    mythBuster:
        'H1/H2 एंटीहिस्टामाइन और स्टेरॉयड धीमे असर करते हैं और ब्रोंकोस्पाज़्म या शॉक को तुरंत ठीक नहीं कर सकते।',
    reference: 'World Allergy Organization (WAO) Anaphylaxis Guidelines',
  ),
  'burns_scalds': EmergencyScienceInfo(
    bodyMechanism:
        'थर्मल चोट डर्मिस में गुप्त ऊष्मा छोड़ती है, जिससे कोएगुलेशन ज़ोन के चारों ओर स्टैसिस ज़ोन में माइक्रोथ्रोम्बोसिस से घाव गहरा हो सकता है।',
    facts: [
      EmergencyScienceFact(
        action: '20 मिनट तक 12–18°C बहता पानी',
        reason:
            'अवशिष्ट डर्मल ऊष्मा को बाहर निकालता है, स्टैसिस ज़ोन में माइक्रोसर्कुलेशन बचाता है और इन्फ्लेमेटरी मीडियाटर्स कम करता है।',
      ),
      EmergencyScienceFact(
        action: 'PVC क्लिंग-फिल्म ड्रेसिंग',
        reason:
            'खुले C-फाइबर नोसिसेप्टर्स को हवा से बचाती है, वाष्पीकरण द्रव हानि कम करती है और जीवाणु अवरोध बनाती है।',
      ),
    ],
    mythBuster:
        'बर्फ तीव्र पेरिफेरल वैसोकंस्ट्रिक्शन पैदा करती है जिससे स्टैसिस ज़ोन में डर्मल इस्केमिया बढ़ जाता है।',
    reference: 'International Society for Burn Injuries (ISBI) & ANZBA',
  ),
  'seizures_fainting': EmergencyScienceInfo(
    bodyMechanism:
        'जनरलाइज्ड टॉनिक-क्लोनिक दौरा पैरोक्सिस्मल हाइपरसिंक्रोनस कॉर्टिकल डिस्चार्ज से होता है, जिसके बाद पोस्टिक्टल अवस्था में हाइपोटोनिया और मंद एयरवे रिफ्लेक्स रहते हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'पोस्टिक्टल लेटरल रिकवरी पोजिशन',
        reason:
            'चेतना मंद रहने के दौरान जीभ के पीछे गिरने और स्राव के एस्पिरेशन को रोकती है।',
      ),
      EmergencyScienceFact(
        action: 'अवधि की निगरानी (>5 मिनट सीमा)',
        reason:
            '5 मिनट से अधिक का दौरा स्टेटस एपिलेप्टिकस के मानदंड में आता है, जिसमें एक्सिटोटॉक्सिक न्यूरोनल क्षति का खतरा रहता है।',
      ),
    ],
    mythBuster:
        'मुंह में वस्तु डालना जीभ कटने से नहीं बचाता (जो टॉनिक शुरुआत में होता है) बल्कि दांत टूटने का खतरा बढ़ाता है।',
    reference: 'International League Against Epilepsy (ILAE) & Epilepsy Foundation',
  ),
  'heart_attack_signs': EmergencyScienceInfo(
    bodyMechanism:
        'एक्यूट कोरोनरी सिंड्रोम (ACS) एथेरोस्क्लेरोटिक प्लाक फटने और इंट्राकोरोनरी थ्रोम्बस बनने से होता है, जिससे सबएंडोकार्डियम से बाहर की ओर मायोकार्डियल इस्केमिया बढ़ता है।',
    facts: [
      EmergencyScienceFact(
        action: 'सेमी-फाउलर स्थिति में शारीरिक विश्राम',
        reason:
            'सिम्पैथेटिक टोन, हृदय गति और अवरुद्ध धमनी के आगे मायोकार्डियल ऑक्सीजन खपत (MVO2) को कम करता है।',
      ),
      EmergencyScienceFact(
        action: 'चबाई हुई नॉन-एंटरिक एस्पिरिन (300–325 mg)',
        reason:
            'बकल अवशोषण द्वारा प्लेटलेट्स में COX-1 का अपरिवर्तनीय अवरोध कर थ्रोम्बोक्सेन A2 मध्यस्थ थक्का वृद्धि रोकती है।',
      ),
    ],
    mythBuster:
        'डायबिटिक ऑटोनॉमिक न्यूरोपैथी और महिलाओं में एंजाइना अक्सर एपिगैस्ट्रिक बेचैनी, डिस्पनिया या पसीने के रूप में दिखता है।',
    reference: 'AHA/ACC Acute Coronary Syndromes Guidelines',
  ),
  'infant_choking_cpr': EmergencyScienceInfo(
    bodyMechanism:
        'शिशुओं की श्वासनली संकरी होती है, ऑक्सीपुट बड़ा होता है और कॉस्टल मार्जिन के नीचे लिवर अपेक्षाकृत असुरक्षित होता है।',
    facts: [
      EmergencyScienceFact(
        action: 'हेड-डाउन प्रोन पोजिशन में बैक ब्लोज़',
        reason:
            'सबग्लोटिक अवरोध को हटाने के लिए गुरुत्वाकर्षण और थोरैसिक दबाव उछाल का संयोजन करता है।',
      ),
      EmergencyScienceFact(
        action: 'पेट के बजाय 2-उंगली स्टर्नल थ्रस्ट्स',
        reason:
            'लिवर या स्प्लीन लैसरेशन से बचाते हुए पर्याप्त इंट्राथोरैसिक निष्कासन दबाव उत्पन्न करता है।',
      ),
    ],
    mythBuster:
        'शिशुओं में कार्डियक अरेस्ट मुख्यतः एस्फिक्सियल (श्वसन जनित) होता है — दबाव के साथ वेंटिलेशन अत्यंत आवश्यक है।',
    reference: 'AHA Pediatric Basic Life Support (PBLS) Guidelines',
  ),
  'asthma_attack': EmergencyScienceInfo(
    bodyMechanism:
        'तीव्र अस्थमा में ब्रोंकोस्पाज़्म, म्यूकोसल एडिमा और म्यूकस प्लगिंग से एक्सपिरेटरी फ्लो लिमिटेशन, डायनामिक हाइपरइन्फ्लेशन और V/Q मिसमैच होता है।',
    facts: [
      EmergencyScienceFact(
        action: 'सीधी ट्राइपॉड मुद्रा',
        reason:
            'सहायक श्वसन मांसपेशियों (स्टर्नोक्लीडोमैस्टॉइड, स्केलीन) को सक्रिय कर डायाफ्रामिक गति को बेहतर बनाती है।',
      ),
      EmergencyScienceFact(
        action: 'टाइट्रेटेड शॉर्ट-एक्टिंग β2-एगोनिस्ट (SABA) पफ',
        reason:
            'ब्रोंकियल स्मूथ मसल β2 रिसेप्टर्स को सक्रिय कर cAMP बढ़ाती है और ब्रोंकोडायलेशन करती है।',
      ),
    ],
    mythBuster:
        'इन्हेल्ड कॉर्टिकोस्टेरॉयड्स (ICS) जीनोमिक मार्ग से दिनों में सूजन घटाते हैं और तीव्र अटैक में ब्रोंकोडायलेशन नहीं करते।',
    reference: 'GINA (Global Initiative for Asthma) Acute Care Guidelines',
  ),
  'diabetic_hypoglycemia': EmergencyScienceInfo(
    bodyMechanism:
        'मस्तिष्क ऊतक में ग्लाइकोजन भंडार नगण्य होते हैं। <70 mg/dL स्तर पर ऑटोनॉमिक काउंटर-रेगुलेशन (एपिनेफ्रिन) और <54 mg/dL पर न्यूरोग्लाइकोपेनिया होता है।',
    facts: [
      EmergencyScienceFact(
        action: '15 ग्राम रैपिड-एक्टिंग सरल कार्बोहाइड्रेट',
        reason:
            'मोनो/डाइसैकेराइड SGLT1/GLUT2 के माध्यम से 10–15 मिनट में तेजी से अवशोषित होकर यूग्लाइसीमिया बहाल करते हैं।',
      ),
      EmergencyScienceFact(
        action: '15 मिनट का पुनर्मूल्यांकन अंतराल',
        reason:
            'गैस्ट्रिक एम्प्टिंग और कैपिलरी-वीनस संतुलन समय का ध्यान रखकर रिबाउंड हाइपरग्लाइसीमिया से बचाता है।',
      ),
    ],
    mythBuster:
        'लिपिड-युक्त खाद्य पदार्थ कोलेसिस्टोकाइनिन स्राव के माध्यम से गैस्ट्रिक एम्प्टिंग को धीमा कर ग्लाइसेमिक वृद्धि रोकते हैं।',
    reference: 'American Diabetes Association (ADA) Standards of Care',
  ),
  'snake_bite': EmergencyScienceInfo(
    bodyMechanism:
        'अधिकांश सर्प विष (हीमोटॉक्सिन, न्यूरोटॉक्सिन) उच्च आणविक भार वाले होते हैं और पहले सबक्यूटेनियस लिम्फैटिक चैनलों से अवशोषित होते हैं।',
    facts: [
      EmergencyScienceFact(
        action: 'अंग का पूर्ण स्थिरीकरण और स्प्लिंटिंग',
        reason:
            'कंकाल मांसपेशियों द्वारा लिम्फैटिक पंपिंग को रोककर सिस्टमिक एनवेनोमेशन को काफी धीमा करता है।',
      ),
      EmergencyScienceFact(
        action: 'कसे हुए आभूषण जल्दी हटाना',
        reason:
            'मेटैलोप्रोटीनेज़ और फॉस्फोलाइपेज़ तेजी से कैपिलरी लीक और कम्पार्टमेंट एडिमा उत्पन्न करते हैं।',
      ),
    ],
    mythBuster:
        'चीरा लगाने और चूसने से नगण्य विष निकलता है जबकि द्वितीयक जीवाणु संक्रमण और ऊतक नेक्रोसिस बढ़ता है।',
    reference: 'WHO Guidelines for the Management of Snakebites',
  ),
  'spinal_injury': EmergencyScienceInfo(
    bodyMechanism:
        'उच्च-ऊर्जा एक्सियल लोडिंग, हाइपरफ्लेक्सन या रोटेशन सर्वाइकल/थोराकोलम्बर कशेरुकाओं को अस्थिर कर मैकेनिकल या इस्केमिक कॉर्ड इंजरी पैदा कर सकता है।',
    facts: [
      EmergencyScienceFact(
        action: 'मैनुअल इन-लाइन स्टेबिलाइजेशन (MILS)',
        reason:
            'सर्वाइकल स्पाइन का तटस्थ संरेखण बनाए रखकर हड्डी के टुकड़ों को स्पाइनल कैनाल में जाने से रोकता है।',
      ),
      EmergencyScienceFact(
        action: 'मोटरसाइकिल हेलमेट न उतारना',
        reason:
            'अप्रशिक्षित हेलमेट हटाने से अनियंत्रित सर्वाइकल फ्लेक्सन/एक्सटेंशन होता है।',
      ),
    ],
    mythBuster:
        'एयरवे और सर्कुलेशन हमेशा स्पाइनल प्रिकॉशन से ऊपर हैं — CPR रोकने पर मिनटों में हाइपोक्सिक मृत्यु हो सकती है।',
    reference: 'ATLS & Prehospital Spinal Motion Restriction Guidelines',
  ),
};
