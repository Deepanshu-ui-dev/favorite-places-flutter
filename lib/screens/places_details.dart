import 'package:favorite_places/models/places.dart';
import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget{
  const PlaceDetailScreen({super.key,required this.place});

  final Places place;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Center(
        child: Text(
          place.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
      ),
    );
  }
}