import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'package:http/http.dart' as http;

int perPage = 2;
int present = 0;
List<User> items = List<User>();
List<User> users = [];
void main() => runApp(GetListActivity());

class GetListActivity extends StatefulWidget {
  @override
  _getDataState createState() => _getDataState();
}

Future<List<User>> getUsersList(String id) async {
  String apiURL = "https://reqres.in/api/users?page=" + id;
  var response = await http.get(apiURL);
  var jsonObject = json.decode(response.body);
  List<dynamic> listUser = (jsonObject as Map<String, dynamic>)['data'];

  for (int i = 0; i < listUser.length; i++) {
    items.add(User.fromJson(listUser[i]));
  }

  return items;
}

class _getDataState extends State<GetListActivity> {
  Future<List<User>> getListUsers;
  @override
  void initState() {
    User.isConnected().then((internet) {
      if (internet) {
        setState(() {
          getListUsers = getUsersList("2").then((items) {
            if (perPage >= items.length) {
              print("masuk");
              users.addAll(items.getRange(0, items.length)); // all index
            } else if (items.length >= 4) {
              print("keluar");
              users.addAll(items.getRange(present, present + perPage));
            }
            present = (present + perPage);
            return users;
          });
        });
      } else {}
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("TEST GET"),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder<List<User>>(
              future: getListUsers,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    {
                      // here we are showing loading view in waiting state.
                      return loadingView();
                    }
                  case ConnectionState.active:
                    {
                      break;
                    }
                  case ConnectionState.done:
                    {
                      if (items != null) {
                        if (items.length > 0) {
                          // here inflate data list
                          return ListView.builder(
                              itemCount: (present < items.length) // 2 < 3
                                  ? users.length + 1
                                  : users.length,
                              //    itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                print(
                                    "user.length = " + users.length.toString());
                                print("index = " + index.toString());
                                return (index == users.length)
                                    ? showmore()
                                    : generateColum(snapshot.data[index]);
                                //    return listviewdata(snapshot.data[index]);
                              });
                        } else {
                          // display error message if your list or data is null.
                          return noDataView("No data found");
                        }
                      } else if (snapshot.hasError) {
                        // display your message if snapshot has error.
                        return noDataView(snapshot.error.toString());
                      } else {
                        return noDataView("Something went wrong");
                      }
                    }
                    break;
                  case ConnectionState.none:
                    {}
                }
                return loadingView();
              }),
        ),
      ),
    );
  }

  Container showmore() {
    return Container(
      color: Colors.white,
      child: FlatButton(
        child: Text(
          "Load More",
          style: TextStyle(
              fontSize: 16,
              color: Color(0xff3B5FDE),
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          loadMore();
        },
      ),
    );
  }

  void loadMore() {
    setState(() {
      print("present = " + present.toString());
      if ((present + perPage) >= items.length) {
        // kalau originalItems iterasi habis
        print("iterasi habis");
        users.addAll(items.getRange(present, items.length));
      } else {
        // kalau originalItems masih iterasi
        print("iterasi lanjut");
        users.addAll(items.getRange(present, present + perPage));
      }
      present = present + perPage;
    });
  }

  Widget loadingView() => Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.red,
        ),
      );

  Widget noDataView(String msg) => Center(
        child: Text(
          msg,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      );

  Widget generateColum(User item) => Card(
        child: ListTile(
          onTap: () {},
          //leading: Image.network(item.img),
          title: Text(
            item.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle:
              Text(item.id, style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}
