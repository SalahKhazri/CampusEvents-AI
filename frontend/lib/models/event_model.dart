class EventModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String startDateTime;
  final String endDateTime;
  final String locationName;
  final String? locationAddress;
  final String organizerName;
  final int capacity;
  final String? tags;
  final String? imageUrl;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final int registrationCount;
  bool isFavorite;
  bool isRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDateTime,
    required this.endDateTime,
    required this.locationName,
    this.locationAddress,
    required this.organizerName,
    required this.capacity,
    this.tags,
    this.imageUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.registrationCount = 0,
    this.isFavorite = false,
    this.isRegistered = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      startDateTime: json['start_date_time'] ?? '',
      endDateTime: json['end_date_time'] ?? '',
      locationName: json['location_name'] ?? '',
      locationAddress: json['location_address'],
      organizerName: json['organizer_name'] ?? '',
      capacity: json['capacity'] ?? 0,
      tags: json['tags'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      registrationCount: json['registration_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'start_date_time': startDateTime,
        'end_date_time': endDateTime,
        'location_name': locationName,
        'location_address': locationAddress,
        'organizer_name': organizerName,
        'capacity': capacity,
        'tags': tags,
        'image_url': imageUrl,
        'is_active': isActive,
      };

  bool get isFullyBooked => registrationCount >= capacity;
  bool get isUpcoming {
    try {
      return DateTime.parse(startDateTime).isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }
}
