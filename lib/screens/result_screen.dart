// lib/screens/result_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Shows diagnosis results — disease name,
// confidence, severity and treatment.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/diagnosis_service.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> diagnosisData;
  final File imageFile;

  const ResultScreen({
    super.key,
    required this.diagnosisData,
    required this.imageFile,
  });

  // Get color based on severity level
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':   return const Color(0xFF922B21);
      case 'medium': return const Color(0xFFD35400);
      case 'low':    return const Color(0xFFD4AC0D);
      default:       return const Color(0xFF1E8449); // none = healthy
    }
  }

  // Get icon based on severity
  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':   return Icons.warning_rounded;
      case 'medium': return Icons.info_rounded;
      case 'low':    return Icons.info_outline;
      default:       return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String friendlyName = diagnosisData['friendly_name'] ?? 'Unknown';
    final String confidence   = diagnosisData['confidence']?.toString() ?? '0';
    final String treatment    = diagnosisData['treatment'] ?? '';
    final String severity     = diagnosisData['severity'] ?? 'none';
    final int diagnosisId     = diagnosisData['id'] ?? 0;
    final bool hasWarning     = diagnosisData['warning'] != null;
    final Color severityColor = _getSeverityColor(severity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Leaf image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                imageFile,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Low confidence warning
            if (hasWarning) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9E7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF39C12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber,
                        color: Color(0xFFF39C12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        diagnosisData['warning'],
                        style: const TextStyle(
                          color: Color(0xFF7D6608),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Disease name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: severityColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getSeverityIcon(severity),
                          color: severityColor, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Diagnosis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    friendlyName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Confidence bar
                  Row(
                    children: [
                      const Text('Confidence: ',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(
                        '$confidence%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: double.parse(confidence) / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: severityColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Severity badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Severity: ${severity.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Treatment section
            const Text(
              'Recommended Treatment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE7E0)),
              ),
              child: Text(
                treatment,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feedback buttons
            const Text(
              'Was this diagnosis accurate?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await DiagnosisService.submitFeedback(
                        diagnosisId: diagnosisId,
                        wasAccurate: true,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for your feedback!'),
                          backgroundColor: Color(0xFF1E8449),
                        ),
                      );
                    },
                    icon: const Icon(Icons.thumb_up_outlined,
                        color: Color(0xFF1E8449)),
                    label: const Text('Yes, correct',
                        style: TextStyle(color: Color(0xFF1E8449))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E8449)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await DiagnosisService.submitFeedback(
                        diagnosisId: diagnosisId,
                        wasAccurate: false,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanks! We will improve.'),
                          backgroundColor: Color(0xFFD35400),
                        ),
                      );
                    },
                    icon: const Icon(Icons.thumb_down_outlined,
                        color: Color(0xFFD35400)),
                    label: const Text('No, wrong',
                        style: TextStyle(color: Color(0xFFD35400))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD35400)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Back to home button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5276),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Diagnose Another Crop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}