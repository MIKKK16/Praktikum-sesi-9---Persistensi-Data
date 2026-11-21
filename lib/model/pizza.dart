// Model Pizza + konstanta kunci JSON (Praktikum 1-3).

// Praktikum 3: konstanta kunci -> typo ketahuan saat kompilasi,
// dan kunci cukup diubah di satu tempat.
const keyId = 'id';
const keyName = 'pizzaName';
const keyDescription = 'description';
const keyPrice = 'price';
const keyImage = 'imageUrl';

class Pizza {
  final int id;
  final String pizzaName;
  final String description;
  final double price;
  final String imageUrl;

  const Pizza({
    required this.id,
    required this.pizzaName,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  /// Praktikum 2: fromJson yang tangguh.
  /// - int.tryParse / double.tryParse: parsing aman, null bila gagal
  /// - `??`: nilai default bila null
  /// - toString(): paksa tipe apa pun menjadi String
  /// Tidak ada cast langsung (`as int`), sehingga data rusak tidak membuat crash.
  factory Pizza.fromJson(Map<String, dynamic> json) {
    return Pizza(
      id: int.tryParse(json[keyId].toString()) ?? 0,
      pizzaName:
          json[keyName] != null ? json[keyName].toString() : 'No name',
      description:
          json[keyDescription] != null ? json[keyDescription].toString() : '',
      price: double.tryParse(json[keyPrice].toString()) ?? 0,
      imageUrl: json[keyImage]?.toString() ?? '',
    );
  }

  /// Praktikum 1: kembali ke Map agar bisa di-jsonEncode.
  Map<String, dynamic> toJson() {
    return {
      keyId: id,
      keyName: pizzaName,
      keyDescription: description,
      keyPrice: price,
      keyImage: imageUrl,
    };
  }
}
