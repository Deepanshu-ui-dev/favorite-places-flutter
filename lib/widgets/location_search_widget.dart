import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/models/places.dart';
import 'package:favorite_places/providers/location_service.dart';

class LocationSearchWidget extends ConsumerStatefulWidget {
  const LocationSearchWidget({
    super.key,
    required this.onLocationSelected,
  });

  final void Function(PlaceLocation location) onLocationSelected;

  @override
  ConsumerState<LocationSearchWidget> createState() {
    return _LocationSearchWidgetState();
  }
}

class _LocationSearchWidgetState
    extends ConsumerState<LocationSearchWidget> {
  final _searchController = TextEditingController();
  late FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final searchQuery = _searchController.text.trim();
    final searchResults =
        ref.watch(locationSearchProvider(searchQuery));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Text(
          'Search Location',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        /// Search Field
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search by address or place name',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.location_on,
              color: colorScheme.primary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        /// Empty State
        if (searchQuery.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Start typing to search for a location',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          )
        else
          searchResults.when(
            /// Loading
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Searching for "$searchQuery"...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Error
            error: (error, stackTrace) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),

            /// Data
            data: (results) {
              if (results.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'No results found for "$searchQuery"',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final result = results[index];

                  return Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        result.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        result.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () async {
                        try {
                          _focusNode.unfocus();

                          final locationService =
                              ref.read(locationServiceProvider);

                          final placeLocation =
                              await locationService
                                  .getLocationFromCoordinates(
                            result.latitude,
                            result.longitude,
                          );

                          widget.onLocationSelected(placeLocation);

                          _searchController.clear();
                          setState(() {});

                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    colorScheme.primary,
                                content: Text(
                                  'Location selected: ${result.displayName}',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    colorScheme.error,
                                content: Text(
                                  e.toString(),
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: colorScheme.onError,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}