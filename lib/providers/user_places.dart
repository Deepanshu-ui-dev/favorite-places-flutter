import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/places.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';


Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        '''
        CREATE TABLE user_places(
          id TEXT PRIMARY KEY,
          title TEXT,
          image TEXT,
          lat REAL,
          lng REAL,
          address TEXT
        )
        ''',
      );
    },
    version: 1,
  );

  return db;
}

class UserPlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }


  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');

    final places = data.map((row) {
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image'] as String),
        location: PlaceLocation(
          latitude: row['lat'] as double,
          longitude: row['lng'] as double,
          address: row['address'] as String,
        ),
        details: '',
      );
    }).toList();

    state = places;
  }


  Future<void> addPlace(
    String title,
    File image,
    PlaceLocation location,
    String details,
  ) async {
    
    final appDir = await syspaths.getApplicationSupportDirectory();
    final fileName = path.basename(image.path);
    final copiedImage =
        await image.copy('${appDir.path}/$fileName');

    final newPlace = Place(
      title: title,
      image: copiedImage,
      location: location,
      details: details,
    );

    final db = await _getDatabase();

    await db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
    );

    state = [newPlace, ...state];
  }
}


final userPlacesProvider =
    NotifierProvider<UserPlacesNotifier, List<Place>>(
  UserPlacesNotifier.new,
);