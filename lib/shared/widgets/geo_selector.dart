import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/offline/cache_manager.dart';

/// Sélecteur géographique cascade :
/// Département → Commune → Section Communale
class GeoSelector extends ConsumerStatefulWidget {
  final Function(String dept, String commune, String section) onChanged;
  final String? initialDept;
  final String? initialCommune;
  final String? initialSection;

  const GeoSelector({
    required this.onChanged,
    this.initialDept,
    this.initialCommune,
    this.initialSection,
    super.key,
  });

  @override
  ConsumerState<GeoSelector> createState() => _GeoSelectorState();
}

class _GeoSelectorState extends ConsumerState<GeoSelector> {
  List<Map<String, dynamic>> _depts    = [];
  List<Map<String, dynamic>> _communes = [];
  List<String>               _sections = [];

  String? _selectedDept;
  String? _selectedCommune;
  String? _selectedSection;
  bool    _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerDepts();
  }

  Future<void> _chargerDepts() async {
    final cache = ref.read(cacheManagerProvider);
    final api   = ref.read(apiClientProvider);

    // Essayer le cache 24h
    final cached = cache.getGeo();
    if (cached != null) {
      final depts = (cached['departements'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() { _depts = depts; _loading = false; });
      _setInitialValues();
      return;
    }

    try {
      final res  = await api.get(AppEndpoints.geoArbre);
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final geoData = data['data'] as Map<String, dynamic>;
        await cache.saveGeo(geoData);
        final depts = (geoData['departements'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() { _depts = depts; _loading = false; });
        _setInitialValues();
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _setInitialValues() {
    if (widget.initialDept != null) {
      _selectedDept = widget.initialDept;
      _chargerCommunes(widget.initialDept!);
    }
  }

  void _chargerCommunes(String deptSlug) {
    final dept = _depts.firstWhere(
      (d) => d['slug'] == deptSlug || d['nom'] == deptSlug,
      orElse: () => {},
    );
    if (dept.isEmpty) return;

    final communes = <Map<String, dynamic>>[];
    for (final arrond in (dept['arrondissements'] as List? ?? [])) {
      for (final commune in (arrond['communes'] as List? ?? [])) {
        communes.add(Map<String, dynamic>.from(commune as Map));
      }
    }
    setState(() {
      _communes        = communes;
      _selectedCommune = widget.initialCommune;
      _selectedSection = null;
      _sections        = [];
    });

    if (widget.initialCommune != null) {
      _chargerSections(widget.initialCommune!);
    }
  }

  void _chargerSections(String communeNom) {
    final commune = _communes.firstWhere(
      (c) => c['nom'] == communeNom,
      orElse: () => {},
    );
    if (commune.isEmpty) return;

    final sections = List<String>.from(
      (commune['sections_communales'] as List? ?? []).cast<String>()
    );
    setState(() {
      _sections        = sections;
      _selectedSection = widget.initialSection;
    });
  }

  void _notifyChanged() {
    widget.onChanged(
      _selectedDept    ?? '',
      _selectedCommune ?? '',
      _selectedSection ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.vertVif),
      );
    }

    return Column(
      children: [
        // Département
        _buildDropdown(
          label:    'Département',
          value:    _selectedDept,
          items:    _depts.map((d) => DropdownMenuItem(
            value: d['slug'] as String,
            child: Text(d['nom'] as String),
          )).toList(),
          onChanged: (v) {
            setState(() {
              _selectedDept    = v;
              _selectedCommune = null;
              _selectedSection = null;
              _communes        = [];
              _sections        = [];
            });
            if (v != null) _chargerCommunes(v);
            _notifyChanged();
          },
        ),
        const SizedBox(height: 12),

        // Commune
        _buildDropdown(
          label:    'Commune',
          value:    _selectedCommune,
          enabled:  _communes.isNotEmpty,
          items:    _communes.map((c) => DropdownMenuItem(
            value: c['nom'] as String,
            child: Text(c['nom'] as String),
          )).toList(),
          onChanged: (v) {
            setState(() {
              _selectedCommune = v;
              _selectedSection = null;
              _sections        = [];
            });
            if (v != null) _chargerSections(v);
            _notifyChanged();
          },
        ),
        const SizedBox(height: 12),

        // Section communale (optionnel)
        _buildDropdown(
          label:    'Section communale (optionnel)',
          value:    _selectedSection,
          enabled:  _sections.isNotEmpty,
          items:    _sections.map((s) => DropdownMenuItem(
            value: s, child: Text(s),
          )).toList(),
          onChanged: (v) {
            setState(() => _selectedSection = v);
            _notifyChanged();
          },
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String                    label,
    required T?                        value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>          onChanged,
    bool                               enabled = true,
  }) => DropdownButtonFormField<T>(
    value:       value,
    items:       items,
    onChanged:   enabled ? onChanged : null,
    isExpanded:  true,
    decoration: InputDecoration(
      labelText:   label,
      enabled:     enabled,
      filled:      true,
      fillColor:   enabled ? Colors.white : AppColors.grisClair,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
    ),
    hint: Text(
      enabled ? 'Sélectionner...' : 'Choisir d\'abord le niveau précédent',
      style: TextStyle(
        color: enabled ? AppColors.noir : AppColors.grisTexte,
        fontSize: 13,
      ),
    ),
  );
}
