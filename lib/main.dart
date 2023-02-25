import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;

  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameContriller = TextEditingController();
  final TextEditingController _quanityContriller = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  final _myBox = Hive.box('myBox');

  //загружаем дату, когда стартуем приложение
  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _myBox.keys.map((key) {
      final item = _myBox.get(key);
      return {'key': key, 'name': item['name'], 'quanity': item['quanity']};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  //create new item
  Future<void> _craeteItem(Map<String, dynamic> newItem) async {
    await _myBox.add(newItem);
    _refreshItems();
  }

  //update item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _myBox.put(itemKey, item);
    _refreshItems();
  }

  //delete item
  Future<void> _deleteItem(int itemKey) async {
    await _myBox.delete(itemKey);
    _refreshItems();
    //display snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Удалено'),
      ),
    );
  }

  //craete form

  void _showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameContriller.text = existingItem['name'];
      _quanityContriller.text = existingItem['quanity'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: false,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //name
            TextField(
              controller: _nameContriller,
              decoration: const InputDecoration(
                hintText: 'Название',
              ),
            ),
            //quanity
            TextField(
              controller: _quanityContriller,
              decoration: const InputDecoration(hintText: 'Описание'),
            ),
            //кнопка создать новую

            const SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 4, 43, 89),
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white)),
              onPressed: () async {
                if (itemKey == null) {
                  _craeteItem({
                    'name': _nameContriller.text,
                    'quanity': _quanityContriller.text,
                  });
                }

                if (itemKey != null) {
                  _updateItem(itemKey, {
                    'name': _nameContriller.text.trim(),
                    'quanity': _quanityContriller.text.trim(),
                  });
                }

                _nameContriller.text = '';
                _quanityContriller.text = '';

                Navigator.of(context).pop();
              },
              child: Text(itemKey == null ? 'Создать' : 'Обновить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 43, 89),
        elevation: 0,
        title: const Text(
          'КОНТЕНТ ПЛАН',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, index) {
          final currentItem = _items[index];
          return Card(
            margin: const EdgeInsets.only(left: 15, top: 15, right: 15),
            color: const Color.fromARGB(255, 2, 125, 253),
            elevation: 3,
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['quanity'].toString()),
              textColor: Colors.white,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //редактировать
                  IconButton(
                    onPressed: () => _showForm(context, currentItem['key']),
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  //удалить
                  IconButton(
                    onPressed: () => _deleteItem(currentItem['key']),
                    icon: Icon(Icons.delete, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 4, 43, 89),
        onPressed: () => _showForm(context, null),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
