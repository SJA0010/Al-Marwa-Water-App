// ignore_for_file: public_member_api_docs, sort_constructors_first
class PaginatedCustomers {
  final List<CustomerData> customers;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;

  PaginatedCustomers({
    required this.customers,
    required this.currentPage,
    required this.lastPage,
    required this.nextPageUrl,
  });
}

class CustomerModel {
  final bool status;
  final String message;
  final CustomerData data;

  CustomerModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      status: json['status'],
      message: json['message'],
      data: CustomerData.fromJson(json['data']),
    );
  }
}

class CustomerData {
  final String date;
  final String customerType;
  final String buildingName;
  final String blockNo;
  final String roomNo;
  final String phone1;
  final String phone2;
  final String deliveryDays;
  final String customerPayId;
  final String bottleGiven;
  final String price;
  final String paidDeposit;
  final String amount;
  final String personName;
  final String phone3;
  final String phone4;
  final String email;
  final String tradeName;
  final String trnNumber;
  final String authPersonName;
  final int salePersonId;
  final String createdAt;
  final String updatedAt;
  final int id;
  final String customerCode;

  CustomerData({
    required this.date,
    required this.customerType,
    required this.buildingName,
    required this.blockNo,
    required this.roomNo,
    required this.phone1,
    required this.phone2,
    required this.deliveryDays,
    required this.customerPayId,
    required this.bottleGiven,
    required this.price,
    required this.paidDeposit,
    required this.amount,
    required this.personName,
    required this.phone3,
    required this.phone4,
    required this.email,
    required this.tradeName,
    required this.trnNumber,
    required this.authPersonName,
    required this.salePersonId,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.customerCode,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) => value?.toString() ?? 'empty';
    int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

    return CustomerData(
      date: parseString(json['date']),
      customerType: parseString(json['customer_type']),
      buildingName: parseString(json['building_name']),
      blockNo: parseString(json['block_no']),
      roomNo: parseString(json['room_no']),
      phone1: parseString(json['phone1']),
      phone2: parseString(json['phone2']),
      deliveryDays: parseString(json['delivery_days']),
      customerPayId: parseString(json['customer_pay']),
      bottleGiven: parseString(json['bottle_given']),
      price: parseString(json['price']),
      paidDeposit: parseString(json['paid_deposit']),
      amount: parseString(json['amount']),
      personName: parseString(json['person_name']),
      phone3: parseString(json['phone3']),
      phone4: parseString(json['phone4']),
      email: parseString(json['email']),
      tradeName: parseString(json['trade_name']),
      trnNumber: parseString(json['trn_number']),
      authPersonName: parseString(json['auth_person_name']),
      salePersonId: parseInt(json['sale_person_id']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
      id: parseInt(json['id']),
      customerCode: parseString(json['customer_code']),
    );
  }

  @override
  String toString() {
    return 'CustomerData(date: $date, customerType: $customerType, buildingName: $buildingName, blockNo: $blockNo, roomNo: $roomNo, phone1: $phone1, phone2: $phone2, deliveryDays: $deliveryDays, customerPayId: $customerPayId, bottleGiven: $bottleGiven, price: $price, paidDeposit: $paidDeposit, amount: $amount, personName: $personName, phone3: $phone3, phone4: $phone4, email: $email, tradeName: $tradeName, trnNumber: $trnNumber, authPersonName: $authPersonName, salePersonId: $salePersonId, createdAt: $createdAt, updatedAt: $updatedAt, id: $id, customerCode: $customerCode)';
  }
}
