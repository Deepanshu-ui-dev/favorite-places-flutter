import 'package:favorite_places/providers/user_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget{
  const AddPlaceScreen({super.key});


  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaxeScreenState();
}

class _AddPlaxeScreenState extends ConsumerState<AddPlaceScreen>{
   
   void _savePlaces(){

    final enteredTitle = _titleController.text;

    if(enteredTitle.isEmpty){
     return;
    }

    ref.read(userPlacesProvider.notifier).addPlace(enteredTitle);
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
              ),
              controller:_titleController,
              style:TextStyle(color:Theme.of(context).colorScheme.onBackground) ,
            ),
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