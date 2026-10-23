import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../acheteur/providers/catalogue_provider.dart';
import '../providers/mes_produits_provider.dart';
import '../providers/unites_mesure_provider.dart';
import '../../../shared/ui/ui.dart';

/// Ajout / modification d'un produit de l'entreprise active.
///
/// Le serveur modère le catalogue : un produit créé est en général
/// `en_attente` (invisible aux acheteurs) jusqu'à la décision du superadmin ;
/// modifier un produit refusé le resoumet, et changer le nom, la
/// description, la variété, la catégorie ou la photo d'un produit publié le
/// remet en validation. On se fie toujours au statut renvoyé.
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
  final _stockCtrl = TextEditingController(text: '0');
  final _seuilCtrl = TextEditingController(text: '10');

  int?    _uniteVenteId;
  int?    _categorieId;
  File?   _imageFile;
  String? _imageActuelle;
  String  _statut     = '';
  String  _motifRefus = '';
  bool    _isLoading  = false;
  bool    _chargement = false;

  bool get _modification => widget.slug != null;

  @override
  void initState() {
    super.initState();
    if (_modification) _prechargement();
  }

  Future<void> _prechargement() async {
    setState(() => _chargement = true);
    final p = await ref.read(mesProduitsProvider.notifier).detail(widget.slug!);
    if (!mounted) return;
    setState(() {
      _chargement = false;
      if (p == null) return;
      _nomCtrl.text   = '${p['nom'] ?? ''}';
      _varCtrl.text   = '${p['variete'] ?? ''}';
      _descCtrl.text  = '${p['description'] ?? ''}';
      _prixCtrl.text  = '${p['prix_unitaire'] ?? ''}';
      _stockCtrl.text = '${p['stock_disponible'] ?? 0}';
      _seuilCtrl.text = '${p['seuil_alerte'] ?? 10}';
      _uniteVenteId   = p['unite_vente_id'] as int?;
      final cat = p['categorie'];
      _categorieId    = cat is Map ? cat['id'] as int? : cat as int?;
      _imageActuelle  = p['image_principale'] as String?;
      _statut         = '${p['statut'] ?? ''}';
      _motifRefus     = '${p['motif_refus'] ?? ''}';
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _varCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _stockCtrl.dispose();
    _seuilCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categorieId == null || _uniteVenteId == null) {
      afficherMessage(context, 'Choisissez la catégorie et l\'unité de vente.',
          succes: false);
      return;
    }
    setState(() => _isLoading = true);

    final body = <String, dynamic>{
      'nom':              _nomCtrl.text.trim(),
      'variete':          _varCtrl.text.trim(),
      'description':      _descCtrl.text.trim(),
      'categorie':        _categorieId,
      'prix_unitaire':    _prixCtrl.text.trim().replaceAll(',', '.'),
      'unite_vente':      _uniteVenteId,
      'stock_disponible': int.tryParse(_stockCtrl.text) ?? 0,
      'seuil_alerte':     int.tryParse(_seuilCtrl.text) ?? 10,
    };

    final n = ref.read(mesProduitsProvider.notifier);
    final r = _modification
        ? await n.modifier(widget.slug!, body, imagePath: _imageFile?.path)
        : await n.creer(body, imagePath: _imageFile?.path);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!r.ok) {
      afficherMessage(context, r.erreur!, succes: false);
      return;
    }

    final message = !_modification
        ? switch (r.statut) {
            'en_attente'        => 'Produit ajouté — en attente de validation',
            'actif' || 'epuise' => 'Produit ajouté et publié',
            _                   => 'Produit ajouté',
          }
        : (r.statut == 'en_attente' && _statut != 'en_attente')
            ? 'Produit mis à jour — envoyé en validation.'
            : 'Produit mis à jour';
    afficherMessage(context, message);
    context.canPop() ? context.pop() : context.go('/producteur/catalogue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? 'Modifier le produit' : 'Nouveau produit'),
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  if (_modification) ...[
                    _BandeauStatut(statut: _statut, motif: _motifRefus),
                    const SizedBox(height: 14),
                  ],

                  // ── Photo ──────────────────────────────────────
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.blanc,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.grisBord),
                      ),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : _imageActuelle != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                        imageUrl: ImageUtils.imageUrl(_imageActuelle),
                                        fit: BoxFit.cover),
                                    const Positioned(
                                      right: 10, bottom: 10,
                                      child: PuceStatut('Changer la photo',
                                          couleur: AppColors.vertFonce),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 40, color: AppColors.grisTexte),
                                    SizedBox(height: 8),
                                    Text('Ajouter une photo',
                                        style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _nomCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit *',
                      prefixIcon: Icon(Icons.eco_outlined),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),

                  // ── Catégorie (obligatoire côté serveur) ───────
                  ref.watch(categoriesProvider).when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text(ErreurChargement.message(e),
                            style: const TextStyle(color: AppColors.rouge)),
                        data: (cats) => DropdownButtonFormField<int>(
                          initialValue: cats.any((c) => c['id'] == _categorieId)
                              ? _categorieId
                              : null,
                          items: [
                            for (final c in cats)
                              DropdownMenuItem(
                                value: c['id'] as int,
                                child: Text('${c['nom']}',
                                    overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: (v) => setState(() => _categorieId = v),
                          decoration: const InputDecoration(
                            labelText: 'Catégorie *',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (v) => v == null ? 'Requis' : null,
                        ),
                      ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _varCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Variété',
                      prefixIcon: Icon(Icons.grass),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Prix & unité ───────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prixCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Prix (HTG) *',
                            prefixIcon: Icon(Icons.sell_outlined),
                          ),
                          validator: (v) =>
                              (double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0) <= 0
                                  ? 'Prix invalide'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ref.watch(unitesMesureProvider).when(
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const Text(
                                  'Unités indisponibles',
                                  style: TextStyle(fontSize: 12, color: AppColors.rouge)),
                              data: (liste) {
                                _uniteVenteId ??= liste.isNotEmpty ? liste.first.id : null;
                                return DropdownButtonFormField<int>(
                                  initialValue: liste.any((u) => u.id == _uniteVenteId)
                                      ? _uniteVenteId
                                      : null,
                                  isExpanded: true,
                                  items: [
                                    for (final u in liste)
                                      DropdownMenuItem(
                                        value: u.id,
                                        child: Text(u.nom, overflow: TextOverflow.ellipsis),
                                      ),
                                  ],
                                  onChanged: (v) => setState(() => _uniteVenteId = v),
                                  decoration: const InputDecoration(labelText: 'Unité *'),
                                  validator: (v) => v == null ? 'Requis' : null,
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Stock & seuil ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock *',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (v) =>
                              int.tryParse(v ?? '') == null ? 'Requis' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _seuilCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Seuil d\'alerte',
                            prefixIcon: Icon(Icons.warning_amber_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: AppColors.blanc, strokeWidth: 2))
                        : Icon(_modification ? Icons.save_outlined : Icons.add),
                    label: Text(_modification
                        ? 'Enregistrer les modifications'
                        : 'Ajouter le produit'),
                    onPressed: _isLoading ? null : _sauvegarder,
                  ),
                  if (!_modification) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Le produit sera visible des acheteurs après validation '
                      'par l\'équipe Makèt Peyizan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: AppColors.grisTexte),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// Statut de modération en tête du formulaire de modification.
class _BandeauStatut extends StatelessWidget {
  final String statut;
  final String motif;
  const _BandeauStatut({required this.statut, required this.motif});

  @override
  Widget build(BuildContext context) {
    final (Color couleur, IconData icone, String titre, String texte) = switch (statut) {
      'refuse' => (
          AppColors.rouge,
          Icons.block_rounded,
          'Produit refusé',
          '${motif.isNotEmpty ? 'Motif : $motif\n' : ''}'
              'Modifiez le produit : il sera soumis à nouveau.',
        ),
      'en_attente' => (
          AppColors.orange,
          Icons.schedule_rounded,
          'En cours de validation',
          'Invisible aux acheteurs pour le moment.',
        ),
      'actif' || 'epuise' => (
          AppColors.vertVif,
          Icons.check_circle_outline_rounded,
          'Produit publié',
          'Changer le nom, la description, la variété, la catégorie ou la '
              'photo le renverra en validation. Prix et stock : sans validation.',
        ),
      _ => (
          AppColors.grisTexte,
          Icons.visibility_off_outlined,
          'Produit non publié',
          'Ce produit n\'est pas visible des acheteurs.',
        ),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teinte(couleur),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: couleur.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre,
                    style: TextStyle(fontWeight: FontWeight.w700, color: couleur)),
                const SizedBox(height: 2),
                Text(texte, style: const TextStyle(fontSize: 13, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
