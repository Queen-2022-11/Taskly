import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget{
  HomePage();
  
  @override
  State<StatefulWidget> createState() {
     return _homepagestate();
  }
}
class _homepagestate extends State<HomePage>
{
  late double _deviceHeight,_deviceWidth;
  String? _newTaskcontent;
  Box? _box;
  _homepagestate();
  @override
  Widget build(BuildContext context) {
    _deviceHeight=MediaQuery.of(context).size.height;
    _deviceWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // Set the toolbar color to red
        toolbarHeight: _deviceHeight*0.10,
        title: const Text("Taskly", style: TextStyle(fontSize: 25,),),
      ),
      body: _taskView(),
      floatingActionButton: _tasksbutton(),
    );
  }
  Widget _taskView(){
    return FutureBuilder(future: Hive.openBox('tasks'), builder: (BuildContext _context, AsyncSnapshot _snapshot,){
      if(_snapshot.hasData){
        _box=_snapshot.data;
        return _taskslist();
      }
      else{
        return( const Center(child: CircularProgressIndicator(),));
      }
    });
  }
  Widget _taskslist() {
    List tasks= _box!.values.toList();

    return ListView.builder(itemCount: tasks.length, itemBuilder:(BuildContext _context,int index){
       var task= Task.fromMap(tasks[index]);
       return ListTile(
          title:  Text(task.content,style: TextStyle( decoration: task.done ? TextDecoration.lineThrough : null,),),
          subtitle: Text(task.timestamp.toString()),
          trailing:  Icon(
            task.done ? Icons.check_box_outlined: Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap:(){
            task.done=!task.done;
            _box!.putAt(index, task.toMap(),);
            setState(() {
            });
          },
          onLongPress: (){
            _box!.deleteAt(index);
            setState(() {
              
            });
          },
        );
    } );
    
  
  }
  Widget _tasksbutton(){
    return FloatingActionButton(onPressed: _taskshowbutton,
    child: const Icon(Icons.add,color: Colors.white) ,
    backgroundColor: Colors.red,
    );
  }
  void _taskshowbutton(){
    showDialog(context: context, builder: (BuildContext _context){
      return AlertDialog(
        title: const Text("Add a new Task"),
        content: TextField(onSubmitted:  (_){
          if(_newTaskcontent!=null){
            var _task=Task(content: _newTaskcontent!, timestamp: DateTime.now(), done: false);
            _box!.add(_task.toMap());
            setState(() {
              _newTaskcontent=null;
              Navigator.pop(context);
            });
          }
        },onChanged: (value) {
          setState(() {
            _newTaskcontent=value;
          });
        },),
      );
    });
  }
}