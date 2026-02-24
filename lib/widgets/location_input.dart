import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favorite_places/screens/map.dart';
import 'package:favorite_places/models/places.dart';
import 'package:favorite_places/widgets/location_search_widget.dart';

const maptilerKey = 'Nmo1zs45VCXFFKXCLOXw';

// Read Geoapify API key from compile-time define to avoid committing secrets.
// Provide it with: `--dart-define=GEOAPIFY_API_KEY=your_key_here`
const geoapifyKey = String.fromEnvironment('GEOAPIFY_API_KEY', defaultValue: '');

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

  @override
  void initState() {
    super.initState();
    // Auto-fetch current location when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getCurrentLocation();
      }
    });
  }

  String _getApiKey() {
    // Try to get API key from compile-time define first, then fall back to .env
    if (geoapifyKey.isNotEmpty) return geoapifyKey;
    return dotenv.env['GEOAPIFY_API_KEY'] ?? '';
  }

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    // Use Geoapify static map for preview (more reliable with provided key)
    final key = _getApiKey();
    if (key.isEmpty) return '';
    return 'https://maps.geoapify.com/v1/staticmap?center=lonlat:$lng,$lat&zoom=14&width=600&height=300&style=osm-carto&apiKey=$key';
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    try {
      setState(() => _errorMessage = null);
      
      final key = _getApiKey();
      if (key.isEmpty) {
        throw Exception(
            'Geoapify API key not set. Provide with --dart-define=GEOAPIFY_API_KEY=your_key or create a .env file');
      }

      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$latitude&lon=$longitude&apiKey=$key',
      );

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
          'https://maps.geoapify.com/v1/staticmap?center=lonlat:$longitude,$latitude&zoom=14&width=600&height=300&style=osm-carto&apiKey=$key';
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
      setState(() {
        _isGettingLocation = true;
        _errorMessage = null;
      });

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          final msg = 'Location service is not enabled on this device';
          setState(() {
            _errorMessage = msg;
            _isGettingLocation = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.orange),
            );
          }
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          final msg = 'Location permission is required. Please enable it in settings.';
          setState(() {
            _errorMessage = msg;
            _isGettingLocation = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.orange),
            );
          }
          return;
        }
      }

      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat == null || lng == null) {
        final msg = 'Could not retrieve location coordinates';
        setState(() {
          _errorMessage = msg;
          _isGettingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
        return;
      }

      await _savePlace(lat, lng);
    } catch (e) {
      final msg = 'Location error: ${e.toString()}';
      print('Location error: $e'); // Debug log
      setState(() {
        _errorMessage = msg;
        _isGettingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
    return Column(
      children: [
        // Primary action: Current Location button at the top
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                if (_errorMessage != null && _errorMessage!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isGettingLocation)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Getting your current location...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  )
                else if (_pickedLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location Captured',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pickedLocation!.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_pickedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_pickedLocation!.longitude.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Tap below to capture your current location',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Capture Current Location'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Secondary: Map selection
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectOnMap,
            icon: const Icon(Icons.map),
            label: const Text('Select Location on Map'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Tertiary: Search bar for manual search
        Text(
          'Or search for a specific location:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        LocationSearchWidget(
          onLocationSelected: (location) {
            setState(() {
              _pickedLocation = location;
            });
            widget.onSelectLocation(location);
          },
        ),
        const SizedBox(height: 20),
        // Location preview map
        if (_pickedLocation != null && locationImage.isNotEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Container(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}