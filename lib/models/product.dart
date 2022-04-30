const String TABLE_PRODUCT = 'product';
const String COLUMN_ID = 'id';
const String COLUMN_ITEM = 'item';
const String COLUMN_QTY = 'qty';


class Product {
  int? id;
  String? item;
  int? qty;

 Product({
  this.id,
  this.item,
  this.qty,
 
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_ITEM: item,
      COLUMN_QTY: qty,    
    };

    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_ID];
    item = map[COLUMN_ITEM];
    qty = map[COLUMN_QTY];
   
  }

  @override
  String toString() => "$id, $item, $qty";
}
