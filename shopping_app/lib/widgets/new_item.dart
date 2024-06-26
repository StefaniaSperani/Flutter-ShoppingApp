import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  //Utilizzo la GlobalKey che crea un oggetto GlobalKey che userò come valore per la mia key nel form,
  //garantendomi che se il metodo Build viene chiamato il widget Form non viene ricostruito,
  //emantendeno il suo stato interno
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() {
    //aggiungo ! per dire DART che questo oggetto di state esiste e non è nullo
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //mando il mio nuovo item alla schermata da cui provengo
      //che in questo caso è GroceryList
      Navigator.of(context).pop(GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory));
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
        //COSTRUISCO IL FORM
        child: Form(
          //dico a Flutter di eseguire i validator
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
                  _enteredName = value!; //non può essere mai null
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //Avendo due widget in una row, utilizzo expanded
                  //che mi permette di adattare i due widget allo spazio presente,
                  //altrimenti senza expanded si adatterebbero naturalmente
                  //causando problemi di rendering
                  Expanded(
                    child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        //imposto il tastierino numerico
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
                        //queste funzioni si attivano se la validation passa i controlli
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      //imposto un valore iniziale nelle categorie
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            //imposto il valore della dropdown
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
                      //utilizzo setState perchè qundo cambia la categoria
                      //deve rimanere sincronizzato con il cambiamento, quindi se seleziono
                      //una cosa diversa da vegetables a schermo cambierà con la mia nuoca selezione
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                        //non ho bisogno di aggiungere onSaved al dropdown perchè già qui sto memorizzando il valore
                      },
                    ),
                  ),
                ],
              ),
              //CREO I BOTTONI PER AGGIUNGERE/RESETTARE
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _saveItem,
                  child: const Text('Add item'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
