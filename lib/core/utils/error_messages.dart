/// Maps raw exceptions to short, user-facing messages. Keeps SocketExceptions
/// and SDK exception class names out of the UI.
String friendlyError(Object? error) {
  final text = error?.toString() ?? '';
  final lower = text.toLowerCase();

  if (lower.contains('failed host lookup') ||
      lower.contains('socketexception') ||
      lower.contains('retryablefetch') ||
      lower.contains('clientexception') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection closed') ||
      lower.contains('timed out')) {
    return "Can't reach the server. Check your internet connection and try "
        'again.';
  }
  if (lower.contains('invalid login credentials')) {
    return 'Incorrect email or password.';
  }
  if (lower.contains('email not confirmed')) {
    return 'Please confirm your email before signing in.';
  }
  if (lower.contains('user already registered') ||
      lower.contains('already been registered')) {
    return 'An account with this email already exists.';
  }
  if (lower.contains('weak password') ||
      lower.contains('password should be at least')) {
    return 'Password is too weak — use at least 6 characters.';
  }

  // Strip a leading "SomethingException: " prefix for anything unmapped.
  final cleaned = text.replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
  return cleaned.isEmpty ? 'Something went wrong. Please try again.' : cleaned;
}
