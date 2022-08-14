import 'package:minerva/minerva.dart';
import 'package:test/test.dart';

void main() {
  group('util', () {
    group('security', () {
      group('password', () {
        final PasswordSecurity security = PasswordSecurity();

        test('Generates salt.', () {
          var salt = security.generateSalt();

          expect(salt.length, 16);
        });

        test('Hashes password with salt.', () {
          const password = 'test';

          const salt = 'k2rliZaR6QyrONEe';

          var hash = security.hashPassword(password, salt: salt);

          expect(hash, 'P/JhWobSc5mSwJsfeh7F36dB4/yBg0V/g.EvhGKxoo.');
        });

        test('Matches password and hashed password with salt.', () {
          const hashedPassword = 'P/JhWobSc5mSwJsfeh7F36dB4/yBg0V/g.EvhGKxoo.';

          const password = 'test';

          const salt = 'k2rliZaR6QyrONEe';

          var isEqual = security.match(password, hashedPassword, salt: salt);

          expect(isEqual, true);
        });
      });
    });
  });
}
