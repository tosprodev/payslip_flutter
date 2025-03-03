class Employee {
  final String id;
  final String companyId;
  final String? employeeId;
  final String? designation;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? panNumber;
  final String? bankName;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? doj;
  final String? dob;
  final String? bloodGroup;
  final String? grossSalary;
  final String? pf;
  final String? esi;
  final String? yearlyLeave;
  final String? photo;
  final String? lastDateOfEmployment;
  final String? createdAt;
  final String? updatedAt;
  final String? uan;
  final String? shiftType;
  final String? aadhar;
  final String? lastEducation;
  final String? degree;
  final String? college;
  final String? completionYear;
  final String? address;
  final String? emergencyContact;
  final Document? documents;

  Employee({
    required this.id,
    required this.companyId,
    this.employeeId,
    this.designation,
    this.fullName,
    this.email,
    this.phone,
    this.panNumber,
    this.bankName,
    this.bankAccountNumber,
    this.ifscCode,
    this.doj,
    this.dob,
    this.bloodGroup,
    this.grossSalary,
    this.pf,
    this.esi,
    this.yearlyLeave,
    this.photo,
    this.lastDateOfEmployment,
    this.createdAt,
    this.updatedAt,
    this.uan,
    this.shiftType,
    this.aadhar,
    this.lastEducation,
    this.degree,
    this.college,
    this.completionYear,
    this.address,
    this.emergencyContact,
    this.documents,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      companyId: json['company_id'].toString(),
      employeeId: json['employee_id']?.toString(),
      designation: json['designation']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      panNumber: json['pan_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      doj: json['doj']?.toString(),
      dob: json['dob']?.toString(),
      bloodGroup: json['bloodgroup']?.toString(),
      grossSalary: json['gross_salary']?.toString(),
      pf: json['pf']?.toString(),
      esi: json['esi']?.toString(),
      yearlyLeave: json['yearly_leave']?.toString(),
      photo: json['photo']?.toString(),
      lastDateOfEmployment: json['last_date_of_employment']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      uan: json['uan']?.toString(),
      shiftType: json['shift_type']?.toString(),
      aadhar: json['aadhar']?.toString(),
      lastEducation: json['last_education']?.toString(),
      degree: json['degree']?.toString(),
      college: json['college']?.toString(),
      completionYear: json['completion_year']?.toString(),
      address: json['address']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      documents: json['documents'] != null ? Document.fromJson(json['documents']) : null,
    );
  }
}

class Document {
  final String id;
  final String employeeId;
  final String? resume;
  final String? idProof;
  final String? addressProof;
  final String? identityCard;
  final String? panCard;
  final String? offerLetter;
  final String? educationalCertificate;
  final String? otherDocumentA;
  final String? otherDocumentsB;
  final String? releaseLetter;
  final String? salarySlip;
  final String? bankStatement;
  final String? passport;
  final String? createdAt;
  final String? updatedAt;

  Document({
    required this.id,
    required this.employeeId,
    this.resume,
    this.idProof,
    this.addressProof,
    this.identityCard,
    this.panCard,
    this.offerLetter,
    this.educationalCertificate,
    this.otherDocumentA,
    this.otherDocumentsB,
    this.releaseLetter,
    this.salarySlip,
    this.bankStatement,
    this.passport,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'].toString(),
      employeeId: json['employee_id'].toString(),
      resume: json['resume']?.toString(),
      idProof: json['id_proof']?.toString(),
      addressProof: json['address_proof']?.toString(),
      identityCard: json['identity_card']?.toString(),
      panCard: json['pan_card']?.toString(),
      offerLetter: json['offer_letter']?.toString(),
      educationalCertificate: json['educational_certificate']?.toString(),
      otherDocumentA: json['other_document_a']?.toString(),
      otherDocumentsB: json['other_documents_b']?.toString(),
      releaseLetter: json['release_letter']?.toString(),
      salarySlip: json['salary_slip']?.toString(),
      bankStatement: json['bank_statement']?.toString(),
      passport: json['passport']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class Company {
  final String id;
  final String? name;
  final String? logo;
  final String? address;
  final String? city;
  final String? country;
  final String? registrationType;
  final String? registrationNumber;
  final String? contactNumber;
  final String? email;
  final String? currency;

  Company({
    required this.id,
    this.name,
    this.logo,
    this.address,
    this.city,
    this.country,
    this.registrationType,
    this.registrationNumber,
    this.contactNumber,
    this.email,
    this.currency,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'].toString(),
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      registrationType: json['registration_type']?.toString(),
      registrationNumber: json['registration_number']?.toString(),
      contactNumber: json['contact_number']?.toString(),
      email: json['email']?.toString(),
      currency: json['currency']?.toString(),
    );
  }
}