import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tarefa11/Login/registo_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_tarefa11/routesprincipais/contactUS.dart';
import 'firebase_options.dart';
import 'package:flutter_tarefa11/routesprincipais/exercise_list_screen.dart';
import 'package:flutter_tarefa11/routesprincipais/profile_screen.dart';
import 'package:flutter_tarefa11/routesprincipais/training_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //assincrono.aAutenticacao
  await Firebase.initializeApp(
    //autenticaçao
    options: DefaultFirebaseOptions.currentPlatform,
  ); //}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GymFit",
      initialRoute: "/estado_user",
      routes: {
        "/estado_user": (context) => const RouterTela(), //página de login
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RouterTela(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RouterTela());
  }
}

//////////////////////////////////////////////////7

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TrainingScreen(),
    ExerciseListScreen(
      onExerciseSelected: (exercise) { },
    ),
    contactUS_Screen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Meu treino',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Exercícios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_enabled),
            label: 'Contactos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 243, 40, 33),
        onTap: _onItemTapped,
      ),
    );
  }
}
/////////////////////////////////////Autenticaçao///////////////////////////////////////////////////////////////
class RouterTela extends StatelessWidget {
  const RouterTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("cheguei aqui!");
          return const MainScreen(); //leva para a pagina inicial da app
        } else {
          print("cheguei ao registo");
          return const RegistoPage(); //caso nao esteja com o login efetuado, vai para a pagina Login.
        }
      },
    ); //permite verificar se estas logado ou não.//verificas se houve alguma mudança com o utilizador.
  }
}
