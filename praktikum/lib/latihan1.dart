import 'package:flutter/material.dart'; // Import paket flutter untuk membangun UI
import 'package:http/http.dart'
    as http; // Import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import pustaka dart:convert untuk mengonversi JSON
import 'package:flutter_bloc/flutter_bloc.dart'; //Import Package flutter bloc untuk menggunakan Cubit

void main() =>
    runApp(const MyApp()); // Method utama yang dijalankan saat aplikasi dimulai

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menghilangkan tanda debug saat di run
      title: 'Menampilkan Universitas dan situs', // Judul aplikasi
      home: BlocProvider(
        create: (context) =>
            UniversityCubit(), // Membuat instance dari UniversityCubit dan melewatkan ke dalam BlocProvider
        child:
            const UniversityList(), // Menempatkan UniversityList di dalam BlocProvider
      ),
    );
  }
}

class UniversityCubit extends Cubit<String> {
  UniversityCubit()
      : super('Indonesia'); // Constructor state awalnya adalah 'Indonesia'

  void changeCountry(String newCountry) {
    emit(newCountry); // Emit event untuk mengubah negara yang dipilih
  }
}

class UniversityList extends StatelessWidget {
  const UniversityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menampilkan Universitas dan situs'),
        backgroundColor: Colors.blue, // Judul app bar
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityCubit, String>(
            builder: (context, selectedCountry) {
              return DropdownButton<String>(
                value:
                    selectedCountry, // Nilai dropdown berdasarkan negara yang dipilih
                items: <String>[
                  'Indonesia',
                  'Singapore',
                  'Malaysia',
                  'Thailand',
                  'Vietnam',
                  'Philippines',
                  'Myanmar',
                  'Cambodia',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Text untuk setiap item dropdown
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<UniversityCubit>().changeCountry(
                        newValue); // Memanggil method changeCountry dari UniversityCubit saat nilai dropdown berubah
                  }
                },
              );
            },
          ),
          const Expanded(
            child:
                UniversityListView(), // Menampilkan UniversityListView di dalam kolom yang dapat memperluas ukuran
          ),
        ],
      ),
    );
  }
}

class UniversityListView extends StatelessWidget {
  const UniversityListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityCubit, String>(
      builder: (context, selectedCountry) {
        return FutureBuilder<List<dynamic>>(
          future: fetchData(
              selectedCountry), // Mengambil data universitas berdasarkan negara yang dipilih
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(), // Menampilkan indikator loading jika data sedang dimuat
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                    'Error fetching data'), // Menampilkan pesan error jika terjadi kesalahan saat mengambil data
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length, // Jumlah item dalam daftar
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all()), //untuk border container
                    padding:
                        const EdgeInsets.all(14), //padding didalam containernya
                    child: ListTile(
                      title: Text(
                          snapshot.data![index]['name']), // Nama universitas
                      subtitle: Text(
                          'Website: ${snapshot.data![index]['web_pages'][0]}'), // Website universitas
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                    'No data available'), // Menampilkan pesan jika tidak ada data yang tersedia
              );
            }
          },
        );
      },
    );
  }

  Future<List<dynamic>> fetchData(String country) async {
    var result = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Mengambil data universitas dari API
    return json.decode(result.body); // Mengembalikan hasil parsing JSON
  }
}
