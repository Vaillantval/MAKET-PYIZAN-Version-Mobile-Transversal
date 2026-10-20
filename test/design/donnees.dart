/// Données factices au format du backend MaketLakay, pour rendre les
/// écrans dans les tests de design.
library;

const _entreprise1 = {
  'id': 7, 'membre_id': 11, 'nom': 'Jaden Kenscoff', 'type': 'producteur',
  'type_label': 'Producteur', 'statut': 'actif', 'code': 'PROD-2026-0007',
  'role': 'proprietaire', 'role_label': 'Propriétaire',
};
const _entreprise2 = {
  'id': 9, 'membre_id': 15, 'nom': 'Kafe Lakay', 'type': 'entreprise',
  'type_label': 'Entreprise', 'statut': 'en_attente', 'code': 'PROD-2026-0009',
  'role': 'gestionnaire', 'role_label': 'Gestionnaire',
};

Map<String, dynamic> _user(String role, List<Map<String, dynamic>> entreprises) => {
  'id': 42, 'username': 'marie', 'email': 'marie.joseph@example.ht',
  'first_name': 'Marie', 'last_name': 'Joseph', 'full_name': 'Marie Joseph',
  'telephone': '+509 3700 0000', 'photo': null, 'role': role,
  'is_verified': true, 'is_superuser': false, 'is_staff': false,
  'profil_producteur_statut': entreprises.isEmpty ? null : 'actif',
  'entreprises': entreprises,
};

final utilisateurAcheteur  = _user('acheteur', []);
final utilisateurMembre    = _user('acheteur', [_entreprise1, _entreprise2]);
final utilisateurEnAttente = _user('acheteur', [
  {..._entreprise2, 'role': 'proprietaire', 'role_label': 'Propriétaire'},
]);
final utilisateurCaissier  = _user('pos_operator', []);

Map<String, dynamic> _produit(int id, String nom, String prix, String unite, int stock,
        {String categorie = 'Légumes', bool vedette = false, String commune = 'Kenscoff'}) => {
  'id': id, 'nom': nom, 'slug': 'produit-$id', 'variete': '', 'description':
      'Produit frais récolté le matin, cultivé sans pesticides dans les mornes.',
  'prix_unitaire': prix, 'unite_vente': unite, 'unite_vente_label': unite,
  'quantite_min_commande': 1, 'stock_reel': stock, 'stock_disponible': stock,
  'is_featured': vedette, 'image_principale': null, 'origine': 'Kenscoff',
  'saison': '', 'created_at': '2026-10-18T10:00:00Z',
  'categorie': {'id': 1, 'nom': categorie, 'slug': 'cat'},
  'producteur': {'id': 7, 'nom': 'Jaden Kenscoff', 'code_producteur': 'PROD-2026-0007',
                 'commune': commune, 'departement': 'ouest'},
  'prix_supplementaires': <dynamic>[],
};

final produits = [
  _produit(1, 'Tomates fraîches', '125.00', 'kg', 40, vedette: true),
  _produit(2, 'Bananes plantain', '60.00', 'pièce', 3, categorie: 'Fruits'),
  _produit(3, 'Café moulu des Thiotte (500 g)', '450.00', 'pièce', 18,
      categorie: 'Café', commune: 'Thiotte'),
  _produit(4, 'Pois noirs', '210.00', 'kg', 0, categorie: 'Céréales'),
  _produit(5, 'Mangues Francique', '35.00', 'pièce', 120, categorie: 'Fruits', vedette: true),
  _produit(6, 'Piment bouc', '20.00', 'pièce', 60, categorie: 'Épices'),
];

Map<String, dynamic> _commande(String num, String statut, String label, String total) => {
  'numero_commande': num, 'producteur_nom': 'Jaden Kenscoff', 'total': total,
  'statut': statut, 'statut_label': label, 'statut_paiement': 'paye',
  'methode_paiement': 'moncash', 'mode_livraison': 'domicile',
  'adresse_livraison': 'Rue Grégoire, Pétion-Ville', 'created_at': '2026-10-19T14:30:00Z',
  'acheteur_nom': 'Paul Pierre',
  'details': [
    {'produit_nom': 'Tomates fraîches', 'quantite': 2, 'prix_unitaire': '125.00', 'sous_total': '250.00', 'unite_vente': 'kg'},
    {'produit_nom': 'Mangues Francique', 'quantite': 6, 'prix_unitaire': '35.00', 'sous_total': '210.00', 'unite_vente': 'pièce'},
  ],
};

final commandes = [
  _commande('CMD-2026-00128', 'en_attente', 'En attente', '460.00'),
  _commande('CMD-2026-00117', 'confirmee', 'Confirmée', '1250.00'),
  _commande('CMD-2026-00098', 'livree', 'Livrée', '890.00'),
];

final _panier = {
  'items': [
    {'id': 1, 'slug': 'produit-1', 'nom': 'Tomates fraîches', 'quantite': 2,
     'prix_unitaire': '125.00', 'sous_total': '250.00', 'unite_vente': 'kg',
     'producteur_id': 7, 'producteur_nom': 'Jaden Kenscoff', 'stock_reel': 40, 'image': null},
    {'id': 2, 'slug': 'produit-3', 'nom': 'Café moulu des Thiotte (500 g)', 'quantite': 1,
     'prix_unitaire': '450.00', 'sous_total': '450.00', 'unite_vente': 'pièce',
     'producteur_id': 9, 'producteur_nom': 'Kafe Lakay', 'stock_reel': 18, 'image': null},
  ],
  'total': '700.00', 'nb_articles': 2, 'nb_items': 3,
  'producteurs': [{'id': 7, 'nom': 'Jaden Kenscoff'}, {'id': 9, 'nom': 'Kafe Lakay'}],
};

final _transactions = [
  {'id': 3, 'type': 'paiement', 'type_display': 'Paiement commande', 'montant': '-460.00',
   'solde_apres': '2540.00', 'commande_numero': 'CMD-2026-00128', 'description': 'Commande CMD-2026-00128',
   'reference': '', 'created_at': '2026-10-19T14:30:00Z'},
  {'id': 2, 'type': 'cashback', 'type_display': 'Cashback', 'montant': '25.00',
   'solde_apres': '3000.00', 'description': 'Cashback fidélité', 'reference': '',
   'created_at': '2026-10-17T09:10:00Z'},
  {'id': 1, 'type': 'recharge', 'type_display': 'Recharge MonCash', 'montant': '2975.00',
   'solde_apres': '2975.00', 'description': 'Recharge MonCash', 'reference': 'MC-8812',
   'created_at': '2026-10-15T18:00:00Z'},
];

final _posCatalogue = [
  for (final p in produits)
    {
      'id': p['id'], 'nom': p['nom'], 'categorie': p['categorie'],
      'prix_unitaire': p['prix_unitaire'],
      'unite_vente': {'id': 1, 'code': p['unite_vente'], 'nom': p['unite_vente']},
      'prix': [
        {'unite_id': 1, 'unite_code': p['unite_vente'], 'unite_nom': p['unite_vente'],
         'prix': p['prix_unitaire'], 'facteur_conversion': '1', 'est_unite_base': true},
      ],
      'stock_disponible': p['stock_reel'], 'photo_url': null, 'lots': <dynamic>[],
    },
];

Map<String, dynamic> _ok(dynamic data) => {'success': true, 'data': data};

/// Réponse factice pour un chemin d'API.
Map<String, dynamic> reponseFactice(String path, Map<String, dynamic> user) {
  switch (path) {
    case '/api/auth/me/':
      return _ok(user);
    case '/api/products/':
      return _ok({'count': produits.length, 'next': null, 'previous': null, 'results': produits});
    case '/api/products/categories/':
      return _ok([
        {'id': 1, 'nom': 'Légumes', 'slug': 'legumes', 'icone': 'fas fa-leaf'},
        {'id': 2, 'nom': 'Fruits', 'slug': 'fruits', 'emoji': '🥭'},
        {'id': 3, 'nom': 'Café', 'slug': 'cafe'},
        {'id': 4, 'nom': 'Céréales', 'slug': 'cereales'},
      ]);
    case '/api/orders/panier/':
      return _ok(_panier);
    case '/api/auth/commandes/':
    case '/api/auth/producteur/commandes/':
      return _ok(commandes);
    case '/api/wallet/':
      return _ok({
        'solde': '2540.00', 'devise': 'HTG', 'titulaire': 'Marie Joseph',
        'entreprise_id': null, 'is_active': true,
        'cashback': {'actif': true, 'taux': '2', 'plafond': '500'},
        'parrainage': {'code': 'MARIE26', 'taux_bonus': '5'},
        'transactions': _transactions,
      });
    case '/api/wallet/transactions/':
      return _ok({'count': 3, 'next': null, 'previous': null, 'results': _transactions});
    case '/api/auth/producteur/stats/':
      return _ok({
        'commandes_en_attente': 3, 'commandes_confirmees': 5, 'commandes_livrees': 41,
        'commandes_total': 49, 'revenus_total': '86450.00', 'revenus_mois': '12800.00',
        'nb_produits_actifs': 12, 'nb_produits_epuises': 2, 'alertes_stock': 1,
        'collectes_a_venir': 1,
      });
    case '/api/products/mes-produits/':
      return _ok(produits);
    case '/api/collectes/mes-participations/':
      return _ok([
        {'id': 1, 'statut': 'inscrit', 'statut_label': 'Inscrit',
         'collecte': {'reference': 'COL-2026-014', 'date_planifiee': '2026-10-24',
                      'zone': {'nom': 'Kenscoff'}, 'statut': 'planifiee'},
         'quantite_prevue': '50', 'quantite_recue': null, 'montant_paye': null,
         'paiement_effectue': false},
      ]);
    case '/api/auth/producteur/profil/':
      return _ok({
        'id': 7, 'code_producteur': 'PROD-2026-0007', 'nom': 'Jaden Kenscoff',
        'nom_affiche': 'Jaden Kenscoff', 'type_label': 'Producteur', 'statut_label': 'Actif',
        'commune': 'Kenscoff', 'departement_label': 'Ouest', 'telephone_entreprise': '+509 3711 2233',
        'adresse_complete': 'Route de Kenscoff, Furcy', 'description': 'Légumes de montagne.',
        'note_admin': '', 'mon_role': 'proprietaire',
      });
    case '/api/entreprises/7/membres/':
      return _ok([
        {'id': 11, 'user_id': 42, 'nom': 'Marie Joseph', 'email': 'marie.joseph@example.ht',
         'role': 'proprietaire', 'role_label': 'Propriétaire'},
        {'id': 12, 'user_id': 43, 'nom': 'Jacques Louis', 'email': 'jacques@example.ht',
         'role': 'gestionnaire', 'role_label': 'Gestionnaire'},
      ]);
    case '/api/pos/catalogue/':
      return _ok(_posCatalogue);
    case '/api/pos/terminal/statut/':
      return _ok({'statut': 'actif', 'device': {'id': 1, 'nom': 'Caisse 1', 'commune': 'Pétion-Ville'}});
    case '/api/pos/rapports/':
      return _ok({'nb_ventes': 0, 'chiffre_affaires': '0.00', 'ventes': <dynamic>[]});
    case '/api/geo/arbre/':
      return _ok({'departements': [
        {'slug': 'ouest', 'nom': 'Ouest', 'arrondissements': [
          {'nom': 'Port-au-Prince', 'communes': [
            {'nom': 'Kenscoff', 'sections_communales': ['1re Section Nouvelle Touraine']},
            {'nom': 'Pétion-Ville', 'sections_communales': ['1re Section Montagne Noire']},
          ]},
        ]},
      ]});
  }
  if (path.startsWith('/api/products/public/')) return _ok(produits.first);
  if (path.startsWith('/api/auth/commandes/') || path.startsWith('/api/auth/producteur/commandes/')) {
    return _ok(commandes.first);
  }
  return _ok(<dynamic>[]);
}
