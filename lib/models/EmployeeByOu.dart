class EmployeeByOu {
  final int employeeid;
  final String fullname;
  final String companyemailid;
  final String unitname;

  EmployeeByOu({
    required this.employeeid,
    required this.fullname,
    required this.companyemailid,
    required this.unitname,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory EmployeeByOu.fromJson(Map<String, dynamic> json) {
    return EmployeeByOu(
      //employeeid: json['employee_id'],
      employeeid: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id'].toString()) ?? 0,
      fullname: json['full_name'],
      companyemailid: json['company_email_id'],
      unitname: json['unit_name'],
    );
  }

  // Method untuk mengkonversi instance menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'employeeid': employeeid,
      'fullname': fullname,
      'companyemailid': companyemailid,
      'unitname': unitname,
    };
  }
}
