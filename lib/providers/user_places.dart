import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:favorite_places/models/places.dart';

class UserPlacesNotifier extends StateNotifier<List<Places>>{
  UserPlacesNotifier():super(const []);

  void addPlace(String title){
    final newPlace = Places(title: title);
    state = [newPlace,...state];
  }
}


final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier,List<Places>>(
  (ref)=>UserPlacesNotifier(),
);