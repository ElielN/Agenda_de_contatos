import 'dart:io';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza} //enum = conjunto de constantes

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper? helper = ContactHelper();

  List<Contact> contacts = []; //Os contatos são puxados do banco de dados e puxados pra essa lista logo ao iniciar o app (ver o initState)

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz
              ),
              const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return _contactCard(context, index);
        }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: getImage(contacts, index),
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacts[index].name,
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(contacts[index].phone,
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        _showOption(context, index);
      },
    );
  }

  void _showOption(BuildContext context, int index){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){

          },
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:EdgeInsets.all(10.0),
                    child: TextButton(
                        onPressed: (){
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                        child: Text("Ligar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        )
                    ),
                  ),
                  Padding(
                    padding:EdgeInsets.all(10.0),
                    child: TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                        child: Text("Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        )
                    ),
                  ),
                  Padding(
                    padding:EdgeInsets.all(10.0),
                    child: TextButton(
                        onPressed: (){
                          helper!.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                        child: Text("Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        )
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  getImage(List contacts, int index){
    if(contacts[index].img == "none") {
      return AssetImage("images/person.png");
    } else {
      return FileImage(File(contacts[index].img));
    }
  }
  //Acessamos a tela ContactPage passando (opcionalmente) informações
  void _showContactPage({Contact? contact}) async { //Parâmetro opcional pois podemos estar criando um novo contato ou editando um existente
    //O Navigator.push é usado para acessar outra tela do app e ao retornar, trazer informações daquela tela, então podemos fazer uma atribuição
    //O Navigator.pop da contact page quando acionado também e retornado aqui para a variável recContact
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact))
    );
    if(recContact != null){
      if(contact != null){
        await helper!.updateContact(recContact);
      }
      else{
        await helper!.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper!.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase()); //O toLowerCase serve para que as letras maiúsculas e minúsculas não interfiram
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase()); //O toLowerCase serve para que as letras maiúsculas e minúsculas não interfiram
        });
        break;
    }
    setState(() {

    });
  }

}
