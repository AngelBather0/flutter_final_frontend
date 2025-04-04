class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final List<Profile> profiles;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profiles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      fullName: json['full_name'],
      email: json['email'],
      profiles: (json['profiles'] as List)
          .map((profile) => Profile.fromJson(profile))
          .toList(),
    );
  }

  bool get isProvider {
    return profiles.any((profile) => profile.role == 'provider');
  }
}

class Profile {
  final String id;
  final String role;

  Profile({
    required this.id,
    required this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      role: json['role'],
    );
  }
}