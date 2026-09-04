import 'package:flutter/material.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/join_ambassador_page.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_status_hub_page.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_dashboard_page.dart';

export 'package:coders_adda_app/views/ambassador_program_pages/join_ambassador_page.dart';
export 'package:coders_adda_app/views/ambassador_program_pages/application_submitted_page.dart';
export 'package:coders_adda_app/views/ambassador_program_pages/ambassador_dashboard_page.dart';
export 'package:coders_adda_app/views/ambassador_program_pages/ambassador_how_it_works_page.dart';
export 'package:coders_adda_app/views/ambassador_program_pages/ambassador_rewards_page.dart';
export 'package:coders_adda_app/views/ambassador_program_pages/ambassador_status_hub_page.dart';

class RefralProgram extends StatefulWidget {
  const RefralProgram({super.key});

  @override
  State<RefralProgram> createState() => _RefralProgramState();
}

class _RefralProgramState extends State<RefralProgram> {
  bool _isLoading = true;
  bool _isAmbassador = false;
  String _status = 'none';
  String _referralCode = '';
  double _walletBalance = 0.0;
  int _referralCount = 0;

  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await _apiClient.get(ApiUrls.getAmbassadorStatus);
      if (response != null && response['success'] == true) {
        final statusVal = (response['status'] ?? 'none').toString().trim().toLowerCase();
        final refCode = response['referralCode']?.toString() ?? '';
        final isAmb = response['isAmbassador'] ?? false;

        setState(() {
          _status = statusVal;
          _isAmbassador = isAmb;
          _referralCode = (refCode == 'none' || refCode == 'null') ? '' : refCode;
          _walletBalance = (response['walletBalance'] ?? 0).toDouble();
          _referralCount = response['referralCount'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = 'none';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _status = 'none';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0052FF)),
        ),
      );
    }

    // If approved or active ambassador
    if (_isAmbassador || _status == 'approved') {
      return AmbassadorDashboardPage(
        referralCode: _referralCode,
        initialBalance: _walletBalance,
        initialReferrals: _referralCount,
      );
    }

    // If under review / pending
    if (_status == 'pending') {
      return const AmbassadorStatusHubPage();
    }

    // Default: Not applied yet
    return const JoinAmbassadorPage();
  }
}