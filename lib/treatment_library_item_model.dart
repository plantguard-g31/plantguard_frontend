class TreatmentLibraryItemModel {
  final String id;
  final String diseaseName;
  final String cropType;
  final String severity;
  final String pesticideName;
  final String dosage;
  final String applicationTiming;
  final String safetyInstructions;
  final dynamic preHarvestIntervalDays;
  final String sourceReference;

  TreatmentLibraryItemModel({
    required this.id,
    required this.diseaseName,
    required this.cropType,
    required this.severity,
    required this.pesticideName,
    required this.dosage,
    required this.applicationTiming,
    required this.safetyInstructions,
    required this.preHarvestIntervalDays,
    required this.sourceReference,
  });

  factory TreatmentLibraryItemModel.fromJson(Map<String, dynamic> json) {
    return TreatmentLibraryItemModel(
      id: (json['id'] ?? json['treatment_id'] ?? '').toString(),
      diseaseName: (
        json['disease_name'] ??
        json['disease_label'] ??
        json['disease'] ??
        'Unknown Disease'
      ).toString(),
      cropType: (
        json['crop_type'] ??
        json['crop'] ??
        'unknown'
      ).toString(),
      severity: (
        json['severity'] ??
        json['severity_level'] ??
        'Not assigned'
      ).toString(),
      pesticideName: (
        json['pesticide_name'] ??
        json['pesticide'] ??
        json['treatment'] ??
        'Not available'
      ).toString(),
      dosage: (
        json['dosage'] ??
        json['dose'] ??
        'Not available'
      ).toString(),
      applicationTiming: (
        json['application_timing'] ??
        json['timing'] ??
        'Not available'
      ).toString(),
      safetyInstructions: (
        json['safety_instructions'] ??
        json['safety'] ??
        'Not available'
      ).toString(),
      preHarvestIntervalDays: json['pre_harvest_interval_days'] ??
          json['pre_harvest_interval'] ??
          json['phi_days'],
      sourceReference: (
        json['source_reference'] ??
        json['source'] ??
        'Not available'
      ).toString(),
    );
  }

  String get displayDisease {
    return diseaseName.replaceAll('__', ' ').replaceAll('_', ' ');
  }

  String get displayCrop {
    return cropType.replaceAll('_', ' ').toUpperCase();
  }

  String get displaySeverity {
    if (severity.trim().isEmpty) {
      return 'Not assigned';
    }

    return severity.replaceAll('_', ' ');
  }

  String get displayPreHarvestInterval {
    if (preHarvestIntervalDays == null ||
        preHarvestIntervalDays.toString().trim().isEmpty ||
        preHarvestIntervalDays.toString() == 'null') {
      return 'Not available';
    }

    return 'Wait $preHarvestIntervalDays days before harvesting';
  }
}