import '../model/bean/settingbean.dart';
import '../model/setting.dart';

class DataHelperSingleton {
  static final DataHelperSingleton _singleton =
               new DataHelperSingleton._internal();
  DataHelperSingleton._internal();

  static DataHelperSingleton getInstance() => _singleton;
  static SettingBean _settingBean = new SettingBean();
  String APIURL;

  Future iniSettingDB() async{
       await _settingBean.createTable();  
       await getAPIUrl();    
  }

  Future insertSetting(Setting setting) async {
      await _settingBean.insert(setting);
      this.APIURL = setting.url; 
  }

   Future updateSetting(Setting setting) async {
      await _settingBean.update(setting.id, setting.url,setting.defwh);
      this.APIURL = setting.url; 
  }

  Future<List<Setting>> getSettings() async {
    List<Setting> setts = await _settingBean.findAll();

    return setts;
  }

  Future<String> getAPIUrl() async {
    String url ="";
    List<Setting> setts = await _settingBean.findAll();
    if (setts.length>0){
        url = setts[0].url;
    }
    this.APIURL = url; 
    return url;
  }

  String getERPApiURL(){
    return this.APIURL;
  }
}
