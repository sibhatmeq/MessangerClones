import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sibhat_messanger/services/auth.dart';
import 'package:sibhat_messanger/services/database.dart';
import 'package:sibhat_messanger/signin.dart';
import 'chat_screen.dart';
import 'package:sibhat_messanger/helperFunctions/sharedpref_helper.dart';
class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  late Stream usersStream;
  late String myName, myProfilePic, myUserName,myEmail;
  TextEditingController searchUsernameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreference()async{
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic =(await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
  }


  getChatRoomIdByUsernames(String a, String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
  }

  onSearchBtnClick() async{
    isSearching =true;
    setState(() {
    });
   usersStream = await DatabaseMethods().getUserByUserName(searchUsernameEditingController.text);
   setState(() {
   });
  }

  Widget searchUserList(){
    return StreamBuilder(
        stream: usersStream,
        builder: (BuildContext, AsyncSnapshot snapshot ){
          return  snapshot.hasData
          ?  ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder:(context, index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                   return searchListUserTile(
                       profileUrl:ds["imgUrl"],
                       name: ds["name"],
                       email: ds["email"],
                       username: ds["username"]
                   );
              }
          ): Container(
            child: CircularProgressIndicator(),
          );
        }
    );
  }

  Widget searchListUserTile({required String profileUrl,username, name, email}){
    return GestureDetector(
      onTap: (){

        var chatRoomId =getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap ={
          "users":[myUserName, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(width: 12,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(email),
            ],
          )
        ],
      ),
    );
  }

  Widget chatRoomsList(){
    return Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    getMyInfoFromSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messanger Clone'),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then(() {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text ="";
                          setState(() {
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.arrow_back),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUsernameEditingController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'username',
                          ),
                        )),
                        GestureDetector(
                          onTap: () {
                            if(searchUsernameEditingController.text!= ""){
                              onSearchBtnClick();
                            }
                          },
                          child: Icon(
                            Icons.search,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching? searchUserList() :chatRoomsList(),
          ],
        ),
      ),
    );
  }
}
