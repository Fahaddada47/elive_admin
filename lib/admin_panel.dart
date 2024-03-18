import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _matchNameController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();

  final CollectionReference _tvListCollection =
  FirebaseFirestore.instance.collection('tvlist');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tvListCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    data['matchName'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['videoUrl']),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(documents[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteMatch(documents[index].id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Match'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _matchNameController,
                decoration: InputDecoration(labelText: 'Match Name'),
              ),
              TextField(
                controller: _videoUrlController,
                decoration: InputDecoration(labelText: 'Video URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addMatch();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Match'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _matchNameController..text = document['matchName'],
                decoration: InputDecoration(labelText: 'Match Name'),
              ),
              TextField(
                controller: _videoUrlController..text = document['videoUrl'],
                decoration: InputDecoration(labelText: 'Video URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateMatch(document.id);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _addMatch() async {
    String matchName = _matchNameController.text;
    String videoUrl = _videoUrlController.text;

    await _tvListCollection.add({
      'matchName': matchName,
      'videoUrl': videoUrl,
    });

    _matchNameController.clear();
    _videoUrlController.clear();
  }

  void _deleteMatch(String documentId) async {
    await _tvListCollection.doc(documentId).delete();
  }

  void _updateMatch(String documentId) async {
    String matchName = _matchNameController.text;
    String videoUrl = _videoUrlController.text;

    await _tvListCollection.doc(documentId).update({
      'matchName': matchName,
      'videoUrl': videoUrl,
    });
  }
}