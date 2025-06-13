// ai_one_flutter/lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ai_one_flutter/screens/contacts/contact_list_screen.dart';
import 'package:ai_one_flutter/screens/notes/note_list_screen.dart';
import 'package:ai_one_flutter/screens/credentials/credential_list_screen.dart';
import 'package:ai_one_flutter/screens/tasks/task_list_screen.dart';

import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/auth_viewmodel.dart'; // NOUVEL IMPORT
import 'package:ai_one_flutter/screens/auth/login_screen.dart'; // NOUVEL IMPORT

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()), // Ajout du AuthViewModel
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
        ChangeNotifierProvider(create: (_) => NoteViewModel()),
        ChangeNotifierProvider(create: (_) => CredentialViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI One App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Utilisation de Consumer pour écouter l'état d'authentification
      home: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (authViewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (authViewModel.isAuthenticated) {
            return const MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ContactListScreen(),
    const NoteListScreen(),
    const CredentialListScreen(),
    const TaskListScreen(),
  ];

  final List<String> _titles = const [
    'Contacts',
    'Notes',
    'Identifiants',
    'Tâches',
  ];

  @override
  void initState() {
    super.initState();
    // Re-initialise les données au démarrage du MainScreen (après login)
    // Cela garantit que les listes sont à jour après la connexion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
      Provider.of<NoteViewModel>(context, listen: false).fetchNotes();
      Provider.of<CredentialViewModel>(context, listen: false).fetchCredentials();
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.logout();
    // Après logout, le Consumer dans MyApp redirigera vers LoginScreen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'AI One Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Contacts'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Identifiants'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tâches'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            const Divider(), // Séparateur
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context); // Ferme le tiroir
                _logout(); // Appelle la fonction de déconnexion
              },
            ),
          ],
        ),
      ),
    );
  }
}