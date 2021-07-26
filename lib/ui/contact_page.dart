import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact? contact;

  //Esse construtor será usado para passagem de parâmetros entre telas
  //Quando vamos editar um contato, suas informações prévias serão passadas para esta tela e para isso precisamos deste contrutor
  ContactPage({this.contact}); //Entre chaves pois esse parâmetro é opcional

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameControler = TextEditingController();
  final _emailControler = TextEditingController();
  final _phoneControler = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;

  Contact? _editedContact;

  @override
  void initState() {
    super.initState();
    //Verifica se o contato é nulo, neste caso estamos criando um novo contato
    if(widget.contact == null){ //O wisget.contact serve pra acessar o Contact mesmo ele não estando nessa classe
      _editedContact = Contact();
    }
    //Caso não seja um novo contato, recupera as informações do contato pré existente para que seja atualizado
    else{
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      //Se estamos editando um contato já existente, suas informações são passadas para esta tela
      _nameControler.text = _editedContact!.name;
      _emailControler.text = _editedContact!.email;
      _phoneControler.text = _editedContact!.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( //Esse widget serve para criar uma ação (neste caso uma dialogAlert) ao voltar para a tela anterior clicando no canto superior esquerdo
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact!.name == "" ? "Novo Contato" : _editedContact!.name),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedContact!.name.isNotEmpty){
              Navigator.pop(context, _editedContact); //Remove esta tela atual (pop) e retorna as inforações pra tela passada (home)
            }
            else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(source: ImageSource.gallery);
                  // ignore: unnecessary_null_comparison
                  if(pickedFile != null){
                    setState(() {
                      _editedContact!.img = pickedFile.path;
                    });
                  }
                  else{
                    return;
                  }
                },
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: getImage(_editedContact!),
                        fit: BoxFit.cover
                      )
                  ),
                ),
              ),
              TextField(
                controller: _nameControler,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){ //O valor passado no textField é passado para a variável text
                  _userEdited = true;
                  setState(() {
                    _editedContact!.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailControler,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact!.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneControler,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact!.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
        builder: (context){
          return AlertDialog( //Quando tentarmos retornar a homepage sem salvar as alterações, um AlertDialog aparecerá na tela
            title: Text("Descartar Alterações?"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context); //Se olharmos a pilha, teremos homepage -> contactpage -> dialog. O pop irá remover apenas o dialog
                },
                child: Text("Cancelar")
              ),
              TextButton(
                  onPressed: (){ //Neste caso, quando o usuário decidir não salvar as alterações, devemos retornar para a tela inicial (homepage), e por isso damos 2 pops
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Sim")
              ),
            ],
          );
        }
      );
      return Future.value(false); //Não sair altomaticamente da tela
    }
    else{
      return Future.value(true); //Sair altomaticamente da tela
    }
  }


  getImage(Contact contacts){
    if(contacts.img == "none") {
      return AssetImage("images/person.png");
    } else {
      return FileImage(File(contacts.img));
    }
  }



}
