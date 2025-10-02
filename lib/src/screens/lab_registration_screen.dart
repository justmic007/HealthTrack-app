import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/labs.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class LabRegistrationScreen extends StatefulWidget {
  const LabRegistrationScreen({super.key});

  @override
  State<LabRegistrationScreen> createState() => _LabRegistrationScreenState();
}

class _LabRegistrationScreenState extends State<LabRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Lab facility fields
  final _labNameController = TextEditingController();
  final _cliaNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _labPhoneController = TextEditingController();
  final _labEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  
  // First lab user fields
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Facility Registration'),
        backgroundColor: AppTheme.lavenderAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Register Your Lab Facility',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lavenderAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Register your clinical laboratory to upload patient test results.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // CLIA Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.orange[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CLIA certification required. Your lab facility will be reviewed by our admin team before activation.',
                        style: TextStyle(color: Colors.orange[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Lab Facility Information
              Text(
                'Lab Facility Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lavenderAccent,
                ),
              ),
              const SizedBox(height: 16),

              // Lab Name
              TextFormField(
                controller: _labNameController,
                decoration: InputDecoration(
                  labelText: 'Lab Facility Name',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter lab facility name';
                  }
                  if (value.trim().length < 2) {
                    return 'Lab name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CLIA Number
              TextFormField(
                controller: _cliaNumberController,
                decoration: InputDecoration(
                  labelText: 'CLIA Number',
                  prefixIcon: const Icon(Icons.verified_user),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'Clinical Laboratory Improvement Amendments number',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter CLIA number';
                  }
                  if (value.trim().length < 10) {
                    return 'CLIA number must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Lab Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter lab address';
                  }
                  if (value.trim().length < 10) {
                    return 'Address must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Lab Phone
              TextFormField(
                controller: _labPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Lab Phone Number (Optional)',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Lab Email
              TextFormField(
                controller: _labEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Lab Email Address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lab email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Lab Website (Optional)',
                  prefixIcon: const Icon(Icons.web),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // First Lab User Information
              Text(
                'First Lab User Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lavenderAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will be the primary administrator account for your lab.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // User Name
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Administrator Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter administrator name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // User Email
              TextFormField(
                controller: _userEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Administrator Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter administrator email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerLab,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lavenderAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Register Lab Facility',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerLab() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final labData = LabRegistrationRequest(
        labName: _labNameController.text.trim(),
        cliaNumber: _cliaNumberController.text.trim(),
        address: _addressController.text.trim(),
        phone: _labPhoneController.text.trim().isEmpty ? null : _labPhoneController.text.trim(),
        labEmail: _labEmailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        userName: _userNameController.text.trim(),
        userEmail: _userEmailController.text.trim(),
        password: _passwordController.text,
      );

      await context.read<AuthProvider>().registerLab(labData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab facility registered! Awaiting admin approval.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _cliaNumberController.dispose();
    _addressController.dispose();
    _labPhoneController.dispose();
    _labEmailController.dispose();
    _websiteController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}