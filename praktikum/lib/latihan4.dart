import 'package:flutter/material.dart'; // Import paket flutter untuk membangun UI
import 'package:http/http.dart'
    as http; // Import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import pustaka dart:convert untuk mengonversi JSON
import 'package:provider/provider.dart'; //Import paket provider untuk menggunakan ChangeNotifierProvider, Consumer, dan Provider

void main() =>
    runApp(const MyApp()); // Main function yang memulai aplikasi Flutter

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menghilangkan tanda debug saat di run
      title: 'Menampilkan Universitas dan situs', // Judul aplikasi
      home: ChangeNotifierProvider(
        create: (context) =>
            UniversityProvider(), // Membuat provider untuk state management
        child:
            const UniversityList(), // Menampilkan halaman UniversityList sebagai home
      ),
    );
  }
}

class UniversityProvider with ChangeNotifier {
  String selectedCountry = 'Indonesia'; // Negara default yang dipilih

  void changeCountry(String? newCountry) {
    selectedCountry = newCountry!; // Mengubah negara yang dipilih
    notifyListeners(); // Memberi tahu listener tentang perubahan pada state
  }
}

class UniversityList extends StatelessWidget {
  const UniversityList({super.key});

  @override
  Widget build(BuildContext context) {
    var universityProvider = Provider.of<UniversityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menampilkan Universitas dan situs'),
        backgroundColor: Colors.blue, // Judul AppBar
      ),
      body: Column(
        // Memuat combobox dan listview di dalam Column
        children: [
          // DropdownButton untuk memilih negara ASEAN
          DropdownButton<String>(
            value:
                universityProvider.selectedCountry, // Nilai negara yang dipilih
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
                child: Text(value), // Menampilkan nama negara pada dropdown
              );
            }).toList(),
            onChanged: (String? newValue) {
              universityProvider.changeCountry(
                  newValue); // Mengubah negara ASEAN yang dipilih
            },
          ),
          const Expanded(
            // Menggunakan Expanded untuk memungkinkan listview menempati sisa ruang yang tersedia
            child:
                UniversityListView(), // Menempatkan UniversityListView di bawah combobox
          ),
        ],
      ),
    );
  }
}

class UniversityListView extends StatefulWidget {
  const UniversityListView({super.key});

  @override
  State<UniversityListView> createState() {
    return _UniversityListViewState();
  }
}

class _UniversityListViewState extends State<UniversityListView> {
  List<dynamic> universities = []; // List untuk menyimpan data universitas

  Future<void> fetchData(String country) async {
    var result = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Melakukan HTTP GET request untuk mendapatkan data universitas berdasarkan negara
    setState(() {
      universities = json.decode(
          result.body); // Mendecode respons JSON ke dalam list universitas
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(
        'Indonesia'); // Mengambil data universitas Indonesia saat initState dipanggil
  }

  @override
  Widget build(BuildContext context) {
    var universityProvider = Provider.of<UniversityProvider>(context);

    if (universityProvider.selectedCountry != '') {
      fetchData(universityProvider
          .selectedCountry); // Mengambil data universitas berdasarkan negara yang dipilih
    }

    return ListView.builder(
      itemCount: universities.length, // Jumlah item dalam list universitas
      itemBuilder: (BuildContext context, int index) {
        return Container(
          decoration:
              BoxDecoration(border: Border.all()), //untuk border container
          padding: const EdgeInsets.all(14), //padding didalam containernya
          child: ListTile(
            title: Text(
                universities[index]['name']), // Menampilkan nama universitas
            subtitle: Text(
                'Website: ${universities[index]['web_pages'][0]}'), // Menampilkan website universitas
          ),
        );
      },
    );
  }
}
