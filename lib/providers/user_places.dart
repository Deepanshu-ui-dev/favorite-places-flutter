import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/places.dart';

class UserPlacesNotifier extends Notifier<List<Places>> {
  @override
  List<Places> build() => const [];

  void addPlace(String title, File image) {
    final newPlace = Places(title: title, image: image);
    state = [newPlace, ...state];
  }
}


final userPlacesProvider = NotifierProvider<UserPlacesNotifier, List<Places>>(
  UserPlacesNotifier.new,
);