import 'package:flutter/material.dart';

/// A single step of a [ProcessFlowDiagram], e.g. "5月：田植え".
class ProcessStep {
  final String label;
  final String detail;
  final IconData icon;

  const ProcessStep({
    required this.label,
    required this.detail,
    required this.icon,
  });
}

/// Renders an ordered sequence of steps as icon+label chips connected by
/// arrows, e.g. the yearly cycle of rice farming (稲作の一年). Uses [Wrap]
/// so the sequence flows onto multiple lines on narrow screens instead of
/// overflowing — no fixed-width assumptions about the device.
class ProcessFlowDiagram extends StatelessWidget {
  final List<ProcessStep> steps;
  final Color color;

  const ProcessFlowDiagram({
    super.key,
    required this.steps,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepChip(step: steps[i], color: color),
          if (i != steps.length - 1)
            Icon(Icons.arrow_forward, color: color.withOpacity(0.6), size: 18),
        ],
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final ProcessStep step;
  final Color color;

  const _StepChip({required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(step.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            step.detail,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}
