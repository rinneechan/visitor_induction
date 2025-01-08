class Plantvisit {
  final int id;
  final String plantCode;
  final String plantName;

  Plantvisit({
    required this.id,
    required this.plantCode,
    required this.plantName,
  });

  factory Plantvisit.fromJson(Map<String, dynamic> json) {
    return Plantvisit(
      id: json['id'],
      plantCode: json['plant_code'],
      plantName: json['plant_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_code': plantCode,
      'plant_name': plantName,
    };
  }
}
