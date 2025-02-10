import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../widgets/button_widget.dart';
import '../widgets/medical_tests_widget.dart';

class MedicalInfoTests extends StatefulWidget {
  MedicalInfoTests({super.key, required this.isDonor});
  bool isDonor;

  @override
  State<MedicalInfoTests> createState() => _MedicalInfoTestsState();
}

class _MedicalInfoTestsState extends State<MedicalInfoTests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          _registerBanner(),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Test status',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: kPinkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Instruction: Please confirm if the following tests have been completed. If completed, upload the relevant reports for validation.',
                    style: TextStyle(fontSize: 14, color: Colors.redAccent),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Immunological Tests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                MedicalTestsWidget(statusLabel: 'ABO Blood Typing'),
                MedicalTestsWidget(statusLabel: 'Tissue Typing (HLA Antigens)'),
                MedicalTestsWidget(statusLabel: 'Family Analysis'),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Laboratory Tests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                MedicalTestsWidget(
                    statusLabel: 'Hematological System Assessment'),
                MedicalTestsWidget(
                    statusLabel: 'Clotting Mechanism Assessment'),
                MedicalTestsWidget(
                    statusLabel:
                        'Kidney Function\n(Glomerular Filtration Rate - GFR)'),
                MedicalTestsWidget(
                    statusLabel: 'Electrolyte Balance Screening'),
                MedicalTestsWidget(
                    statusLabel: 'Glucose Intolerance Screening'),
                MedicalTestsWidget(statusLabel: 'Venereal Disease Screening'),
                MedicalTestsWidget(statusLabel: 'Pancreatitis Screening'),
                MedicalTestsWidget(statusLabel: 'Liver Function Tests'),
                MedicalTestsWidget(statusLabel: 'Hepatitis B Screening'),
                MedicalTestsWidget(
                    statusLabel: 'Viral Activity Screening\n(CMV, HIV)'),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Urine Tests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                MedicalTestsWidget(
                    statusLabel: 'Kidney Disease Screening (ACR)'),
                MedicalTestsWidget(
                    statusLabel: 'Urinary Tract Infection Screening'),
                MedicalTestsWidget(
                    statusLabel: 'Protein Excretion &\nCreatinine Clearance'),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Other Tests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                MedicalTestsWidget(
                    statusLabel: 'Medical History & Physical Examination'),
                MedicalTestsWidget(
                    statusLabel:
                        'EKG (Electrocardiogram)\n-Heart Function Assessment'),
                MedicalTestsWidget(
                    statusLabel: 'Chest X-Ray - Lung Assessment'),
                MedicalTestsWidget(statusLabel: 'Psychological Evaluation'),
                MedicalTestsWidget(
                    statusLabel:
                        'Gynecological Exam & Mammography\n(For Female Donors)'),
                MedicalTestsWidget(
                    statusLabel:
                        'Intravenous Pyelography (IVP)\n-Kidney Structure Assessment'),
                MedicalTestsWidget(
                    statusLabel:
                        'Helical CT Scan\n-Kidney Internal Structure Evaluation'),
                MedicalTestsWidget(
                    statusLabel:
                        'Renal Arteriogram\n-Kidney Blood Vessel &\nVascular Disease Assessment'),
                MedicalTestsWidget(statusLabel: 'Financial Consultation'),
                SizedBox(
                  height: 10,
                ),
                ButtonWidget(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalInfoTests(
                                  isDonor: true,
                                ))),
                    title: 'Submit'),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Container _registerBanner() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: const BoxDecoration(
        gradient: kGradientRegister,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(94),
          bottomRight: Radius.circular(94),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isDonor ? 'DONATOR!' : 'RECIPIENT!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Image.asset(
            widget.isDonor
                ? 'assets/images/donator.png'
                : 'assets/images/recipient.png',
            height: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
    );
  }
}
