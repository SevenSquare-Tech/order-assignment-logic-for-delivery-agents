import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ridderapp/model/redertrx.dart';
import 'package:ridderapp/repository/transactionrepo.dart';

class TransImage extends StatefulWidget {
  final RiderTrxDtl trx;
  TransImage(this.trx, {Key key}) : super(key: key);

  _TransImageState createState() => _TransImageState();
}

class _TransImageState extends State<TransImage> {
  RiderTrxDtl _trx;
  final TrxRepository _repo = new TrxRepository();

  @override
  void initState() {
    super.initState();
    _trx = widget.trx;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.blueGrey),
        child: Column(
      children: <Widget>[
        Expanded(
          child: PhotoView(
              imageProvider: NetworkImage(_repo.getImageUrl(_trx.imageFName))),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            "OK",
          ),
        ),
      ],
    ));
  }
}
