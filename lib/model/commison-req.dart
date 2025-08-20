class CommissionRequest {
  String name;
  DateTime date;
  int month;
  int year;

  CommissionRequest({this.name, this.date, this.month, this.year});

   Map<String, dynamic> toJson(CommissionRequest instance) => <String, dynamic>{
        'name': instance.name,
        'date': instance.date.toIso8601String(),
        'month': instance.month,
        'year': instance.year
      };
}
