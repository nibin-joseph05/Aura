enum AuthMethod { phone, google, email }

class AuthSuccessPayload {
  final AuthMethod method;
  final String? identifier;
  final bool isNewUser;

  const AuthSuccessPayload({
    required this.method,
    this.identifier,
    this.isNewUser = true,
  });
}
