import 'package:flutter/material.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

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
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    //creo un widget che mostra un messagio al centro se non c'è niente nella lista
    Widget content = const Center(child: Text('No items added yet'));

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
