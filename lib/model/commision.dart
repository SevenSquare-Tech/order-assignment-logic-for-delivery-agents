class Commision {
  final String order_No;
  final double commission;

  Commision({this.order_No, this.commission});

  Map<String, dynamic> toJson(Commision instance) => <String, dynamic>{
        'orderNo': instance.order_No,
        'commission': instance.commission
      };
  
   factory Commision.fromJson(Map<String, dynamic> json) {
    return Commision(
      order_No: json['orderNo'],
      commission: json['commission']
    );
   }
}
