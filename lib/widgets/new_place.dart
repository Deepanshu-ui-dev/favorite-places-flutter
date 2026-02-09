import 'package:flutter/material.dart';
import 'package:favorite_places/models/places.dart';

class NewPlace extends StatefulWidget {
  const NewPlace({super.key});

  @override
  State<NewPlace> createState() => _NewPlaceState();
}

class _NewPlaceState extends State<NewPlace> {
  final _formKey = GlobalKey<FormState>();
  String _enteredPlace = '';
  var _isSubmitting = false;

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newPlace = Places(
      _enteredPlace,
      DateTime.now().toString(),
    );

    Navigator.of(context).pop(newPlace);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Create a new favorite place',
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Place name',
                      prefixIcon: const Icon(Icons.place),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.trim().length < 2) {
                        return 'Enter a valid place name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredPlace = value ?? '';
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _formKey.currentState!.reset(),
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _saveItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Place'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
