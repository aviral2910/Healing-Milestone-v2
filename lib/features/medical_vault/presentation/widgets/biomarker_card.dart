import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';

class BiomarkerCard extends StatefulWidget {
  final BiomarkerModel biomarker;
  final bool compact;
  final bool isEditing;
  final VoidCallback? onEditTap;
  final void Function(String)? onSave;

  const BiomarkerCard({
    super.key,
    required this.biomarker,
    this.compact = false,
    this.isEditing = false,
    this.onEditTap,
    this.onSave,
  });

  @override
  State<BiomarkerCard> createState() => _BiomarkerCardState();
}

class _BiomarkerCardState extends State<BiomarkerCard> {
  late TextEditingController _editController;
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final displayValue =
        widget.biomarker.valueNumeric?.toString() ??
        widget.biomarker.valueText ??
        '';
    _editController = TextEditingController(text: displayValue);
  }

  @override
  void didUpdateWidget(covariant BiomarkerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      final displayValue =
          widget.biomarker.valueNumeric?.toString() ??
          widget.biomarker.valueText ??
          '';
      _editController.text = displayValue;
      Future.delayed(const Duration(milliseconds: 50), () {
        _editFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.onSave != null) {
      widget.onSave!(_editController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.biomarker;
    final isAbnormal = b.isAbnormal == true;
    final isTextResult = b.resultType != 'numeric';
    final displayValue = b.valueNumeric?.toString() ?? b.valueText ?? '-';
    final unit = b.rawUnit ?? '';

    final padding = widget.compact
        ? const EdgeInsets.all(12)
        : const EdgeInsets.all(16);
    final iconSize = widget.compact ? 18.0 : 22.0;
    final titleFontSize = widget.compact ? 14.0 : 15.0;
    final valueFontSize = widget.compact ? 16.0 : 18.0;
    final unitFontSize = widget.compact ? 11.0 : 12.0;

    Widget buildIcon() {
      return Container(
        padding: EdgeInsets.all(widget.compact ? 8 : 10),
        decoration: BoxDecoration(
          color: isAbnormal
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(widget.compact ? 10 : 12),
        ),
        child: Icon(
          isAbnormal ? Icons.warning_amber_rounded : Icons.science_rounded,
          color: isAbnormal ? Colors.red : theme.colorScheme.primary,
          size: iconSize,
        ),
      );
    }

    Widget buildName() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            b.aiPredictedStandardName ?? b.rawName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (b.aiPredictedStandardName != null &&
              b.aiPredictedStandardName != b.rawName)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                b.rawName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }

    Widget buildValueOrEdit() {
      if (widget.isEditing) {
        return Row(
          mainAxisAlignment: isTextResult
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            Expanded(
              flex: isTextResult ? 1 : 0,
              child: SizedBox(
                width: isTextResult ? null : 100,
                child: TextField(
                  controller: _editController,
                  focusNode: _editFocusNode,
                  keyboardType: isTextResult
                      ? TextInputType.multiline
                      : const TextInputType.numberWithOptions(decimal: true),
                  maxLines: isTextResult ? null : 1,
                  textAlign: isTextResult ? TextAlign.left : TextAlign.right,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isTextResult
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 20),
              ),
            ),
          ],
        );
      }

      if (isTextResult) {
        final lines = displayValue
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList();
        final hasBullets =
            lines.length > 1 ||
            displayValue.trim().startsWith('-') ||
            RegExp(r'^\d+\.\s').hasMatch(displayValue.trim());

        if (hasBullets) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.map((line) {
              var cleanLine = line.trim();
              if (cleanLine.startsWith('- ') || cleanLine.startsWith('* ')) {
                cleanLine = cleanLine.substring(2).trim();
              } else if (RegExp(r'^\d+\.\s').hasMatch(cleanLine)) {
                cleanLine = cleanLine
                    .replaceFirst(RegExp(r'^\d+\.\s'), '')
                    .trim();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, right: 10.0),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        cleanLine,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        return Text(
          displayValue,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayValue,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: valueFontSize,
              color: isAbnormal ? Colors.red : theme.colorScheme.primary,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: unitFontSize,
              ),
            ),
        ],
      );
    }

    return InkWell(
      onTap: widget.isEditing ? null : widget.onEditTap,
      borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
      child: Container(
        margin: widget.compact
            ? const EdgeInsets.only(bottom: 10)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
          border: Border.all(
            color: isAbnormal
                ? Colors.red.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isAbnormal
                  ? Colors.red.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: widget.compact ? 6 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: padding,
        child: isTextResult
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildIcon(),
                      const SizedBox(width: 16),
                      Expanded(child: buildName()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buildValueOrEdit(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildIcon(),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: buildName()),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: buildValueOrEdit(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
