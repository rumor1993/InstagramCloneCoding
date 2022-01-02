import 'package:flutter/material.dart';
import 'style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
          create: (c) => Store1(),
          child: MaterialApp(
              theme: style.theme,
              home: MyApp()
          ),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tap = 0;
  var data = [];
  var userImage;

  saveData() async {
    SharedPreferences.setMockInitialValues({});
    var storage = await SharedPreferences.getInstance();
    storage.setString('name', 'john');
    var result = storage.get('name');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveData();
    getData('https://codingapple1.github.io/app/data.json');
  }

  getData(url) async {
    var result = await http.get( Uri.parse(url) );
    setState(() {
      var response = jsonDecode(result.body);
      data = response;
    });
  }

  addData(value) {
    setState(() {
      data.add(value);
    });
  }

  insetData(value) {
    setState(() {
      data.insert(0, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Instagram"),
        actions: [
          IconButton(
            onPressed: () async {

              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              // var image = await picker.pickMultiImage();

              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return Upload(userImage: userImage, insetData: insetData);
                  })
              );
            },
            icon: Icon(Icons.add_box_outlined),
            iconSize: 30,
          )
        ],
      ),
      body: [
        Home(data : data, addData: addData),
        Text('샵')
      ][tap],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (tapNumber){
          setState(() {
            tap = tapNumber;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈',
              activeIcon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: '샵',
              activeIcon: Icon(Icons.shopping_bag)
    ),
        ],
      ),
    );
  }
}


class Home extends StatefulWidget {
  const Home({Key? key, this.data, this.addData}) : super(key: key);
  final data;
  final addData;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();

  getMore() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMore();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
      controller: scroll,
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        if (widget.data.isNotEmpty) {
          return ListBody(
            children: [
              widget.data[index]['image'].runtimeType == String
              ? Image.network(widget.data[index]['image'])
              : Image.file(widget.data[index]['image']),
              // ImageType(image: widget.data[index]["image"]),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(child: Text(widget.data[index]["user"]),
                      onTap: (){
                        Navigator.push(context, CupertinoPageRoute(builder: (c) => Profile())
                        );
                      },
                    ),
                    Text("좋아요 ${widget.data[index]["likes"].toString()}"),
                    Text(widget.data[index]["date"]),
                    Text(widget.data[index]["content"]),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Text("Loading..");
        }
      },
    );
  }
}

class ImageType extends StatelessWidget {
  const ImageType({Key? key, this.image}) : super(key: key);
  final image;
  @override
  Widget build(BuildContext context) {
    if (image.toString().contains("https")) {
      return Image.network(image);
    } else {
      return Image.file(image);
    }
  }
}

class Store1 extends ChangeNotifier {
  var name = 'john kim';
  var follower = 0 ;
  var isFollower = {'john': false};

  changeName() {
    name = 'john park';
    notifyListeners();
  }

  follow() {
    if (isFollower['john'] == false) {
      follower++;
      isFollower['john'] = true;
    } else {
      follower--;
      isFollower['john'] = false;
    }
    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store1>().name),),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                context.read<Store1>().changeName();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                  ),
                  Text('팔로우 ${context.watch<Store1>().follower}'),
                  ElevatedButton(onPressed: () {
                    context.read<Store1>().follow();

                  }, child: Text(context.watch<Store1>().isFollower['john'] == false ? '팔로우' : '팔로우취소'))
                ],
              )
          )
        ],
      )
    );
  }
}


class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.insetData}) : super(key: key);
  final userImage;
  final insetData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(actions: [TextButton(onPressed: (){
          var userData = {
            "id": 3,
            "likes": 5,
            "image": userImage,
            "user": "rumor",
            "content": "test"
          };
          print(userImage);
          insetData(userData);
        }, child: Text("발행"))],),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage, width: 200, height: 200,),
            TextField(),
            IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)
            ),
          ],
        ),
    );

  }
}