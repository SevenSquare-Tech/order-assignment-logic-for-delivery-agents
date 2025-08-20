import 'package:flutter/material.dart';
import 'package:ridderapp/model/account.dart';
import 'package:ridderapp/repository/transactionrepo.dart';
import 'package:ridderapp/utilities/button-util.dart';

class RiderAccount extends StatefulWidget {
  RiderAccount({Key key}) : super(key: key);

  _RiderAccountState createState() => _RiderAccountState();
}

class _RiderAccountState extends State<RiderAccount> {
  TrxRepository repo = new TrxRepository();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('My Account'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: SingleChildScrollView(
          child: new FutureBuilder(
              future: repo.getAccount(),
              builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return accountWidget(snapshot.data);
                  } else {
                    return loading();
                  }
                } else {
                  return loading();
                }
              }),
        ),
      ),
    );
  }

  Widget loading() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget accountWidget(Account acct) {
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white),
        child: Column(
          children: <Widget>[
            TextFormField(
              readOnly: true,
              initialValue: acct.name,
              decoration: InputDecoration(labelText: 'User ID', hintText: 'ID',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.fullName,
              decoration:
                  InputDecoration(labelText: 'Full Name', hintText: 'Name',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.icno,
              decoration:
                  InputDecoration(labelText: 'NRIC No.', hintText: 'IC No.',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.contact,
              decoration:
                  InputDecoration(labelText: 'Phone No.', hintText: 'Phone',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.email,
              decoration:
                  InputDecoration(labelText: 'Email', hintText: 'Email',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.plateNo,
              decoration: InputDecoration(
                  labelText: 'Vechicle No.', hintText: 'Vechicle No.',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.status,
              decoration:
                  InputDecoration(labelText: 'Status', hintText: 'Status',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            TextFormField(
              readOnly: true,
              initialValue: acct.joinDate.toString(),
              decoration: InputDecoration(
                  labelText: 'Join Date', hintText: 'Join Date',labelStyle: TextStyle(color:Color(0xfbb2E4053))),
            ),
            Divider(),
            ButtonUtil.getRaiseButton(() {
              Navigator.of(context).pop();
            }, "OK", Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
