import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tarefa11/routesprincipais/Hub_loginE_registo.dart';
import 'package:flutter_tarefa11/Login/autenticacao.dart';
import 'package:flutter_tarefa11/_comum/minhascores.dart';
import 'package:flutter_tarefa11/widgets/snackbar.dart';

class RegistoPage extends StatefulWidget {
  const RegistoPage({Key? key}) : super(key: key);

  @override
  State<RegistoPage> createState() => _RegistoPageState();
}

class _RegistoPageState extends State<RegistoPage> {
  bool queroEntrar = true;
  final _formKey = GlobalKey<FormState>(); //controla o formulario
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  Autenticacao _autenService = Autenticacao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Minhascores.vermelho_escuro, Minhascores.preto])),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/logo2.png',
                  height: 200,
                  width: 0,
                ),
                const Text(
                  "GymFit",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller:
                                  _emailController, //armazena tudo que for escrito no email
                              decoration: InputDecoration(
                                label: Text("E-mail"),
                                hintText: "nome@email.com",
                              ),
                              validator: (email) {
                                if (email == null || email.isEmpty) {
                                  return "Escreva o seu email";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller:
                                  _senhaController, //armazena tudo que for escrito na password
                              decoration: InputDecoration(
                                  label: Text("Palavra-Passe"),
                                  hintText: "Palavra-passe"),
                              validator: (senha) {
                                if (senha == null || senha.isEmpty) {
                                  return "Escreva o seu e-mail";
                                } else if (senha.length <= 6) {
                                  return "Escreva uma password mais forte";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  botaologinpressionad();
                                },
                                child: Text((queroEntrar)
                                    ? "Entrar"
                                    : "Registar")), //Caso cliques no "Já tem conta? Estavamos mesmo à sua espera"
                            Divider(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  queroEntrar = !queroEntrar;
                                });
                              },
                              child: Text((queroEntrar)
                                  ? "Ainda não tem uma conta? Junte-se à Gym Fit "
                                  : "Já tem conta? Estavamos mesmo à sua espera!"),
                            ),
                          ]),
                    ),
                  ),
                ),
              ]),
        ],
      ),
    );
  }

  botaologinpressionad() {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String password = _senhaController.text;

    if (_formKey.currentState!
        .validate()) //previne de clicar no entrar e nao tenha digito
    {
      if (queroEntrar) {
        print("Entrada validade");
        _autenService
            .loginUtilizadores(email: email, password: password)
            .then((String? erro) {
          if (erro != null) {
            mostrarSnackBar(context: context, texto: erro);
          } else {}
        });
      } else {
        print("Registo Validado");
        _autenService
            .registoUtilizador(nome: nome, password: password, email: email)
            .then(
          (String? erro) {
            if (erro != null) {
              //voltou com erro
              mostrarSnackBar(context: context, texto: erro);
            }
          },
        );
      }
      //gasta recursos da api por isso, convem validar se
      //os campos email e pw estao preenchid
    }
  }
}
