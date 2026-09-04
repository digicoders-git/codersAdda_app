import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final CourseService _courseService = CourseService();

  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoading = true);
    final courses = await _courseService.getAllCoursesForSearch();
    if (mounted) {
      setState(() {
        _allCourses = courses;
        _filteredCourses = [];
        _isLoading = false;
      });
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCourses = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        return course.title.toLowerCase().contains(lowerQuery) ||
            course.technology.toLowerCase().contains(lowerQuery) ||
            course.description.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey[100],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search courses by name or technology...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 16,
                    ),
                    isCollapsed: true,
                  ),
                  onChanged: _search,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchController.text.isEmpty
                    ? Center(
                        child: Text(
                          "Type to search for courses",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : _filteredCourses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No results found for "${_searchController.text}"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = _filteredCourses[index];
                              return _buildCourseResult(course);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseResult(Course course) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: course.thumbnail.isNotEmpty
              ? Image.network(
                  course.thumbnail,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.menu_book, color: Colors.grey),
                ),
        ),
        title: Text(
          course.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            course.isFree ? "Free" : "₹${course.price}",
            style: TextStyle(
              color: course.isFree ? AppColors.successColor : AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          NavigationService.navigateToCourseDetail(context, course);
        },
      ),
    );
  }
}
