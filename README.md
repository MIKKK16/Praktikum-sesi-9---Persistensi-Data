# Jawaban Praktikum Flutter Minggu 13

Persistensi Data: JSON, SharedPreferences, File System, dan Secure Storage

**Nama:** David Pratama  
**NIM:** 23.52.0001

---

## Soal 1 - Nama panggilan di title dan warna tema (Praktikum 1)

Title aplikasi diberi nama panggilan lewat konstanta `nickname`, dan warna tema diganti dengan mengubah `seedColor` pada `ColorScheme.fromSeed` menjadi teal.

```dart
const String nickname = 'David';

MaterialApp(
  title: 'Store Data $nickname',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    useMaterial3: true,
  ),
  home: const MyHomePage(),
);
```
<img width="979" height="526" alt="image" src="https://github.com/user-attachments/assets/1134de27-0507-4dc5-8785-5d9a70d7cf2b" />

## Soal 2 - Screenshot hasil membaca JSON (Praktikum 1)

File `assets/pizzalist.json` dibaca dengan `DefaultAssetBundle.of(context).loadString()`. Pada tahap ini isi file belum diubah menjadi objek, sehingga seluruh JSON tampil sebagai satu teks panjang di layar.

```dart
String pizzaString = '';

Future readJsonFile() async {
  String myString = await DefaultAssetBundle
      .of(context)
      .loadString('assets/pizzalist.json');
  setState(() {
    pizzaString = myString;
  });
}
```
<img width="979" height="526" alt="image" src="https://github.com/user-attachments/assets/e9418ec3-fc4a-48df-9457-87b736e625dc" />

## Soal 3 - Screenshot hasil ListView List<Pizza> (Praktikum 1)

Alur konversinya: String JSON diubah `jsonDecode()` menjadi `List<Map>`, tiap Map diubah `Pizza.fromJson()` menjadi objek `Pizza`, lalu ditampilkan dengan `ListView.builder`. Hasilnya daftar pizza tampil terstruktur, satu `ListTile` untuk tiap objek.

```dart
List pizzaMapList = jsonDecode(myString);
List<Pizza> myPizzas = [];
for (var pizza in pizzaMapList) {
  Pizza myPizza = Pizza.fromJson(pizza);
  myPizzas.add(myPizza);
}
return myPizzas;

body: ListView.builder(
  itemCount: myPizzas.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(myPizzas[index].pizzaName),
      subtitle: Text(myPizzas[index].description),
    );
  },
),
```
<img width="979" height="525" alt="image" src="https://github.com/user-attachments/assets/d7aa9105-8a66-4e6a-9b34-9f9e9412c2c8" />

## Soal 4 - Run dengan data JSON tidak konsisten (Praktikum 2)

Data dari API sering tidak sesuai model. Tiga masalah paling umum dan error yang muncul jika `fromJson` memakai cast langsung:

| Masalah | Contoh | Error | Solusi |
|---|---|---|---|
| String ke int | `"id": "1"` | 'String' is not a subtype of 'int' | `int.tryParse(json['id'].toString()) ?? 0` |
| Field null | imageUrl hilang | 'Null' is not a subtype of 'String' | `json['imageUrl'] ?? ''` / `toString()` |
| String ke double | `"price": "8.75"` | 'String' is not a subtype of 'double' | `double.tryParse(json['price'].toString()) ?? 0` |

`fromJson` yang tangguh:

```dart
Pizza.fromJson(Map<String, dynamic> json) {
  id = int.tryParse(json['id'].toString()) ?? 0;
  pizzaName = json['pizzaName'] != null
      ? json['pizzaName'].toString() : 'No name';
  description = json['description'] != null
      ? json['description'].toString() : '';
  price = double.tryParse(json['price'].toString()) ?? 0;
  imageUrl = json['imageUrl'] ?? '';
}
```

Hasil yang diharapkan dengan `assets/pizzalist_broken.json` (aktifkan switch di tab JSON). Aplikasi tidak crash dan nilai yang rusak diganti nilai pengganti yang ramah:

| Data ke | Isi JSON bermasalah | Tampil di aplikasi |
|---|---|---|
| 1 | id "1" (String), price "8.75" (String) | Margherita, id 1, harga 8.75 (berhasil diparse) |
| 2 | pizzaName null, imageUrl hilang | No name, harga 7.5 |
| 3 | id "tiga", price "mahal", description hilang | Napoli, id 0, harga 0.0, deskripsi kosong |
| 4 | id hilang, pizzaName 404 (angka), description 12345 | 404, id 0, deskripsi 12345, harga 9.0 |

<img width="979" height="526" alt="image" src="https://github.com/user-attachments/assets/cb4e8321-7fd3-4311-85c0-372ce667cf30" />

## Soal 5 - Maksud kode lebih safe dan maintainable (Praktikum 3)

Pada Praktikum 3, string literal kunci JSON diganti dengan konstanta yang dideklarasikan di luar class:

```dart
const keyId = 'id';
const keyName = 'pizzaName';
const keyDescription = 'description';
const keyPrice = 'price';
const keyImage = 'imageUrl';

// sebelum                        // sesudah
json['pizzaName']                 json[keyName]
'pizzaName': pizzaName,           keyName: pizzaName,
```

### Safe (aman)

Jika kunci ditulis sebagai string literal, salah ketik seperti `json['pizzaNmae']` tetap valid secara sintaks. Dart tidak mengeluh, nilainya diam-diam menjadi `null`, dan bug baru muncul saat aplikasi berjalan (bahkan bisa tidak disadari karena nilai pengganti seperti 'No name' tampil). Dengan konstanta, salah ketik seperti `keyNmae` menghasilkan error *undefined name* saat kompilasi, sehingga editor langsung menandainya dan kesalahan ketahuan sebelum aplikasi dijalankan.

### Maintainable (mudah dirawat)

Kunci yang sama dipakai di dua tempat, yaitu `toJson()` dan `fromJson()`. Dengan konstanta, jika nama kunci di API berubah (misalnya `pizzaName` menjadi `name`), perubahan cukup dilakukan di satu baris deklarasi dan semua pemakaian ikut berubah. Tanpa konstanta, setiap string literal harus dicari dan diubah satu per satu, dan satu yang terlewat menjadi bug.

Kesimpulan: konstanta membuat kode **safe** karena typo ketahuan saat kompilasi, dan **maintainable** karena kunci hanya diubah di satu tempat.

<img width="979" height="526" alt="image" src="https://github.com/user-attachments/assets/976fc835-1c10-4e82-a67e-47ce138dc57b" />

## Soal 6 - GIF SharedPreferences: counter dan reset (Praktikum 4)

`shared_preferences` menyimpan pasangan key-value sederhana. Counter dibaca dari key `appCounter` (default 0 jika belum ada), ditambah satu setiap aplikasi dibuka, lalu disimpan kembali. Tombol Reset memanggil `prefs.clear()`.

```dart
Future readAndWritePreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  appCounter = prefs.getInt('appCounter') ?? 0;
  appCounter++;
  await prefs.setInt('appCounter', appCounter);
  setState(() { appCounter = appCounter; });
}

Future deletePreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  setState(() { appCounter = 0; });
}
```

**Langkah merekam GIF:**

- Jalankan aplikasi, tab *Preferences* menampilkan angka, misalnya 1.
- Tutup aplikasi sepenuhnya lalu buka lagi (bukan sekadar hot reload). Angka naik menjadi 2, 3, dan seterusnya. Ini membuktikan data bertahan walau aplikasi ditutup.
- Tekan *Reset counter*, angka kembali 0.

<img width="979" height="525" alt="image" src="https://github.com/user-attachments/assets/07b76b2a-d4a5-44f6-a801-65ee9ed1c345" />

## Soal 7 - Screenshot path documents dan temp (Praktikum 5)

Package `path_provider` menemukan direktori yang sesuai di tiap platform, sehingga kode tidak perlu menulis path secara manual.

| Fungsi | Kegunaan |
|---|---|
| `getApplicationDocumentsDirectory()` | Data milik aplikasi yang perlu disimpan permanen |
| `getTemporaryDirectory()` | Data sementara atau cache, boleh dibersihkan sistem |

```dart
Future getPaths() async {
  final docDir = await getApplicationDocumentsDirectory();
  final tempDir = await getTemporaryDirectory();
  setState(() {
    documentsPath = docDir.path;
    tempPath = tempDir.path;
  });
}
```

Di Android emulator, bentuk path biasanya `/data/user/0/<nama.package>/app_flutter` untuk documents dan `/data/user/0/<nama.package>/cache` untuk temp. Hasil pastinya berbeda di tiap perangkat, jadi screenshot harus diambil dari aplikasimu sendiri.

<img width="979" height="526" alt="image" src="https://github.com/user-attachments/assets/dd9bc580-ca3a-4263-8dfb-009f7d6b0059" />

## Soal 8 - Penjelasan kode dan GIF akses file (Praktikum 6)

Modul tidak memberi nomor langkah pada slide, jadi penjelasan dibagi per blok kode pada slide 19. Cocokkan nomor *langkah 3* dan *langkah 7* dengan lembar praktikum kamu sebelum dikumpulkan.

```dart
late File myFile;
String fileText = '';

Future<bool> writeFile() async {
  try {
    await myFile.writeAsString('Margherita, Capricciosa, Napoli');
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> readFile() async {
  try {
    String fileContent = await myFile.readAsString();
    setState(() { fileText = fileContent; });
    return true;
  } catch (e) {
    return false;
  }
}

// initState()
getPaths().then((_) {
  myFile = File('$documentsPath/pizzas.txt');
  writeFile();
});
```

### Penjelasan per bagian

- **late File myFile**: objek File dari `dart:io`. Kata `late` berarti diisi nanti, karena path folder baru diketahui setelah `getPaths()` selesai.
- **writeFile()**: `writeAsString()` menulis teks ke file (membuat file jika belum ada, menimpa jika sudah ada). Dibungkus `try-catch` karena operasi I/O bisa gagal (izin, penyimpanan penuh), dan mengembalikan `true` atau `false` sebagai penanda berhasil.
- **readFile()**: `readAsString()` membaca isi file, lalu `setState` memperbarui `fileText` agar tampil di layar. Pola `try-catch` dan nilai kembalian sama seperti `writeFile()`.
- **initState()**: `getPaths()` dijalankan dahulu untuk mendapat folder documents. Setelah selesai (`.then`), `myFile` dibuat menunjuk ke `pizzas.txt` di folder itu, lalu `writeFile()` menulis isinya. Urutan ini penting: jika file dibuat sebelum path tersedia, aplikasi error.
- **async/await**: semua akses file bersifat asynchronous supaya tampilan tidak membeku selama membaca atau menulis.

Catatan project: pada *store_data_david* logika yang sama dipindahkan ke `LocalStorageService` (`writePizzaFile` dan `readPizzaFile`) dan menyimpan daftar pizza sebagai JSON. Jika dosen meminta persis seperti slide, gunakan versi `pizzas.txt` di atas.

<img width="979" height="528" alt="image" src="https://github.com/user-attachments/assets/7872bf9a-e369-45e2-8f18-845405ba912c" />

## Soal 9 - GIF secure storage (Praktikum 7)

`flutter_secure_storage` dipakai untuk data sensitif seperti token autentikasi dan kata sandi. Berbeda dengan `shared_preferences` yang menyimpan nilai apa adanya, secure storage memakai penyimpanan aman milik platform (Keychain di iOS, Keystore di Android) sehingga isinya terenkripsi.

```dart
final storage = const FlutterSecureStorage();
final myKey = 'myPass';

Future writeToSecureStorage() async {
  await storage.write(key: myKey, value: pwdController.text);
}

Future<String> readFromSecureStorage() async {
  String secret = await storage.read(key: myKey) ?? '';
  return secret;
}
```

**Langkah merekam GIF:**

- Buka tab *Secure*, ketik sebuah kata sandi di `TextField`, tekan *Save Value*.
- Tutup dan buka kembali aplikasi (atau kosongkan field), tekan *Read Value*.
- Nilai yang tadi disimpan muncul kembali di layar.

Untuk Android, `flutter_secure_storage` biasanya membutuhkan `minSdkVersion` 23 di `android/app/build.gradle`.

<img width="979" height="525" alt="image" src="https://github.com/user-attachments/assets/a3435105-f3f0-4ac8-be69-23921676436d" />

