class AppStrings {
  static const String appTitle = 'FlexBiller';
  static const String loginTitle = 'Login';
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to your account to continue';
  static const String email = 'Email';
  static const String emailHint = 'Enter your email';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String loginButton = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String changePassword = 'Change Password';
  static const String dontHaveAccount = 'Don\'t have an account? Sign up';
  static const String testCredentials = 'Test with: techtcoder1237@gmail.com / Tcoder@123';
  
  // Forgot Password
  static const String forgotPasswordTitle = 'Reset Your Password';
  static const String forgotPasswordDescription = 'Enter your email address and we\'ll send you a link to reset your password.';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogin = 'Back to Login';
  static const String didntReceiveEmail = 'Didn\'t receive the email?';
  static const String enterResetTokenManually = 'Enter Reset Token Manually';
  
  // Change Password
  static const String changePasswordTitle = 'Change Your Password';
  static const String changePasswordDescription = 'Enter your current password and choose a new one.';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String confirmNewPassword = 'Confirm New Password';
  static const String changePasswordButton = 'Change Password';
  static const String cancel = 'Cancel';
  
  // Reset Password
  static const String resetPasswordTitle = 'Reset Your Password';
  static const String resetPasswordDescription = 'Enter the reset token from your email and choose a new password.';
  static const String resetToken = 'Reset Token';
  static const String resetTokenHint = 'Enter the token from your email';
  static const String resetPasswordButton = 'Reset Password';
  
  // Validation Messages
  static const String validationRequired = 'This field is required';
  static const String validationEmail = 'Please enter a valid email';
  static String validationPasswordLength(int minLength) => 'Password must be at least $minLength characters';
  static const String validationPasswordsMatch = 'Passwords do not match';
  static String validationMinLength(int minLength) => 'Must be at least $minLength characters';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successPasswordChanged = 'Password changed successfully. Please log in with your new password.';
  static const String successPasswordReset = 'Password reset successfully. You can now login with your new password.';
  static const String successResetEmailSent = 'Password reset email sent successfully. Please check your email.';
  
  // Error Messages
  static const String errorInvalidCredentials = 'Invalid credentials';
  static const String errorInvalidRequestData = 'Invalid request data';
  static const String errorConnectionTimeout = 'Connection timeout';
  static const String errorRequestTimeout = 'Request timeout';
  static const String errorNetworkError = 'Network error occurred';
  static const String errorUnexpected = 'Unexpected error occurred';
  static const String errorInvalidEmail = 'Invalid email address';
  static const String errorEmailNotFound = 'Email not found';
  static const String errorInvalidPassword = 'Invalid password format';
  static const String errorCurrentPasswordIncorrect = 'Current password is incorrect';
  static const String errorInvalidToken = 'Invalid or expired token';
  static const String errorNoToken = 'No authorization token provided';
  static const String errorServerError = 'Server error occurred';
  
  // Theme
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String themeSystem = 'System';
  static const String themeToggleTooltip = 'Toggle theme';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Information';
}
