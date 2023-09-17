import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('student_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  List<Map<String, dynamic>> _studs = [];

  final _studentBox = Hive.box('student_box');

  @override
  void initState() {
    super.initState();
    _refreshDetails();
  }

  void _refreshDetails() {
    final data = _studentBox.keys.map((key) {
      final std = _studentBox.get(key);
      return {"key": key, "name": std["name"], "class": std["class"]};
    }).toList();
    setState(() {
      _studs = data.reversed.toList();
      //print(_studs.length);
    });
  }

  Future<void> _studentDetails(Map<String, dynamic> newStd) async {
    await _studentBox.add(newStd);
    _refreshDetails();
  }

  Future<void> _studentUpdate(int stdKey, Map<String, dynamic> updStd) async {
    await _studentBox.put(stdKey, updStd);
    _refreshDetails();
  }

  Future<void> _studentDelete(int stdKey) async {
    await _studentBox.delete(stdKey);
    _refreshDetails();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted')));
  }

  void _showForm(BuildContext ctx, int? stdKey) async {
    if (stdKey != null) {
      final existingStd =
          _studs.firstWhere((element) => element['key'] == stdKey);
      _nameController.text = existingStd['name'];
      _classController.text = existingStd['class'];
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _classController,
              decoration: const InputDecoration(hintText: 'Class'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                //For Inserting
                if (stdKey == null) {
                  _studentDetails({
                    "name": _nameController.text,
                    "class": _classController.text,
                  });
                }

                //For Updation
                if (stdKey != null) {
                  _studentUpdate(stdKey, {
                    "name": _nameController.text.trim(),
                    "class": _classController.text.trim()
                  });
                }

                //Clear the text field
                _nameController.text = '';
                _classController.text = '';
                Navigator.of(context).pop();
              },
              child: const Text('Add Student'),
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
        title: const Text('Student Details'),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: _studs.length,
          itemBuilder: (_, index) {
            final currentStudent = _studs[index];
            return Card(
              margin: const EdgeInsets.all(8),
              elevation: 3,
              color: const Color.fromARGB(255, 89, 181, 227),
              child: ListTile(
                title: Text(currentStudent['name']),
                subtitle: Text(currentStudent['class']),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    onPressed: () => _showForm(context, currentStudent['key']),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _studentDelete(currentStudent['key']),
                    icon: const Icon(Icons.delete),
                  ),
                ]),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
