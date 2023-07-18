import 'dart:convert';

Bill billFromJson(String str) => Bill.fromJson(json.decode(str));
String billToJson(Bill data) => json.encode(data.toJson());

class Bill {
    String? accountId;
    final String accountAddress;
    final String accountCurrentMeterReading;
    final String accountNewMeterReading;

    Bill({
        this.accountId,
        required this.accountAddress,
        required this.accountCurrentMeterReading,
        required this.accountNewMeterReading,
    });

    factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        accountId: json["Account_Id"],
        accountAddress: json["Account_Address"],
        accountCurrentMeterReading: json["Account_CurrentMeterReading"],
        accountNewMeterReading: json["Account_NewMeterReading"],
    );

    Map<String, dynamic> toJson() => {
        "Account_Id": accountId,
        "Account_Address": accountAddress,
        "Account_CurrentMeterReading": accountCurrentMeterReading,
        "Account_NewMeterReading": accountNewMeterReading,
    };
}
