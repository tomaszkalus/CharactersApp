import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> characters = [];
  int nextPage = 1;
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCharacters(nextPage);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchCharacters(nextPage);
      }
    });
  }

  fetchCharacters(int page) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character?page=$page'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          characters.addAll(data['results']);
          nextPage++;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load characters');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Characters'),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: isLoading ? characters.length + 1 : characters.length,
          itemBuilder: (context, index) {
            if (index == characters.length) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListTile(
                title: Text(characters[index]['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterDetails(character: characters[index], key: Key(characters[index]['id'].toString()),),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}


class CharacterDetails extends StatelessWidget {
  final Map<String, dynamic> character;
  CharacterDetails({required Key key, required this.character}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.network(character['image']),
            ),
            SizedBox(height: 50),
            Text.rich(
              TextSpan(
                text: 'Name: ',
                style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
                children: <TextSpan>[
                  TextSpan(text: '${character['name']}', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Status: ',
                style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
                children: <TextSpan>[
                  TextSpan(text: '${character['status']}', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Species: ',
                style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
                children: <TextSpan>[
                  TextSpan(text: '${character['species']}', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Gender: ',
                style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
                children: <TextSpan>[
                  TextSpan(text: '${character['gender']}', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Appears in ',
                style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
                children: <TextSpan>[
                  TextSpan(text: '${character['episode'].length} episodes', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}