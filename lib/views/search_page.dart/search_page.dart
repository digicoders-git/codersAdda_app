import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Flutter development',
    'React Native course',
    'Python for beginners',
    'Web development',
    'Data science',
    'Machine learning',
    'UI/UX design',
    'Mobile app development',
  ];

  List<String> _filteredSearches = [];
  List<String> _searchSuggestions = [
    'Flutter tutorial for beginners',
    'Flutter vs React Native',
    'Flutter animation',
    'Flutter state management',
    'Flutter web development',
    'Flutter Firebase',
    'Flutter API integration',
    'Flutter UI design',
  ];

  @override
  void initState() {
    super.initState();
    _filteredSearches = _recentSearches;
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSearches = _recentSearches;
      });
      return;
    }

    // Filter recent searches based on query
    final filtered = _recentSearches.where((search) {
      return search.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredSearches = filtered;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      // Add to recent searches if not already present
      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          // Keep only last 10 searches
          if (_recentSearches.length > 10) {
            _recentSearches.removeLast();
          }
        });
      }

      // Navigate to search results or perform search
      print('Searching for: $query');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search",style: TextStyle(fontSize: AppSizer.deviceSp20,fontWeight: FontWeight.bold),),
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
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
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
                    isCollapsed:
                        true,
                  ),
                  onChanged: _search,
                  onSubmitted: _performSearch,
                ),
              ),
            ),
          ),

         
          if (_searchController.text.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggestions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  ..._searchSuggestions
                      .where(
                        (suggestion) => suggestion.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        ),
                      )
                      .take(5)
                      .map((suggestion) => _buildSuggestionItem(suggestion))
                      .toList(),
                ],
              ),
            ),
          ],

          
          if (_searchController.text.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (_recentSearches.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                      child: Text(
                        'Clear all',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],

          
          Expanded(
            child:
                _searchController.text.isNotEmpty && _filteredSearches.isEmpty
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
                        SizedBox(height: 8),
                        Text(
                          'Try different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSearches.length,
                    itemBuilder: (context, index) {
                      final search = _filteredSearches[index];
                      return _buildRecentSearchItem(search);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return ListTile(
      leading: Icon(Icons.history, color: Colors.grey),
      title: Text(search),
      trailing: IconButton(
        icon: Icon(Icons.clear, size: 16),
        onPressed: () {
          setState(() {
            _recentSearches.remove(search);
            _filteredSearches = List.from(_recentSearches);
          });
        },
      ),
      onTap: () {
        _searchController.text = search;
        _performSearch(search);
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return ListTile(
      leading: Icon(Icons.search, color: Colors.grey),
      title: Text(suggestion),
      onTap: () {
        _searchController.text = suggestion;
        _performSearch(suggestion);
      },
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
