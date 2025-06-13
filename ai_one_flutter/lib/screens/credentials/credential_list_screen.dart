// ai_one_flutter/lib/screens/credentials/credential_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_one_flutter/models/credential.dart';
import 'package:ai_one_flutter/screens/credentials/credential_form_screen.dart';
import 'package:ai_one_flutter/screens/credentials/credential_detail_screen.dart';
import 'package:ai_one_flutter/viewmodels/credential_viewmodel.dart';

class CredentialListScreen extends StatefulWidget {
  const CredentialListScreen({super.key});

  @override
  State<CredentialListScreen> createState() => _CredentialListScreenState();
}

class _CredentialListScreenState extends State<CredentialListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CredentialViewModel>(context, listen: false).fetchCredentials();
    });
    _searchController.addListener(() {
      Provider.of<CredentialViewModel>(context, listen: false).setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddEditCredential({Credential? credential}) async {
    final bool? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CredentialFormScreen(credential: credential),
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opération terminée avec succès.')),
      );
    }
  }

  Future<void> _confirmAndDeleteCredential(int id, String nomSiteCompte) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'identifiant pour "$nomSiteCompte" ?'),
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
      final success = await Provider.of<CredentialViewModel>(context, listen: false).deleteCredential(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Identifiant pour "$nomSiteCompte" supprimé avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de l\'identifiant pour "$nomSiteCompte".')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CredentialViewModel>(
      builder: (context, credentialViewModel, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un identifiant',
                  hintText: 'Entrez un site, email, etc.',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            credentialViewModel.setSearchTerm('');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: credentialViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : credentialViewModel.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              credentialViewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : credentialViewModel.credentials.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? 'Aucun identifiant trouvé pour "${_searchController.text}".'
                                    : 'Aucun identifiant trouvé. Appuyez sur "+" pour en ajouter un.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: credentialViewModel.credentials.length,
                              itemBuilder: (context, index) {
                                final credential = credentialViewModel.credentials[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: const Icon(Icons.lock),
                                    title: Text(credential.nomSiteCompte),
                                    subtitle: Text('Utilisateur: ${credential.nomUtilisateurEmail}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _navigateToAddEditCredential(credential: credential),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _confirmAndDeleteCredential(credential.id, credential.nomSiteCompte),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CredentialDetailScreen(credential: credential),
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