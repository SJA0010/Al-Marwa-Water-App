// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Bill {
  final String salesCode;
  final String siNumber;
  final String date;
  final String customer;
  final String product;
  final String trn;
  final String quantity;
  final bool isCreditBill;
  final String vatValue;
  final String customerName;
  final String productName;
  final String rate;
  final bool isVAT;
  final String total;
  final int? id;

  Bill({
    required this.salesCode,
    required this.siNumber,
    required this.date,
    required this.customer,
    required this.product,
    required this.trn,
    required this.quantity,
    required this.isCreditBill,
    required this.vatValue,
    required this.customerName,
    required this.productName,
    required this.rate,
    required this.isVAT,
    required this.total,
    this.id,
  });

  Bill copyWith({
    String? salesCode,
    String? siNumber,
    String? date,
    String? customer,
    String? product,
    String? trn,
    String? quantity,
    bool? isCreditBill,
    String? vatValue,
    String? customerName,
    String? productName,
    String? rate,
    bool? isVAT,
    String? total,
    int? id,
  }) {
    return Bill(
      salesCode: salesCode ?? this.salesCode,
      siNumber: siNumber ?? this.siNumber,
      date: date ?? this.date,
      customer: customer ?? this.customer,
      product: product ?? this.product,
      trn: trn ?? this.trn,
      quantity: quantity ?? this.quantity,
      isCreditBill: isCreditBill ?? this.isCreditBill,
      vatValue: vatValue ?? this.vatValue,
      customerName: customerName ?? this.customerName,
      productName: productName ?? this.productName,
      rate: rate ?? this.rate,
      isVAT: isVAT ?? this.isVAT,
      total: total ?? this.total,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'salesCode': salesCode,
      'siNumber': siNumber,
      'date': date,
      'customer': customer,
      'product': product,
      'trn': trn,
      'quantity': quantity,
      'isCreditBill': isCreditBill,
      'vatValue': vatValue,
      'customerName': customerName,
      'productName': productName,
      'rate': rate,
      'isVAT': isVAT,
      'total': total,
      'id': id,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      salesCode: map['salesCode'] as String,
      siNumber: map['siNumber'] as String,
      date: map['date'] as String,
      customer: map['customer'] as String,
      product: map['product'] as String,
      trn: map['trn'] as String,
      quantity: map['quantity'] as String,
      isCreditBill: map['isCreditBill'] as bool,
      vatValue: map['vatValue'] as String,
      customerName: map['customerName'] as String,
      productName: map['productName'] as String,
      rate: map['rate'] as String,
      isVAT: map['isVAT'] as bool,
      total: map['total'] as String,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bill.fromJson(String source) =>
      Bill.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Bill(salesCode: $salesCode, siNumber: $siNumber, date: $date, customer: $customer, product: $product, trn: $trn, quantity: $quantity, isCreditBill: $isCreditBill, vatValue: $vatValue, customerName: $customerName, productName: $productName, rate: $rate, isVAT: $isVAT, total: $total, id: $id)';
  }

  @override
  bool operator ==(covariant Bill other) {
    if (identical(this, other)) return true;

    return other.salesCode == salesCode &&
        other.siNumber == siNumber &&
        other.date == date &&
        other.customer == customer &&
        other.product == product &&
        other.trn == trn &&
        other.quantity == quantity &&
        other.isCreditBill == isCreditBill &&
        other.vatValue == vatValue &&
        other.customerName == customerName &&
        other.productName == productName &&
        other.rate == rate &&
        other.isVAT == isVAT &&
        other.total == total &&
        other.id == id;
  }

  @override
  int get hashCode {
    return salesCode.hashCode ^
        siNumber.hashCode ^
        date.hashCode ^
        customer.hashCode ^
        product.hashCode ^
        trn.hashCode ^
        quantity.hashCode ^
        isCreditBill.hashCode ^
        vatValue.hashCode ^
        customerName.hashCode ^
        productName.hashCode ^
        rate.hashCode ^
        isVAT.hashCode ^
        total.hashCode ^
        id.hashCode;
  }
}
