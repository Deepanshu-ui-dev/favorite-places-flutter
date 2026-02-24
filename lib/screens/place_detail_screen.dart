import 'package:flutter/material.dart';

import 'package:favorite_places/models/places.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Image.file(
                place.image,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(place.location.address),
              subtitle: Text(
                'Lat: ${place.location.latitude.toStringAsFixed(4)}, Lng: ${place.location.longitude.toStringAsFixed(4)}',
              ),
            ),
            const SizedBox(height: 16),
            if (place.details.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        place.details,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
