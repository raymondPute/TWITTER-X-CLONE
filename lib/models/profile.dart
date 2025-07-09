class Profile {
  final String id; // User ID
  final String name;
  final String email;
  final String dateOfBirth; // Format: YYYY-MM-DD
  final String? bio; // Optional bio
  final String? profileImageUrl;
  final List<String>? followers; // List of user IDs who follow this user
  final List<String>? following; // List of user IDs this user is following

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    this.bio,
    this.profileImageUrl,
    this.followers,
    this.following,
  });

  // Convert Profile object to a Map (useful for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'followers': followers ?? [], // Store as an empty list if null
      'following': following ?? [], // Store as an empty list if null
    };
  }

  // Create a Profile object from a Map (e.g., fetched from Firestore)
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      dateOfBirth: map['date_of_birth'],
      bio: map['bio'],
      profileImageUrl: map['profile_image_url'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }
}
