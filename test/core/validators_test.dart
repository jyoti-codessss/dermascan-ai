import 'package:dermascan_ai/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthInputValidators Tests', () {
    test('validateEmail validates email formats correctly', () {
      expect(AuthInputValidators.validateEmail(''), 'Please enter your email address.');
      expect(AuthInputValidators.validateEmail('invalid-email'), 'Please enter a valid email address.');
      expect(AuthInputValidators.validateEmail('user@domain'), 'Please enter a valid email address.');
      expect(AuthInputValidators.validateEmail('user@example.com'), isNull);
    });

    test('validatePassword enforces security rules', () {
      expect(AuthInputValidators.validatePassword(''), 'Please enter a password.');
      expect(AuthInputValidators.validatePassword('Short1!'), 'Password must be at least 8 characters long.');
      expect(AuthInputValidators.validatePassword('lowercase1!'), 'Password must contain at least one uppercase letter.');
      expect(AuthInputValidators.validatePassword('UPPERCASE1!'), 'Password must contain at least one lowercase letter.');
      expect(AuthInputValidators.validatePassword('NoNumber!'), 'Password must contain at least one number.');
      expect(AuthInputValidators.validatePassword('NoSpecial1'), 'Password must contain at least one special character.');
      expect(AuthInputValidators.validatePassword('StrongPass1!'), isNull);
    });

    test('validateConfirmPassword checks password equality', () {
      expect(AuthInputValidators.validateConfirmPassword('', 'Pass123!'), 'Please confirm your password.');
      expect(AuthInputValidators.validateConfirmPassword('Different1!', 'Pass123!'), 'Passwords do not match.');
      expect(AuthInputValidators.validateConfirmPassword('Pass123!', 'Pass123!'), isNull);
    });
  });
}
