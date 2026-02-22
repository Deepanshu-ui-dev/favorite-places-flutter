import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/models/places.dart';

class UserPlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() => const [];

  void addPlace(String title, File image, PlaceLocation location) {
    final newPlace = Place(title: title, image: image, location: location);
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    NotifierProvider<UserPlacesNotifier, List<Place>>(
  UserPlacesNotifier.new,
);