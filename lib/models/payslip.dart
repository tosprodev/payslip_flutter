class Payslip {
  int id;
  int companyId;
  int employeeId;
  String payslipMonth;
  String payslipYear;
  int paidDays;
  int workDays;
  int lateDays;
  int lopDays;
  int leaveDaysTaken;
  int leaveBalance;
  String payDate;
  num grossSalary;
  num ptax;
  num incentive;
  num canteen;
  num transportation;
  num grossSalaryMonth;
  num basic;
  num hra;
  num convenyance;
  num special;
  num nightshift;
  num locationPay;
  num leaveTravel;
  num cityAllow;
  num otherAllow;
  num epf;
  num tds;
  num esic;
  num gratuity;
  num grossWage;
  num epfemp;
  num esicEmp;
  num otherBenefits;
  num ctc;
  num food;
  dynamic exta;
  dynamic extb;
  dynamic extc;
  dynamic extd;
  num inhandSalary;
  String createdAt;
  String updatedAt;
  String hashedId;
  Employee employee;
  Company company;

  Payslip({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.payslipMonth,
    required this.payslipYear,
    required this.paidDays,
    required this.workDays,
    required this.lateDays,
    required this.lopDays,
    required this.leaveDaysTaken,
    required this.leaveBalance,
    required this.payDate,
    required this.grossSalary,
    required this.ptax,
    required this.incentive,
    required this.canteen,
    required this.transportation,
    required this.grossSalaryMonth,
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
    required this.epfemp,
    required this.esicEmp,
    required this.otherBenefits,
    required this.ctc,
    required this.food,
    this.exta,
    this.extb,
    this.extc,
    this.extd,
    required this.inhandSalary,
    required this.createdAt,
    required this.updatedAt,
    required this.hashedId,
    required this.employee,
    required this.company,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id'],
      companyId: json['company_id'],
      employeeId: json['employee_id'],
      payslipMonth: json['payslip_month'],
      payslipYear: json['payslip_year'],
      paidDays: json['paid_days'],
      workDays: json['work_days'],
      lateDays: json['late_days'],
      lopDays: json['lop_days'],
      leaveDaysTaken: json['leave_days_taken'],
      leaveBalance: json['leave_balance'],
      payDate: json['pay_date'],
      grossSalary: json['gross_salary'],
      ptax: json['ptax'],
      incentive: json['incentive'],
      canteen: json['canteen'],
      transportation: json['transportation'],
      grossSalaryMonth: json['gross_salary_month'],
      basic: json['basic'],
      hra: json['hra'],
      convenyance: json['convenyance'],
      special: json['special'],
      nightshift: json['nightshift'],
      locationPay: json['location_pay'],
      leaveTravel: json['leave_travel'],
      cityAllow: json['city_allow'],
      otherAllow: json['other_allow'],
      epf: json['epf'],
      tds: json['tds'],
      esic: json['esic'],
      gratuity: json['gratuity'],
      grossWage: json['gross_wage'],
      epfemp: json['epfemp'],
      esicEmp: json['esic_emp'],
      otherBenefits: json['other_benefits'],
      ctc: json['ctc'],
      food: json['food'],
      exta: json['exta'],
      extb: json['extb'],
      extc: json['extc'],
      extd: json['extd'],
      inhandSalary: json['inhand_salary'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      hashedId: json['hashedId'],
      employee: Employee.fromJson(json['employee']),
      company: Company.fromJson(json['company']),
    );
  }
}

class Employee {
  int id;
  int companyId;
  String employeeId;
  String designation;
  String fullName;
  String email;
  String phone;
  String panNumber;
  String bankName;
  String bankAccountNumber;
  String ifscCode;
  String doj;
  String dob;
  dynamic lastDateOfEmployment;
  int roleId;
  String bloodgroup;
  num grossSalary;
  String pf;
  dynamic esi;
  int yearlyLeave;
  String uan;
  String shiftType;
  String aadhar;
  String lastEducation;
  String degree;
  String college;
  int completionYear;
  String address;
  String emergencyContact;
  dynamic loanType;
  dynamic loanAmount;
  String photo;
  String createdAt;
  String updatedAt;
  dynamic loginCode;
  dynamic loginCodeGeneratedAt;
  dynamic lastLoginAt;
  dynamic probationPeriod;

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
    this.lastDateOfEmployment,
    required this.roleId,
    required this.bloodgroup,
    required this.grossSalary,
    required this.pf,
    this.esi,
    required this.yearlyLeave,
    required this.uan,
    required this.shiftType,
    required this.aadhar,
    required this.lastEducation,
    required this.degree,
    required this.college,
    required this.completionYear,
    required this.address,
    required this.emergencyContact,
    this.loanType,
    this.loanAmount,
    required this.photo,
    required this.createdAt,
    required this.updatedAt,
    this.loginCode,
    this.loginCodeGeneratedAt,
    this.lastLoginAt,
    this.probationPeriod,
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
      lastDateOfEmployment: json['last_date_of_employment'],
      roleId: json['role_id'],
      bloodgroup: json['bloodgroup'],
      grossSalary: json['gross_salary'],
      pf: json['pf'],
      esi: json['esi'],
      yearlyLeave: json['yearly_leave'],
      uan: json['uan'],
      shiftType: json['shift_type'],
      aadhar: json['aadhar'],
      lastEducation: json['last_education'],
      degree: json['degree'],
      college: json['college'],
      completionYear: json['completion_year'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      loanType: json['loan_type'],
      loanAmount: json['loan_amount'],
      photo: json['photo'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      loginCode: json['login_code'],
      loginCodeGeneratedAt: json['login_code_generated_at'],
      lastLoginAt: json['last_login_at'],
      probationPeriod: json['probation_period'],
    );
  }
}

class Company {
  int id;
  String name;
  String logo;
  String address;
  String city;
  String pincode;
  String country;
  String registrationType;
  String registrationNumber;
  String contactNumber;
  String email;
  String epfService;
  String esicService;
  String currency;
  String stampStatus;
  String stampImg;
  String stampDate;
  String sendEmail;
  String host;
  String port;
  String username;
  String encryption;
  String fromEmail;
  String fromName;
  String createdAt;
  String updatedAt;
  String modules;
  int notesEnabled;
  int leadmanagementEnabled;

  Company({
    required this.id,
    required this.name,
    required this.logo,
    required this.address,
    required this.city,
    required this.pincode,
    required this.country,
    required this.registrationType,
    required this.registrationNumber,
    required this.contactNumber,
    required this.email,
    required this.epfService,
    required this.esicService,
    required this.currency,
    required this.stampStatus,
    required this.stampImg,
    required this.stampDate,
    required this.sendEmail,
    required this.host,
    required this.port,
    required this.username,
    required this.encryption,
    required this.fromEmail,
    required this.fromName,
    required this.createdAt,
    required this.updatedAt,
    required this.modules,
    required this.notesEnabled,
    required this.leadmanagementEnabled,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      address: json['address'],
      city: json['city'],
      pincode: json['pincode'],
      country: json['country'],
      registrationType: json['registration_type'],
      registrationNumber: json['registration_number'],
      contactNumber: json['contact_number'],
      email: json['email'],
      epfService: json['epf_service'],
      esicService: json['esic_service'],
      currency: json['currency'],
      stampStatus: json['stamp_status'],
      stampImg: json['stamp_img'],
      stampDate: json['stamp_date'],
      sendEmail: json['send_email'],
      host: json['host'],
      port: json['port'],
      username: json['username'],
      encryption: json['encryption'],
      fromEmail: json['from_email'],
      fromName: json['from_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      modules: json['modules'],
      notesEnabled: json['notes_enabled'],
      leadmanagementEnabled: json['leadmanagement_enabled'],
    );
  }
}