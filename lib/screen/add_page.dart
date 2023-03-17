import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class AddToDoPage extends StatefulWidget {
  final Map?todo;
  const AddToDoPage({Key? key, this.todo}) : super(key: key);

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  bool isEdit = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    final todo = widget.todo;
    if(widget.todo != null){
      isEdit = true;
      final title = todo?['title'];
      final description = todo?['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? 'Edit To Do' : 'Add To Do'
        ),
      ),
      body: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: isEdit ? updateData : submitData,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                    isEdit ? 'Update' : 'Submit'
                ),
              ),
          )
        ],
      )
    );
  }

  void submitData() async{
    FocusManager.instance.primaryFocus?.unfocus();
    //Get data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": true,
    };

    //Submit data to server
    final url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    //Show success or fail message
    if(response.statusCode == 201){
      showSuccessMessage("Task added successfully");
    }
    else{
      showFailMessage("Failed to add task");
    }
  }

  void updateData() async{
    FocusManager.instance.primaryFocus?.unfocus();

    final todo = widget.todo;
    if(todo == null){
      print('You can not call updated without todo data');
      return;
    }
    //Get data from form
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": true,
    };

    //Submit update data to server
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    //Show success or fail message
    if(response.statusCode == 200){
      showSuccessMessage("Task updated successfully");
    }
    else{
      showFailMessage("Failed to update task");
    }
  }

  void showSuccessMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(message),
      ),
      backgroundColor: Colors.greenAccent,
    ));
  }

  void showFailMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(message),
      ),
      backgroundColor: Colors.redAccent,
    ));
  }
}
