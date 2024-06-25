import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
         backgroundColor: Color.fromARGB(255, 238, 24, 24)
      ),
      body: const Center(
        child: Text('Conteúdo do perfil'),
      ),
    );
  }
}