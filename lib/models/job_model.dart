class JobDetail {
  final String id;
  final String jobTitle;
  final String jobCategory;
  final String location;
  final String salaryPackage;
  final String requiredExperience;
  final String workType;
  final int numberOfOpenings;
  final List<String> requiredSkills;
  final String jobDescription;
  final String companyName;
  final String? companyMobile;
  final String? companyWebsite;
  final String? contactEmail;
  final String? fullAddress;
  final String jobStatus;
  final int price;
  final String priceType;
  final String createdAt;
  final String updatedAt;
  final bool companyIsHide;
  final bool locked;
  final bool hasApplied;

  JobDetail({
    required this.id,
    required this.jobTitle,
    required this.jobCategory,
    required this.location,
    required this.salaryPackage,
    required this.requiredExperience,
    required this.workType,
    required this.numberOfOpenings,
    required this.requiredSkills,
    required this.jobDescription,
    required this.companyName,
    this.companyMobile,
    this.companyWebsite,
    this.contactEmail,
    this.fullAddress,
    required this.jobStatus,
    required this.price,
    required this.priceType,
    required this.createdAt,
    required this.updatedAt,
    required this.companyIsHide,
    required this.locked,
    this.hasApplied = false,
  });

  factory JobDetail.fromJson(Map<String, dynamic> json) {
    return JobDetail(
      id: json['_id'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      jobCategory: json['jobCategory'] ?? '',
      location: json['location'] ?? '',
      salaryPackage: json['salaryPackage']?.toString() ?? '',
      requiredExperience: json['requiredExperience'] ?? '',
      workType: json['workType'] ?? '',
      numberOfOpenings: (json['numberOfOpenings'] ?? 0).toInt(),
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      jobDescription: json['jobDescription'] ?? '',
      companyName: json['companyName'] ?? '',
      companyMobile: json['companyMobile'],
      companyWebsite: json['companyWebsite'],
      contactEmail: json['contactEmail'],
      fullAddress: json['fullAddress'],
      jobStatus: json['jobStatus'] ?? '',
      price: (json['price'] ?? 0).toInt(),
      priceType: json['priceType'] ?? 'free',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      companyIsHide: json['companyIsHide'] ?? false,
      locked: json['locked'] ?? false,
      hasApplied: json['hasApplied'] ?? false,
    );
  }

  JobDetail copyWith({
    bool? locked,
    bool? companyIsHide,
    String? jobStatus,
    int? price,
    String? priceType,
    bool? hasApplied,
  }) {
    return JobDetail(
      id: id,
      jobTitle: jobTitle,
      jobCategory: jobCategory,
      location: location,
      salaryPackage: salaryPackage,
      requiredExperience: requiredExperience,
      workType: workType,
      numberOfOpenings: numberOfOpenings,
      requiredSkills: requiredSkills,
      jobDescription: jobDescription,
      companyName: companyName,
      companyMobile: companyMobile,
      companyWebsite: companyWebsite,
      contactEmail: contactEmail,
      fullAddress: fullAddress,
      jobStatus: jobStatus ?? this.jobStatus,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      createdAt: createdAt,
      updatedAt: updatedAt,
      companyIsHide: companyIsHide ?? this.companyIsHide,
      locked: locked ?? this.locked,
      hasApplied: hasApplied ?? this.hasApplied,
    );
  }
}