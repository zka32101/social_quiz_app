import 'package:flutter/material.dart';

/// Collapsible "図でみる" panel that wraps a diagram widget. Collapsed by
/// default so it doesn't push the first question off-screen, but easy for
/// kids to reopen at any point during the quiz to check the picture again.
class DiagramPanel extends StatefulWidget {
  final String title;
  final Color color;
  final Widget diagram;
  final bool initiallyExpanded;

  const DiagramPanel({
    super.key,
    required this.title,
    required this.color,
    required this.diagram,
    this.initiallyExpanded = true,
  });

  @override
  State<DiagramPanel> createState() => _DiagramPanelState();
}

class _DiagramPanelState extends State<DiagramPanel> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: widget.color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: widget.color,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: widget.diagram,
            ),
        ],
      ),
    );
  }
}
