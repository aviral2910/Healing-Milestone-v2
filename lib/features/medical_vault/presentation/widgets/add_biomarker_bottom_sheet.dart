import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';
import 'package:uuid/uuid.dart';

class AddBiomarkerBottomSheet extends StatefulWidget {
  final Function(BiomarkerModel) onSave;

  const AddBiomarkerBottomSheet({super.key, required this.onSave});

  static Future<void> show(BuildContext context, Function(BiomarkerModel) onSave) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddBiomarkerBottomSheet(onSave: onSave),
      ),
    );
  }

  @override
  State<AddBiomarkerBottomSheet> createState() => _AddBiomarkerBottomSheetState();
}

class _AddBiomarkerBottomSheetState extends State<AddBiomarkerBottomSheet> {
  bool _isNumeric = true;
  bool _isAbnormal = false;

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final valText = _valueController.text.trim();

    double? numVal;
    String? textVal;

    if (_isNumeric) {
      numVal = double.tryParse(valText);
      if (numVal == null) return; // Invalid number
    } else {
      textVal = valText;
      if (textVal.isEmpty) return;
    }

    final newMetric = BiomarkerModel(
      id: const Uuid().v4(), // Temporary ID until backend assigns one, or backend might use it
      rawName: name,
      resultType: _isNumeric ? 'numeric' : 'text',
      valueNumeric: numVal,
      valueText: textVal,
      rawUnit: _isNumeric && _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : null,
      isAbnormal: _isAbnormal,
      aiPredictedStandardName: name, // For display
    );

    widget.onSave(newMetric);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Metric Manually',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Toggle Numeric vs Text
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Numeric (e.g. Blood Test)')),
              ButtonSegment(value: false, label: Text('Text (e.g. Ultrasound)')),
            ],
            selected: {_isNumeric},
            onSelectionChanged: (val) {
              setState(() {
                _isNumeric = val.first;
                _valueController.clear();
              });
            },
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Metric Name',
              hintText: 'e.g. Hemoglobin, Liver Size',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          if (_isNumeric)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      hintText: 'e.g. 14.5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit (Optional)',
                      hintText: 'g/dL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            )
          else
            TextField(
              controller: _valueController,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Findings / Notes',
                hintText: 'Type or paste the findings here...',
                border: OutlineInputBorder(),
              ),
            ),
            
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Mark as Abnormal'),
            subtitle: const Text('Highlight this metric in red'),
            value: _isAbnormal,
            activeColor: theme.colorScheme.error,
            onChanged: (val) => setState(() => _isAbnormal = val),
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 32),
          
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Metric', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
