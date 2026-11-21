import 'package:flutter/material.dart';

import 'model/pizza.dart';
import 'services/local_storage_service.dart';

// Soal 1: nama panggilan di title app + warna tema.
const String nickname = 'David';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Data $nickname',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Store Data $nickname'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'JSON'),
              Tab(text: 'Preferences'),
              Tab(text: 'Paths'),
              Tab(text: 'File'),
              Tab(text: 'Secure'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PizzaTab(),
            CounterTab(),
            PathsTab(),
            FileTab(),
            SecureTab(),
          ],
        ),
      ),
    );
  }
}

final _service = LocalStorageService();

// ------------------------------------------------ Praktikum 1-3: JSON ------

class PizzaTab extends StatefulWidget {
  const PizzaTab({super.key});

  @override
  State<PizzaTab> createState() => _PizzaTabState();
}

class _PizzaTabState extends State<PizzaTab> {
  List<Pizza> myPizzas = [];
  bool useBroken = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final asset =
        useBroken ? 'assets/pizzalist_broken.json' : 'assets/pizzalist.json';
    final pizzas = await _service.loadPizzasFromAsset(asset);
    // Soal 2: hasil toJson tercetak di Debug Console.
    debugPrint(_service.convertToJson(pizzas));
    if (!mounted) return;
    setState(() => myPizzas = pizzas);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Pakai pizzalist_broken.json'),
          value: useBroken,
          onChanged: (v) {
            setState(() => useBroken = v);
            _load();
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: myPizzas.length,
            itemBuilder: (context, index) {
              final p = myPizzas[index];
              return ListTile(
                title: Text(p.pizzaName),
                subtitle: Text('${p.description}\n\$${p.price}'),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------ Praktikum 4: SharedPreferences --

class CounterTab extends StatefulWidget {
  const CounterTab({super.key});

  @override
  State<CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<CounterTab> {
  int appCounter = 0;

  @override
  void initState() {
    super.initState();
    _service.incrementAppCounter().then((v) {
      if (mounted) setState(() => appCounter = v);
    });
  }

  Future<void> _reset() async {
    await _service.resetPreferences();
    if (mounted) setState(() => appCounter = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You have opened the app $appCounter times.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _reset,
            child: const Text('Reset counter'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------- Praktikum 5: path_provider --

class PathsTab extends StatefulWidget {
  const PathsTab({super.key});

  @override
  State<PathsTab> createState() => _PathsTabState();
}

class _PathsTabState extends State<PathsTab> {
  String documentsPath = '';
  String tempPath = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final docs = await _service.getDocumentsPath();
    final temp = await _service.getTempPath();
    if (!mounted) return;
    setState(() {
      documentsPath = docs;
      tempPath = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documents path:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(documentsPath),
          const SizedBox(height: 16),
          const Text('Temp path:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tempPath),
        ],
      ),
    );
  }
}

// ------------------------------------------------ Praktikum 6: dart:io -----

class FileTab extends StatefulWidget {
  const FileTab({super.key});

  @override
  State<FileTab> createState() => _FileTabState();
}

class _FileTabState extends State<FileTab> {
  String fileText = '';
  String status = '';

  Future<void> _write() async {
    final pizzas = await _service.loadPizzasFromAsset('assets/pizzalist.json');
    final ok = await _service.writePizzaFile(pizzas);
    if (mounted) setState(() => status = ok ? 'Tulis berhasil' : 'Tulis gagal');
  }

  Future<void> _read() async {
    final pizzas = await _service.readPizzaFile();
    if (!mounted) return;
    setState(() {
      fileText = pizzas.map((p) => p.pizzaName).join(', ');
      status = pizzas.isEmpty ? 'File kosong / belum ada' : 'Baca berhasil';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(onPressed: _write, child: const Text('Write file')),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _read, child: const Text('Read file')),
            ],
          ),
          const SizedBox(height: 16),
          Text(status),
          const SizedBox(height: 8),
          Text(fileText),
        ],
      ),
    );
  }
}

// ------------------------------------------ Praktikum 7: secure storage ----

class SecureTab extends StatefulWidget {
  const SecureTab({super.key});

  @override
  State<SecureTab> createState() => _SecureTabState();
}

class _SecureTabState extends State<SecureTab> {
  final TextEditingController pwdController = TextEditingController();
  String myPass = '';

  @override
  void dispose() {
    pwdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _service.saveUserToken(pwdController.text);
  }

  Future<void> _read() async {
    final secret = await _service.getUserToken();
    if (mounted) setState(() => myPass = secret);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: pwdController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password / token'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save Value')),
          ElevatedButton(onPressed: _read, child: const Text('Read Value')),
          const SizedBox(height: 12),
          Text(myPass),
        ],
      ),
    );
  }
}
