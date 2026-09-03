import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_messages.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_header.dart';

/// Where an invite or password-recovery deep link lands.
///
/// `supabase_flutter` consumes the link and establishes a session before this
/// screen is shown, so the user is technically signed in — but they have no
/// password they know. [passwordRecoveryProvider] keeps the router pinned here
/// until they set one, which is what stops an invited tenant from wandering
/// into the app with a credential only their manager could have chosen.
class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .changePassword(_password.text);
    if (!ok || !mounted) return;
    // Clearing the flag releases the router, which sends them to their role's
    // home via the normal redirect.
    ref.read(passwordRecoveryProvider.notifier).resolve();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Password set')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(friendlyError(next.error))));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                // Errors surface as the user leaves a field, not only in one dump at
                // submit -- CLAUDE.md's FORMS section calls for inline validation.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Choose a password',
                      subtitle:
                          'Set a password for your account. Only you will know '
                          'it — nobody else can see it, including your manager.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'New password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        // Supabase rejects shorter passwords server-side; catch
                        // it here so the user isn't bounced by a raw API error.
                        if (v.length < 8) return 'At least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration:
                          const InputDecoration(labelText: 'Confirm password'),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) =>
                          v == _password.text ? null : 'Passwords do not match',
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: state.isLoading ? null : _submit,
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Set password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
