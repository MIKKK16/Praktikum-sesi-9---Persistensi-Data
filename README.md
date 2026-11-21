# Praktikum Persistensi Data (Flutter)

Praktikum Flutter Minggu 13: menyimpan data dengan **JSON**, **SharedPreferences**, **File System** (`path_provider` + `dart:io`), dan **Secure Storage**.

| | |
|---|---|
| **Nama** | David Pratama |
| **NIM** | 23.52.0001 |
| **Kampus** | STMIK PPKIA Paradnya Paramitha Malang |

## Isi Project

```
store_data_david/
├── assets/
│   ├── pizzalist.json            # data normal
│   └── pizzalist_broken.json     # data tidak konsisten (Soal 4)
├── lib/
│   ├── main.dart                 # gabungan semua praktikum (5 tab)
│   ├── model/pizza.dart          # model Pizza + konstanta kunci JSON
│   ├── services/local_storage_service.dart
│   └── soal/                     # satu file kode per soal
│       ├── soal_app.dart
│       ├── soal02_text_json.dart
│       ├── soal03_listview.dart
│       ├── soal04_json_tidak_kompatibel.dart
│       ├── soal06_shared_preferences.dart
│       ├── soal07_paths.dart
│       ├── soal08_file.dart
│       └── soal09_secure_storage.dart
└── docs/                         # screenshot hasil run
```

## Cara Menjalankan

```bash
flutter pub get
flutter run -t lib/soal/soal03_listview.dart
```

Ganti nama file setelah `-t` sesuai soal yang ingin dijalankan (lihat tabel di bawah).

| Soal | Praktikum | File |
|------|-----------|------|
| 1, 2 | 1 | `lib/soal/soal02_text_json.dart` |
| 3 | 1 | `lib/soal/soal03_listview.dart` |
| 4, 5 | 2, 3 | `lib/soal/soal04_json_tidak_kompatibel.dart` |
| 6 | 4 | `lib/soal/soal06_shared_preferences.dart` |
| 7 | 5 | `lib/soal/soal07_paths.dart` |
| 8 | 6 | `lib/soal/soal08_file.dart` |
| 9 | 7 | `lib/soal/soal09_secure_storage.dart` |

---

## Soal 1 - Nama panggilan di title dan warna tema

Title aplikasi memakai nama panggilan lewat konstanta `nickname`, dan warna tema diganti dengan mengubah `seedColor` pada `ColorScheme.fromSeed` menjadi teal.

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

![Soal 1](docs/soal01.png)

## Soal 2 - Hasil membaca JSON

File `assets/pizzalist.json` dibaca dengan `loadString()`. Pada tahap ini isinya belum diubah menjadi objek, sehingga seluruh JSON tampil sebagai satu teks panjang. Folder `assets` harus terdaftar di `pubspec.yaml`.

```dart
Future readJsonFile() async {
  String myString = await rootBundle.loadString('assets/pizzalist.json');
  setState(() {
    pizzaString = myString;
  });
}
```

![Soal 2](docs/soal02.png)

## Soal 3 - Hasil ListView `List<Pizza>`

Alurnya: String JSON → `jsonDecode()` → `List<Map>` → `Pizza.fromJson()` → `List<Pizza>` → `ListView.builder`. Fungsi `toJson()` dan `jsonEncode()` melakukan arah sebaliknya dan hasilnya dicetak di Debug Console.

```dart
List pizzaMapList = jsonDecode(myString);
List<Pizza> pizzas = [];
for (var pizza in pizzaMapList) {
  pizzas.add(Pizza.fromJson(pizza));
}

String convertToJSON(List<Pizza> pizzas) {
  return jsonEncode(pizzas.map((pizza) => pizza.toJson()).toList());
}
```

![Soal 3](docs/soal03.png)

## Soal 4 - Run dengan data JSON tidak konsisten

Data dari API sering tidak sesuai model. Jika `fromJson` memakai cast langsung, tiga masalah ini menyebabkan error:

| Masalah | Contoh | Error | Solusi |
|---|---|---|---|
| String ke int | `"id": "1"` | `'String' is not a subtype of 'int'` | `int.tryParse(json['id'].toString()) ?? 0` |
| Field null | `imageUrl` hilang | `'Null' is not a subtype of 'String'` | `json['imageUrl'] ?? ''` |
| String ke double | `"price": "8.75"` | `'String' is not a subtype of 'double'` | `double.tryParse(json['price'].toString()) ?? 0` |

`fromJson` yang tangguh (`lib/model/pizza.dart`):

```dart
factory Pizza.fromJson(Map<String, dynamic> json) {
  return Pizza(
    id: int.tryParse(json[keyId].toString()) ?? 0,
    pizzaName: json[keyName] != null ? json[keyName].toString() : 'No name',
    description: json[keyDescription] != null ? json[keyDescription].toString() : '',
    price: double.tryParse(json[keyPrice].toString()) ?? 0,
    imageUrl: json[keyImage]?.toString() ?? '',
  );
}
```

Dengan `assets/pizzalist_broken.json`, aplikasi tidak crash dan nilai yang rusak diganti nilai pengganti: `No name`, id `0`, harga `0`, atau deskripsi kosong.

![Soal 4](docs/soal04.png)

## Soal 5 - Maksud kode lebih *safe* dan *maintainable*

String literal kunci JSON diganti dengan konstanta:

```dart
const keyId = 'id';
const keyName = 'pizzaName';
const keyDescription = 'description';
const keyPrice = 'price';
const keyImage = 'imageUrl';

// sebelum: json['pizzaName']      sesudah: json[keyName]
```

- **Safe (aman):** salah ketik pada string literal seperti `json['pizzaNmae']` tetap valid secara sintaks, nilainya diam-diam menjadi `null`, dan bug baru muncul saat aplikasi berjalan. Dengan konstanta, salah ketik seperti `keyNmae` menghasilkan error *undefined name* saat kompilasi, sehingga ketahuan sebelum aplikasi dijalankan.
- **Maintainable (mudah dirawat):** kunci yang sama dipakai di `toJson()` dan `fromJson()`. Jika nama kunci di API berubah, cukup diubah di satu baris deklarasi dan semua pemakaian ikut berubah.

![Soal 5](docs/soal05.png)

## Soal 6 - SharedPreferences (counter dan reset)

`shared_preferences` menyimpan pasangan key-value sederhana. Counter dibaca dari key `appCounter` (default 0), ditambah satu setiap aplikasi dibuka, lalu disimpan kembali. Tombol Reset memanggil `prefs.clear()`.

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

![Soal 6](docs/soal06.png)

## Soal 7 - Path documents dan temp

`path_provider` menemukan direktori yang sesuai di tiap platform, sehingga path tidak perlu ditulis manual.

| Fungsi | Kegunaan |
|---|---|
| `getApplicationDocumentsDirectory()` | Data aplikasi yang perlu disimpan permanen |
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

![Soal 7](docs/soal07.png)

## Soal 8 - Akses file (`dart:io`)

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

- **`late File myFile`**: objek `File` dari `dart:io`. `late` berarti diisi nanti, karena path folder baru diketahui setelah `getPaths()` selesai.
- **`writeFile()`**: `writeAsString()` menulis teks ke file (membuat file jika belum ada, menimpa jika sudah ada). Dibungkus `try-catch` karena operasi I/O bisa gagal, dan mengembalikan `true` atau `false` sebagai penanda berhasil.
- **`readFile()`**: `readAsString()` membaca isi file, lalu `setState` memperbarui `fileText` agar tampil di layar.
- **`initState()`**: `getPaths()` dijalankan dahulu untuk mendapat folder documents. Setelah selesai (`.then`), `myFile` dibuat menunjuk ke `pizzas.txt` di folder itu, lalu `writeFile()` menulis isinya. Urutan ini penting: jika file dibuat sebelum path tersedia, aplikasi error.
- **`async/await`**: akses file bersifat asynchronous supaya tampilan tidak membeku saat membaca atau menulis.

![Soal 8](docs/soal08.png)

## Soal 9 - Secure Storage

`flutter_secure_storage` dipakai untuk data sensitif seperti token dan kata sandi. Berbeda dengan `shared_preferences` yang menyimpan nilai apa adanya, secure storage memakai penyimpanan aman milik platform (Keychain di iOS, Keystore di Android) sehingga isinya terenkripsi.

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

![Soal 9](docs/soal09.png)

---

## Catatan

Screenshot di atas dijalankan di Chrome (web). `path_provider` dan `dart:io` tidak mendukung web, sehingga pada Soal 7 dan 8 path dan isi file tidak tampil. Pada Android atau Windows, path documents dan temp akan terisi dan file `pizzas.txt` dapat ditulis lalu dibaca.
