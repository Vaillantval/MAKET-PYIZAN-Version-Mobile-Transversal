// Le backend renvoie parfois les montants/quantités décimaux sous
// forme de chaînes (ex: "500.00") au lieu de nombres JSON — ces
// helpers tolèrent les deux formes pour éviter un crash `as num`
// dans le code généré par json_serializable.

double jsonToDouble(dynamic v) => v == null
    ? 0.0
    : v is num
        ? v.toDouble()
        : double.tryParse(v.toString()) ?? 0.0;

double? jsonToDoubleNullable(dynamic v) => v == null
    ? null
    : v is num
        ? v.toDouble()
        : double.tryParse(v.toString());
