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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
    });
    // Écoute les changements dans le champ de recherche pour filtrer
    _searchController.addListener(() {
      Provider.of<ContactViewModel>(context, listen: false).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {}); // Important: retirer le listener
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddEditContact({Contact? contact}) async {
    final bool? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(contact: contact),
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opération terminée avec succès.')),
      );
    }
  }

  Future<void> _confirmAndDeleteContact(int id, String nomComplet) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer $nomComplet ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await Provider.of<ContactViewModel>(context, listen: false).deleteContact(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nomComplet supprimé avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de $nomComplet.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactViewModel>(
      builder: (context, contactViewModel, child) {
        return Column( // Utiliser Column pour la barre de recherche et la liste
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un contact',
                  hintText: 'Entrez un nom, email, etc.',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            contactViewModel.setSearchTerm(''); // Réinitialise le filtre
                            FocusScope.of(context).unfocus(); // Ferme le clavier
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded( // Expanded pour que la liste prenne le reste de l'espace
              child: contactViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contactViewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              contactViewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : contactViewModel.contacts.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? 'Aucun contact trouvé pour "${_searchController.text}".'
                                    : 'Aucun contact trouvé. Appuyez sur "+" pour en ajouter un.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: contactViewModel.contacts.length,
                              itemBuilder: (context, index) {
                                final contact = contactViewModel.contacts[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(contact.nomComplet),
                                    subtitle: Text(contact.adresseEmail),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _navigateToAddEditContact(contact: contact),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _confirmAndDeleteContact(contact.id, contact.nomComplet),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ContactDetailScreen(contact: contact),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }
}