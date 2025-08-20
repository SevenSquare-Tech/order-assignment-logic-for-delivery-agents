import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/number_symbols_data.dart';

import '../model/redertrx.dart';
import '../model/trx-type.dart';
import '../repository/transactionrepo.dart';
import '../utilities/util.dart';
import '../utilities/button-util.dart';
import '../utilities/snackbarutil.dart';
import '../utilities/textstyle-util.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class TransactionEntry extends StatefulWidget {
  // final Transaction Transaction;
  final String editmode;
  final RiderTrxDtl trx;
  TransactionEntry(this.trx, this.editmode, {Key key}) : super(key: key);

  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<TransactionEntry>
    with SingleTickerProviderStateMixin {
  final TrxRepository repo = new TrxRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();
  final _trxtypeController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();

  bool _editMode;
  bool _saveChanges;
  TrxType refType;
  TrxTypeList trxTypeList;
  File _image;
  String newID = "";
  RiderTrxDtl _trx;

  @override
  void initState() {
    super.initState();
    _saveChanges = false;
    _editMode = widget.editmode == "EDIT";
    trxTypeList = new TrxTypeList();
    refType = trxTypeList.list[0];
    _dateController.text = Utility.dateToString(DateTime.now());
    if (_editMode) {
      _trx = widget.trx;
      loadData();
    } else {
      _trx = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadData() {
    print(_trx.refType);
    print(_trx.trxType);
    _dateController.text = Utility.dateToString(_trx.trxDate);
    var found = trxTypeList.list.where((x) =>
        x.direction.toUpperCase() == _trx.trxType.toUpperCase() &&
        x.type.toUpperCase() == _trx.refType.toUpperCase());
    if (found.length > 0) {
      refType = found.first;
      _descController.text = refType.desc;
      _trxtypeController.text = refType.type;
    }
    _amountController.text = _trx.amount.toString();
    _remarkController.text = _trx.remarks;
    newID = _trx.uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Transaction'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                //Divider(),
                inputForm(),
                actionButtons(),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputForm() {
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
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  enabled: false,
                  decoration:
                      TextStyleUtil.getFormFieldInputDecoration('Trx Date'),
                  controller: _dateController,
                ),
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context, showTitleActions: true,
                      onChanged: (date) {
                    //print('change $date');
                  }, onConfirm: (date) {
                    _dateController.text = Utility.dateToString(date);
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Icon(
                  Icons.calendar_today,
                  size: 32,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
          DropdownButton<TrxType>(
            items: trxTypeList.list.map((TrxType value) {
              return new DropdownMenuItem<TrxType>(
                value: value,
                child: new Text(value.display),
              );
            }).toList(),
            isExpanded: true,
            onChanged: (val) {
              setState(() {
                refType = val;
                _descController.text = val.desc;
                _trxtypeController.text = val.type;
              });
            },
            value: refType,
            hint: Text(
              "Select Trx Type",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextFormField(
            enabled: false,
            decoration: TextStyleUtil.getFormFieldInputDecoration('Desciption'),
            controller: _descController,
          ),
          TextFormField(
            enabled: false,
            decoration: TextStyleUtil.getFormFieldInputDecoration('Trx Type'),
            controller: _trxtypeController,
          ),
          TextFormField(
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: true),
            decoration:
                TextStyleUtil.getFormFieldInputDecoration('Amount (RM)'),
            controller: _amountController,
          ),
          TextFormField(
            enabled: true,
            decoration: TextStyleUtil.getFormFieldInputDecoration('Remark'),
            controller: _remarkController,
          ),
          Divider(),
          (_saveChanges)?attachButtons():Divider(height: 2),
          // ButtonUtil.getRaiseButton(
          //     uploadAttachment, "Attachment", Theme.of(context).primaryColor),
          (!_saveChanges)?Divider(height: 2):FutureBuilder<void>(
              future: retrieveLostData(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                   return  const Text(
                      '',
                      textAlign: TextAlign.center,
                    );
                  case ConnectionState.waiting:
                    return  const Text(
                      'You have not yet picked an image.',
                      textAlign: TextAlign.center,
                    );
                  case ConnectionState.done:
                    if (_image != null)
                      return imageBox();
                    else
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    break;
                  default:
                    if (snapshot.hasError) {
                      return Text(
                        'Pick image/video error: ${snapshot.error}}',
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    }
                }
              })
        ],
      ),
    );
  }

  Widget imageBox() {
    return Container(
      height: 250,
      width: 250,
      decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.black,
              blurRadius: 20.0,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
          color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.file(_image, width: 200, height: 200, fit: BoxFit.cover)
        ],
      ),
    );
  }

  Widget attachButtons() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(children: <Widget>[
        Expanded(
          child: RaisedButton(
            onPressed: () {
              uploadAttachment(ImageSource.camera);
            },
            child: Row(
              children: <Widget>[
                Icon(Icons.camera),
                Text("Camera"),
              ],
            ),
          ),
        ),
        Text(' '),
        Expanded(
            child: RaisedButton(
          onPressed: () {
            uploadAttachment(ImageSource.gallery);
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.image),
              Text("Galary"),
            ],
          ),
        )),
      ]),
    );
  }

  Widget actionButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Row(children: <Widget>[
        Expanded(
          child: ButtonUtil.getRaiseButton(
              saveTransaction, "Save", Theme.of(context).primaryColor),
        ),
        Text(' '),
        Expanded(
          child: ButtonUtil.getRaiseButton(
              onCancelHandler, "Cancel", Colors.redAccent),
        ),
      ]),
    );
  }

  Future onCancelHandler() async {
    if (_saveChanges) {
      Navigator.pop(context);
    } else {
      ConfirmAction action = await _asyncConfirmDialog(context);
      if (action == ConfirmAction.ACCEPT) {
        Navigator.pop(context);
      }
    }
    //if (_editMode) {
    //  Navigator.pop(context);
    //} else {
    //  resetForm();
    //}
  }

  bool validateInputs() {
    if (_dateController.text == "") {
      SnackBarUtil.showSnackBar('Invalid trx date...', _scaffoldKey);
      return false;
    }

    if (_trxtypeController.text == "") {
      SnackBarUtil.showSnackBar('Invalid trx type...', _scaffoldKey);
      return false;
    }

    var amount = double.tryParse(_amountController.text);
    if (amount == null) {
      SnackBarUtil.showSnackBar('Invalid trx amount...', _scaffoldKey);
      return false;
    }
    return true;
  }

  saveTransaction() {
    if (!validateInputs()) return;

    int trxid = int.tryParse(newID);
    _trx = new RiderTrxDtl(
        amount: double.parse(_amountController.text),
        desc: _descController.text,
        refType: refType.type,
        remarks: _remarkController.text,
        trxDate: DateTime.now(),
        trxStatus: "Pending",
        trxType: refType.direction,
        uid: (trxid == null) ? 0 : trxid,
        name: "");

    repo.postTransaction(_trx).then((resp) {
      String msg = "";
      newID = resp;
      if (resp == "0") {
        msg = "Error submitting transaction!";
      } else {
        msg = "Transaction Submitted.";
        _trx.uid = int.parse(newID);
        setState(() {
           _saveChanges = true;
        });
       
      }
      SnackBarUtil.showSnackBar(msg, _scaffoldKey);
      //anyAttachment();
      //resetForm();
    }, onError: (e) {
      SnackBarUtil.showSnackBar("Error submitting data....", _scaffoldKey);
    });
  }

  Future getImageFromDeviceAndPost(ImageSource imagsource) async {
    try {
      _image = await ImagePicker.pickImage(
          //8:10
          source: imagsource, //ImageSource.camera,
          maxHeight: 1024,
          maxWidth: 2048);

      int id = _trx.uid;
      repo.postImage(_image, id).then((val) {
        _saveChanges = true;
        SnackBarUtil.showSnackBar(val, _scaffoldKey);
      }, onError: (e) {
        SnackBarUtil.showSnackBar("Error uploading image...", _scaffoldKey);
      });
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  Future uploadAttachment(ImageSource source) async {
    if (_trx == null || _trx.uid <= 0) {
      SnackBarUtil.showSnackBar(
          "Please submit Transaction first.", _scaffoldKey);
      return;
    }
    await getImageFromDeviceAndPost(source);
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    } else {
      print(response.exception.code);
    }
  }

  void resetForm() {
    setState(() {});
  }

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: const Text('Changes not save yet, Confirm to leave?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('YES'),
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
