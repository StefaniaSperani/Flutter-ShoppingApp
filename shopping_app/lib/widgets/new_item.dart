import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';
// import 'package:shopping_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // Utilizzo la GlobalKey che crea un oggetto GlobalKey che userò come valore per la mia key nel form,
  // garantendomi che se il metodo Build viene chiamato il widget Form non viene ricostruito,
  // emantendeno il suo stato interno
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    // Aggiungo ! per dire DART che questo oggetto di state esiste e non è nullo
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      // Colleggo il backend garzie al pacchetto http di flutter
      final url = Uri.https(
        'flutter-prep-d6dbc-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final res = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
        },
        body: json.encode(
          {
            // Non invio un id perchè Firebase lo creerà da solo
            // 'id': DateTime.now().toString(),
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory
                .title, // .title perchè essendo un oggetto completo la codifica potrebbe fallire,
            // e poi lo userò come identificatore per mappare l'oggetto
          },
        ),
      );

      final Map<String, dynamic> resData = json.decode(res.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );

      // Mando il mio nuovo item alla schermata da cui provengo
      // che in questo caso è GroceryList
      // Navigator.of(context).pop(GroceryItem(
      // id: DateTime.now().toString(),
      // name: _enteredName,
      // quantity: _enteredQuantity,
      // category: _selectedCategory));
      // }  USO FIREBASE E NON MI SERVE PIU
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        // COSTRUISCO IL FORM
        child: Form(
          // Dico a Flutter di eseguire i validator
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!; // Non può essere mai null
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avendo due widget in una row, utilizzo expanded
                  // che mi permette di adattare i due widget allo spazio presente,
                  // altrimenti senza expanded si adatterebbero naturalmente
                  // causando problemi di rendering
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      // Imposto il tastierino numerico
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                      // Queste funzioni si attivano se la validation passa i controlli
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      // Imposto un valore iniziale nelle categorie
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            // Imposto il valore della dropdown
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      // Utilizzo setState perchè quando cambia la categoria
                      // deve rimanere sincronizzato con il cambiamento, quindi se seleziono
                      // una cosa diversa da vegetables a schermo cambierà con la mia nuova selezione
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                        // Non ho bisogno di aggiungere onSaved al dropdown perchè già qui sto memorizzando il valore
                      },
                    ),
                  ),
                ],
              ),
              // CREO I BOTTONI PER AGGIUNGERE/RESETTARE
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    //disabilito i tasti se sta inviando la richiesta
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
