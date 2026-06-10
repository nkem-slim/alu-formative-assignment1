import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String organizer;
  final String organizerEmail;
  final DateTime date;
  final String location;
  final String description;
  final bool isPaid;
  final double? price;
  final bool isOnCampus;
  final bool hasFood;
  final int likes;
  final int dislikes;
  final int comments;
  final Color headerColor;

  const Event({
    required this.id,
    required this.title,
    required this.organizer,
    required this.organizerEmail,
    required this.date,
    required this.location,
    required this.description,
    this.isPaid = false,
    this.price,
    this.isOnCampus = false,
    this.hasFood = false,
    this.likes = 0,
    this.dislikes = 0,
    this.comments = 0,
    required this.headerColor,
  });

  bool get isFree => !isPaid;
}
