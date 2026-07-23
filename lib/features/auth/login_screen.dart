import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/auth/create_account_screen.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';
import 'package:travelmate/shared/state/auth_service.dart';
import 'package:travelmate/shared/widgets/app_snackbar.dart';
import 'package:travelmate/shared/widgets/app_text_field.dart';
import 'package:travelmate/shared/widgets/brand_header.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';
import 'package:travelmate/shared/widgets/link_text.dart';

/// Signature for verifying a login attempt.
typedef CredentialValidator =
    Future<bool> Function(String username, String password);

/// Initial login screen: brand header, username/password fields, and an
/// "Enter" button that authenticates against the encrypted SQLite account.
///
/// Credentials are verified through [AuthService] (username AES-decrypted and
/// compared, password checked against a PBKDF2 salted hash). On success the app
/// shell opens; on failure an inline error is shown. Both the validator and the
/// success navigation are injectable so the screen is testable in isolation.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authenticate, this.onAuthenticated});

  /// Verifies the entered credentials. Defaults to [AuthService].
  final CredentialValidator? authenticate;

  /// Invoked after a successful login. Defaults to opening the app shell.
  final ValueChanged<BuildContext>? onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEnter() async {
    if (_submitting) {
      return;
    }

    final authenticate = widget.authenticate ?? AuthService.instance.authenticate;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _submitting = true);

    final success = await authenticate(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);

    if (success) {
      (widget.onAuthenticated ?? _openApp)(context);
      return;
    }

    AppSnackBar.show(messenger, AppStrings.loginErrorMessage);
  }

  void _openApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NavigationShell()),
    );
  }

  void _openCreateAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.padL,
                vertical: sizes.spaceM,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BrandHeader(),
                        SizedBox(height: sizes.spaceL),
                        AppTextField(
                          controller: _usernameController,
                          label: AppStrings.loginUsernameLabel,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: sizes.spaceS),
                        AppTextField(
                          controller: _passwordController,
                          label: AppStrings.loginPasswordLabel,
                          obscureText: true,
                          onSubmitted: (_) => _handleEnter(),
                        ),
                        SizedBox(height: sizes.spaceM),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: AppStrings.loginButtonLabel,
                            color: AppColors.yellow,
                            onPressed: _submitting ? () {} : _handleEnter,
                          ),
                        ),
                        SizedBox(height: sizes.spaceM),
                        LinkText(
                          text: AppStrings.loginCreateAccountLink,
                          onTap: () => _openCreateAccount(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
