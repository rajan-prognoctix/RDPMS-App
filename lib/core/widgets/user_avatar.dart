import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Round user avatar: the profile photo when there is one, else the initials
/// of [name] on the primary colour. Used by the User Profile page and the
/// side-menu header.
class UserAvatar extends StatelessWidget {
  final String name;

  /// Local photo file, from the profile.
  final String? photoPath;

  /// Network photo, when the API provides one. Used only if [photoPath] is null.
  final String? photoUrl;

  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.photoUrl,
    this.radius = 32,
  });

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = photoPath != null
        ? FileImage(File(photoPath!))
        : photoUrl != null
            ? NetworkImage(photoUrl!)
            : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Text(
        initials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.68,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}