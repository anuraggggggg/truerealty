class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.developer,
    required this.imageUrl,
    required this.priceRange,
    required this.totalUnits,
    required this.availableUnits,
    required this.activeLeads,
    required this.visits,
    required this.brochureUrl,
    required this.brochureFileName,
    required this.configurations,
    required this.raw,
  });

  final String id;
  final String name;
  final String location;
  final String status;
  final String developer;
  final String imageUrl;
  final String priceRange;
  final int totalUnits;
  final int availableUnits;
  final int activeLeads;
  final int visits;
  final String? brochureUrl;
  final String? brochureFileName;
  final List<String> configurations;
  final Map<String, dynamic> raw;

  bool get hasBrochure =>
      brochureUrl != null && brochureUrl!.trim().isNotEmpty;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final units = _asMapList(json['units']);
    final available = units.where((unit) {
      final availability = _readString(unit, const [
        'availability',
        'status',
        'bookingStatus',
      ]).toLowerCase();
      return availability.contains('available') ||
          availability.contains('open');
    }).length;

    final visitsFromUnits = units.fold<int>(0, (sum, unit) {
      final visitCount = unit['visitCount'];
      if (visitCount is num) return sum + visitCount.toInt();
      final count = unit['_count'];
      if (count is Map && count['siteVisits'] is num) {
        return sum + (count['siteVisits'] as num).toInt();
      }
      return sum;
    });

    final upcoming = json['upcomingVisits'];
    final visits = upcoming is num ? upcoming.toInt() : visitsFromUnits;

    final brochure = _firstBrochure(json);
    final minPrice = json['minPrice'];
    final maxPrice = json['maxPrice'];
    final priceRange = _readString(json, const ['priceRange']).isNotEmpty
        ? _readString(json, const ['priceRange'])
        : _formatPriceRange(minPrice, maxPrice);

    return ProjectModel(
      id: _readString(json, const ['id', 'projectId']),
      name: _readString(json, const ['name', 'projectName', 'title'],
          fallback: 'Untitled Project'),
      location: _readString(json, const [
        'location',
        'area',
        'city',
        'address',
      ], fallback: 'Location not available'),
      status: _readString(json, const [
        'status',
        'projectStatus',
      ], fallback: 'Active'),
      developer: _readString(json, const ['developer', 'builder']),
      imageUrl: _readString(json, const [
        'imageUrl',
        'coverImage',
        'image',
        'thumbnail',
      ]),
      priceRange: priceRange.isEmpty ? 'Price on request' : priceRange,
      totalUnits: units.isNotEmpty
          ? units.length
          : _readInt(json, const ['totalUnits', 'inventory', 'unitCount']),
      availableUnits: units.isNotEmpty
          ? available
          : _readInt(json, const ['availableUnits', 'available']),
      activeLeads: _readInt(json, const ['activeLeads', 'linkedLeads', 'leads']),
      visits: visits,
      brochureUrl: brochure?.$1,
      brochureFileName: brochure?.$2,
      configurations: _stringList(json['configurations']),
      raw: json,
    );
  }

  static (String?, String?)? _firstBrochure(Map<String, dynamic> json) {
    final url = _readString(json, const ['brochureUrl', 'brochure']);
    final fileName = _readString(json, const [
      'brochureFileName',
      'brochureName',
    ]);
    if (url.isNotEmpty) {
      return (url, fileName.isEmpty ? _fileNameFromUrl(url) : fileName);
    }

    final brochures = _asMapList(json['brochures']);
    if (brochures.isEmpty) return null;
    final first = brochures.first;
    final brochureUrl = _readString(first, const ['url', 'brochureUrl']);
    if (brochureUrl.isEmpty) return null;
    final brochureName = _readString(first, const ['fileName', 'name']);
    return (
      brochureUrl,
      brochureName.isEmpty ? _fileNameFromUrl(brochureUrl) : brochureName,
    );
  }

  static String _fileNameFromUrl(String url) {
    final path = Uri.tryParse(url)?.pathSegments;
    if (path == null || path.isEmpty) return 'Brochure.pdf';
    return path.last;
  }

  static String _formatPriceRange(Object? minPrice, Object? maxPrice) {
    final min = _formatInr(minPrice);
    final max = _formatInr(maxPrice);
    if (min == null && max == null) return '';
    if (min != null && max != null) return '$min - $max';
    return min ?? max ?? '';
  }

  static String? _formatInr(Object? value) {
    final number = _toDouble(value);
    if (number == null || number <= 0) return null;
    if (number >= 10000000) {
      final cr = number / 10000000;
      final formatted = cr >= 10
          ? cr.toStringAsFixed(0)
          : cr.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
      return 'INR $formatted Cr';
    }
    if (number >= 100000) {
      final lac = number / 100000;
      final formatted = lac >= 10
          ? lac.toStringAsFixed(0)
          : lac.toStringAsFixed(1).replaceFirst(RegExp(r'\.?0+$'), '');
      return 'INR $formatted L';
    }
    return 'INR ${number.toStringAsFixed(0)}';
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', ''));
    return null;
  }

  static List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }
}

class ProjectSummary {
  const ProjectSummary({
    required this.totalProjects,
    required this.totalUnits,
    required this.availableUnits,
    required this.linkedLeads,
  });

  final int totalProjects;
  final int totalUnits;
  final int availableUnits;
  final int linkedLeads;
}

enum ProjectFilter {
  all,
  active,
  readyToMove,
  underConstruction,
  highDemand,
}

extension ProjectFilterX on ProjectFilter {
  String get label {
    switch (this) {
      case ProjectFilter.all:
        return 'All Projects';
      case ProjectFilter.active:
        return 'Active';
      case ProjectFilter.readyToMove:
        return 'Ready To Move';
      case ProjectFilter.underConstruction:
        return 'Under Construction';
      case ProjectFilter.highDemand:
        return 'High Demand';
    }
  }

  bool matches(ProjectModel project) {
    final status = project.status.trim().toLowerCase();
    switch (this) {
      case ProjectFilter.all:
        return true;
      case ProjectFilter.active:
        return status == 'active';
      case ProjectFilter.readyToMove:
        return status.contains('ready');
      case ProjectFilter.underConstruction:
        return status.contains('under construction') ||
            status.contains('construction');
      case ProjectFilter.highDemand:
        return status.contains('high demand') || status.contains('demand');
    }
  }
}
