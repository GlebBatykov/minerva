part of minerva_util;

enum HashAlgoritm { sha256, sha512 }

class PasswordSecurity {
  final RandomStringGenerator _generator = RandomStringGenerator();

  String generateSalt({int length = 16}) {
    return _generator.generate(length);
  }

  String hashPassword(String key,
      {int? rounds,
      String? salt,
      HashAlgoritm algoritm = HashAlgoritm.sha256}) {
    switch (algoritm) {
      case HashAlgoritm.sha256:
        return Crypt.sha256(key, rounds: rounds, salt: salt).hash;
      case HashAlgoritm.sha512:
        return Crypt.sha512(key, rounds: rounds, salt: salt).hash;
    }
  }

  bool match(String password, String hashedPassword,
      {String? salt,
      int? rounds,
      HashAlgoritm algoritm = HashAlgoritm.sha256}) {
    late String hash;

    switch (algoritm) {
      case HashAlgoritm.sha256:
        hash = Crypt.sha256(password, salt: salt, rounds: rounds).hash;
        break;
      case HashAlgoritm.sha512:
        hash = Crypt.sha512(password, salt: salt, rounds: rounds).hash;
    }

    return hash == hashedPassword;
  }
}
