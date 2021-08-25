import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _taskList = [];
  TextEditingController _titleController = TextEditingController();

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/dados.json");
  }

  _saveTask() async {
    Map<String, dynamic> task = Map();
    task['title'] = _titleController.text;
    task['finished'] = false;

    _titleController.text = "";

    setState(() {
      _taskList.add(task);
    });

    await _saveFile();
  }

  _saveFile() async {
    var file = await _getFile();

    file.writeAsString(json.encode(_taskList));
  }

  _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (error) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _readFile().then((data) {
      setState(() {
        _taskList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de Tarefas"), backgroundColor: Colors.purple),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
          itemCount: _taskList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              background: Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [Icon(Icons.edit, color: Colors.white)],
                  )),
              secondaryBackground: Container(
                  color: Colors.red,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.delete, color: Colors.white)],
                  )),
              key: Key('teste'),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                Map<String, dynamic> _removedTask = Map();
                _removedTask['title'] = _taskList[index]['title'];
                _removedTask['finished'] = _taskList[index]['finished'];

                setState(() {
                  _taskList.removeAt(index);
                });

                final snackBar = SnackBar(
                    content: Text("Tarefa removida"),
                    action: SnackBarAction(
                        label: "Desfazer",
                        onPressed: () {
                          setState(() {
                            _taskList.add(_removedTask);
                          });
                        }),
                    duration: Duration(seconds: 5));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                _saveFile();
              },
              child: CheckboxListTile(
                  value: _taskList[index]['finished'],
                  title: Text(_taskList[index]['title']),
                  onChanged: (valorAlterado) {
                    setState(() {
                      _taskList[index]['finished'] = valorAlterado;
                    });
                    _saveFile();
                  }),
            );

            //return ListTile(title: Text(_taskList[index]["title"]));
          },
        ))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: Text("Adicionar Tarefa"),
                      content: TextField(
                          controller: _titleController,
                          decoration:
                              InputDecoration(labelText: "Digite sua tarefa"),
                          onChanged: (text) {}),
                      actions: [
                        TextButton(
                            child: Text("Cancelar"),
                            onPressed: () => Navigator.pop(context)),
                        TextButton(
                            child: Text("Salvar"),
                            onPressed: () {
                              _saveTask();
                              Navigator.pop(context);
                            })
                      ]);
                });
          },
          child: Icon(Icons.add)),
    );
  }
}
