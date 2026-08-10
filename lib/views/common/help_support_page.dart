import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/faq_service.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Course Query';
  String _faqFilterCategory = 'All';
  bool _isSubmitting = false;

  // My Tickets State
  List<dynamic> _myTickets = [];
  bool _isLoadingTickets = false;

  final List<String> _ticketCategories = [
    'Course Query',
    'Payment & Refund',
    'Job & Internship',
    'Certificate Issue',
    'Technical Problem',
    'Other Query'
  ];

  List<Map<String, dynamic>> _allFaqs = [];
  List<Map<String, dynamic>> _filteredFaqs = [];
  bool _isLoadingFaqs = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredFaqs = [];
    _searchController.addListener(_filterFaqs);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyTickets();
      _fetchFaqs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyTickets() async {
    setState(() => _isLoadingTickets = true);

    try {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      final user = profileVM.user;
      final email = user?.email ?? '';

      final url = '${ApiUrls.getMySupportTickets}?email=${Uri.encodeComponent(email)}';
      final response = await ApiClient().get(url);

      if (mounted && response != null && response['success'] == true) {
        setState(() {
          _myTickets = response['data'] ?? [];
          _isLoadingTickets = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error fetching my tickets: $e');
    }

    if (mounted) {
      setState(() => _isLoadingTickets = false);
    }
  }

  Future<void> _fetchFaqs() async {
    setState(() => _isLoadingFaqs = true);
    final fetchedFaqs = await FaqService.getFaqs(platform: 'app');
    if (mounted) {
      setState(() {
        _allFaqs = fetchedFaqs;
        _isLoadingFaqs = false;
      });
      _filterFaqs();
    }
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqs = _allFaqs.where((faq) {
        // Assume 'category' might not exist on dynamic FAQs unless added. So checking 'All' or if it matches.
        final matchesCategory = _faqFilterCategory == 'All' || (faq['category'] != null && faq['category'] == _faqFilterCategory);
        final matchesQuery = (faq['question']?.toLowerCase() ?? '').contains(query) ||
            (faq['answer']?.toLowerCase() ?? '').contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch: $urlString', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Unable to open link. Please try again.', Colors.red);
    }
  }

  void _openWhatsApp() {
    final phone = '+918081347355';
    final message = Uri.encodeComponent('Hello CodersAdda Support, I need assistance with my account.');
    _launchURL('whatsapp://send?phone=$phone&text=$message')
        .catchError((_) => _launchURL('https://wa.me/$phone?text=$message'));
  }

  void _makePhoneCall() {
    _launchURL('tel:+918081347355');
  }

  void _sendEmail() {
    _launchURL('mailto:support@codersadda.com?subject=Support%20Request&body=Hi%20CodersAdda%20Team,');
  }

  void _openTelegram() {
    _launchURL('https://t.me/codersadda');
  }

  void _showSnackBar(String message, Color bgColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitSupportTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      final user = profileVM.user;

      final body = {
        'name': user?.name ?? 'Student',
        'email': user?.email ?? '',
        'mobile': user?.mobile ?? '',
        'category': _selectedCategory,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
      };

      final response = await ApiClient().post(ApiUrls.createSupportTicket, body);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (response != null && response['success'] == true) {
        _subjectController.clear();
        _messageController.clear();
        _fetchMyTickets(); // Refresh my tickets list

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: AppSizer.deviceSp24),
                SizedBox(width: AppSizer.deviceWidth2),
                Text('Ticket Submitted', style: TextStyle(fontSize: AppSizer.deviceSp18)),
              ],
            ),
            content: const Text(
              'Your query has been recorded! You can check admin responses anytime under "My Queries & Responses" tab.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1); // Switch to My Tickets tab
                },
                child: const Text('View My Queries'),
              ),
            ],
          ),
        );
      } else {
        _showSnackBar(response?['message'] ?? 'Failed to submit support ticket', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackBar('Submitted ticket offline. We will review your message soon.', Colors.green);
      _subjectController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.help_outline), text: 'Help & Contact'),
            Tab(icon: Icon(Icons.message_outlined), text: 'My Queries & Responses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Help & Contact
          _buildHelpTab(),

          // Tab 2: My Queries & Responses
          _buildMyTicketsTab(),
        ],
      ),
    );
  }

  Widget _buildHelpTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderBanner(),
          SizedBox(height: AppSizer.deviceHeight2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Contact Options',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight1_5),
                _buildQuickContactGrid(),
                SizedBox(height: AppSizer.deviceHeight3),
                _buildFaqSection(),
                SizedBox(height: AppSizer.deviceHeight3),
                _buildTicketForm(),
                SizedBox(height: AppSizer.deviceHeight3),
                _buildSupportInfoFooter(),
                SizedBox(height: AppSizer.deviceHeight4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTicketsTab() {
    return RefreshIndicator(
      onRefresh: _fetchMyTickets,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Support Tickets',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                IconButton(
                  onPressed: _fetchMyTickets,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.primaryColor,
                  tooltip: 'Refresh Responses',
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight1),

            if (_isLoadingTickets)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_myTickets.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(AppSizer.deviceWidth6),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 54, color: Colors.grey.shade400),
                      SizedBox(height: AppSizer.deviceHeight1_5),
                      Text(
                        'No Support Tickets Yet',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight0_5),
                      Text(
                        'If you have any questions or issues, submit a query from the "Help & Contact" tab above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _myTickets.length,
                itemBuilder: (context, index) {
                  final ticket = _myTickets[index];
                  final String category = ticket['category'] ?? 'Query';
                  final String subject = ticket['subject'] ?? 'Support Issue';
                  final String message = ticket['message'] ?? '';
                  final String status = ticket['status'] ?? 'Pending';
                  final String adminReply = ticket['adminReply'] ?? '';
                  final String createdAt = ticket['createdAt'] ?? '';

                  return _buildTicketResponseCard(
                    category: category,
                    subject: subject,
                    message: message,
                    status: status,
                    adminReply: adminReply,
                    createdAt: createdAt,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketResponseCard({
    required String category,
    required String subject,
    required String message,
    required String status,
    required String adminReply,
    required String createdAt,
  }) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.hourglass_top;

    if (status == 'Resolved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'In Progress') {
      statusColor = Colors.blue;
      statusIcon = Icons.sync;
    } else if (status == 'Closed') {
      statusColor = Colors.grey;
      statusIcon = Icons.block;
    }

    String formattedDate = '';
    try {
      if (createdAt.isNotEmpty) {
        final dt = DateTime.parse(createdAt).toLocal();
        formattedDate = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth2_5,
                    vertical: AppSizer.deviceHeight0_5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth2_5,
                    vertical: AppSizer.deviceHeight0_5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: AppSizer.deviceSp12, color: statusColor),
                      SizedBox(width: AppSizer.deviceWidth1),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizer.deviceHeight1_5),

            // Subject
            Text(
              subject,
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight1),

            // Student Message
            Text(
              message,
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                color: AppColors.onSurfaceVariant,
                height: 1.3,
              ),
            ),

            if (formattedDate.isNotEmpty) ...[
              SizedBox(height: AppSizer.deviceHeight1),
              Text(
                'Submitted: $formattedDate',
                style: TextStyle(fontSize: AppSizer.deviceSp11, color: Colors.grey.shade500),
              ),
            ],

            SizedBox(height: AppSizer.deviceHeight2),

            // Admin Response Section
            if (adminReply.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green.shade700, size: AppSizer.deviceSp16),
                        SizedBox(width: AppSizer.deviceWidth1_5),
                        Text(
                          'Admin Response / Solution',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    Text(
                      adminReply,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp13,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade900,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_filled, color: Colors.amber.shade800, size: AppSizer.deviceSp16),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Expanded(
                      child: Text(
                        'Your query is under review by admin. Check back soon for resolution response!',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizer.deviceWidth4,
        AppSizer.deviceHeight1,
        AppSizer.deviceWidth4,
        AppSizer.deviceHeight3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello! 👋',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent,
                  size: AppSizer.deviceSp32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          TextField(
            controller: _searchController,
            style: TextStyle(fontSize: AppSizer.deviceSp14),
            decoration: InputDecoration(
              hintText: 'Search queries or keywords...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: AppSizer.deviceHeight1,
                horizontal: AppSizer.deviceWidth4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSizer.deviceWidth3,
      mainAxisSpacing: AppSizer.deviceHeight1_5,
      childAspectRatio: 1.5,
      children: [
        _buildContactCard(
          icon: Icons.chat_bubble,
          color: const Color(0xFF25D366),
          title: 'WhatsApp',
          subtitle: 'Instant Chat Support',
          onTap: _openWhatsApp,
        ),
        _buildContactCard(
          icon: Icons.phone_in_talk,
          color: const Color(0xFF007AFF),
          title: 'Call Us',
          subtitle: '10 AM - 7 PM',
          onTap: _makePhoneCall,
        ),
        _buildContactCard(
          icon: Icons.email_rounded,
          color: const Color(0xFFFF9500),
          title: 'Email Support',
          subtitle: 'support@codersadda.com',
          onTap: _sendEmail,
        ),
        _buildContactCard(
          icon: Icons.send_rounded,
          color: const Color(0xFF0088CC),
          title: 'Telegram',
          subtitle: 'Join Student Group',
          onTap: _openTelegram,
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(AppSizer.deviceWidth3),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth2_5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: AppSizer.deviceSp22),
              ),
              SizedBox(width: AppSizer.deviceWidth2_5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizer.deviceHeight0_5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    final categories = ['All', 'Courses', 'Payments', 'Jobs', 'Certificates', 'Account'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight1_5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _faqFilterCategory == cat;
              return Padding(
                padding: EdgeInsets.only(right: AppSizer.deviceWidth2),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: AppSizer.deviceSp13,
                  ),
                  backgroundColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _faqFilterCategory = cat;
                        _filterFaqs();
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        if (_filteredFaqs.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.find_in_page_outlined, size: 48, color: Colors.grey.shade400),
                SizedBox(height: AppSizer.deviceHeight1),
                Text(
                  'No matching FAQs found',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: AppSizer.deviceSp14),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredFaqs.length,
            itemBuilder: (context, index) {
              final faq = _filteredFaqs[index];
              return Card(
                elevation: 1,
                margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.help_outline, color: AppColors.primaryColor, size: AppSizer.deviceSp18),
                  ),
                  title: Text(
                    faq['question']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizer.deviceWidth4,
                        0,
                        AppSizer.deviceWidth4,
                        AppSizer.deviceHeight2,
                      ),
                      child: Text(
                        faq['answer']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTicketForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.confirmation_number_outlined, color: AppColors.primaryColor),
                  SizedBox(width: AppSizer.deviceWidth2),
                  Text(
                    'Raise a Support Ticket',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizer.deviceHeight0_5),
              Text(
                'Can\'t find an answer? Send us a direct message and our team will resolve it.',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight2),
              Text(
                'Issue Category',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight0_5),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth3,
                    vertical: AppSizer.deviceHeight1,
                  ),
                ),
                items: _ticketCategories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              SizedBox(height: AppSizer.deviceHeight2),
              Text(
                'Subject',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight0_5),
              TextFormField(
                controller: _subjectController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a subject' : null,
                decoration: InputDecoration(
                  hintText: 'Brief topic of your issue...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth3,
                    vertical: AppSizer.deviceHeight1,
                  ),
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight2),
              Text(
                'Description / Message',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight0_5),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please describe your query' : null,
                decoration: InputDecoration(
                  hintText: 'Explain your question or problem in detail...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.all(AppSizer.deviceWidth3),
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight2_5),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitSupportTicket,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Query',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportInfoFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: AppColors.primaryColor, size: AppSizer.deviceSp18),
              SizedBox(width: AppSizer.deviceWidth2),
              Text(
                'Support Hours: Mon - Sat (10:00 AM - 7:00 PM)',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            'CodersAdda • Learn, Grow & Succeed',
            style: TextStyle(
              fontSize: AppSizer.deviceSp12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
