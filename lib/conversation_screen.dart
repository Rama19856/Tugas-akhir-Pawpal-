import 'package:flutter/material.dart';
class ConversationScreen extends StatefulWidget {
final Map<String, dynamic> chat;
final Function(Map<String, dynamic>) onChatUpdated;
ConversationScreen({required this.chat, required this.onChatUpdated});
@override
_ConversationScreenState createState() => _ConversationScreenState();
}
class _ConversationScreenState extends State<ConversationScreen> {
int _currentIndex = 2;
List<Map<String, dynamic>> _messages = [];
TextEditingController _messageController = TextEditingController();
late String _profileImage;
@override
void initState() {
super.initState();
_messages = List.from(widget.chat['messages']);
_profileImage = widget.chat['profileImage'] ?? 'assets/hewan.png';
}
void _sendMessage(String text) {
if (text.isNotEmpty) {
setState(() {
_messages.add({'text': text, 'isMe': true, 'status': 'terkirim'});
widget.chat['messages'].add({'text': text, 'isMe': true, 'status': 'terkirim'});
widget.chat['message'] = text;

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.last['status'] = 'dibaca';
        widget.chat['messages'].last['status'] = 'dibaca';
      });
    });
    _messageController.clear();
      widget.onChatUpdated(widget.chat); // Notify chat list about changes

  });
}
}
void _changeProfileImage(String imagePath) {
setState(() {
_profileImage = imagePath;
widget.chat['profileImage'] = imagePath;
});
}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.red,
appBar: PreferredSize(
preferredSize: Size.fromHeight(100.0),
child: Container(
color: Colors.red,
child: Padding(
padding: const EdgeInsets.only(top: 20.0),
child: AppBar(
backgroundColor: Colors.red,
elevation: 0,
title: Row(
children: [
GestureDetector(
onTap: () {
_showImagePickerDialog(context);
},
child: CircleAvatar(
backgroundImage: AssetImage(_profileImage),
radius: 20,
),
),
SizedBox(width: 10),
Text(widget.chat['name'], style: TextStyle(color: Colors.white)),
],
),
centerTitle: true,
leading: IconButton(
icon: Icon(Icons.arrow_back, color: Colors.white),
onPressed: () {
Navigator.pop(context);
widget.onChatUpdated(widget.chat);
},
),
),
),
),
),
body: ClipRRect(
borderRadius: BorderRadius.only(
topLeft: Radius.circular(30.0),
topRight: Radius.circular(30.0),
),
child: Container(
decoration: BoxDecoration(
color: Colors.white,
),
child: Column(
children: [
Expanded(
child: ListView.builder(
itemCount: _messages.length,
itemBuilder: (context, index) {
return _buildMessageItem(_messages[index]['text'], _messages[index]['isMe'], _messages[index]['status']);
},
),
),
Container(
padding: EdgeInsets.all(8.0),
decoration: BoxDecoration(
border: Border.all(color: Colors.grey),
borderRadius: BorderRadius.circular(30),
),
margin: EdgeInsets.all(8.0),
child: Row(
children: [
IconButton(
icon: Icon(Icons.attach_file),
onPressed: () {},
),
Expanded(
child: TextField(
controller: _messageController,
decoration: InputDecoration(
hintText: 'Type a message',
border: InputBorder.none,
),
onSubmitted: (text) => _sendMessage(text),
),
),
IconButton(
icon: Icon(Icons.send),
onPressed: () => _sendMessage(_messageController.text),
),
],
),
),
],
),
),
),
bottomNavigationBar: BottomNavigationBar(
backgroundColor: Colors.red,
selectedItemColor: Colors.white,
unselectedItemColor: Colors.grey,
showSelectedLabels: true,
showUnselectedLabels: true,
currentIndex: _currentIndex,
onTap: (int index) {
setState(() {
_currentIndex = index;
});
switch (index) {
case 0:
Navigator.pushReplacementNamed(context, '/homepage');
break;
case 1:
Navigator.pushReplacementNamed(context, '/marketplace');
break;
case 2:
// Chat is already selected, do nothing or refresh
break;
case 3:
// Profile
break;
}
},
items: const <BottomNavigationBarItem>[
BottomNavigationBarItem(
icon: Icon(Icons.home),
label: 'Home',
backgroundColor: Colors.red,
),
BottomNavigationBarItem(
icon: Icon(Icons.shopping_cart),
label: 'Marketplace',
backgroundColor: Colors.red,
),
BottomNavigationBarItem(
icon: Icon(Icons.chat),
label: 'Chat',
backgroundColor: Colors.red,
),
BottomNavigationBarItem(
icon: Icon(Icons.person),
label: 'Profile',
backgroundColor: Colors.red,
),
],
),
);
}
Widget _buildMessageItem(String message, bool isMe, String? status) {
return Padding(
padding: const EdgeInsets.all(8.0),
child: Align(
alignment: isMe ? Alignment.topRight : Alignment.topLeft,
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Container(
padding: EdgeInsets.all(8.0),
decoration: BoxDecoration(
color: isMe ? Colors.red : Colors.grey,
borderRadius: BorderRadius.circular(8),
),
child: Text(
message,
style: TextStyle(color: isMe ? Colors.white : Colors.black),
),
),
if (isMe && status != null)
Text(
status,
style: TextStyle(fontSize: 10, color: Colors.grey),
),
],
),
),
);
}
void _showImagePickerDialog(BuildContext context) {
showDialog(
context: context,
builder: (BuildContext context) {
return AlertDialog(
title: Text("Pilih Gambar Profil"),
content: SingleChildScrollView(
child: ListBody(
children: [
GestureDetector(
child: Text("Ambil dari Galeri"),
onTap: () {
_changeProfileImage('assets/image2.png');
Navigator.pop(context);
},
),
Padding(padding: EdgeInsets.all(8.0)),
GestureDetector(
child: Text("Gunakan Gambar Default"),
onTap: () {
_changeProfileImage('assets/hewan.png');
Navigator.pop(context);
},
),
],
),
),
);
},
);
}
}
