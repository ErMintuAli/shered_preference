import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';  // Ensure this file exists and defines Users class properly

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Users> _users = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final userList = prefs.getStringList('users') ?? [];
      _users = userList
          .map((e) => Users.fromUsers(Map<String, dynamic>.from(jsonDecode(e))))
          .toList();
    });
  }

  Future<void> _addUsers(Users user) async {
    if (user.name.isNotEmpty && user.email.isNotEmpty && user.phone.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      if (_editingIndex != null) {
        _users[_editingIndex!] = user;
        _editingIndex = null;
      } else {
        _users.add(user);
      }
      await prefs.setStringList(
          'users', _users.map((e) => jsonEncode(e.toUser())).toList());
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      setState(() {});
    } else {
      // You can add a simple dialog or snackbar to notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void editUser(int index) {
    _nameController.text = _users[index].name;
    _emailController.text = _users[index].email;
    _phoneController.text = _users[index].phone;
    _editingIndex = index;
  }

  Future<void> _deleteUser(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _users.removeAt(index);
    await prefs.setStringList(
        'users', _users.map((e) => jsonEncode(e.toUser())).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text("Shared Preference with CRUD"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Enter user name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Enter user email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Enter user phone",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final user = Users(
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                );
                _addUsers(user);
              },
              child: Text(_editingIndex != null ? 'Update User' : 'Add User'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('${user.email} | ${user.phone}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            editUser(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
