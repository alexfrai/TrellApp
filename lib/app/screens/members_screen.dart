import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/widgets/header.dart';
import 'package:flutter_trell_app/app/widgets/sidebar.dart';

///Class
class MembersScreen extends StatefulWidget {
  ///Constructor
  const MembersScreen({ super.key });

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 151, 102),
      body: Column(
        children: <Widget>[
          const Header(),
          Row(
            children: <Widget>[
              const Sidebar(),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                        child: Text(
                          //curentWorkspace.isNotEmpty ? curentWorkspace[0] : '?',
                          'z',
                        ),
                      ),
                          const Column(
                            children: <Widget>[
                              Text('Workspace'),
                              Text('Visibility'),
                            ],
                          ),
                          ElevatedButton(onPressed:() {print('hello');}, 
                          child: const Text('Add members to the board')
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      
    );
  }
}
