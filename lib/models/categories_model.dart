import 'package:flutter/material.dart';

class ServiceItem {
  final String image;
  final String badge;
  final String text;
  final Color color;

  ServiceItem({
    required this.image,
    required this.badge,
    required this.text,
    required this.color,
  });
}


class ShortcutItem {
  final IconData icon;
  final String label;

  ShortcutItem({required this.icon, required this.label});
}

class RestaurantItem {
  final String name;
  final String rating;
  final String image;

  RestaurantItem({
    required this.name,
    required this.rating,
    required this.image,
  });
}