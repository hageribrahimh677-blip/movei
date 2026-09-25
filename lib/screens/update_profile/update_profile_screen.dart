import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  static const routeName = '/update-profile';

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _avatarOptions = List.generate(
    9,
        (index) => 'avatar_${index + 1}.png',
  );

  String? _selectedAvatar;
  bool _isLoading = false;
  bool _isSaving = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentData() async {
    final user = _currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (mounted) {
      setState(() {
        _nameController.text = data?['name'] as String? ?? '';
        _phoneController.text = data?['phone'] as String? ?? '';
        _selectedAvatar = data?['avatar'] as String?;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdate() async {
    final user = _currentUser;
    if (user == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'avatar': _selectedAvatar,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اتحدثت بياناتك بنجاح')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حصل خطأ، حاولي تاني'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final user = _currentUser;
    if (user?.email == null) return;

    try {
      await _authService.resetPassword(email: user!.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('بعتنالك لينك تغيير الباسورد على إيميلك')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حصل خطأ، حاولي تاني'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('حذف الحساب',
            style: TextStyle(color: AppColors.textWhite)),
        content: const Text(
          'الخطوة دي مش هترجع، هيتمسح حسابك وكل بياناتك نهائيًا. متأكدة؟',
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('لأ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('أيوة، احذفي الحساب',
                style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = _currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'الخطوة دي حساسة، لازم تسجلي خروج ودخول تاني قبل ما تحذفي الحساب'),
              backgroundColor: AppColors.primaryRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حصل خطأ، حاولي تاني'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Update Profile'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
            color: AppColors.primaryYellow),
      )
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.surface,
                  backgroundImage: _selectedAvatar != null
                      ? AssetImage('assets/avatars/$_selectedAvatar')
                      : null,
                  child: _selectedAvatar == null
                      ? const Icon(Icons.person,
                      size: 45, color: AppColors.textGrey)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person_outline,
                      color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined,
                      color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'اختاري صورة',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final avatarName = _avatarOptions[index];
                  final isSelected = _selectedAvatar == avatarName;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedAvatar = avatarName),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryYellow
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/avatars/$avatarName',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _handleUpdate,
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : const Text('Update Data'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _handleResetPassword,
                child: const Text('Reset Password'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _handleDeleteAccount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  side:
                  const BorderSide(color: AppColors.primaryRed),
                ),
                child: const Text('Delete Account'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}