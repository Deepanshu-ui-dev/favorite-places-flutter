import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:favorite_places/models/places.dart';

class LocationSearchResult {
  final double latitude;
  final double longitude;
  final String address;
  final String displayName;

  LocationSearchResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.displayName,
  });
}

class LocationService {
  final String apiKey;

  LocationService(this.apiKey);

  Future<List<LocationSearchResult>> searchLocation(String query) async {
    if (query.isEmpty) {
      return [];
    }

    if (apiKey.isEmpty) {
      throw Exception('Geoapify API key is not configured');
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://api.geoapify.com/v1/geocode/search?text=$encodedQuery&apiKey=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location search request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to search location (status: ${response.statusCode})');
      }

      final resData = json.decode(response.body);
      final features = resData['features'] as List<dynamic>? ?? [];

      return features.map((feature) {
        final properties = feature['properties'] as Map<String, dynamic>? ?? {};
        final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
        final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

        final longitude = coordinates.isNotEmpty ? coordinates[0] as double : 0.0;
        final latitude = coordinates.length > 1 ? coordinates[1] as double : 0.0;
        final address =
            properties['formatted'] as String? ?? properties['address_line1'] ?? 'Unknown';
        final displayName = properties['name'] as String? ?? address;

        return LocationSearchResult(
          latitude: latitude,
          longitude: longitude,
          address: address,
          displayName: displayName,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error searching location: ${e.toString()}');
    }
  }

  Future<PlaceLocation> getLocationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    if (apiKey.isEmpty) {
      throw Exception('Geoapify API key is not configured');
    }

    try {
      final url =
          'https://api.geoapify.com/v1/geocode/reverse?lat=$latitude&lon=$longitude&apiKey=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Reverse geocoding request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get address (status: ${response.statusCode})');
      }

      final resData = json.decode(response.body);
      final features = resData['features'] as List<dynamic>? ?? [];

      if (features.isEmpty) {
        return PlaceLocation(
          latitude: latitude,
          longitude: longitude,
          address: 'Coordinates: $latitude, $longitude',
        );
      }

      final properties = features[0]['properties'] as Map<String, dynamic>? ?? {};
      final address =
          properties['formatted'] as String? ?? properties['address_line1'] ?? 'Unknown location';

      return PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
    } catch (e) {
      throw Exception('Error getting address: ${e.toString()}');
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  final apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';
  return LocationService(apiKey);
});

final locationSearchProvider = FutureProvider.family<List<LocationSearchResult>, String>(
  (ref, query) async {
    final locationService = ref.watch(locationServiceProvider);
    return locationService.searchLocation(query);
  },
);
