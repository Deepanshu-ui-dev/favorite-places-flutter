import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favorite_places/screens/map.dart';
import 'package:favorite_places/models/places.dart';

const maptilerKey = 'Nmo1zs45VCXFFKXCLOXw';

// Read Geoapify API key from compile-time define to avoid committing secrets.
// Provide it with: `--dart-define=GEOAPIFY_KEY=your_key_here`
const geoapifyKey = String.fromEnvironment('GEOAPIFY_KEY', defaultValue: '');

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  String? _errorMessage;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    // Use Geoapify static map for preview (more reliable with provided key)
    final key = geoapifyKey.isNotEmpty ? geoapifyKey : dotenv.env['GEOAPIFY_KEY'] ?? '';
    if (key.isEmpty) return '';
    return 'https://maps.geoapify.com/v1/staticmap?center=lonlat:$lng,$lat&zoom=14&width=600&height=300&style=osm-carto&apiKey=$key';
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    try {
      setState(() => _errorMessage = null);
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$latitude&lon=$longitude&apiKey=$geoapifyKey',
      );

      final key = geoapifyKey.isNotEmpty ? geoapifyKey : dotenv.env['GEOAPIFY_KEY'] ?? '';
      if (key.isEmpty) {
        throw Exception(
            'Geoapify API key not set. Provide with --dart-define=GEOAPIFY_KEY=your_key or create a .env file');
      }

      final response = await http.get(url.replace(queryParameters: {
        ...url.queryParameters,
        'apiKey': key,
      })).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch address (status: ${response.statusCode})');
      }

      final resData = json.decode(response.body);
      if (resData['features'] == null || resData['features'].isEmpty) {
        throw Exception('No address found');
      }

      // Geoapify's formatted address is in features[0].properties.formatted
      final address = resData['features'][0]['properties']?['formatted'] ??
          resData['features'][0]['properties']?['address_line1'] ??
          'Unknown location';

        // Verify static map preview (use Geoapify) before setting picked location
        // so we can give better debug feedback if the tiles or key/style are invalid.
        final staticMapUrl =
          'https://maps.geoapify.com/v1/staticmap?center=lonlat:$longitude,$latitude&zoom=14&width=600&height=300&style=osm-carto&apiKey=$geoapifyKey';
      try {
        final mapResp = await http
            .get(Uri.parse(staticMapUrl))
            .timeout(const Duration(seconds: 8));
        if (mapResp.statusCode != 200) {
          // surface a non-fatal warning to the user but continue setting location
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Map preview load failed (status ${mapResp.statusCode}). Check API key/style.'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Map preview check failed: ${e.toString()}'),
        ));
      }

      setState(() {
        _pickedLocation = PlaceLocation(
          latitude: latitude,
          longitude: longitude,
          address: address,
        );
        _isGettingLocation = false;
      });

      widget.onSelectLocation(_pickedLocation!);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  void _getCurrentLocation() async {
    Location location = Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() => _errorMessage = 'Location service disabled');
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() => _errorMessage = 'Permission denied');
          return;
        }
      }

      setState(() {
        _isGettingLocation = true;
        _errorMessage = null;
      });

      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat == null || lng == null) {
        setState(() => _errorMessage = 'Could not get location');
        return;
      }

      await _savePlace(lat, lng);
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    }
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<PlaceLocation>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    await _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No location chosen',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );

    if (_isGettingLocation) {
      previewContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Getting location...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (_pickedLocation != null && locationImage.isNotEmpty) {
      previewContent = Container(
        color: Colors.grey[200],
        child: Image.network(
          locationImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Map Preview',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat: ${_pickedLocation!.latitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  'Lng: ${_pickedLocation!.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: previewContent,
          ),
        ),
        const SizedBox(height: 16),
        if (_pickedLocation != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _pickedLocation!.address,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat: ${_pickedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_pickedLocation!.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Current Location'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map),
                label: const Text('Select on Map'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}