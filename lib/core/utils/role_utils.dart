/// Le wallet est accessible aux acheteurs ET aux producteurs (retraits),
/// avec les mêmes écrans montés sous deux préfixes de route différents.
String walletBasePath(String? role) =>
    role == 'producteur' ? '/producteur' : '/acheteur';
