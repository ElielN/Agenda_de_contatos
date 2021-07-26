import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";


//Usamos o padrão singleton pois não haverá múltiplos objetos dessa classe
class ContactHelper{
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //Quando quiser obter uma instância de ContactHelper, chamamos o ContactHelper.instance
  //e assim o obtemos de qualquer parte do código, sendo esse único

  Database? _db;

  Future<Database?> get db async { //Inicializa o banco de dados
    if(_db != null){ //Se o banco de dados já estevier povoado, apenas o retorne
      return _db;
    }
    else{
      _db = await initDb(); //Case contrário, chamamos a função que irá incializar o db
      return _db;
    }
  }

  Future<Database> initDb() async { //Usamos o async por conta da necessidade do await
    final databasesPath = await getDatabasesPath(); //Usamos o await pois não é retornado na mesma hora
    final path = join(databasesPath, "contacts2.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await db; //Obtém o banco de dados
    contact.id = await dbContact!.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    List<Map> maps = await dbContact!.query(contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    }
    else{
      return null;
    }
  }

  Future<int> deleteContact(int? id) async {
    Database? dbContact = await db;
    return await dbContact!.delete(contactTable,
      where: "$idColumn = ?",
      whereArgs: [id]
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database? dbContact = await db;
    return await dbContact!.update(contactTable, contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id]
    );
  }

  Future<List<Contact>> getAllContacts() async {
    Database? dbContact = await db;
    List listMap = await dbContact!.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }
  
  Future<int> getNumber() async {
    Database? dbContact = await db;
    return Sqflite.firstIntValue(await dbContact!.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database? dbContact = await db;
    dbContact!.close();
  }

}

class Contact{
  //Se o atributo for late, não podemos colocar como autoincrement no BD porque o programa considera que ele
  //não foi inicializado e da problema
  int? id; //Chave primária

  String name = "";
  String email = "";
  String phone = "";
  String img = "none"; //Não conseguimos armazenar uma imagem nesse bd, por isso esse img será o path para a imagem armazenada no cel

  Contact();

  Contact.fromMap(Map map){ //Esse construtor serve para recuperar os nossos dados salvos, que foram salvos como maps
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}