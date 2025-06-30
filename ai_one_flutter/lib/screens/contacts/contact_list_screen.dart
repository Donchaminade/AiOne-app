// ai_one_flutter/lib/screens/contacts/contact_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/contact.dart';
import 'package:ai_one_flutter/screens/contacts/contact_form_screen.dart';
import 'package:ai_one_flutter/screens/contacts/contact_detail_screen.dart';
import 'package:ai_one_flutter/viewmodels/contact_viewmodel.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Exécute la récupération des contacts après que le premier rendu du widget est terminé.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
    });

    // Ajoute un écouteur au contrôleur de recherche pour filtrer les contacts en temps réel.
    _searchController.addListener(() {
      Provider.of<ContactViewModel>(context, listen: false).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    // Supprime l'écouteur et libère le contrôleur pour éviter les fuites de mémoire.
    _searchController.removeListener(() {
      // Le listener n'a pas besoin de faire quoi que ce soit ici car il est supprimé
      // de la même manière qu'il a été ajouté, ce qui est suffisant.
    });
    _searchController.dispose();
    super.dispose();
  }

  // Méthode pour naviguer vers l'écran d'ajout ou d'édition de contact.
  // Utilise PageRouteBuilder pour une transition de fondu personnalisée.
  void _navigateToAddEditContact({Contact? contact}) async {
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ContactFormScreen(contact: contact),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Animation de fondu pour la transition d'écran
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400), // Durée de l'animation
      ),
    );

    // Si une opération (ajout/édition) a réussi, rafraîchit la liste des contacts
    // et affiche un message de succès.
    if (result == true) {
      if (context.mounted) {
        Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(contact == null ? 'Contact ajouté avec succès !' : 'Contact mis à jour avec succès !'),
            backgroundColor: Colors.green, // Feedback visuel positif
          ),
        );
      }
    }
  }

  // Méthode pour confirmer la suppression d'un contact via une boîte de dialogue stylisée.
  Future<void> _confirmAndDeleteContact(int id, String nomComplet) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Coins arrondis pour la boîte de dialogue
        title: Text(
          'Supprimer le contact ?',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        content: Text('Voulez-vous vraiment supprimer "$nomComplet" de vos contacts ?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // Couleur rouge pour l'action de suppression
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    // Si l'utilisateur confirme la suppression, appelle le ViewModel pour supprimer le contact.
    if (confirm == true) {
      if (context.mounted) {
        final success = await Provider.of<ContactViewModel>(context, listen: false).deleteContact(id);
        if (success) {
          if (context.mounted) {
            Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Contact "$nomComplet" supprimé avec succès !'),
                backgroundColor: Colors.green, // Feedback positif
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    Provider.of<ContactViewModel>(context, listen: false).errorMessage ??
                        'Erreur lors de la suppression du contact "$nomComplet".'),
                backgroundColor: Colors.red, // Feedback négatif
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar avec un titre et un dégradé, ainsi qu'un bouton d'ajout stylisé.
      appBar: AppBar(
        title: const Text('Mes Contacts'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // Utilise les mêmes couleurs de dégradé que les autres écrans pour la cohérence
              colors: [Color(0xFF673AB7), Color(0xFF5C6BC0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Bouton flottant pour ajouter un nouveau contact
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30, color: Colors.white), // Icône plus visible
            tooltip: 'Ajouter un nouveau contact',
            onPressed: () => _navigateToAddEditContact(),
          ),
          const SizedBox(width: 10), // Petit espacement
        ],
      ),
      body: Consumer<ContactViewModel>(
        builder: (context, contactViewModel, child) {
          return Column(
            children: [
              // Champ de recherche stylisé
              Padding(
                padding: const EdgeInsets.all(16.0), // Padding pour la barre de recherche
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher un contact',
                    hintText: 'Nom, profession, email...',
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Bords très arrondis
                      borderSide: BorderSide.none, // Pas de bordure visible par défaut
                    ),
                    enabledBorder: OutlineInputBorder( // Bordure quand non focus
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder( // Bordure quand focus
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100], // Couleur de fond légère
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              contactViewModel.setSearchTerm('');
                              FocusScope.of(context).unfocus(); // Cacher le clavier
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Affichage conditionnel de l'état (chargement, erreur, vide, liste)
              Expanded(
                child: contactViewModel.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 10),
                            Text(
                              'Chargement des contacts...',
                              style: TextStyle(color: Colors.grey[700], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : contactViewModel.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Erreur : ${contactViewModel.errorMessage!}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red, fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () => contactViewModel.fetchContacts(),
                                    icon: const Icon(Icons.refresh, color: Colors.white),
                                    label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : contactViewModel.contacts.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_alt_outlined, color: Colors.grey[400], size: 60),
                                      const SizedBox(height: 15),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? 'Aucun contact trouvé pour "${_searchController.text}".'
                                            : 'Vous n\'avez pas encore de contacts.\nAppuyez sur le bouton "+" pour en ajouter un.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                      ),
                                      if (_searchController.text.isEmpty) ...[
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          onPressed: () => _navigateToAddEditContact(),
                                          icon: const Icon(Icons.person_add, color: Colors.white),
                                          label: const Text('Ajouter un Contact', style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(), // Effet de rebond à la fin du défilement
                                itemCount: contactViewModel.contacts.length,
                                itemBuilder: (context, index) {
                                  final contact = contactViewModel.contacts[index];
                                  return SlideTransition( // Animation d'entrée des éléments de la liste
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: ModalRoute.of(context)!.animation!,
                                        curve: Interval(0.1 * index / contactViewModel.contacts.length, 1.0, curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: _buildContactCard(context, contact),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
      // Optionnel : un FloatingActionButton pour ajouter, si vous préférez cela au bouton dans l'AppBar
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _navigateToAddEditContact(),
      //   backgroundColor: Theme.of(context).colorScheme.secondary,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  // Widget helper pour construire chaque carte de contact
  Widget _buildContactCard(BuildContext context, Contact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Marges autour de chaque carte
      elevation: 6.0, // Ombre plus prononcée
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Coins plus arrondis
      ),
      // Effet de survol/clique avec InkWell pour un feedback visuel
      child: InkWell(
        onTap: () async {
          final bool? result = await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ContactDetailScreen(contact: contact),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
          // Si l'écran de détail renvoie un succès (ex: après modification)
          if (result == true) {
            if (context.mounted) {
              Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
            }
          }
        },
        borderRadius: BorderRadius.circular(15.0), // Important pour l'effet de ripple
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding interne de la carte
          child: Row(
            children: [
              // Avatar ou icône de contact
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 15),
              // Informations du contact (nom, profession)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.nomComplet,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (contact.profession != null && contact.profession!.isNotEmpty)
                      Text(
                        contact.profession!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Text(
                        'Aucune profession',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              // Boutons d'action (édition et suppression)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary), // Couleur du thème
                    tooltip: 'Modifier',
                    onPressed: () => _navigateToAddEditContact(contact: contact),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Rouge pour la suppression
                    tooltip: 'Supprimer',
                    onPressed: () => _confirmAndDeleteContact(contact.id, contact.nomComplet),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}