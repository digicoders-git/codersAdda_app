class JobDetail {
  final String id;
  final String title;
  final String company;
  final String location;
  final String experience;
  final String jobType;
  final List<String> skills;
  final String salary;
  final String position;
  final int totalOpenings;
  final String companyAddress;
  final String companyEmail;
  final String companyMobile;
  final String companyWebsite;
  final String description;
  final String applyLink;
  final String addedDate;
  final String lastDate;

  JobDetail({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.experience,
    required this.jobType,
    required this.skills,
    required this.salary,
    required this.position,
    required this.totalOpenings,
    required this.companyAddress,
    required this.companyEmail,
    required this.companyMobile,
    required this.companyWebsite,
    required this.description,
    required this.applyLink,
    required this.addedDate,
    required this.lastDate,
  });
}