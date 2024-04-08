import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loja',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/store': (context) => StorePage(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _nameController = TextEditingController();
  String? _userType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
            ),
          ),
          SizedBox(height: 20.0),
          DropdownButtonFormField<String>(
            value: _userType,
            onChanged: (String? newValue) {
              setState(() {
                _userType = newValue;
              });
            },
            items: ['Funcionário', 'Cliente VIP', 'Cliente Convencional']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Tipo de usuário',
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              String userName = _nameController.text;
              if (userName.isNotEmpty && _userType != null) {
                Navigator.pushNamed(context, '/store', arguments: {
                  'userName': userName,
                  'userType': _userType,
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Erro'),
                      content: Text('Por favor, preencha todos os campos.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Item> _items = [];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _valueController = TextEditingController();

  String? _userName;
  String? _userType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _userName = args['userName'];
      _userType = args['userType'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loja'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do item',
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: 'Valor do item',
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    String name = _nameController.text;
                    double value =
                        double.tryParse(_valueController.text) ?? 0.0;
                    if (name.isNotEmpty && value > 0) {
                      setState(() {
                        _items.add(Item(name: name, value: value));
                      });
                      _nameController.clear();
                      _valueController.clear();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Erro'),
                            content: Text(
                                'Por favor, preencha o nome e o valor do item corretamente.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Adicionar Item'),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    double total = _calculateTotal();
                    double discount = _calculateDiscount(total);
                    double finalTotal = total - discount;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Compra Finalizada'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Obrigado, $_userName!'),
                              Text(
                                  'Valor total: R\$ ${total.toStringAsFixed(2)}'),
                              Text(
                                  'Desconto aplicado: R\$ ${discount.toStringAsFixed(2)}'),
                              Text(
                                  'Total a pagar: R\$ ${finalTotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pop(context);
                              },
                              child: Text('Retornar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Comprar Tudo'),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Itens:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          '${_items[index].name} - R\$ ${_items[index].value.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return _items.fold(
        0.0, (previousValue, item) => previousValue + item.value);
  }

  double _calculateDiscount(double total) {
    if (_userType == 'Cliente VIP') {
      return total * 0.05;
    } else if (_userType == 'Funcionário') {
      return total * 0.10;
    }
    return 0.0;
  }
}

class Item {
  String name;
  double value;

  Item({required this.name, required this.value});
}
