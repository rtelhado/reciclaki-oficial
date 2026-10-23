import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> entrar(String email, String senha) async {
    await auth.signInWithEmailAndPassword(email: email.trim(), password: senha);
  }

  /// Retorna false se a conta foi criada, mas o perfil precisa ser completado.
  static Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String nascimento,
    required String avatarId,
  }) async {
    final credencial = await auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: senha,
    );
    final usuario = credencial.user!;
    // A senha pertence somente ao Firebase Authentication. Nunca ao Firestore.
    try {
      await usuario.updateDisplayName(nome.trim());
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .set({
            'nome': nome.trim(),
            'email': usuario.email!,
            'telefone': telefone.trim(),
            'nascimento': nascimento,
            'avatarId': avatarId,
            'criadoEm': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 20));
      return true;
    } catch (_) {
      // Não informar que a conta falhou quando o Authentication já a criou.
      return false;
    }
  }

  static Future<void> recuperarSenha(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());

  static Future<void> sair() => auth.signOut();

  static String mensagemErro(Object erro) {
    if (erro is FirebaseException) {
      return switch (erro.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'E-mail ou senha incorretos.',
        'invalid-email' => 'Digite um e-mail válido.',
        'email-already-in-use' =>
          'Este e-mail já possui uma conta. Entre ou recupere sua senha.',
        'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
        'user-disabled' => 'Esta conta foi desativada.',
        'network-request-failed' || 'unavailable' =>
          'Não foi possível conectar. Confira sua internet e tente novamente.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde um pouco antes de tentar novamente.',
        'permission-denied' =>
          'O Firestore negou o acesso aos pontos. Confirme se sua sessão está ativa e se as regras publicadas permitem leitura da coleção pontos_coleta.',
        'operation-not-allowed' =>
          'O login por e-mail ainda precisa ser habilitado no Firebase.',
        _ => 'Não foi possível concluir a operação. Tente novamente.',
      };
    }
    return 'Não foi possível concluir a operação. Confira sua conexão e tente novamente.';
  }
}
