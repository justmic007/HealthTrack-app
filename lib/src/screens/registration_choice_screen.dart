import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'patient_registration_screen.dart';
import 'caregiver_registration_screen.dart';
import 'lab_registration_screen.dart';

class RegistrationChoiceScreen extends StatelessWidget {
  const RegistrationChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join HealthTrack'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Text(
              'Choose Your Account Type',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lavenderAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Select the option that best describes you',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Patient Option
            _buildOptionCard(
              context,
              title: 'I am a Patient',
              subtitle: 'Manage my test results and health data',
              icon: Icons.person,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientRegistrationScreen()),
              ),
            ),
            const SizedBox(height: 24),

            // Caregiver Option
            _buildOptionCard(
              context,
              title: 'I am a Healthcare Professional',
              subtitle: 'View shared patient results (requires license verification)',
              icon: Icons.medical_services,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CaregiverRegistrationScreen()),
              ),
            ),
            const SizedBox(height: 24),

            // Lab Option
            _buildOptionCard(
              context,
              title: 'I represent a Lab Facility',
              subtitle: 'Upload test results for patients (requires CLIA certification)',
              icon: Icons.science,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LabRegistrationScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}