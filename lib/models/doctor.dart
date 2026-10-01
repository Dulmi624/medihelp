class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.location,
    required this.experience,
    required this.rating,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String specialization;
  final String location;
  final String experience;
  final double rating;
  final String? imageUrl;
}