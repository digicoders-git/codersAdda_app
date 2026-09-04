import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/test_program_pages/test_instructions_page.dart';

class AvailableTestsPage extends StatefulWidget {
  final List<Map<String, dynamic>> testsList;
  final List<Map<String, dynamic>> attemptedList;
  final String initialCategory; // 'All', 'Tests', 'Quizzes'

  const AvailableTestsPage({
    super.key,
    required this.testsList,
    required this.attemptedList,
    this.initialCategory = 'All',
  });

  @override
  State<AvailableTestsPage> createState() => _AvailableTestsPageState();
}

class _AvailableTestsPageState extends State<AvailableTestsPage> {
  late String _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
      case 'expert':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF0033CC);
    }
  }

  Color _getLevelBgColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFFECFDF5);
      case 'intermediate':
        return const Color(0xFFFFFBEB);
      case 'advanced':
      case 'expert':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  List<Color> _getIconGradient(int index, String title) {
    final t = title.toLowerCase();
    if (t.contains('c++') || t.contains('cpp')) {
      return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    } else if (t.contains('data') || t.contains('dsa') || t.contains('structure')) {
      return [const Color(0xFFF97316), const Color(0xFFEA580C)];
    } else if (t.contains('web') || t.contains('html') || t.contains('js')) {
      return [const Color(0xFF0284C7), const Color(0xFF0369A1)];
    } else if (t.contains('python')) {
      return [const Color(0xFF0284C7), const Color(0xFFF59E0B)];
    }

    final gradients = [
      [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      [const Color(0xFFF97316), const Color(0xFFEA580C)],
      [const Color(0xFF0284C7), const Color(0xFF0369A1)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
    ];
    return gradients[index % gradients.length];
  }

  IconData _getTopicIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('c++') || t.contains('cpp')) {
      return Icons.code;
    } else if (t.contains('data') || t.contains('structure')) {
      return Icons.layers;
    } else if (t.contains('web')) {
      return Icons.code_rounded;
    } else if (t.contains('python')) {
      return Icons.terminal;
    }
    return Icons.assignment_outlined;
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Flexible Schedule';
    final parsed = DateTime.tryParse(dateStr)?.toLocal();
    if (parsed == null) return 'Flexible Schedule';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour);
    final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}, ${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filteredList = widget.testsList.where((test) {
      // Category filter
      if (_selectedCategory == 'Tests') {
        final type = (test['type'] ?? 'Test').toString().toLowerCase();
        if (!type.contains('test')) return false;
      } else if (_selectedCategory == 'Quizzes') {
        final type = (test['type'] ?? 'Quiz').toString().toLowerCase();
        if (!type.contains('quiz')) return false;
      }

      // Search query filter
      if (query.isNotEmpty) {
        final title = (test['title'] ?? '').toString().toLowerCase();
        final desc = (test['description'] ?? '').toString().toLowerCase();
        return title.contains(query) || desc.contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1033)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: const Color(0xFF0B1033),
            ),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field (collapsible)
          if (_isSearchVisible)
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight1,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by test name or topic...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: AppSizer.deviceSp13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0033CC), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          // Header Title & Filter Pills
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              AppSizer.deviceWidth4,
              AppSizer.deviceHeight1,
              AppSizer.deviceWidth4,
              AppSizer.deviceHeight1_5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Tests & Quizzes',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B1033),
                      ),
                    ),
                    Text(
                      '${filteredList.length} Total',
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizer.deviceHeight1_5),
                // Pill buttons: All | Tests | Quizzes
                Row(
                  children: [
                    _buildFilterPill('All'),
                    SizedBox(width: AppSizer.deviceWidth2),
                    _buildFilterPill('Tests'),
                    SizedBox(width: AppSizer.deviceWidth2),
                    _buildFilterPill('Quizzes'),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // List of Tests
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade300),
                        SizedBox(height: AppSizer.deviceHeight1),
                        Text(
                          'No available tests or quizzes found',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth4,
                      vertical: AppSizer.deviceHeight2,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildTestCard(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isSelected = _selectedCategory == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0033CC) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppSizer.deviceSp13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> item, int index) {
    final title = item['title'] ?? 'Test';
    final level = item['difficulty'] ?? item['level'] ?? 'Beginner';
    final qCount = item['questions'] ?? item['totalQuestions'] ?? 10;
    final duration = item['duration'] ?? 15;
    final points = item['points'] ?? (qCount * 1);
    final dateStr = item['scheduledStartTime']?.toString() ?? '';

    final badgeColor = _getLevelColor(level);
    final badgeBgColor = _getLevelBgColor(level);
    final iconGradient = _getIconGradient(index, title);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final isQuiz = (item['type'] ?? '').toString().toLowerCase().contains('quiz');
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestInstructionsPage(
                  quiz: item,
                  isQuiz: isQuiz,
                ),
              ),
            );
            if (result == true && mounted) {
              Navigator.pop(context, true);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: iconGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getTopicIcon(title),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0B1033),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp11,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizer.deviceHeight0_5),

                      // Date Time
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 15, color: Color(0xFF0033CC)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(dateStr),
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),

                      // Stats Row
                      Row(
                        children: [
                          _buildStatChip(Icons.article_outlined, '$qCount Qs'),
                          const SizedBox(width: 12),
                          _buildStatChip(Icons.timer_outlined, '$duration mins'),
                          const SizedBox(width: 12),
                          _buildStatChip(Icons.emoji_events_outlined, '$points pts'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Padding(
                  padding: EdgeInsets.only(top: 14, left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF0033CC),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
