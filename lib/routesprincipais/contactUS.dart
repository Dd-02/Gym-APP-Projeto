import 'package:flutter/material.dart';


class contactUS_Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos.'),
         backgroundColor: Color.fromARGB(255, 238, 24, 24)
      ),
      body: Center(
        child: Column( children: [
            Text(
            'Instagram: gym_fit_Oficial\nFacebook: gymfit_Oficcial\nContactos: \n250 001 100\n200 300 003 \n +351 910101001',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),]
        ),
      ),
    );
  }
}
