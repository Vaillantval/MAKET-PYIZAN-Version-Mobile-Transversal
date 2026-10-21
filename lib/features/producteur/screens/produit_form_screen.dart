import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/ui/ui.dart';
import '../providers/mes_produits_provider.dart';
import '../providers/unites_mesure_provider.dart';

class ProduitFormScreen extends ConsumerStatefulWidget {
  final String? slug; // null = nouveau, slug = modifier
  const ProduitFormScreen({this.slug, super.key});

  @override
  ConsumerState<ProduitFormScreen> createState() =>
      _ProduitFormScreenState();
}

class _ProduitFormScreenState extends ConsumerState<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl   = TextEditingController();
  final _varCtrl   = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _prixCtrl  = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _seuilCtrl = TextEditingController();
  final _origCtrl  = TextEditingController();

  int?    _uniteVenteId;
  int?    _categorieId;
  File?   _imageFile;
  bool    _isLoading   = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _varCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _stockCtrl.dispose();
    _seuilCtrl.dispose();
    _origCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth:  800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uniteVenteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez une unité de vente.'),
          backgroundColor: AppColors.rouge,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final body = <String, dynamic>{
      'nom':              _nomCtrl.text.trim(),
      'variete':          _varCtrl.text.trim(),
      'description':      _descCtrl.text.trim(),
      'prix_unitaire':    _prixCtrl.text.trim(),
      'stock_disponible': int.tryParse(_stockCtrl.text) ?? 0,
      'seuil_alerte':     int.tryParse(_seuilCtrl.text) ?? 10,
      'unite_vente':      _uniteVenteId,
      'origine':          _origCtrl.text.trim(),
      if (_categorieId != null) 'categorie': _categorieId,
    };

    bool success;
    if (widget.slug == null) {
      success = await ref.read(mesProduitsProvider.notifier)
          .creer(body, imagePath: _imageFile?.path);
    } else {
      success = await ref.read(mesProduitsProvider.notifier)
          .modifier(widget.slug!, body, imagePath: _imageFile?.path);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      afficherMessage(context,
          widget.slug == null ? 'Produit créé' : 'Produit modifié');
      context.go('/producteur/catalogue');
    } else {
      afficherMessage(context, "Le produit n'a pas pu être enregistré",
          succes: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.slug == null
              ? 'Nouveau produit'
              : 'Modifier le produit',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Image ──────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height:   180,
                  width:    double.infinity,
                  decoration: BoxDecoration(
                    color:        AppColors.blanc,
                    borderRadius: BorderRadius.circular(18),
                    border:       Border.all(color: AppColors.grisBord),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                              size:  40,
                              color: AppColors.grisTexte,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color:      AppColors.noir,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Nom ────────────────────────────────────────
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText:  'Nom du produit *',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // ── Variété ────────────────────────────────────
              TextFormField(
                controller: _varCtrl,
                decoration: const InputDecoration(
                  labelText:  'Variété',
                  prefixIcon: Icon(Icons.grass),
                ),
              ),
              const SizedBox(height: 12),

              // ── Description ────────────────────────────────
              TextFormField(
                controller: _descCtrl,
                maxLines:   3,
                decoration: const InputDecoration(
                  labelText:  'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // ── Prix & Unité ───────────────────────────────
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller:   _prixCtrl,
                    keyboardType: const TextInputType
                        .numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText:   'Prix (HTG) *',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                    validator: (v) =>
                        (double.tryParse(v ?? '') ?? 0) <= 0
                            ? 'Prix invalide' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final unites = ref.watch(unitesMesureProvider);
                      return unites.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => const Text(
                          'Erreur de chargement des unités',
                          style: TextStyle(fontSize: 12, color: AppColors.rouge),
                        ),
                        data: (liste) {
                          _uniteVenteId ??= liste.isNotEmpty ? liste.first.id : null;
                          return DropdownButtonFormField<int>(
                            initialValue: _uniteVenteId,
                            items: liste.map((u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.nom, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (v) =>
                                setState(() => _uniteVenteId = v),
                            decoration: const InputDecoration(
                              labelText: 'Unité *',
                            ),
                            validator: (v) => v == null ? 'Requis' : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Stock & Seuil ──────────────────────────────
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller:   _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText:  'Stock disponible *',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller:   _seuilCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText:   'Seuil alerte',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // ── Origine ────────────────────────────────────
              TextFormField(
                controller: _origCtrl,
                decoration: const InputDecoration(
                  labelText:  'Commune / Origine',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 28),

              // ── Bouton sauvegarder ─────────────────────────
              ElevatedButton.icon(
                icon:      Icon(
                  widget.slug == null ? Icons.add : Icons.save,
                ),
                label:     Text(
                  widget.slug == null
                      ? 'Créer le produit'
                      : 'Enregistrer les modifications',
                ),
                onPressed: _isLoading ? null : _sauvegarder,
                style:     ElevatedButton.styleFrom(
                  minimumSize:     const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
