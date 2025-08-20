import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:ridderapp/model/account.dart';
import 'package:ridderapp/model/commision.dart';
import 'package:ridderapp/model/commison-req.dart';
import 'package:ridderapp/model/redertrx.dart';
import 'package:ridderapp/model/wallet.dart';
import 'dart:convert';

import '../model/user.dart';
import '../base/apibase.dart';

class TrxRepository extends ApiBase {
  Future<String> postTransaction(RiderTrxDtl trx) async {
    String token = await getToken();
    User user = getAuthTokenInfo(token);
    String url = apiURL + "rider/transaction";
    print(url);
    var body = jsonEncode(trx.toJson(trx, user.name));
    print(body);
    var response = await http.post(url,
        headers: {'content-type': 'application/json', 'Authorization': token},
        body: body);

    print(response.statusCode);
    dynamic resp = jsonDecode(response.body);
    print(resp);
    String msg;
    if (resp['value']["ok"] == "yes") {
      msg = resp['value']["newid"].toString();
    } else {
      msg = "0";
    }
    print(msg);
    return msg;
  }

  Future<String> postImage(File file, int id) async {
    String url = apiURL + "rider/uploadfile/" + id.toString();
    var postUri = Uri.parse(url);
    if (file == null) return "Invalid file object.";

    String filename = basename(file.path);
    String ext = extension(filename);
    var request = http.MultipartRequest("POST", postUri);
    request.files.add(new http.MultipartFile.fromBytes(
        'file', await file.readAsBytes(),
        filename: filename, contentType: MediaType('image', ext)));
    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    dynamic resp = jsonDecode(respStr);
    print(resp["ok"]);
    print(resp["filename"]);
    String msg = "Fail to upload image.";

    if (resp["ok"] == "yes") {
      msg = "Image Uploaded ";
    }

    return msg;
  }

  Future<List<RiderTrxDtl>> getTransactions({bool showAll: false}) async {
    List<RiderTrxDtl> _trxlist = new List<RiderTrxDtl>();
    String token = await getToken();
    User user = getAuthTokenInfo(token);
    print(user.name);
    String url = apiURL +
        "rider/transactions?\$filter=Rider_Name eq '" +
        user.name +"' & \$orderby=TransactionDate desc";
  print(url);
    var response;
    try {
      response = await http.get(url, headers: {
        'content-type': 'application/json',
        'Authorization': token
      });
      print(response.statusCode);
      if (response.statusCode != 200) {
        throw new Exception("Internal error happening at Server.");
      }
    } catch (e) {
      print(e.toString());
      throw new Exception(
          "Error connecting to Server. Please check you mobile nextwork.");
    }

    dynamic resp = jsonDecode(response.body);

    dynamic data = resp;
    data.forEach((item) {
      _trxlist.add(RiderTrxDtl.fromTrxJson(item));
    });
     _trxlist.sort((a,b){
        return b.trxDate.compareTo(a.trxDate) ;
     });
    return _trxlist;
  }

  Future<String> deleteTransaction(int id) async {
    String token = await getToken();

    String url = apiURL + "rider/" + id.toString();
    print(url);

    var response = await http.delete(url,
        headers: {'content-type': 'application/json', 'Authorization': token});
    dynamic resp = jsonDecode(response.body);
    print(resp);
    String msg;
    if (resp["ok"] == "yes") {
      msg = "Transaction deleted";
    } else {
      msg = "Error deleting transaction....";
    }

    return msg;
  }

  Future<Wallet> getWallet() async {
    Wallet wallet = new Wallet(name: "", balance: 0.0);
    String token = await getToken();
    User user =getAuthTokenInfo(token);

    String url = apiURL + "rider/wallet/" + user.name;
    print(url);

    var response = await http.get(url,
        headers: {'content-type': 'application/json', 'Authorization': token});
    dynamic resp = jsonDecode(response.body);
    String msg;
    if (resp["ok"] == "yes") {
      wallet.name = resp["name"];
      wallet.balance = resp["balance"];
      wallet.nickname = resp["nickname"]==null?resp["name"]:resp["nickname"];
    } else {
      msg = "Error deleting transaction....";
    }

    return wallet;
  }
  
  Future<Account> getAccount() async {
    Account wallet = new Account();
    String token = await getToken();
    User user =getAuthTokenInfo(token);

    String url = apiURL + "rider/account/" + user.name;

    var response = await http.get(url,
        headers: {'content-type': 'application/json', 'Authorization': token});
    dynamic resp = jsonDecode(response.body);
    String msg;
    if (resp["ok"] == "yes") {
      wallet.name = resp["name"];
      wallet.fullName = resp["fullName"];
      wallet.contact = resp["contact"];
      wallet.email = resp["email"];
      wallet.icno = resp["icno"];
      wallet.joinDate =  resp["joinDate"]!=null?DateTime.parse(resp["joinDate"]):null;
      wallet.plateNo = resp["plateNo"];
      wallet.status = resp["status"];
      wallet.nickname = resp["nickname"];
    } else {
      msg = "Error deleting transaction....";
    }
    print('account');
    print(wallet);
    return wallet;
  }


  String getImageUrl(String imageFName) {
    String url = "";
    if (imageFName.isNotEmpty) {
      url = imageURL + imageFName;
    } else {
      url = imageURL + "no_image_available.png";
    }
    return url;
  }

  Future<List<Commision>> getDailyCommision(DateTime date) async {
    List<Commision> list = new List<Commision>();
    String token = await getToken();
    User user =getAuthTokenInfo(token);
    CommissionRequest req = new CommissionRequest(name: user.name,date: date,month: date.month,year:date.year);
    String url = apiURL + "rider/commission/daily";
    print(url);
    var body = jsonEncode(req.toJson(req)); 
    print(body);
    var response = await http.post(url,
                          headers: {'content-type': 'application/json', 'Authorization': token},
                          body: body);
    
    dynamic resp = jsonDecode(response.body);
    String msg;
    if (resp["ok"] == "yes") {
        var data = resp["data"];
        data.forEach((item) {
          list.add(Commision.fromJson(item));
        });
    } else {
      msg = "Error deleting transaction....";
    }
    return list;
  }
}
