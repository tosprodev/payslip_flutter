class Payslip {
  final int id;
  final String payslipMonth;
  final String payslipYear;
  final double grossSalary;
  final double inHandSalary;
  final double ctc;
  final double paidDays;
  final double workDays;
  final double lateDays;
  final double lopDays;
  final double leaveDaysTaken;
  final String payDate;
  final String hashedId;
  final Employee employee;
  final Company company;
  final double ptax;
  final double incentive;
  final double canteen;
  final double transportation;
  final double basic;
  final double hra;
  final double convenyance;
  final double special;
  final double nightshift;
  final double locationPay;
  final double leaveTravel;
  final double cityAllow;
  final double otherAllow;
  final double epf;
  final double tds;
  final double esic;
  final double gratuity;
  final double grossWage;
  final double epfEmp;
  final double esicEmp;
  final double otherBenefits;
  final double food;
  final String extraA;
  final double extraB;
  final double extraC;
  final double extraD;
  final String hAshedId;

  Payslip({
    required this.id,
    required this.payslipMonth,
    required this.payslipYear,
    required this.grossSalary,
    required this.inHandSalary,
    required this.ctc,
    required this.paidDays,
    required this.workDays,
    required this.lateDays,
    required this.lopDays,
    required this.leaveDaysTaken,
    required this.payDate,
    required this.hashedId,
    required this.employee,
    required this.company,
    required this.ptax,
    required this.incentive,
    required this.canteen,
    required this.transportation,
    required this.basic,
    required this.hra,
    required this.convenyance,
    required this.special,
    required this.nightshift,
    required this.locationPay,
    required this.leaveTravel,
    required this.cityAllow,
    required this.otherAllow,
    required this.epf,
    required this.tds,
    required this.esic,
    required this.gratuity,
    required this.grossWage,
    required this.epfEmp,
    required this.esicEmp,
    required this.otherBenefits,
    required this.food,
    required this.extraA,
    required this.extraB,
    required this.extraC,
    required this.extraD,
    required this.hAshedId,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id'],
      payslipMonth: json['payslip_month'],
      payslipYear: json['payslip_year'],
      grossSalary: double.parse(json['gross_salary'].toString()),
      inHandSalary: double.parse(json['inhand_salary'].toString()),
      ctc: double.parse(json['ctc'].toString()),
      paidDays: double.parse(json['paid_days'].toString()),
      workDays: double.parse(json['work_days'].toString()),
      lateDays: double.parse(json['late_days'].toString()),
      lopDays: double.parse(json['lop_days'].toString()),
      leaveDaysTaken: double.parse(json['leave_days_taken'].toString()),
      payDate: json['pay_date'],
      hashedId: json['hashedId'],
      ptax: double.parse(json['ptax'].toString()),
      incentive: double.parse(json['incentive'].toString()),
      canteen: double.parse(json['canteen'].toString()),
      transportation: double.parse(json['transportation'].toString()),
      basic: double.parse(json['basic'].toString()),
      hra: double.parse(json['hra'].toString()),
      convenyance: double.parse(json['convenyance'].toString()),
      special: double.parse(json['special'].toString()),
      nightshift: double.parse(json['nightshift'].toString()),
      locationPay: double.parse(json['location_pay'].toString()),
      leaveTravel: double.parse(json['leave_travel'].toString()),
      cityAllow: double.parse(json['city_allow'].toString()),
      otherAllow: double.parse(json['other_allow'].toString()),
      epf: double.parse(json['epf'].toString()),
      tds: double.parse(json['tds'].toString()),
      esic: double.parse(json['esic'].toString()),
      gratuity: double.parse(json['gratuity'].toString()),
      grossWage: double.parse(json['gross_wage'].toString()),
      epfEmp: double.parse(json['epfemp'].toString()),
      esicEmp: double.parse(json['esic_emp'].toString()),
      otherBenefits: double.parse(json['other_benefits'].toString()),
      food: double.parse(json['food'].toString()),
      extraA: json['extraA'],
      extraB: json['extb'] != null ? double.parse(json['extb'].toString()) : 0.0,
      extraC: json['extc'] != null ? double.parse(json['extc'].toString()) : 0.0,
      extraD: json['extd'] != null ? double.parse(json['extd'].toString()) : 0.0,
      hAshedId: json['hashedId'].toString(),
      employee: Employee.fromJson(json['employee']),
      company: Company.fromJson(json['company']),
    );
  }
}

class Employee {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String designation;
  final String panNumber;
  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;
  final String doj;
  final String dob;
  final String bloodGroup;
  final String grossSalary;
  final String pf;
  final String shiftType;
  final String aadhar;
  final String lastEducation;
  final String degree;
  final String college;
  final String completionYear;
  final String address;
  final String emergencyContact;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.designation,
    required this.panNumber,
    required this.bankName,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.doj,
    required this.dob,
    required this.bloodGroup,
    required this.grossSalary,
    required this.pf,
    required this.shiftType,
    required this.aadhar,
    required this.lastEducation,
    required this.degree,
    required this.college,
    required this.completionYear,
    required this.address,
    required this.emergencyContact,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      designation: json['designation'],
      panNumber: json['pan_number'],
      bankName: json['bank_name'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      doj: json['doj'],
      dob: json['dob'],
      bloodGroup: json['bloodgroup'],
      grossSalary: json['gross_salary'].toString(),
      pf: json['pf'].toString(),
      shiftType: json['shift_type'],
      aadhar: json['aadhar'].toString(),
      lastEducation: json['last_education'],
      degree: json['degree'],
      college: json['college'],
      completionYear: json['completion_year'].toString(),
      address: json['address'],
      emergencyContact: json['emergency_contact'],
    );
  }
}

class Company {
  final int id;
  final String name;
  final String logo;
  final String address;
  final String city;
  final String country;
  final String registrationType;
  final String registrationNumber;
  final String contactNumber;
  final String email;
  final String epfService;
  final String esicService;
  final String currency;
  final String host;
  final String port;
  final String username;
  final String fromEmail;
  final String fromName;

  Company({
    required this.id,
    required this.name,
    required this.logo,
    required this.address,
    required this.city,
    required this.country,
    required this.registrationType,
    required this.registrationNumber,
    required this.contactNumber,
    required this.email,
    required this.epfService,
    required this.esicService,
    required this.currency,
    required this.host,
    required this.port,
    required this.username,
    required this.fromEmail,
    required this.fromName,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      logo: json['logo'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      registrationType: json['registration_type'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      epfService: json['epf_service'] ?? '',
      esicService: json['esic_service'] ?? '',
      currency: json['currency'] ?? '',
      host: json['host'] ?? '',
      port: json['port'] ?? '',
      username: json['username'] ?? '',
      fromEmail: json['from_email'] ?? '',
      fromName: json['from_name'] ?? '',
    );
  }
}