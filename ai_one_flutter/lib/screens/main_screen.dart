// ai_one_flutter/lib/screens/main_screen.dart

import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

// Importez vos ViewModels
import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart';

// Importez vos écrans de liste
import 'package:ai_one_flutter/screens/contacts/contact_list_screen.dart';
import 'package:ai_one_flutter/screens/notes/note_list_screen.dart';
import 'package:ai_one_flutter/screens/credentials/credential_list_screen.dart';
import 'package:ai_one_flutter/screens/tasks/task_list_screen.dart';

// Importez les écrans de formulaire pour les actions rapides
import 'package:ai_one_flutter/screens/contacts/contact_form_screen.dart';
import 'package:ai_one_flutter/screens/notes/note_form_screen.dart';
import 'package:ai_one_flutter/screens/credentials/credential_form_screen.dart';
import 'package:ai_one_flutter/screens/tasks/task_form_screen.dart';

// --- NOUVEAU WIDGET POUR LE CONTENU DU TABLEAU DE BORD (Accueil) ---
class DashboardContent extends StatelessWidget {
  final Function(int)
  navigateToTab; // Pour naviguer vers les onglets principaux
  final LocalAuthentication
  localAuth; // Passé pour l'authentification si nécessaire

  const DashboardContent({
    super.key,
    required this.navigateToTab,
    required this.localAuth,
  });

  // Méthode pour construire un élément du tableau de bord
  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            Text('$count', style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire une action rapide
  Widget _buildQuickAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écoutez les ViewModels pour obtenir les données dynamiques
    // Note: Utilisation de `select` pour optimiser les rebuilds si seul la longueur est nécessaire.
    final contactCount = Provider.of<ContactViewModel>(context).contacts.length;
    final noteCount = Provider.of<NoteViewModel>(context).notes.length;
    final credentialCount = Provider.of<CredentialViewModel>(
      context,
    ).credentials.length;
    final taskCount = Provider.of<TaskViewModel>(context).tasks.length;

    // Pour les actions rapides, nous avons besoin des instances des ViewModels pour appeler fetch*()
    // Utiliser listen: false ici est crucial si vous n'avez besoin que d'appeler des méthodes.
    // L'écoute des changements pour les counts se fait déjà ci-dessus.
    final contactViewModel = Provider.of<ContactViewModel>(
      context,
      listen: false,
    );
    final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);
    final credentialViewModel = Provider.of<CredentialViewModel>(
      context,
      listen: false,
    );
    final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);

    // Liste des chemins d'images pour le carrousel
    final List<String> imgList = [
      'assets/images/ai1.png',
      'assets/images/ai2.png',
      'assets/images/ai3.png',
      'assets/images/ai4.png',
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de bienvenue améliorée
            Text(
              'Bienvenue sur AI One !',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre assistant personnel intelligent.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // Carrousel d'images
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: imgList
                  .map(
                    (item) => Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(item),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistiques en un coup d\'œil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDashboardItem(
                        context,
                        icon: Icons.people,
                        count: contactCount,
                        label: 'Contacts',
                        onTap: () => navigateToTab(
                          1,
                        ), // Navigue vers ContactListScreen (index 1)
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.notes,
                        count: noteCount,
                        label: 'Notes',
                        onTap: () => navigateToTab(
                          2,
                        ), // Navigue vers NoteListScreen (index 2)
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.vpn_key,
                        count: credentialCount,
                        label: 'Identifiants',
                        onTap: () => navigateToTab(
                          3,
                        ), // Navigue vers CredentialListScreen (index 3)
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.task,
                        count: taskCount,
                        label: 'Tâches',
                        onTap: () => navigateToTab(
                          4,
                        ), // Navigue vers TaskListScreen (index 4)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Actions Rapides',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildQuickAction(
                  context,
                  label: 'Nouveau Contact',
                  icon: Icons.person_add,
                  onTap: () async {
                    final bool? result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const ContactFormScreen(),
                      ),
                    );
                    if (result == true) {
                      if (context.mounted) {
                        contactViewModel
                            .fetchContacts(); // Rafraîchir les données
                      }
                    }
                  },
                ),
                _buildQuickAction(
                  context,
                  label: 'Nouvelle Note',
                  icon: Icons.note_add,
                  onTap: () async {
                    final bool? result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const NoteFormScreen(),
                      ),
                    );
                    if (result == true) {
                      if (context.mounted) {
                        noteViewModel.fetchNotes(); // Rafraîchir les données
                      }
                    }
                  },
                ),
                _buildQuickAction(
                  context,
                  label: 'Nouvel Identifiant',
                  icon: Icons.key,
                  onTap: () async {
                    // Authentification biométrique avant d'accéder au formulaire d'identifiants
                    final bool canAuthenticate =
                        await localAuth.canCheckBiometrics;
                    if (canAuthenticate) {
                      final bool didAuthenticate = await localAuth.authenticate(
                        localizedReason:
                            'Authentifiez-vous pour créer un identifiant',
                        options: const AuthenticationOptions(
                          biometricOnly: false,
                        ),
                      );
                      if (didAuthenticate) {
                        final bool? result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const CredentialFormScreen(),
                          ),
                        );
                        if (result == true) {
                          if (context.mounted) {
                            credentialViewModel
                                .fetchCredentials(); // Rafraîchir les données
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentification annulée ou échouée.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      // Si pas de biométrie, naviguer directement (ou afficher un message)
                      final bool? result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const CredentialFormScreen(),
                        ),
                      );
                      if (result == true) {
                        if (context.mounted) {
                          credentialViewModel.fetchCredentials();
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Authentification requise pour les identifiants.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                _buildQuickAction(
                  context,
                  label: 'Nouvelle Tâche',
                  icon: Icons.add_task,
                  onTap: () async {
                    final bool? result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const TaskFormScreen(),
                      ),
                    );
                    if (result == true) {
                      if (context.mounted) {
                        taskViewModel.fetchTasks(); // Rafraîchir les données
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final LocalAuthentication auth = LocalAuthentication();

  // Déclarez _widgetOptions ici comme 'late final'
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    // Initialisez _widgetOptions avec SEULEMENT les widgets d'écran.
    // NE METTEZ PAS les appels fetch() ici.
    _widgetOptions = <Widget>[
      DashboardContent(
        navigateToTab: _onItemTapped,
        localAuth: auth,
      ), // Index 0
      const ContactListScreen(), // Index 1
      const NoteListScreen(), // Index 2
      const CredentialListScreen(), // Index 3
      const TaskListScreen(), // Index 4
    ];

    // C'est ici que les appels fetch() doivent être placés,
    // À L'INTÉRIEUR DU addPostFrameCallback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Ces appels sont sûrs ici car ils se produisent après le build initial
        Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
        Provider.of<NoteViewModel>(context, listen: false).fetchNotes();
        Provider.of<CredentialViewModel>(
          context,
          listen: false,
        ).fetchCredentials();
        Provider.of<TaskViewModel>(context, listen: false).fetchTasks();
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int realIndex) {
    if (_selectedIndex != realIndex) {
      setState(() {
        _selectedIndex = realIndex;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ai2.png', height: 30),
            const SizedBox(width: 10),
            Text(
              'AI One',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF5C6BC0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavBarItem(1, Icons.people, 'Contacts'),
                      _buildNavBarItem(2, Icons.notes, 'Notes'),
                    ],
                  ),
                ),
                const SizedBox(width: 80),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavBarItem(3, Icons.vpn_key, 'Identifiants'),
                      _buildNavBarItem(4, Icons.task, 'Tâches'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () =>
                    _onItemTapped(0), // Navigue vers l'index 0 (Dashboard)
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 10,
                child: const Icon(Icons.home, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cette méthode construit les éléments normaux de la BottomNavigationBar
  Widget _buildNavBarItem(int itemIndex, IconData icon, String label) {
    final bool isSelected = _selectedIndex == itemIndex;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(itemIndex),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
