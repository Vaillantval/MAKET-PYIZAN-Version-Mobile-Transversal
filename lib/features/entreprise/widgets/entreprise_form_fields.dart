import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/geo_selector.dart';

/// Valeurs saisies pour créer une entreprise — même format que
/// EntrepriseCreationSerializer côté backend (POST /api/entreprises/ ou
/// champ `entreprise` de POST /api/auth/register/).
class EntrepriseFormController {
  String type = 'producteur';
  String? departement;
  String? commune;
  String? localite;
  String? provenance;
  String? activite;

  final nom             = TextEditingController();
  final telephone       = TextEditingController();
  final adresse         = TextEditingController();
  final description     = TextEditingController();
  // Producteur
  final superficie      = TextEditingController();
  final numId           = TextEditingController();
  // Fournisseur
  final zonesDesservies = TextEditingController();
  // Entreprise
  final nif             = TextEditingController();
  final siteWeb         = TextEditingController();

  /// Message d'erreur si la localisation (requise par le backend) manque.
  String? valider() {
    if ((departement ?? '').isEmpty || (commune ?? '').isEmpty) {
      return 'Département et commune de l\'entreprise sont requis.';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    String? t(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return {
      'type_entreprise': type,
      'nom':             nom.text.trim(),
      'departement':     departement,
      'commune':         commune,
      if (t(telephone) != null)   'telephone_entreprise': t(telephone),
      if (t(adresse) != null)     'adresse_complete':     t(adresse),
      if (t(description) != null) 'description':          t(description),
      // Le backend ignore les champs propres aux autres types
      if (type == 'producteur') ...{
        if ((localite ?? '').isNotEmpty) 'localite': localite,
        if (double.tryParse(superficie.text.trim()) != null)
          'superficie_ha': double.parse(superficie.text.trim()),
        if (t(numId) != null) 'num_identification': t(numId),
      },
      if (type == 'fournisseur') ...{
        if (provenance != null) 'provenance': provenance,
        if (t(zonesDesservies) != null) 'zones_desservies': t(zonesDesservies),
      },
      if (type == 'entreprise') ...{
        if (activite != null) 'activite': activite,
        if (t(nif) != null)     'nif':      t(nif),
        if (t(siteWeb) != null) 'site_web': t(siteWeb),
      },
    };
  }

  void dispose() {
    for (final c in [nom, telephone, adresse, description, superficie,
        numId, zonesDesservies, nif, siteWeb]) {
      c.dispose();
    }
  }
}

/// Champs du formulaire de création d'entreprise. À placer dans un `Form`
/// (les validateurs des champs texte s'y rattachent).
class EntrepriseFormFields extends StatefulWidget {
  final EntrepriseFormController controller;
  const EntrepriseFormFields({required this.controller, super.key});

  @override
  State<EntrepriseFormFields> createState() => _EntrepriseFormFieldsState();
}

class _EntrepriseFormFieldsState extends State<EntrepriseFormFields> {
  static const _types = [
    ('producteur',  'Producteur',  'Je cultive / j\'élève',                Icons.agriculture_outlined),
    ('fournisseur', 'Fournisseur', 'Je revends des produits',             Icons.local_shipping_outlined),
    ('entreprise',  'Entreprise',  'Transformation, marque, coopérative…', Icons.storefront_outlined),
  ];

  static const _provenances = [
    ('propre',      'Production propre'),
    ('achat_local', 'Achat auprès de producteurs locaux'),
    ('importation', 'Importation'),
  ];

  static const _activites = [
    ('transformation', 'Transformation'),
    ('marque',         'Marque / fabricant'),
    ('cooperative',    'Coopérative'),
    ('commerce',       'Commerce'),
    ('autre',          'Autre'),
  ];

  EntrepriseFormController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type d\'entreprise',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        for (final t in _types)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TypeTile(
              label:    t.$2,
              aide:     t.$3,
              icone:    t.$4,
              selected: c.type == t.$1,
              onTap:    () => setState(() => c.type = t.$1),
            ),
          ),
        const SizedBox(height: 8),
        TextFormField(
          controller: c.nom,
          decoration: const InputDecoration(
            labelText:  'Nom de l\'entreprise *',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
          validator: (v) => (v ?? '').trim().isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller:   c.telephone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText:  'Téléphone professionnel (optionnel)',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Localisation *',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GeoSelector(
          key: const ValueKey('geo-entreprise'),
          onChanged: (dept, commune, section) => setState(() {
            c.departement = dept;
            c.commune     = commune;
            c.localite    = section;
          }),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: c.adresse,
          decoration: const InputDecoration(
            labelText:  'Adresse (optionnel)',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 16),
        ..._champsType(),
        TextFormField(
          controller: c.description,
          maxLines:   3,
          decoration: const InputDecoration(
            labelText:  'Description (optionnel)',
            prefixIcon: Icon(Icons.description_outlined),
          ),
        ),
      ],
    );
  }

  List<Widget> _champsType() {
    switch (c.type) {
      case 'fournisseur':
        return [
          DropdownButtonFormField<String>(
            initialValue: c.provenance,
            items: _provenances.map((p) =>
                DropdownMenuItem(value: p.$1, child: Text(p.$2))).toList(),
            onChanged: (v) => setState(() => c.provenance = v),
            decoration: const InputDecoration(
              labelText:  'Provenance des produits (optionnel)',
              prefixIcon: Icon(Icons.local_shipping_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: c.zonesDesservies,
            decoration: const InputDecoration(
              labelText:  'Zones desservies (optionnel)',
              prefixIcon: Icon(Icons.map_outlined),
            ),
          ),
          const SizedBox(height: 16),
        ];
      case 'entreprise':
        return [
          DropdownButtonFormField<String>(
            initialValue: c.activite,
            items: _activites.map((a) =>
                DropdownMenuItem(value: a.$1, child: Text(a.$2))).toList(),
            onChanged: (v) => setState(() => c.activite = v),
            decoration: const InputDecoration(
              labelText:  'Activité (optionnel)',
              prefixIcon: Icon(Icons.factory_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: c.nif,
            decoration: const InputDecoration(
              labelText:  'NIF / patente (optionnel)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller:   c.siteWeb,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText:  'Site web ou réseau social (optionnel)',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 16),
        ];
      default:
        return [
          TextFormField(
            controller:   c.superficie,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText:  'Superficie exploitée (ha, optionnel)',
              prefixIcon: Icon(Icons.landscape_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: c.numId,
            decoration: const InputDecoration(
              labelText:  'N° d\'identification (optionnel)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
        ];
    }
  }
}

class _TypeTile extends StatelessWidget {
  final String label;
  final String aide;
  final IconData icone;
  final bool   selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.label,
    required this.aide,
    required this.icone,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color:        AppColors.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.noir : AppColors.grisBord,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            TuileIcone(icone,
                couleur: selected ? AppColors.vertFonce : AppColors.grisTexte,
                taille: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(aide, style: const TextStyle(
                    fontSize: 12, color: AppColors.grisTexte)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.noir),
          ],
        ),
      ),
    );
  }
}
