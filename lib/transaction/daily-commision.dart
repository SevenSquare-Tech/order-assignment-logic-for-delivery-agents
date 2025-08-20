import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:ridderapp/model/commision.dart';
import 'package:ridderapp/repository/transactionrepo.dart';
import 'package:ridderapp/utilities/util.dart';

class DailyCommision extends StatefulWidget {
  DailyCommision({Key key}) : super(key: key);

  _DailyCommisionState createState() => _DailyCommisionState();
}

class _DailyCommisionState extends State<DailyCommision> {
  final _dateController = TextEditingController();
  final TrxRepository _repo = new TrxRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final formatter = new NumberFormat("#,###.00");
  DateTime _date;
  double _totalAmt = 0.00;
  StreamController<double> streamController = new StreamController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _totalAmt = 0.00;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Daily Commmision"),
          ),
          body: FutureBuilder(
              future: _repo.getDailyCommision(_date),
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
                      return new Center(
                        child: Text(
                          '${snapshot.error}',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                              fontSize: 18.0),
                        ),
                      );
                    else {
                      if (snapshot.hasData)
                        return createListView(context, snapshot);
                      else
                        return Text('');
                    }
                }
              }),
          bottomNavigationBar: StreamBuilder(
            stream: streamController.stream,
            builder: (context, snapshot) {
              return bottomAppBar(snapshot);
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.calendar_today),
            onPressed: () {
              onFilterHandler();
            },
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }

  Widget bottomAppBar(snapshot) {
    var data = 0.00;
    if (snapshot.hasData) data = snapshot.data;

    return BottomAppBar(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 1, 20, 1),
        child: Row(
          children: <Widget>[
            Text(
              Utility.dateToStringFormat(_date, "dd-MM-yyyy"),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Expanded(
              child: Text(
                "Total RM " + formatter.format(data),
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
            color: Theme.of(context).primaryColor),
        height: 40.0,
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Commision> transactions = snapshot.data as List<Commision>;
    if (transactions.length == 0) {
      return Container(
        decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            color: Colors.white),
        child: Center(
            child: Text(
          "You have No Order.",
          style: TextStyle(
              fontSize: 25,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold),
        )),
      );
    }
    _totalAmt = 0.00;
    transactions.forEach((x) => _totalAmt = _totalAmt + x.commission);
    streamController.add(_totalAmt);

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Order No#",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Text(
                    "RM",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedList(
                key: _listKey,
                initialItemCount: transactions.length,
                itemBuilder: (BuildContext context, int index, animation) {
                  return listItem(transactions[index], index, animation);
                }),
          ),
        ],
      ),
    );
  }

  Widget listItem(Commision item, int index, Animation animation) {
    _totalAmt = _totalAmt + item.commission;

    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 4, 10, 4),
        decoration: BoxDecoration(
           
            color: index.isEven ? Colors.white : Color(0xffD6EAF8)),
        padding: EdgeInsets.fromLTRB(20, 1, 20, 1),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.order_No,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: Text(
                formatter.format(item.commission),
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future onFilterHandler() async {
    DatePicker.showDatePicker(context, showTitleActions: true,
        onChanged: (date) {
      //print('change $date');
    }, onConfirm: (date) {
      //_dateController.text = Utility.dateToString(date);
      setState(() {
        _date = date;
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }
}
