import 'package:flutter/material.dart';
import 'belajar_bahasa_jepang/bahasa_jepang.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  darkModeNotifier.value = await DatabaseHelper.loadDarkMode();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          darkModeNotifier, // Mendengarkan perubahan status dark mode
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Aplikasi Belajar Bahasa Jepang',
          theme: ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.apply(
                  fontFamily: 'Roboto', // Perbaikan di sini
                ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Roboto', // Perbaikan di sini
                ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Profil sebagai halaman default

  static const List<Widget> _pages = <Widget>[
    PlaceholderWidget(), // Halaman Profil
    BahasaJepang(), // Halaman Belajar Bahasa Jepang
    PengaturanPage(), // Halaman Pengaturan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Menutup Drawer setelah memilih item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruang Pribadi'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Navigasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _onItemTapped(2),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Belajar Alfabet Jepang'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Menampilkan halaman yang dipilih
    );
  }
}

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SwitchListTile(
              title: Text('Mode Gelap'),
              value: darkModeNotifier.value,
              onChanged: (bool value) {
                darkModeNotifier.value = value;
                DatabaseHelper.saveDarkMode(value); // Simpan ke database
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Ruang Pilihan'),
    );
  }
}

// Contoh notifier untuk dark mode
final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
