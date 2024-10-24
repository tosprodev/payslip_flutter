class Employee {
  final String id;
  final String companyId;
  final String employeeId;
  final String designation;
  final String fullName;
  final String email;
  final String phone;
  final String panNumber;
  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;

  Employee({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.designation,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.panNumber,
    required this.bankName,
    required this.bankAccountNumber,
    required this.ifscCode,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      companyId: json['company_id'].toString(),
      employeeId: json['employee_id'],
      designation: json['designation'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      panNumber: json['pan_number'],
      bankName: json['bank_name'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
    );
  }
}
