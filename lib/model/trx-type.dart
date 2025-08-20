class TrxType {
  final String display;
  final String type;
  final String direction;
  final String desc;

  TrxType({this.display, this.type, this.direction, this.desc});
}

class TrxTypeList {
  List<TrxType> list = new List<TrxType>();

  TrxTypeList() {
    list.add(TrxType(
        display: "Advance",
        type: "Advance",
        direction: "Out",
        desc: "Advance"));
     list.add(TrxType(
        display: "Commission",
        type: "Commission",
        direction: "Out",
        desc: "Commission"));
     list.add(TrxType(
        display: "Salary",
        type: "Salary",
        direction: "In",
        desc: "Service Fee"));
     list.add(TrxType(
        display: "Cash In",
        type: "Cash",
        direction: "In",
        desc: "Cash In"));
     list.add(TrxType(
        display: "Cash Out",
        type: "Cash",
        direction: "Out",
        desc: "Cash Out"));
     list.add(TrxType(
        display: "BankTransfer In",
        type: "BankTransfer",
        direction: "In",
        desc: "Cash In"));
     list.add(TrxType(
        display: "BankTransfer Out",
        type: "BankTransfer",
        direction: "Out",
        desc: "Cash Out"));
  }
}
