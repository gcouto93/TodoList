import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _todoList = [];
  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;

  final _todoController = TextEditingController();

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    _readData().then((value) {
      setState(() {
        _todoList = json.decode(value!);
      });

    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDO = Map();
      newToDO["title"] = _todoController.text;
      _todoController.text = "";
      newToDO["ok"] = false;
      _todoList.add(newToDO);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                 Expanded(
                   child: TextField(
                     controller: _todoController,
                    decoration: InputDecoration(
                      labelText: 'Nova Tarefa',
                      labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                ),
                 ),
                ElevatedButton(
                  onPressed: _addToDo,
                  child: Text('ADD'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white)
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                  itemCount: _todoList.length,
                  itemBuilder: buildItem),
          )
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch(e) {
      return null;
    }
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      child:  CheckboxListTile(
        onChanged: (c) {
          setState(() {
            _todoList[index]["ok"] = c;
            _saveData();
          });
        },
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["ok"] ? Icons.check : Icons.error),
        ),
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
              content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(label: "Desfazer",
            onPressed: () {
              setState(() {
                _todoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
              });

            },
            ),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
      direction: DismissDirection.startToEnd,
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),


    );
  }

}





