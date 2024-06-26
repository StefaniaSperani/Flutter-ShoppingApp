import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_app/data/categories.dart';

import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error; //può essere null ma se non lo è restituisce una String

  //inizializzo lo stato quando viene creato per la prima volta
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    //con Firebase recupero i dati dal db per mostrarli nella lista
    final url = Uri.https(
      'flutter-prep-d6dbc-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    try {
      final res = await http.get(url);

      if (res.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data, please try again later';
        });
      }

      //per evitare il caricamento all'infinito quando elimino tutti gli item, aggiungo un controllo
      //la stringa null dipende da Firsebase, un altro be potrebbe essere diverso
      if (res.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return; //evito che carichi dei dati che non esistono più
      }
      if (res.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data, please try again later';
        });
      }

      //per evitare il caricamento all'infinito quando elimino tutti gli item, aggiungo un controllo
      //la stringa null dipende da Firsebase, un altro be potrebbe essere diverso
      if (res.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return; //evito che carichi dei dati che non esistono più
      }

      final Map<String, dynamic> listData = json.decode(res.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      //quando viene eseguito di nuovo, interfaccia sarà aggiornata
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong, please try again later';
      });
    }
  }

//funzione che mi permette di passare alla pagina
//NewItem() che mi farà aggiungere un nuovo item
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      //push() contiene eventuali dati passati da NewItem (dico anche che tipo di dati saranno)
      //nel futuro, nel futuro perchè l'utente ci impiegherà un po di tempo prima di compilare il form
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
    //senza firebase
    // if (newItem == null) {
    //   return;
    // }

    // setState(() {
    //   _groceryItems.add(newItem);
    // });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-d6dbc-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //posso inserire un messaggio di errore
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //creo un widget che mostra un messagio al centro se non c'è niente nella lista
    Widget content = const Center(child: Text('No items added yet'));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    //altrimenti mostra la ListView
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        //faccio sapere a flutter quante volte dovrà chiamare groceryItems
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) =>
            //Dismissible mi permetterà di swipare e cancellare l'elemento
            Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      //Se è una lista molto lunga, l'elenco sarà ottimizzato
      //renderizzando gli elementi che sono effettivamente visibili o quasi
      body: content,
    );
  }
}
