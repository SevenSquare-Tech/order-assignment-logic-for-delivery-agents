import 'dart:io';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class ConnectionStatusSingleton {

    static final ConnectionStatusSingleton _singleton = new ConnectionStatusSingleton._internal();
    ConnectionStatusSingleton._internal();

    static ConnectionStatusSingleton getInstance() => _singleton;

    bool hasConnection = false;

    StreamController connectionChangeController = new StreamController.broadcast();

    final Connectivity _connectivity = Connectivity();

    void initialize() {
        _connectivity.onConnectivityChanged.listen(_connectionChange);
        checkConnection();
    }

    Stream get connectionChange => connectionChangeController.stream;

    void dispose() {
        connectionChangeController.close();
    }

    void _connectionChange(ConnectivityResult result) {
         print('_connectionChange');
        checkConnection();
    }

    Future<bool> checkConnection() async {
        bool previousConnection = hasConnection;
         print('check connection....');
        try {
            final result = await InternetAddress.lookup('google.com');
            print(result.toString());
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                hasConnection = true;
            } else {
                hasConnection = false;
            }
        } on SocketException catch(_) {
            hasConnection = false;
        }

        if (previousConnection != hasConnection) {
            connectionChangeController.add(hasConnection);
        }

        return hasConnection;
    }
}