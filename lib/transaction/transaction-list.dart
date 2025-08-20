import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ridderapp/model/redertrx.dart';
import 'package:ridderapp/transaction/trams-image.dart';
import 'package:ridderapp/transaction/transaction.dart';
import '../repository/transactionrepo.dart';

import '../utilities/snackbarutil.dart';
import '../base/customroute.dart';
import '../utilities/displayutil.dart';
import '../utilities/util.dart';



enum ConfirmAction { CANCEL, ACCEPT }

class TransactionList extends StatefulWidget {
  TransactionList({Key key}) : super(key: key);

  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final TrxRepository _repo = new TrxRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  bool _dataAvailable;

  @override
  void initState() {
    super.initState();
    _dataAvailable = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Transaction List'),
      ),
      floatingActionButton: (!_dataAvailable)
          ? Text('')
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  new CustomRoute(
                      builder: (context) => TransactionEntry(null, "NEW")),
                );
              },
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
            ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: FutureBuilder(
            initialData: new List<RiderTrxDtl>(),
            future: _repo.getTransactions(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 30.0,
                    width: 30.0,
                  ));
                default:
                  if (snapshot.hasError)
                    return new Center(child:Text('${snapshot.error}',
                    style: TextStyle(color: Colors.redAccent,fontStyle: FontStyle.italic,fontSize: 18.0),),);
                  else
                    return createListView(context, snapshot);
              }
            }),
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    // setState(() {
    //   _dataAvailable =true;
    // });
    List<RiderTrxDtl> transactions = snapshot.data as List<RiderTrxDtl>;
    return AnimatedList(
        key: _listKey,
        initialItemCount: transactions.length,
        itemBuilder: (BuildContext context, int index, animation) {
          return listItem(transactions[index], index, animation);
        });

    // return ListView.builder(
    //     itemCount: Transactions.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return listItem(Transactions[index], index);
    //     });
  }

  Widget listItem(RiderTrxDtl item, int index, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child: Container(
          padding: EdgeInsets.fromLTRB(1, 5, 1, 5),
          decoration: BoxDecoration(
              color: (index % 2 == 0)
                  ? Colors.white
                  : Color.fromRGBO(0, 0, 255, 0.1)),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(
                          Utility.dateToStringFormat(item.trxDate,"dd/MM/yy"),
                          fontSize: 14.0)),
                  Expanded(
                      flex: 3,
                      child: DisplayUtil.listItemText(item.refType,
                          fontSize:14.0,fontWeight: FontWeight.bold)),
                  Expanded(
                      flex: 1,
                      child:
                          DisplayUtil.listItemText(item.trxType, fontSize: 13.0,textAlign: TextAlign.left)),
                  Expanded(
                      flex: 2,
                      child: (item.trxType.toUpperCase()=="OUT")?
                               DisplayUtil.listItemText(item.amount.toString()+" -",
                               color: Colors.red,
                                fontSize: 17.0,textAlign: TextAlign.right,fontWeight: FontWeight.bold)
                               :DisplayUtil.listItemText("",
                                   fontSize: 14.0,textAlign: TextAlign.right)
                   ),
                  Expanded(
                      flex: 2,
                      child: (item.trxType.toUpperCase()=="IN")?
                               DisplayUtil.listItemText(item.amount.toString()+" +",
                               color: Colors.green,
                                fontSize: 17.0,textAlign: TextAlign.right,fontWeight: FontWeight.bold)
                               :DisplayUtil.listItemText("",
                                   fontSize: 14.0,textAlign: TextAlign.right)
                   ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.trxStatus,fontSize: 14.0)),
                  Expanded(
                      flex: 8,
                      child:(item.remarks!="")?
                          DisplayUtil.listItemText(item.remarks, fontSize: 14.0):
                          DisplayUtil.listItemText(item.desc, fontSize: 14.0)),
                ],
              ),
              Divider(
                height: 5,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new IconSlideAction(
              caption: 'EDIT',
              color: (item.trxStatus.toUpperCase()=="PENDING")? 
                       Theme.of(context).primaryColor:
                       Theme.of(context).disabledColor,
              icon: Icons.edit,
              onTap: () {
                if (item.trxStatus.toUpperCase()=="PENDING"){
                  Navigator.push(
                    context,
                    new CustomRoute(
                        builder: (context) => TransactionEntry(item, "EDIT")),
                  );
                }
              }),
           new IconSlideAction(
              caption: 'VIEW',
              color: Theme.of(context).accentColor,
              icon: Icons.image,
              onTap: () {
                Navigator.push(
                  context,
                  new CustomRoute(
                      builder: (context) => TransImage(item)),
                );
              }),
        ],
        secondaryActions: <Widget>[
          new IconSlideAction(
              caption: 'DELETE',
              color:(item.trxStatus.toUpperCase()=="PENDING")? 
                       Colors.redAccent:
                       Theme.of(context).disabledColor, 
              icon: Icons.delete,
              onTap: () {
                if (item.trxStatus.toUpperCase()=="PENDING"){
                  deleteIem(item);
                }
              }),
        ],
      ),
    );
  }

  deleteIem(RiderTrxDtl item) {
    _asyncConfirmDialog(context).then((val) {
      if (val == ConfirmAction.ACCEPT) {
        _repo.deleteTransaction(item.uid).then((resp) {
          setState(() {});
        }, onError: (e) {
          print(e.toString());
          SnackBarUtil.showSnackBar("Error deleting record...",_scaffoldKey);
        });
      }
    });
  }

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: const Text('Confirm to delete this record?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('CONFIRM'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }
}
