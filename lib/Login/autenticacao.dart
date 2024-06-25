import 'package:firebase_auth/firebase_auth.dart';

class Autenticacao {
  //registo
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> registoUtilizador({
    required String nome,
    required String password,
    required String email,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O utilizador já está registado";
      }
      return "Erro não identificado";
    }
  }

  Future<String?> loginUtilizadores(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null; //se der certo, o utilizador faz login retorna null
    } on FirebaseAuthException catch (e) {
      return e.message; //se algo der erro.
    }
  }

  Future<void> signout() async {        //quando chamado, desloga o utilizador.
    return _firebaseAuth.signOut();
  }
}
