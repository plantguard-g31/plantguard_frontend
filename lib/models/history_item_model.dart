class HistoryItemModel {
  final String id;
  final String diseaseLabel;
  final String cropType;
  final double confidence;
  final String severity;
  final DateTime? diagnosedAt;

  HistoryItemModel({
    required this.id,
    required this.diseaseLabel,
    required this.cropType,
    required this.confidence,
    required this.severity,
    required this.diagnosedAt,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: (json['id'] ?? '').toString(),
      diseaseLabel: (
        json['disease_label'] ??
        json['disease'] ??
        'Unknown Disease'
      ).toString(),
      cropType: (
        json['crop_type'] ??
        json['crop'] ??
        'Unknown'
      ).toString(),
      confidence: _toDouble(json['confidence']),
      severity: (json['severity'] ?? 'Not assigned').toString(),
      diagnosedAt: _parseDate(json['diagnosed_at']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String get displayDisease {
    return diseaseLabel
        .replaceAll('__', ' ')
        .replaceAll('_', ' ');
  }

  String get displayCrop {
    return cropType
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  String get displayConfidence {
    double value = confidence;

    if (value <= 1) {
      value = value * 100;
    }

    return '${value.toStringAsFixed(1)}%';
  }

  String get displayDate {
    if (diagnosedAt == null) {
      return 'Date not available';
    }

    final date = diagnosedAt!;

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}