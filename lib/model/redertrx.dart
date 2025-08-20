class RiderTrxDtl {
  int uid;
  final String name;
  final DateTime trxDate;
  final String desc;
  final double amount;
  final String trxType;
  final String trxStatus;
  final String refType;
  final String remarks;
  final String imageFName;

  RiderTrxDtl(
      {this.uid,
      this.name,
      this.trxDate,
      this.desc,
      this.amount,
      this.trxType,
      this.trxStatus,
      this.refType,
      this.remarks,
      this.imageFName});

  Map<String, dynamic> toJson(RiderTrxDtl instance, String userid) =>
      <String, dynamic>{
        'uid': instance.uid,
        'name': userid,
        'trxDate': instance.trxDate.toIso8601String(),
        'desc': instance.desc,
        'amount': instance.amount,
        'trxType': instance.trxType,
        'trxStatus': instance.trxStatus,
        'refType': instance.refType,
        'remarks': instance.remarks
      };

   factory RiderTrxDtl.fromJson(Map<String, dynamic> json) {
    return RiderTrxDtl(
      uid: json['uid'],
      trxDate: DateTime.parse(json['trxDate']),
      name: json['name'] as String,
      desc: (json['desc'] == null) ? "" : json['desc'] as String,
      trxType: json['trxType'],
      trxStatus: json['trxStatus'],
      refType: json['refType'],
      remarks: json['remarks'],
      amount: json['amount'],
      imageFName:""
     
    );
  }

  factory RiderTrxDtl.fromTrxJson(Map<String, dynamic> json) {
    return RiderTrxDtl(
      uid: json['id'],
      trxDate: DateTime.parse(json['transactionDate']),
      name: json['rider_Name'] as String,
      desc: (json['transactionDesc'] == null) ? "" : json['transactionDesc'] as String,
      trxType: json['transactionType'],
      trxStatus: json['transactionStatus'],
      refType: json['refType'],
      remarks: json['remarks'],
      amount: json['transactionAmt'],
      imageFName: json['imageFname']==null?"":json['imageFname'],
    );
  }

}
