// import 'package:favorite_places/widgets/places_list.dart';
import 'package:favorite_places/providers/user_places.dart';
import 'package:favorite_places/screens/add_place.dart';
import 'package:favorite_places/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() {
    return _PlacesScreenState();
  }
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late Future<void> _placesFuture;

  @override
  void initState() {
    _placesFuture = ref.read(UserPlacesProvider.notifier).loadPlaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(UserPlacesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Places"), actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AddPlaceScreen()));
          },
          icon: const Icon(Icons.add),
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 1),
        child: FutureBuilder(
            future: _placesFuture,
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : PlacesList(places: userPlaces)),
      ),
    );
  }
}
