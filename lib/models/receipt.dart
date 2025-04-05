import 'dart:io';

class Receipt {
  //data to test with
  String date = "4/2/2023";
  String invoiceId = "00011";
  String clientId = "0001";
  String companyName = "David's Mowing Service";
  String streetAddress = '123 Sugar Lane';
  String state = 'Texas';
  String zipCode = '77777';
  String phoneNumber = '956-555-5555';
  String email = 'davidmowsitright@test.com';
  String jobName = 'regular lot sized mow';
  String serviceCost = '40';
  String notes = 'dogs are put away and trash has been removed';
  String netServiceCost = '40.00';
  String taxes = '3.30';
  String totalPaid = '43.30';
  String paymentMethod = 'Credit Card/Debit Card';
  String receiptText = "";

  void generateReceipt() {
    receiptText = """
-----------------
RECEIPT
-----------------

Date: $date
Receipt Number: $invoiceId
Client ID: $clientId

$companyName
$streetAddress
$state, $zipCode
$phoneNumber
$email

Description                   Price
$jobName                      $serviceCost



Notes: $notes

Sub Total: $netServiceCost
Sales Tax: $taxes
Total Amount: $totalPaid

Payment Method: $paymentMethod

Thank you for your business!


""";
  }

  String getReceiptText() {
    return receiptText;
  }

  bool createReceiptFile() {
    String receiptFileName = '$clientId' + '$invoiceId' + '.txt';

    File receiptFile = File(receiptFileName);
    receiptFile.writeAsStringSync(getReceiptText());

    return true;
  }
}
