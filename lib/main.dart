import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var emailText = TextEditingController();
  var passText = TextEditingController();
  bool _isNotValidate = false;

  void registerUser() async{
    if(emailText.text.isNotEmpty && passText.text.isNotEmpty){
        var regBody = {
          "email":emailText.text,
          "password":passText.text
        };

        var response = await http.post(
            Uri.parse(registration),
          headers: {"Content-Type":"application/json"},
            body: jsonEncode(regBody)
        );
        if(response.statusCode == 200){
          print("registration successful");
        }else{
          print("registration failed");
        }

    }else{
      setState(() {
        _isNotValidate = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(

                    controller: emailText,
                    // enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.deepOrange,width: 2)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blueAccent,width: 2)
                      ),

                      prefixIcon: Icon(Icons.email,color:Colors.deepOrange),
                      // border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.deepOrange))
                    ),
                  ),
                  Container(height: 11,),
                  TextField(
                    // keyboardType: TextInputType.phone,
                    controller: passText,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                        hintText: 'password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.deepOrange))
                    ),
                  ),
                  ElevatedButton(onPressed: (){
                    String uEmail = emailText.text.toString();
                    String uPass = passText.text;//toString is redundant
                    registerUser();
                    print("Email: $uEmail, Pass: $uPass");
                  }, child: Text('Sign up'))
                ],
              ))
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
