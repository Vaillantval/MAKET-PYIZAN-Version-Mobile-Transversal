import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/mes_produits_provider.dart';

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

  String  _uniteVente  = 'kg';
  int?    _categorieId;
  File?   _imageFile;
  bool    _isLoading   = false;

  static const _unites = [
    ('kg',     'Kilogramme (kg)'),
    ('tonne',  'Tonne'),
    ('sac_50', 'Sac 50 kg'),
    ('sac_25', 'Sac 25 kg'),
    ('botte',  'Botte'),
    ('piece',  'Pièce'),
    ('litre',  'Litre'),
    ('carton', 'Carton'),
    ('douz',   'Douzaine'),
  ];

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
    setState(() => _isLoading = true);

    final body = <String, dynamic>{
      'nom':              _nomCtrl.text.trim(),
      'variete':          _varCtrl.text.trim(),
      'description':      _descCtrl.text.trim(),
      'prix_unitaire':    _prixCtrl.text.trim(),
      'stock_disponible': int.tryParse(_stockCtrl.text) ?? 0,
      'seuil_alerte':     int.tryParse(_seuilCtrl.text) ?? 10,
      'unite_vente':      _uniteVente,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.slug == null
              ? '✅ Produit créé avec succès !'
              : '✅ Produit modifié !'),
          backgroundColor: AppColors.vertVif,
        ),
      );
      context.go('/producteur/catalogue');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de la sauvegarde.'),
          backgroundColor: AppColors.rouge,
        ),
      );
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
                    color:        AppColors.vertMenthe,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(
                      color: AppColors.vertVif.withOpacity(0.3),
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                              size:  48,
                              color: AppColors.vertVif,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color:      AppColors.vertVif,
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
                  child: DropdownButtonFormField<String>(
                    value:    _uniteVente,
                    items:    _unites.map((u) => DropdownMenuItem(
                      value: u.$1,
                      child: Text(u.$2,
                        overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) =>
                        setState(() => _uniteVente = v!),
                    decoration: const InputDecoration(
                      labelText: 'Unité *',
                    ),
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
                  backgroundColor: AppColors.vertFonce,
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
