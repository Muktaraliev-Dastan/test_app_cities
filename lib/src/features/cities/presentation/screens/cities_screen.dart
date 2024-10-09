import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_cities/src/features/cities/data/model/city_model.dart';
import 'package:test_app_cities/src/features/cities/presentation/providers/providers.dart';

class CitiesScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final citiesState = ref.watch(citiesStateProvider);

    final sharedPreferencesFuture = useFuture(SharedPreferences.getInstance());

    useEffect(() {
      if (sharedPreferencesFuture.data != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(citiesStateProvider.notifier).fetchCities();
        });
      }
      return null;
    }, [sharedPreferencesFuture.data]);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              ref.read(citiesStateProvider.notifier).fetchCities(search: value);
            },
            decoration: const InputDecoration(
              hintText: 'Поиск города',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: citiesState.when(
        data: (cities) {
          if (cities.isEmpty) {
            return const Center(child: Text('Города не найдены'));
          }
          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              CityModel city = cities[index];
              return ListTile(
                title: Text(city.name),
                onTap: () {},
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
