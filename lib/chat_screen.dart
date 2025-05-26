import 'package:flutter/material.dart';
import 'package:pawpal/conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _currentIndex = 2;
  String _searchText = '';
  List<Map<String, dynamic>> _chatList = [
    {
      'name': 'Janish Sebastian',
      'message': 'Hi, I want to adopt Daisy',
      'time': '18:01',
      'isBlocked': false,
      'messages': [
        {'text': 'Hi, I want to adopt Daisy', 'isMe': false, 'status': 'dibaca'},
      ],
      'profileImage': 'assets/profile.png',
    },
    {
      'name': 'Malik Rumalolas',
      'message': 'Hi, is the cats food available?',
      'time': '17:05',
      'isBlocked': false,
      'messages': [
        {'text': 'Hi, is the cats food available?', 'isMe': false, 'status': 'dibaca'},
      ],
      'profileImage': 'assets/profile.png',
    },
    {
      'name': 'Hasan Basri',
      'message': 'Can i ask about the price?',
      'time': '10:00',
      'isBlocked': false,
      'messages': [
        {'text': 'Can i ask about the price?', 'isMe': false, 'status': 'dibaca'},
      ],
      'profileImage': 'assets/profile.png',
    },
    {
      'name': 'Samsul Ma\'arif',
      'message': 'Oke see you',
      'time': '08:30',
      'isBlocked': false,
      'messages': [
        {'text': 'Oke see you', 'isMe': false, 'status': 'dibaca'},
      ],
      'profileImage': 'assets/profile.png',
    },
    {
      'name': 'Haris Maulana',
      'message': 'I want to meet you',
      'time': '07:12',
      'isBlocked': false,
      'messages': [
        {'text': 'I want to meet you', 'isMe': false, 'status': 'dibaca'},
      ],
      'profileImage': 'assets/profile.png',
    },
  ];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(_chatList);
  }

  void _searchChat(String query) {
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _searchResults = List.from(_chatList);
      } else {
        _searchResults = _chatList.where((chat) {
          return chat['name']!.toLowerCase().contains(query.toLowerCase()) ||
              chat['messages'].any((msg) => msg['text'].toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
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
              title: Text("Chats", style: TextStyle(color: Colors.white)),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chat',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    constraints: BoxConstraints(maxHeight: 36),
                  ),
                  onChanged: _searchChat,
                ),
              ),
              Expanded(
                child: _searchResults.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildChatItem(
                            context,
                            _searchResults[index]['name']!,
                            _searchResults[index]['messages'].last['text'],
                            _searchResults[index]['time']!,
                            index,
                            _searchResults[index]['profileImage'],
                            _searchResults[index]['isBlocked'],
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'Not Found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
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
              Navigator.pushReplacementNamed(context, '/account');
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red, // Set background color for all items
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Marketplace',
            backgroundColor: Colors.red, // Set background color for all items
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.red, // Set background color for all items
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.red, // Set background color for all items
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String message, String time, int index, String profileImage, bool isBlocked) {
    return InkWell(
      onTap: () {
        if (!isBlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationScreen(
                chat: _searchResults[index],
                onChatUpdated: (updatedChat) {
                  setState(() {
                    _chatList[index] = updatedChat;
                    _searchResults[index] = updatedChat;
                  });
                },
              ),
            ),
          );
        } else {
          _showBlockedDialog(context, index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(profileImage),
              radius: 30,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    message,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time),
                PopupMenuButton<String>(
                  onSelected: (String choice) {
                    switch (choice) {
                      case 'Blokir':
                        _showBlockDialog(context, index);
                        break;
                      case 'Hapus':
                        _showDeleteDialog(context, index);
                        break;
                      case 'Report':
                        _showReportDialog(context, index);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return ['Blokir', 'Hapus', 'Report'].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                  child: Icon(Icons.more_vert), // Use the three-dot icon
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Blokir Pengguna'),
          content: Text('Apakah Anda yakin ingin memblokir pengguna ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _chatList[index]['isBlocked'] = true;
                  _searchResults[index]['isBlocked'] = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Blokir'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Chat'),
          content: Text('Apakah Anda yakin ingin menghapus chat ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _chatList.removeAt(index);
                  _searchResults.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportDialog();
      },
    );
  }

  void _showBlockedDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text(
              'Anda tidak dapat mengirim pesan karena anda memblokir pengguna ini'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Oke'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _chatList[index]['isBlocked'] = false;
                  _searchResults[index]['isBlocked'] = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Buka Blokir'),
            ),
          ],
        );
      },
    );
  }
}

class ReportDialog extends StatefulWidget {
  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  bool _spamChecked = false;
  bool _kasarChecked = false;
  bool _saraChecked = false;
  bool _lainnyaChecked = false;
  String _deskripsi = '';
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Mengapa anda melaporkan orang ini?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          CheckboxListTile(
            title: Text('Spam', style: TextStyle(color: _errorMessage.isNotEmpty ? Colors.red : Colors.black)),
            value: _spamChecked,
            onChanged: _lainnyaChecked
                ? null
                : (bool? value) {
                    setState(() {
                      _spamChecked = value ?? false;
                      _errorMessage = '';
                    });
                  },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Berkata Kasar', style: TextStyle(color: _errorMessage.isNotEmpty ? Colors.red : Colors.black)),
            value: _kasarChecked,
            onChanged: _lainnyaChecked
                ? null
                : (bool? value) {
                    setState(() {
                      _kasarChecked = value ?? false;
                      _errorMessage = '';
                    });
                  },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Terdapat unsur SARA', style: TextStyle(color: _errorMessage.isNotEmpty ? Colors.red : Colors.black)),
            value: _saraChecked,
            onChanged: _lainnyaChecked
                ? null
                : (bool? value) {
                    setState(() {
                      _saraChecked = value ?? false;
                      _errorMessage = '';
                    });
                  },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Lainnya', style: TextStyle(color: _errorMessage.isNotEmpty ? Colors.red : Colors.black)),
            value: _lainnyaChecked,
            onChanged: (bool? value) {
              setState(() {
                _lainnyaChecked = value ?? false;
                if (_lainnyaChecked) {
                  _spamChecked = false;
                  _kasarChecked = false;
                  _saraChecked = false;
                }
                _errorMessage = '';
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Text('Deskripsi (Opsional)'),
          TextFormField(
            maxLength: 500,
            decoration: InputDecoration(border: OutlineInputBorder()),
            onChanged: (text) {
              _deskripsi = text;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Kembali'),
        ),
        TextButton(
          onPressed: () {
            int checkedCount = 0;
            if (_spamChecked) checkedCount++;
            if (_kasarChecked) checkedCount++;
            if (_saraChecked) checkedCount++;
            if (_lainnyaChecked) checkedCount++;

            if (checkedCount >= 1 && checkedCount <= 3) {
              Navigator.of(context).pop();
              _showReportSentDialog(context);
            } else {
              setState(() {
                _errorMessage = 'Centang 1 hingga 3 kotak';
              });
            }
          },
          child: Text('Laporkan'),
        ),
      ],
    );
  }

  void _showReportSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Laporan Terkirim'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Oke'),
            ),
          ],
        );
      },
    );
  }
}


