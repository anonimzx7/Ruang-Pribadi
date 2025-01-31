import 'package:flutter/material.dart';
import '../database/database.dart';

class BahasaJepang extends StatelessWidget {
  const BahasaJepang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PilihanHalaman(),
    );
  }
}

class PilihanHalaman extends StatefulWidget {
  const PilihanHalaman({super.key});

  @override
  PilihanHalamanState createState() => PilihanHalamanState();
}

class PilihanHalamanState extends State<PilihanHalaman> {
  String pilihanHuruf = "hiragana";
  bool acak = false;
  String? kategori = 'a';
  bool showKategoriDropdown = false;
  List<Map<String, dynamic>> daftarHuruf = [];
  List<String> kategoriList = [];
  List<String> hurufList = ['hiragana', 'katakana'];

  Future<void> ambilKategori() async {
    try {
      final db = await DatabaseHelper.database;
      String query =
          "SELECT DISTINCT group_name FROM $pilihanHuruf WHERE group_name IS NOT NULL";
      List<Map<String, dynamic>> kategoriData = await db.rawQuery(query);

      List<String> kategoriTemp =
          kategoriData.map((e) => e['group_name'] as String).toSet().toList();

      setState(() {
        kategoriList = kategoriTemp;
      });
    } catch (e) {
      print("Gagal mengambil kategori: $e");
    }
  }

  void ambilData() async {
    List<Map<String, dynamic>> data;

    final db = await DatabaseHelper.database;

    String query = "SELECT * FROM $pilihanHuruf";

    // Hanya tambahkan filter kategori jika "Pilih berdasarkan kategori" diaktifkan
    if (showKategoriDropdown && kategori != null && kategori!.isNotEmpty) {
      query += " WHERE group_name = '$kategori'";
    }

    // Tambahkan pengacakan jika "Acak" diaktifkan
    if (acak) {
      query += " ORDER BY RANDOM()";
    }

    data = await db.rawQuery(query);

    setState(() {
      daftarHuruf = data;
    });

    if (daftarHuruf.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TampilanHurufHalaman(daftarHuruf: daftarHuruf),
        ),
      );
    } else {
      print("Tidak ada data yang ditemukan.");
    }
  }

  @override
  void initState() {
    super.initState();
    ambilKategori();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pilih Jenis Huruf:"),
            DropdownButton<String>(
              value: pilihanHuruf,
              items: hurufList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  pilihanHuruf = newValue!;
                  ambilKategori();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: acak,
                  onChanged: (value) {
                    setState(() {
                      acak = value!;
                    });
                  },
                ),
                Text("Acak"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: showKategoriDropdown,
                  onChanged: (value) {
                    setState(() {
                      showKategoriDropdown = value!;
                    });
                  },
                ),
                Text("Pilih berdasarkan kategori"),
              ],
            ),
            if (showKategoriDropdown)
              DropdownButton<String>(
                value: kategori,
                items: kategoriList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    kategori = newValue;
                  });
                },
              ),
            ElevatedButton(
              onPressed: ambilData,
              child: Text("Tampilkan Huruf"),
            ),
          ],
        ),
      ),
    );
  }
}

class TampilanHurufHalaman extends StatefulWidget {
  final List<Map<String, dynamic>> daftarHuruf;

  const TampilanHurufHalaman({super.key, required this.daftarHuruf});

  @override
  TampilanHurufHalamanState createState() => TampilanHurufHalamanState();
}

class TampilanHurufHalamanState extends State<TampilanHurufHalaman> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Belajar Huruf Jepang")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.daftarHuruf.isEmpty
            ? Center(child: Text("Belum ada data"))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.daftarHuruf[currentIndex]['character'] ??
                        'Tidak ada karakter',
                    style: TextStyle(fontSize: 40),
                  ),
                  Text(
                    widget.daftarHuruf[currentIndex]['romaji'] ??
                        'Tidak ada romaji',
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: currentIndex > 0
                            ? () {
                                setState(() {
                                  currentIndex--;
                                });
                              }
                            : null,
                        child: Text("Back"),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: currentIndex < widget.daftarHuruf.length - 1
                            ? () {
                                setState(() {
                                  currentIndex++;
                                });
                              }
                            : null,
                        child: Text("Next"),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
