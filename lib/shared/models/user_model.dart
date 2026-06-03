/// Mirrors the `/profile/me` payload the backend returns. Three boolean
/// gates — `isAdmin`, `isMember`, and the membership lifecycle `status` —
/// drive the role-aware shell at the router level.
///
/// Geography (`province`, `district`, `ward`, `cell`) is read-only on the
/// app — those values are issued by an admin at verification time and are
/// never editable by the citizen themself.
class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;

  /// Role flags from the API.
  /// - `isAdmin`: politician / sector head / verification staff
  /// - `isMember`: verified party member (has a member number + card)
  /// A logged-in user with neither flag is treated as a citizen.
  final bool isAdmin;
  final bool isMember;

  /// Membership lifecycle — only meaningful when `isMember` or there is a
  /// pending application. Values from the backend: CITIZEN | PENDING |
  /// VERIFIED | SUSPENDED | EXPIRED.
  final String status;

  /// Issued at verification — the QR encodes this.
  final String? memberNumber;
  final String? memberSince;
  final String? cardExpiresAt;

  /// Admin-assigned geography (read-only on the mobile app).
  final String? province;
  final String? district;
  final String? ward;
  final String? cell;

  /// Editable address fields the citizen owns.
  final String? street;
  final String? neighbourhood;
  final String? town;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.isAdmin = false,
    this.isMember = false,
    this.status = 'CITIZEN',
    this.memberNumber,
    this.memberSince,
    this.cardExpiresAt,
    this.province,
    this.district,
    this.ward,
    this.cell,
    this.street,
    this.neighbourhood,
    this.town,
  });

  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    final joined = [f, l].where((s) => s.isNotEmpty).join(' ');
    return joined.isEmpty ? email : joined;
  }

  String get initials {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isNotEmpty && l.isNotEmpty) return '${f[0]}${l[0]}'.toUpperCase();
    if (f.isNotEmpty) return f.substring(0, f.length >= 2 ? 2 : 1).toUpperCase();
    return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'U';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend may return the profile flat or nested under `profile` —
    // unwrap if needed so callers don't have to care.
    final src = (json['profile'] is Map) ? json['profile'] as Map : json;

    return UserModel(
      id: src['id']?.toString() ?? '',
      email: src['email']?.toString() ?? '',
      firstName: src['firstName']?.toString(),
      lastName: src['lastName']?.toString(),
      phone: src['phone']?.toString(),
      avatarUrl: src['avatarUrl']?.toString(),
      isAdmin: src['isAdmin'] as bool? ?? false,
      isMember: src['isMember'] as bool? ?? false,
      status: src['status']?.toString() ?? 'CITIZEN',
      memberNumber: src['memberNumber']?.toString(),
      memberSince: src['memberSince']?.toString(),
      cardExpiresAt: src['cardExpiresAt']?.toString(),
      province: src['province']?.toString(),
      district: src['district']?.toString(),
      ward: src['ward']?.toString(),
      cell: src['cell']?.toString(),
      street: src['street']?.toString(),
      neighbourhood: src['neighbourhood']?.toString(),
      town: src['town']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'isAdmin': isAdmin,
        'isMember': isMember,
        'status': status,
        'memberNumber': memberNumber,
        'memberSince': memberSince,
        'cardExpiresAt': cardExpiresAt,
        'province': province,
        'district': district,
        'ward': ward,
        'cell': cell,
        'street': street,
        'neighbourhood': neighbourhood,
        'town': town,
      };

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? street,
    String? neighbourhood,
    String? town,
  }) =>
      UserModel(
        id: id,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isAdmin: isAdmin,
        isMember: isMember,
        status: status,
        memberNumber: memberNumber,
        memberSince: memberSince,
        cardExpiresAt: cardExpiresAt,
        province: province,
        district: district,
        ward: ward,
        cell: cell,
        street: street ?? this.street,
        neighbourhood: neighbourhood ?? this.neighbourhood,
        town: town ?? this.town,
      );
}
