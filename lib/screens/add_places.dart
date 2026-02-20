import 'dart:io';

import 'package:favorite_places/providers/user_places.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget{
  const AddPlaceScreen({super.key});


  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaxeScreenState();
}

class _AddPlaxeScreenState extends ConsumerState<AddPlaceScreen>{
  File? _pickedImage;
  
   void _savePlaces(){

    final enteredTitle = _titleController.text;

    if(enteredTitle.isEmpty){
     return;
    }

    if (_pickedImage == null) {
      return;
    }

    ref.read(userPlacesProvider.notifier).addPlace(enteredTitle, _pickedImage!);
    Navigator.of(context).pop();

   }

  final _titleController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Place'
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          
          children: [
            TextField(
              decoration:const InputDecoration(
                label: Text('Title'),
                hintText: 'Enter your title',
              ),
              controller:_titleController,
              style:TextStyle(color:Theme.of(context).colorScheme.onBackground) ,
            ),
            SizedBox(height: 16,),
            ImageInput(onPickImage: (image){
              setState((){
                _pickedImage = image;
              });
            }),
            SizedBox(height: 16,),
            LocationInput(),
            SizedBox(height: 16,),
            ElevatedButton.icon(
              onPressed:_savePlaces, 
              icon:const Icon(Icons.add),
              label: const Text('Add Place')),
          ],
        ),
      ),

    );
    
  }
}