import 'package:flutter/material.dart';

import 'package:favorite_places/models/places.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  late PlaceLocation _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.location;
  }

  void _moveLocation(double latChange, double lngChange) {
    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: _pickedLocation.latitude + latChange,
        longitude: _pickedLocation.longitude + lngChange,
        address: _pickedLocation.address,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Placeholder for the map view
                Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Map View Placeholder',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          'Lat: ${_pickedLocation.latitude.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          'Lng: ${_pickedLocation.longitude.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isSelecting)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _moveLocation(0.01, 0),
                              icon: const Icon(Icons.arrow_upward),
                              label: const Text('North'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _moveLocation(0, -0.01),
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('West'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _moveLocation(0, 0.01),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('East'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _moveLocation(-0.01, 0),
                              icon: const Icon(Icons.arrow_downward),
                              label: const Text('South'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Removed the separate Container for selected location info as it's now integrated into the map placeholder
        ],
      ),
    );
  }
}



