import 'package:favorite_places/models/places.dart';
import 'package:favorite_places/screens/places_details.dart';
import 'package:flutter/material.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.places});

  final List<Places> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Center(
        child: Text(
          'No places added yet',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(

        
        
        child: ListView.builder(
          itemCount: places.length,
          itemBuilder: (ctx, index) => SizedBox(
            height: 75,
            child: ListTile(
              leading: CircleAvatar(
                
                radius: 30,
                backgroundImage: FileImage(places[index].image),
              ),
              title: Text(
                places[index].title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>PlaceDetailScreen(place: places[index])));
              },
              
            ),
          ),
        ),
      ),
    );
  }
}
