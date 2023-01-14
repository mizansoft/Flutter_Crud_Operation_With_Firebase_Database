import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products =
  FirebaseFirestore.instance.collection("products");
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  _save([DocumentSnapshot? documentSnapshot]) {
    if (documentSnapshot != null) {
      idController.text = documentSnapshot['id'];
      nameController.text = documentSnapshot['name'];
      brandController.text = documentSnapshot['brand'];
      priceController.text = documentSnapshot['price'].toString();
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  hintText: "Enter Id",
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter name",
                ),
              ),
              TextField(
                controller: brandController,
                decoration: InputDecoration(
                  hintText: "Enter type name",
                ),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  hintText: "Enter price",
                ),
              ),

              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: Text("Save"),
                onPressed: () async {
                  final String id1 = idController.text.toString();
                  final String name1 = nameController.text.toString();
                  final String brand1 = brandController.text.toString();
                  final String price1 =
                  int.parse(priceController.text).toString();
                  if (price1 != null) {
                    await _products.add({"id": id1, "name": name1, "brand": brand1 ,"price": price1, });
                    idController.text = '';
                    nameController.text = '';
                    brandController.text = '';
                    priceController.text = '';
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _update([DocumentSnapshot? documentSnapshot]) {
    if (documentSnapshot != null) {
      // idController.text = documentSnapshot['id'];
      nameController.text = documentSnapshot['name'];
      brandController.text = documentSnapshot['brand'];
      priceController.text = documentSnapshot['price'].toString();
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              // TextField(
              //   controller: idController,
              //   decoration: InputDecoration(
              //     hintText: "Enter Id",
              //   ),
              // ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter name",
                ),
              ),

              TextField(
                controller: brandController,
                decoration: InputDecoration(
                  hintText: "Enter type name",
                ),
              ),

              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  hintText: "Enter price",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: Text("Update"),
                onPressed: () async {
                  // final String id1 = idController.text.toString();
                  final String name1 = nameController.text.toString();
                  final String brand1 = brandController.text.toString();
                  final String price1 =
                  int.parse(priceController.text).toString();
                  if (price1 != null) {
                    _products
                        .doc(documentSnapshot!.id)
                        .update({ "name": name1, "brand": brand1 ,"price": price1 });

                    nameController.text = '';
                    brandController.text = '';
                    priceController.text = '';

                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _delete(String productId) async {
    await _products.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted"),
      ),
    );
  }

  //_products.add({name:"abc",price:100});
  //_products.update({name:"abc",price:100});
  //_products.doc(productId).detete();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                snapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                     // leading: Text( ),
                    title: Text("Id : "+documentSnapshot['id']+"\n"+"Name : "+documentSnapshot['name'], style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text("Type: "+documentSnapshot['brand'].toString()+"\n"+"Price : "+"\$ "+documentSnapshot['price']),

                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            color: Colors.green,
                            onPressed: () {
                              _update(documentSnapshot);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            color: Colors.red,
                            onPressed: () {
                              _delete(documentSnapshot.id);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Icon(Icons.add),
        onPressed: () {
          _save();
        },
      ),
    );
  }
}
