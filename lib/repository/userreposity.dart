import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/user.dart';
import '../base/apibase.dart';

class UserRepository extends ApiBase {
  String authToken = "";
  User user;

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    String url = apiURL + "auth/jwt2";
    print(url);
    Map body = loginBody(username, password);
    var response;
    try {
      response = await http.post(url, body: json.encode(body), headers: {
        'content-type': 'application/json',
      });
    } catch (e) {
      print(e.toString());
      throw new Exception(
          "Error connecting to Server. "+url);
    }
    
    var resp = jsonDecode(response.body);
   // print(resp);
    String _token = "";
    if (resp['ok'] == "yes") {
      try {
        _token = resp['data'];
       // print(resp);
        Map<String, dynamic> jsonObj = jsonDecode(_token);
        _token = jsonObj["auth_token"];
        print(_token);
      } catch (e) {
        _token = "";
        print(e.toString());
      }
    } else {
      await deleteToken();
      print('invalid data');
    }
    return _token;
  }

  Map loginBody(username, password) {
    var map = new Map<String, String>();
    map["name"] = username;
    map["fullname"] = "-";
    map["password"] = password;
   
    return map;
  }

  bool isAuthenticated() {
    if (authToken == "") return false;
    int numError = decodeToken(authToken);

    return (numError == 0);
  }

  User getAuthUserInfo() {
    if (authToken == "" || authToken == null) return null;

    return getAuthTokenInfo(authToken);
  }
}
