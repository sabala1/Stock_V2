import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stock_v2/models/product.dart';

class DBProvider {
  late Database database;

  Future<bool> initDB() async {
    try {
      final String databaseName = 'MYSTOCK.db';
      final String databasePath = await getDatabasesPath();
      final String path = join(databasePath, databaseName);

      if (!await Directory(dirname(path)).exists()) {
        await Directory(dirname(path)).create(recursive: true);
      }

      database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print("Database Create");
          String sql = "CREATE TABLE $TABLE_PRODUCT ("
            "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_ITEM TEXT,"
            "$COLUMN_QTY INTEGER"
            ")";
          await db.execute(sql);
        },
      
        onOpen: (Database db) async {
          print('Database version: ${await db.getVersion()}');
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future close() async => database.close();

  Future<List<Product>> getProducts() async {
    List<Map<String, dynamic>> maps = await database.query(
      TABLE_PRODUCT,
      columns: [COLUMN_ID, COLUMN_ITEM, COLUMN_QTY],
    );

//    List<Map> maps = await database.rawQuery("SELECT * FROM $TABLE_PRODUCT");

    if (maps.length > 0) {
      return maps.map((p) => Product.fromMap(p)).toList();
    }
    return [];
  }

  Future<Product?> getProduct(int id) async {
    List<Map<String, dynamic>> maps = await database.query(
      TABLE_PRODUCT,
      columns: [COLUMN_ID, COLUMN_ITEM, COLUMN_QTY],
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product> insertProduct(Product product) async {
    product.id = await database.insert(TABLE_PRODUCT, product.toMap());
    return product;
  }

  Future<int> updateProduct(Product product) async {
    print(product.id);
    return await database.update(
      TABLE_PRODUCT,
      product.toMap(),
      where: "$COLUMN_ID = ?",
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await database.delete(
      TABLE_PRODUCT,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    String sql = "Delete from $TABLE_PRODUCT";
    return await database.rawDelete(sql);
  }
}
