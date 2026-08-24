import 'package:flutter/material.dart';

import '../../../../core/security/hash_helper.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../settings/data/models/school_profile_model.dart';
import '../../data/auth_service.dart';

class InitialSetupPage extends StatefulWidget {
  const InitialSetupPage({super.key});

  @override
  State<InitialSetupPage> createState() => _InitialSetupPageState();
}

class _InitialSetupPageState extends State<InitialSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _schoolNameController = TextEditingController();
  final _governorateController = TextEditingController();
  final _directorNameController = TextEditingController();
  final _secretaryNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _schoolNameController.dispose();
    _governorateController.dispose();
    _directorNameController.dispose();
    _secretaryNameController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _authService.completeInitialSetup(
        username: _usernameController.text,
        fullName: _fullNameController.text,
        password: _passwordController.text,
        schoolProfile: SchoolProfileModel(
          schoolName: _schoolNameController.text.trim(),
          governorate: _governorateController.text.trim(),
          directorName: _directorNameController.text.trim(),
          secretaryName: _secretaryNameController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إكمال الإعداد: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            size: 56,
                            color: Color(0xFF1E3A8A),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'إعداد أمانة السر المدرسية',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'أنشئ حساب المدير وعرّف بيانات المدرسة. لا توجد حسابات افتراضية في التطبيق.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'بيانات المدرسة',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _requiredField(_schoolNameController, 'اسم المدرسة'),
                          const SizedBox(height: 12),
                          _requiredField(_governorateController, 'المحافظة'),
                          const SizedBox(height: 12),
                          _requiredField(_directorNameController, 'اسم المدير'),
                          const SizedBox(height: 12),
                          _requiredField(
                              _secretaryNameController, 'اسم أمين السر'),
                          const SizedBox(height: 24),
                          Text(
                            'حساب المدير',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _requiredField(_fullNameController, 'الاسم الكامل'),
                          const SizedBox(height: 12),
                          _requiredField(_usernameController, 'اسم المستخدم'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'كلمة المرور',
                              helperText:
                                  '12 محرفًا على الأقل، من 3 أنواع من الأحرف أو الأرقام أو الرموز.',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'كلمة المرور مطلوبة.';
                              }
                              return HashHelper.isValidNewPassword(value)
                                  ? null
                                  : HashHelper.newPasswordValidationMessage();
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmedPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value != _passwordController.text
                                    ? 'كلمتا المرور غير متطابقتين.'
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _completeSetup,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              _isSaving
                                  ? 'جارٍ حفظ الإعداد...'
                                  : 'إكمال الإعداد',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requiredField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label مطلوب.' : null,
    );
  }
}
