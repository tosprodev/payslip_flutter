// employee.dart
class Employee {
  final int id;
  final int companyId;
  final String employeeId;
  final String designation;
  final String fullName;
  final String email;
  final String phone;
  final String panNumber;
  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;
  final String doj;
  final String dob;
  final String bloodGroup; // Add this line
  final String grossSalary;
  final String pf;
  final String? esi;
  final String yearlyLeave;
  final String photo;
  final String? lastDateOfEmployment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String uan;
  final String shiftType;
  final String aadhar;
  final String lastEducation;
  final String degree;
  final String college;
  final int completionYear;
  final String address;
  final String emergencyContact;
  final Document? documents; // Add this line

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
    required this.doj,
    required this.dob,
    required this.bloodGroup, // Add this line
    required this.grossSalary,
    required this.pf,
    this.esi,
    required this.yearlyLeave,
    required this.photo,
    this.lastDateOfEmployment,
    required this.createdAt,
    required this.updatedAt,
    required this.uan,
    required this.shiftType,
    required this.aadhar,
    required this.lastEducation,
    required this.degree,
    required this.college,
    required this.completionYear,
    required this.address,
    required this.emergencyContact,
    this.documents, // Add this line
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      companyId: json['company_id'],
      employeeId: json['employee_id'],
      designation: json['designation'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      panNumber: json['pan_number'],
      bankName: json['bank_name'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      doj: json['doj'],
      dob: json['dob'],
      bloodGroup: json['bloodgroup'], // Add this line
      grossSalary: json['gross_salary'],
      pf: json['pf'],
      esi: json['esi'],
      yearlyLeave: json['yearly_leave'],
      photo: json['photo'],
      lastDateOfEmployment: json['last_date_of_employment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      uan: json['uan'],
      shiftType: json['shift_type'],
      aadhar: json['aadhar'],
      lastEducation: json['last_education'],
      degree: json['degree'],
      college: json['college'],
      completionYear: json['completion_year'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      documents: json['documents'] != null ? Document.fromJson(json['documents']) : null, // Add this line
    );
  }
}

class Document {
  final int id;
  final int employeeId;
  final String resume;
  final String idProof;
  final String addressProof;
  final String? identityCard;
  final String panCard;
  final String offerLetter;
  final String? educationalCertificate;
  final String? otherDocumentA;
  final String? otherDocumentsB;
  final String? releaseLetter;
  final String? salarySlip;
  final String? bankStatement;
  final String? passport;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.employeeId,
    required this.resume,
    required this.idProof,
    required this.addressProof,
    this.identityCard,
    required this.panCard,
    required this.offerLetter,
    this.educationalCertificate,
    this.otherDocumentA,
    this.otherDocumentsB,
    this.releaseLetter,
    this.salarySlip,
    this.bankStatement,
    this.passport,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      employeeId: json['employee_id'],
      resume: json['resume'],
      idProof: json['id_proof'],
      addressProof: json['address_proof'],
      identityCard: json['identity_card'],
      panCard: json['pan_card'],
      offerLetter: json['offer_letter'],
      educationalCertificate: json['educational_certificate'],
      otherDocumentA: json['other_document_a'],
      otherDocumentsB: json['other_documents_b'],
      releaseLetter: json['release_letter'],
      salarySlip: json['salary_slip'],
      bankStatement: json['bank_statement'],
      passport: json['passport'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
