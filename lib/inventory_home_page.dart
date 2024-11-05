import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryHomePage extends StatefulWidget {
  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text('Quantity: ${doc['quantity']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditDialog(doc),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('inventory')
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    _nameController.clear();
    _quantityController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  int.tryParse(_quantityController.text) != null) {
                FirebaseFirestore.instance.collection('inventory').add({
                  'name': _nameController.text,
                  'quantity': int.parse(_quantityController.text),
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(DocumentSnapshot doc) {
    _nameController.text = doc['name'];
    _quantityController.text = doc['quantity'].toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  int.tryParse(_quantityController.text) != null) {
                FirebaseFirestore.instance
                    .collection('inventory')
                    .doc(doc.id)
                    .update({
                  'name': _nameController.text,
                  'quantity': int.parse(_quantityController.text),
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
