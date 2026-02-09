import 'package:favorite_places/models/places.dart';
import 'package:flutter/material.dart';
import 'new_place.dart';

class FavoritesListScreen extends StatefulWidget {
  const FavoritesListScreen({super.key});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  final List<Places> _placesList = [];

  Future<void> _addNewPlace() async {
    final newPlace = await Navigator.of(context).push<Places>(
      MaterialPageRoute(
        builder: (ctx) => const NewPlace(),
      ),
    );

    if (newPlace == null) return;

    setState(() {
      _placesList.insert(0, newPlace);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.location_off, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No places added yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );

    if (_placesList.isNotEmpty) {
      content = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _placesList.length,
        itemBuilder: (ctx, index) {
          final place = _placesList[index];

          return Dismissible(
            key: ValueKey(place.id),
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _placesList.removeAt(index);
              });
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  child: Text(
                    place.title[0].toUpperCase(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                title: Text(
                  place.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tap to view details'),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        centerTitle: true,
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlace,
        child: const Icon(Icons.add),
      ),
    );
  }
}
