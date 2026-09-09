import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/medical_vault_repository.dart';

class AddBiomarkerBottomSheet extends ConsumerStatefulWidget {
  final Function(BiomarkerModel) onSave;

  const AddBiomarkerBottomSheet({super.key, required this.onSave});

  static Future<void> show(
    BuildContext context,
    Function(BiomarkerModel) onSave,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddBiomarkerBottomSheet(onSave: onSave),
      ),
    );
  }

  @override
  ConsumerState<AddBiomarkerBottomSheet> createState() =>
      _AddBiomarkerBottomSheetState();
}

class _AddBiomarkerBottomSheetState
    extends ConsumerState<AddBiomarkerBottomSheet> {
  bool _isNumeric = true;
  bool _isAbnormal = false;

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();

  final Map<String, String?> _localCommonBiomarkers = {
    // Vitals
    'Heart Rate': 'bpm',
    'Blood Pressure': 'mmHg',
    'Blood Pressure (BP)': 'mmHg',
    'BP (Systolic)': 'mmHg',
    'BP (Diastolic)': 'mmHg',
    'Blood Pressure (Systolic)': 'mmHg',
    'Blood Pressure (Diastolic)': 'mmHg',
    'Weight': 'kg',
    'Height': 'cm',
    'BMI': 'kg/m²',
    'Temperature': '°F',
    'Oxygen Saturation (SpO2)': '%',
    'Respiratory Rate': 'breaths/min',

    // Complete Blood Count (CBC)
    'Hemoglobin': 'g/dL',
    'Hematocrit': '%',
    'Red Blood Cell Count (RBC)': 'millions/µL',
    'White Blood Cell Count (WBC)': 'cells/mcL',
    'Platelet Count': 'thousands/µL',
    'Mean Corpuscular Volume (MCV)': 'fL',
    'Mean Corpuscular Hemoglobin (MCH)': 'pg',
    'Mean Corpuscular Hemoglobin Concentration (MCHC)': 'g/dL',
    'Red Cell Distribution Width (RDW)': '%',
    'Neutrophils': '%',
    'Lymphocytes': '%',
    'Monocytes': '%',
    'Eosinophils': '%',
    'Basophils': '%',

    // Comprehensive Metabolic Panel (CMP)
    'Glucose': 'mg/dL',
    'Glucose (Fasting)': 'mg/dL',
    'Glucose (Postprandial)': 'mg/dL',
    'Calcium': 'mg/dL',
    'Sodium': 'mEq/L',
    'Potassium': 'mEq/L',
    'Chloride': 'mEq/L',
    'Carbon Dioxide (CO2)': 'mEq/L',
    'Blood Urea Nitrogen (BUN)': 'mg/dL',
    'Creatinine': 'mg/dL',
    'BUN/Creatinine Ratio': null,
    'Estimated Glomerular Filtration Rate (eGFR)': 'mL/min/1.73m²',

    // Liver Function Test (LFT)
    'Alkaline Phosphatase (ALP)': 'U/L',
    'Alanine Aminotransferase (ALT/SGPT)': 'U/L',
    'Aspartate Aminotransferase (AST/SGOT)': 'U/L',
    'Total Bilirubin': 'mg/dL',
    'Direct Bilirubin': 'mg/dL',
    'Indirect Bilirubin': 'mg/dL',
    'Total Protein': 'g/dL',
    'Albumin': 'g/dL',
    'Globulin': 'g/dL',
    'Albumin/Globulin (A/G) Ratio': null,
    'Gamma-Glutamyl Transferase (GGT)': 'U/L',

    // Lipid Profile
    'Total Cholesterol': 'mg/dL',
    'High-Density Lipoprotein (HDL)': 'mg/dL',
    'Low-Density Lipoprotein (LDL)': 'mg/dL',
    'Triglycerides': 'mg/dL',
    'Very Low-Density Lipoprotein (VLDL)': 'mg/dL',
    'Cholesterol/HDL Ratio': null,

    // Thyroid Profile
    'Thyroid Stimulating Hormone (TSH)': 'mIU/L',
    'Free T4': 'ng/dL',
    'Free T3': 'pg/mL',
    'Total T4': 'µg/dL',
    'Total T3': 'ng/dL',

    // Diabetic Screen
    'Hemoglobin A1C (HbA1c)': '%',
    'Average Blood Glucose (eAG)': 'mg/dL',
    'Fasting Insulin': 'µIU/mL',

    // Iron Studies & Anemia
    'Iron': 'µg/dL',
    'Total Iron Binding Capacity (TIBC)': 'µg/dL',
    'Ferritin': 'ng/mL',
    'Transferrin': 'mg/dL',
    'Transferrin Saturation': '%',

    // Vitamins & Minerals
    'Vitamin B12': 'pg/mL',
    'Vitamin D, 25-Hydroxy': 'ng/mL',
    'Folate (Folic Acid)': 'ng/mL',
    'Magnesium': 'mg/dL',
    'Phosphorus': 'mg/dL',

    // Inflammatory & Cardiac Markers
    'C-Reactive Protein (hs-CRP)': 'mg/L',
    'Erythrocyte Sedimentation Rate (ESR)': 'mm/hr',
    'Homocysteine': 'µmol/L',
    'Uric Acid': 'mg/dL',
    'Creatine Kinase (CK)': 'U/L',

    // Urinalysis
    'Urine Specific Gravity': null,
    'Urine pH': null,
    'Urine Protein': 'mg/dL',
    'Urine Glucose': 'mg/dL',
    'Urine Ketones': 'mg/dL',
    'Urine Bilirubin': null,
    'Urine Urobilinogen': 'mg/dL',
    'Urine Leukocytes': 'cells/HPF',
    'Urine Nitrite': null,
    'Urine RBC': 'cells/HPF',

    // Common Text/Imaging Findings
    'Ultrasound Findings': null,
    'X-Ray Findings': null,
    'MRI Impressions': null,
    'CT Scan Impressions': null,
    'ECG/EKG Notes': null,
  };

  Future<Iterable<String>> _searchBiomarkers(String query) async {
    if (query.isEmpty) return const Iterable<String>.empty();

    final queryLower = query.toLowerCase();

    // 1. Instant local search (searching keys of the map)
    final localResults = _localCommonBiomarkers.keys
        .where((b) => b.toLowerCase().contains(queryLower))
        .toList();

    // If it's a very short query and we have local hits, just return them to be fast
    if (query.length < 3 && localResults.isNotEmpty) {
      return localResults;
    }

    // 2. Deep search via backend
    try {
      final repo = ref.read(medicalVaultRepositoryProvider);
      final remoteResults = await repo.searchBiomarkerDictionary(query);

      // Combine and deduplicate, keeping local hits on top
      final combined = <String>{...localResults, ...remoteResults};
      return combined.take(15);
    } catch (_) {
      return localResults;
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final valText = _valueController.text.trim();

    double? numVal;
    String? textVal;

    if (_isNumeric) {
      numVal = double.tryParse(valText);
      if (numVal == null) return;
    } else {
      textVal = valText;
      if (textVal.isEmpty) return;
    }

    final newMetric = BiomarkerModel(
      id: const Uuid().v4(),
      rawName: name,
      resultType: _isNumeric ? 'numeric' : 'text',
      valueNumeric: numVal,
      valueText: textVal,
      rawUnit: _isNumeric && _unitController.text.trim().isNotEmpty
          ? _unitController.text.trim()
          : null,
      isAbnormal: _isAbnormal,
      aiPredictedStandardName: name,
    );

    widget.onSave(newMetric);
    Navigator.of(context).pop();
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? minLines,
    TextStyle? textStyle,
    FocusNode? focusNode,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      style: textStyle ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Metric',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              // Minimal Toggle
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _isNumeric = true;
                        _valueController.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isNumeric
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Number',
                          style: TextStyle(
                            color: _isNumeric
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: _isNumeric
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _isNumeric = false;
                        _valueController.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: !_isNumeric
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Text',
                          style: TextStyle(
                            color: !_isNumeric
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: !_isNumeric
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          RawAutocomplete<String>(
            textEditingController: _nameController,
            optionsBuilder: (TextEditingValue textEditingValue) {
              return _searchBiomarkers(textEditingValue.text);
            },
            onSelected: (String selection) {
              _nameController.text = selection;
              final unit = _localCommonBiomarkers[selection];
              if (unit != null) {
                _unitController.text = unit;
              }
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  return _buildMinimalTextField(
                    controller: controller,
                    focusNode: focusNode,
                    hint: 'Metric name (e.g., Hemoglobin)',
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest,
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth:
                          MediaQuery.of(context).size.width -
                          64, // match padding
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text(
                              option,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          if (_isNumeric)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildMinimalTextField(
                    controller: _valueController,
                    hint: 'Value (e.g., 14.5)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildMinimalTextField(
                    controller: _unitController,
                    hint: 'Unit (g/dL)',
                  ),
                ),
              ],
            )
          else
            _buildMinimalTextField(
              controller: _valueController,
              hint: 'Enter finding or note...',
              maxLines: 5,
              minLines: 2,
            ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mark as Abnormal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch.adaptive(
                value: _isAbnormal,
                activeTrackColor: theme.colorScheme.error.withValues(
                  alpha: 0.5,
                ),
                activeThumbColor: theme.colorScheme.error,
                onChanged: (val) => setState(() => _isAbnormal = val),
              ),
            ],
          ),

          const SizedBox(height: 32),

          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ), // fully rounded
            ),
            child: const Text(
              'Save Metric',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
