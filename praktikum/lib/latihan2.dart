import 'package:flutter/material.dart'; // Import paket flutter untuk membangun UI
import 'package:http/http.dart'
    as http; // Import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import pustaka dart:convert untuk mengonversi JSON
import 'package:flutter_bloc/flutter_bloc.dart'; //Import Package flutter bloc untuk bisa digunakan

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
            UniversityBloc(), // Membuat instance dari UniversityBloc dan melewatkan ke dalam BlocProvider
        child:
            const UniversityList(), // Menempatkan UniversityList di dalam BlocProvider
      ),
    );
  }
}

class UniversityEvent {
  final String country; // Event untuk mengubah negara yang dipilih

  UniversityEvent(this.country); // Konstruktor event dengan parameter negara
}

class UniversityState {
  final String selectedCountry; // State yang menyimpan negara yang dipilih

  UniversityState(
      this.selectedCountry); // Konstruktor state dengan parameter negara
}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  UniversityBloc() : super(UniversityState('Indonesia')) {
    // Constructor untuk UniversityBloc, state awalnya adalah Indonesia
    on<UniversityEvent>((event, emit) {
      // Mendaftarkan penanganan event untuk UniversityEvent yang akan menghasilkan state baru dengan negara yang dipilih dari event
      emit(UniversityState(event.country));
    });
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
          BlocBuilder<UniversityBloc, UniversityState>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: state
                    .selectedCountry, // Nilai dropdown berdasarkan negara yang dipilih
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
                    context.read<UniversityBloc>().add(UniversityEvent(
                        newValue)); // Memanggil event UniversityEvent(newValue) saat nilai dropdown berubah
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
    return BlocBuilder<UniversityBloc, UniversityState>(
      builder: (context, state) {
        return FutureBuilder<List<dynamic>>(
          future: fetchData(state
              .selectedCountry), // Mengambil data universitas berdasarkan negara yang dipilih
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
