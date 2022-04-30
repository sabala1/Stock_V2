import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_v2/models/product.dart';
import 'package:stock_v2/provider/db_provider.dart';

class Stock extends StatefulWidget {
  const Stock({Key? key}) : super(key: key);

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  var _refresh = GlobalKey<RefreshIndicatorState>();

  late DBProvider dbProvider;

  @override
  void initState() {
    dbProvider = DBProvider();
    super.initState();
  }

  @override
  void dispose() {
    dbProvider.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          createDialog();
        },
        label: Text(
          'เพิ่ม',
          style: GoogleFonts.kanit(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  _buildAppBar() => AppBar(
        title: Text(
          'STOCK APP',
          style: GoogleFonts.kanit(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _refresh.currentState!.show();
              dbProvider.deleteAll();
            },
          ),
        ],
      );

  _buildContent() {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        setState(() {});
      },
      child: FutureBuilder(
        future: dbProvider.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Product> products = snapshot.data as List<Product>;
            if (products.length > 0) {
              return _buildListView(products.reversed.toList());
            }
            return Center(
              child: Text(
                'ไม่พบข้อมูล',
                style: GoogleFonts.kanit(),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _buildListView(List<Product> product) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Color.fromARGB(255, 103, 162, 211),
      ),
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        columns: const [
          DataColumn(
            label: Text('Item'),
          ),
          DataColumn(
            label: Text('Qty'),
          ),
          DataColumn(
            label: Text('Edit'),
          ),
          DataColumn(
            label: Text('Delete'),
          )
        ],
        rows: product
            .map(
              (items) => DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: 120,
                      child: Text(items.item.toString()),
                    ),
                    onTap: () {},
                  ),
                  DataCell(
                    Container(width: 100, child: Text(items.qty.toString())),
                    onTap: () {},
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                      ),
                      onPressed: () {
                        editDialog(items);
                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                      ),
                      onPressed: () async {
                        _refresh.currentState!.show();
                        dbProvider.deleteProduct(items.id!);
                        await Future.delayed(Duration(seconds: 2));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item deleted'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                _refresh.currentState!.show();
                                dbProvider.insertProduct(items).then(
                                  (value) {
                                    print(product);
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  _buildBody() => FutureBuilder(
        future: dbProvider.initDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildContent();
          }
          return Center(
            child: snapshot.hasError
                ? Text(snapshot.error.toString())
                : CircularProgressIndicator(),
          );
        },
      );

  createDialog() {
    var _formKey = GlobalKey<FormState>();
    Product product = Product();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty || value == "") {
                      return 'กรุณากรอกรายการสินค้า';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(hintText: 'รายการสินค้า (ITEM)'),
                  onSaved: (value) {
                    product.item = value;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty || value == "") {
                      return 'กรุณากรอกจำนวน';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(hintText: 'จำนวน (QTY)'),
                  onSaved: (value) {
                    product.qty = int.parse(value!);
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      'บันทึก',
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _refresh.currentState!.show();
                        Navigator.pop(context);
                        dbProvider.insertProduct(product).then((value) {
                          print(product);
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  editDialog(Product product) {
    var _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: product.item,
                  validator: (value) {
                    if (value!.isEmpty || value == "") {
                      return 'กรุณากรอกรายการสินค้า';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(hintText: 'รายการสินค้า (ITEM)'),
                  onSaved: (value) {
                    product.item = value;
                  },
                ),
                TextFormField(
                  initialValue: product.qty.toString(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty || value == "") {
                      return 'กรุณากรอกจำนวน';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(hintText: 'จำนวน (QTY)'),
                  onSaved: (value) {
                    product.qty = int.parse(value!);
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      'บันทึก',
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _refresh.currentState!.show();
                        Navigator.pop(context);
                        dbProvider.updateProduct(product).then((row) {
                          print(row.toString());
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
