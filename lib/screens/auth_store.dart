import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? profileImagePath;

  const AppUser({
    required this.name,
    required this.email,
    required this.password,
    this.phone = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.profileImagePath,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profileImagePath,
  }) => AppUser(
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    profileImagePath: profileImagePath ?? this.profileImagePath,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'profileImagePath': profileImagePath,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    password: json['password'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    address: json['address'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    profileImagePath: json['profileImagePath'] as String?,
  );
}

class AuthStore {
  static const _usersKey = 'auth_users_v1';
  static const _sessionEmailKey = 'auth_session_email';
  static const _sessionTokenKey = 'auth_session_token';
  static const demoEmail = '423000470@ntc.edu.ph';
  static const demoPassword = 'customer123';

  static Future<List<AppUser>> _readUsers() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_usersKey);
    final users = stored == null
        ? <AppUser>[]
        : (jsonDecode(stored) as List<dynamic>)
              .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
              .toList();
    if (!users.any((user) => user.email.toLowerCase() == demoEmail)) {
      users.insert(
        0,
        const AppUser(
          name: 'Justine Berdejo',
          email: demoEmail,
          password: demoPassword,
        ),
      );
      await _writeUsers(users);
    }
    return users;
  }

  static Future<void> _writeUsers(List<AppUser> users) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _usersKey,
      jsonEncode(users.map((user) => user.toJson()).toList()),
    );
  }

  static Future<AppUser?> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readUsers();
    for (final user in users) {
      if (user.email.toLowerCase() == normalizedEmail &&
          user.password == password) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(_sessionEmailKey, user.email);
        await preferences.setString(
          _sessionTokenKey,
          List<int>.generate(
            32,
            (_) => Random.secure().nextInt(256),
          ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
        );
        return user;
      }
    }
    return null;
  }

  static Future<AppUser?> currentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_sessionEmailKey);
    final token = preferences.getString(_sessionTokenKey);
    if (email == null || token == null || token.isEmpty) return null;
    for (final user in await _readUsers()) {
      if (user.email.toLowerCase() == email.toLowerCase()) return user;
    }
    await signOut();
    return null;
  }

  static Future<bool> saveUser(
    AppUser updated, {
    required String previousEmail,
  }) async {
    final users = await _readUsers();
    final index = users.indexWhere(
      (user) => user.email.toLowerCase() == previousEmail.toLowerCase(),
    );
    if (index < 0 ||
        users.any(
          (user) =>
              user.email.toLowerCase() == updated.email.toLowerCase() &&
              user.email.toLowerCase() != previousEmail.toLowerCase(),
        )) {
      return false;
    }
    users[index] = updated;
    await _writeUsers(users);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionEmailKey, updated.email);
    return true;
  }

  static Future<bool> register(AppUser user) async {
    final users = await _readUsers();
    if (users.any(
      (existing) => existing.email.toLowerCase() == user.email.toLowerCase(),
    )) {
      return false;
    }
    users.add(user);
    await _writeUsers(users);
    return true;
  }

  static Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionEmailKey);
    await preferences.remove(_sessionTokenKey);
  }
}
