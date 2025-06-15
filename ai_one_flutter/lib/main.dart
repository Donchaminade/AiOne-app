// ai_one_flutter/lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importez vos ViewModels
import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/note_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart';
import 'package:ai_one_flutter/viewmodels/task_viewmodel.dart';

// Importez le nouveau MainScreen
import 'package:ai_one_flutter/screens/main_screen.dart';
// Importez le Splash Screen
import 'package:ai_one_flutter/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
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
      title: 'AI One',
      debugShowCheckedModeBanner: false, // Enlève le bandeau "Debug"
      theme: ThemeData(
        // Utilisation de primarySwatch pour les couleurs par défaut
        primarySwatch: Colors.indigo, // Une couleur principale de base
        // Adapte la densité visuelle selon la plateforme
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // Définition d'un ColorScheme pour un contrôle plus fin des couleurs du thème
        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: Colors.indigo, // Une couleur primaire forte
              accentColor:
                  Colors.deepPurpleAccent, // Une couleur secondaire/accent
            ).copyWith(
              // Définition des couleurs primaires et secondaires spécifiques
              // Ces couleurs correspondent au dégradé utilisé dans l'AppBar et le Dashboard
              primary: const Color(
                0xFF673AB7,
              ), // Violet profond (pour l'AppBar, icônes principales, etc.)
              secondary: const Color(
                0xFF5C6BC0,
              ), // Bleu-indigo (pour les FAB, boutons d'action, etc.)
              surface: Colors
                  .white, // Couleur de fond générale de l'application
              error: Colors.red, // Couleur pour les messages d'erreur
              onPrimary: Colors
                  .white, // Couleur du texte/icônes sur la couleur primaire
              onSecondary: Colors
                  .white, // Couleur du texte/icônes sur la couleur secondaire
              onSurface:
                  Colors.black87, // Couleur du texte/icônes sur le fond
              onError: Colors
                  .white, // Couleur du texte/icônes sur la couleur d'erreur
            ),

        // Style de texte global pour l'application
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 96.0,
            fontWeight: FontWeight.w300,
            color: Colors.black87,
          ),
          displayMedium: TextStyle(
            fontSize: 60.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          displaySmall: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontSize: 34.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ), // Utilisé pour les titres des listes (e.g., TaskListScreen)
          titleMedium: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ), // Utilisé pour les sous-titres importants
          bodyLarge: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ), // Texte principal
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: Colors.black87,
          ), // Texte de corps par défaut
          labelLarge: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ), // Pour les boutons par exemple
          labelSmall: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ), // Pour les petites légendes
          bodySmall: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ), // Texte secondaire ou descriptions courtes
        ),

        // Thème global pour les cartes (Card)
        cardTheme: CardThemeData(
          // Changed from CardTheme to CardThemeData
          elevation: 4.0, // Ombre des cartes
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ), // Bords arrondis
          margin: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ), // Marge par défaut
        ),

        // Style des AppBars
        appBarTheme: const AppBarTheme(
          elevation:
              0, // Pas d'ombre par défaut (le dégradé donne déjà un effet)
          backgroundColor: Colors
              .transparent, // Couleur de fond transparente pour le dégradé
          iconTheme: IconThemeData(color: Colors.white), // Icônes blanches
          actionsIconTheme: IconThemeData(
            color: Colors.white,
          ), // Icônes d'action blanches
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Thème des FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(
            0xFF5C6BC0,
          ), // Utilise la couleur secondaire
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 8.0,
        ),

        // Thème des boutons surélevés (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Texte blanc sur le bouton
            backgroundColor: const Color(0xFF673AB7), // Couleur primaire
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Bords arrondis
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Thème des TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF673AB7), // Couleur primaire
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Thème des input fields (TextField, TextFormField)
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none, // Pas de bordure par défaut
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: const Color(0xFF673AB7),
              width: 2.0,
            ), // Bordure colorée au focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          filled: true,
          fillColor:
              Colors.grey.shade100, // Fond légèrement grisé pour les champs
          hintStyle: TextStyle(color: Colors.grey.shade500),
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),

        // Thème de la BottomNavigationBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFF673AB7), // Couleur primaire
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType
              .fixed, // Tous les labels sont toujours visibles
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 8.0, // Ombre
        ),
      ),
      home: const SplashScreen(), // Commencer par le splash screen
      routes: {
        '/home': (context) =>
            const MainScreen(), // Route vers l'écran principal
        // Ajoutez d'autres routes si nécessaire pour les formulaires de création/édition
        // '/addContact': (context) => ContactFormScreen(), // Exemple de route pour ajouter un contact
      },
    );
  }
}
