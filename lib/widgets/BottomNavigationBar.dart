import "package:flutter/material.dart";
import "package:flutter_tarefa11/routesprincipais/contactUS.dart";
import "package:flutter_tarefa11/routesprincipais/exercise_list_screen.dart";
import "package:flutter_tarefa11/routesprincipais/exercise_list_screen.dart";
import "package:flutter_tarefa11/routesprincipais/training_screen.dart";
import "package:flutter_tarefa11/routesprincipais/profile_screen.dart";

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    contactUS_Screen(),
    ProfileScreen(),
    TrainingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Meu Treino',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Exercicios',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Perfil',
            backgroundColor: Colors.red,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 142, 140, 137),
        onTap: _onItemTapped,
      ),
    );
  }
}
