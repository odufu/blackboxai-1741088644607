class Stand {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String exhibitorName;
  final String exhibitorContact;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;

  Stand({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.exhibitorName,
    required this.exhibitorContact,
    this.imageUrl,
    this.additionalInfo,
  });

  factory Stand.fromJson(Map<String, dynamic> json) {
    return Stand(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      exhibitorName: json['exhibitorName'] as String,
      exhibitorContact: json['exhibitorContact'] as String,
      imageUrl: json['imageUrl'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'exhibitorName': exhibitorName,
      'exhibitorContact': exhibitorContact,
      'imageUrl': imageUrl,
      'additionalInfo': additionalInfo,
    };
  }

  Stand copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? exhibitorName,
    String? exhibitorContact,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Stand(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      exhibitorName: exhibitorName ?? this.exhibitorName,
      exhibitorContact: exhibitorContact ?? this.exhibitorContact,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
