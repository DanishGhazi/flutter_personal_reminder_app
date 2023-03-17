import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_personal_reminder_app/screen/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/todo_service.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  State<ToDoList> createState() => _ToDoListState();
}
class _ToDoListState extends State<ToDoList> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchToDo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child:
            Text(
              'To Do List',
              style: TextStyle(fontSize: 20.0),
            )
        ),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: SpinKitDoubleBounce(
            color: Colors.greenAccent,
            size: 80.0,
          ),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchToDo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No Task Available. Create One Now!',
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context,index){
                final item = items[index] as Map;
                final id = item['_id'];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index+1}'),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value){
                        if(value == 'edit'){
                          navigateToEditPage(item);
                        }
                        else if(value == 'delete'){
                          showAlert(id);
                        }
                      },
                      itemBuilder: (context){
                        return [
                          PopupMenuItem(
                              child:
                              ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                              ),
                              value: 'edit',
                          ),
                          PopupMenuItem(
                              child:
                              ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              ),
                              value: 'delete',
                          )
                        ];
                      },
                    )
                  ),
                );
              },
            ),
          ),
        ),

      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Icon(Icons.add_task_rounded),
      ),
    );

  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  void navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  Future<void> deleteById(String id) async{

    final isSuccess = await TodoService.deleteById(id);
    if(isSuccess){
      showSuccessMessage('Task deleted successfully!');
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }
    else{
      showErrorMessage('Failed to delete task!');
    }
  }


  Future<void> fetchToDo() async {
    final response = await TodoService.fetchTodos();
    if(response != null){
      setState(() {
        items = response;
      });
      // final json = jsonDecode(response.body) as Map;
      // final result = json['items'] as List;
      // print(result);
      // setState(() {
      //   items = result;
      // });
    }
    else{
      showErrorMessage('Failed to retrieve tasks.');
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(message),
      ),
      backgroundColor: Colors.redAccent,
    ));
  }

  void showSuccessMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(message),
      ),
      backgroundColor: Colors.greenAccent,
    ));
  }

  void showAlert(String id) {

    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () => Navigator.pop(context, 'Cancel'),
    );

    Widget deleteButton = TextButton(
      child: Text(
        "Delete",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: (){
        Navigator.pop(context);
        deleteById(id);
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text("Are you sure you want to delete this task?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}



