
import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/job_viewmodel.dart';
import 'package:coders_adda_app/views/job_pages/single_job_detailed_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobsPage extends StatelessWidget {
  final JobsViewModel viewModel = JobsViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Premium Jobs',
            style: TextStyle(fontSize: AppSizer.deviceSp20),
          ),
        ),
        body: Consumer<JobsViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Search and Filter Section
                _buildSearchFilterSection(context, viewModel),
                
                // Jobs List
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    child: Column(
                      children: [
                        ...viewModel.filteredJobs.map((job) => _buildJobCard(job, context, viewModel)).toList(),
                        
                        // No results message
                        if (viewModel.filteredJobs.isEmpty)
                          Container(
                            padding: EdgeInsets.all(AppSizer.deviceWidth8),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: AppSizer.deviceSp48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: AppSizer.deviceHeight2),
                                Text(
                                  'No jobs found',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Try changing your search or filters',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection(BuildContext context, JobsViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => viewModel.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search jobs by title, skills, company...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizer.deviceWidth4,
                  vertical: AppSizer.deviceHeight2,
                ),
                suffixIcon: viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => viewModel.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          
          // Filter Row
          Row(
            children: [
              // Job Type Filter
              Expanded(
                child: _buildFilterDropdown(
                  value: viewModel.selectedJobType,
                  items: ['All Types', ...viewModel.availableJobTypes],
                  hint: 'Job Type',
                  onChanged: (value) => viewModel.setSelectedJobType(value!),
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth2),
              
              // Experience Filter
              Expanded(
                child: _buildFilterDropdown(
                  value: viewModel.selectedExperience,
                  items: ['All Levels', ...viewModel.availableExperiences],
                  hint: 'Experience',
                  onChanged: (value) => viewModel.setSelectedExperience(value!),
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth2),
              
              // Filter Button
              Container(
                decoration: BoxDecoration(
                  color: viewModel.hasActiveFilters ? AppColors.primaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: viewModel.hasActiveFilters ? Colors.white : Colors.grey,
                  ),
                  onPressed: () => _showAdvancedFilterDialog(context, viewModel),
                ),
              ),
            ],
          ),
          
          // Active Filters Chips
          if (viewModel.hasActiveFilters) ...[
            SizedBox(height: AppSizer.deviceHeight2),
            _buildActiveFiltersChips(viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth2),
      child: DropdownButton<String>(
        value: value.isEmpty ? null : value,
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
        hint: Text(
          hint,
          style: TextStyle(fontSize: AppSizer.deviceSp14, color: Colors.grey),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: AppSizer.deviceSp12),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (newValue) => onChanged(newValue ?? ''),
      ),
    );
  }

  Widget _buildActiveFiltersChips(JobsViewModel viewModel) {
    return Wrap(
      spacing: AppSizer.deviceWidth2,
      runSpacing: AppSizer.deviceHeight1,
      children: [
        if (viewModel.searchQuery.isNotEmpty)
          _buildFilterChip(
            label: 'Search: "${viewModel.searchQuery}"',
            onRemove: () => viewModel.setSearchQuery(''),
          ),
        if (viewModel.selectedJobType.isNotEmpty && viewModel.selectedJobType != 'All Types')
          _buildFilterChip(
            label: 'Type: ${viewModel.selectedJobType}',
            onRemove: () => viewModel.setSelectedJobType(''),
          ),
        if (viewModel.selectedExperience.isNotEmpty && viewModel.selectedExperience != 'All Levels')
          _buildFilterChip(
            label: 'Exp: ${viewModel.selectedExperience}',
            onRemove: () => viewModel.setSelectedExperience(''),
          ),
        if (viewModel.selectedSkills.isNotEmpty)
          ...viewModel.selectedSkills.map((skill) => _buildFilterChip(
            label: 'Skill: $skill',
            onRemove: () => viewModel.removeSelectedSkill(skill),
          )).toList(),
        
        // Clear All Button
        if (viewModel.hasActiveFilters)
          InkWell(
            onTap: viewModel.clearAllFilters,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight1,
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: AppSizer.deviceSp12, color: Colors.red),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: AppSizer.deviceSp12),
      ),
      deleteIcon: Icon(Icons.close, size: AppSizer.deviceSp14),
      onDeleted: onRemove,
      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
void _showAdvancedFilterDialog(BuildContext context, JobsViewModel viewModel) {
  final allSkills = viewModel.allJobs
      .expand((job) => job.skills)
      .toSet()
      .toList()
    ..sort();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets + EdgeInsets.all(20),
          duration: Duration(milliseconds: 100),
          child: MediaQuery.removeViewInsets(
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            context: context,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Row(
                            children: [
                              Icon(Icons.filter_list, color: AppColors.primaryColor),
                              SizedBox(width: AppSizer.deviceWidth2),
                              Text(
                                'Advanced Filters',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizer.deviceHeight4),
                          
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Skills Filter
                                  Text(
                                    'Filter by Skills:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppSizer.deviceSp14,
                                    ),
                                  ),
                                  SizedBox(height: AppSizer.deviceHeight2),
                                  
                                  // Selected Skills Chips
                                  if (viewModel.selectedSkills.isNotEmpty) ...[
                                    Wrap(
                                      spacing: AppSizer.deviceWidth2,
                                      runSpacing: AppSizer.deviceHeight1,
                                      children: viewModel.selectedSkills.map((skill) {
                                        return Chip(
                                          label: Text(skill),
                                          deleteIcon: Icon(Icons.close, size: AppSizer.deviceSp14),
                                          onDeleted: () {
                                            setState(() {
                                              viewModel.removeSelectedSkill(skill);
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight2),
                                  ],
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: AppSizer.deviceHeight20,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount: allSkills.length,
                                      itemBuilder: (context, index) {
                                        final skill = allSkills[index];
                                        final isSelected = viewModel.selectedSkills.contains(skill);
                                        
                                        return CheckboxListTile(
                                          value: isSelected,
                                          onChanged: (selected) {
                                            setState(() {
                                              if (selected!) {
                                                viewModel.addSelectedSkill(skill);
                                              } else {
                                                viewModel.removeSelectedSkill(skill);
                                              }
                                            });
                                          },
                                          title: Text(
                                            skill,
                                            style: TextStyle(fontSize: AppSizer.deviceSp14),
                                          ),
                                          controlAffinity: ListTileControlAffinity.leading,
                                          dense: true,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Buttons
                          SizedBox(height: AppSizer.deviceHeight4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              TextButton(
                                onPressed: () {
                                  viewModel.clearAllFilters();
                                  Navigator.pop(context);
                                },
                                child: Text('Reset'),
                              ),
                              SizedBox(width: AppSizer.deviceWidth2),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Apply Filters'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
 

 Widget _buildJobCard(JobDetail job, BuildContext context, JobsViewModel viewModel) {
  final canApply = viewModel.canApplyForJob(job.id);
  
  return Card(
    margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Title and Premium Badge
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth3,
                      vertical: AppSizer.deviceHeight1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.position,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Premium Lock Badge
              if (!canApply)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppSizer.deviceWidth1),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: AppSizer.deviceSp12, color: Colors.white),
                        SizedBox(width: AppSizer.deviceWidth1),
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Key Details Row
          Row(
            children: [
              _buildDetailItem(Icons.location_on, job.location),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.work_outline, job.jobType),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.timeline, job.experience),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Salary and Openings Row
          Row(
            children: [
              _buildDetailItem(Icons.currency_rupee, job.salary),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.people, '${job.totalOpenings} Openings'),
              SizedBox(width: AppSizer.deviceWidth3),
              _buildDetailItem(Icons.calendar_today, 'Posted: ${job.addedDate}'),
            ],
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Skills Section
          Text(
            'Required Skills:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizer.deviceSp16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Wrap(
            spacing: AppSizer.deviceWidth2,
            runSpacing: AppSizer.deviceHeight1,
            children: job.skills.map((skill) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight1,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            )).toList(),
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Company Details Section (NEW)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer.deviceWidth4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizer.deviceSp14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight2),
                
                // Company Name
                _buildHiddenDetailItem(
                  Icons.business,
                  'Company: ${_hideMiddleCharacters(job.company)}',
                ),
                SizedBox(height: AppSizer.deviceHeight1),
                
                // Company Email
                _buildHiddenDetailItem(
                  Icons.email,
                  'Email: ${_hideMiddleCharacters(job.companyEmail)}',
                ),
                SizedBox(height: AppSizer.deviceHeight1),
                
                // Company Mobile
                _buildHiddenDetailItem(
                  Icons.phone,
                  'Mobile: ${_hideMiddleCharacters(job.companyMobile)}',
                ),
                SizedBox(height: AppSizer.deviceHeight1),
                
                // Company Website
                _buildHiddenDetailItem(
                  Icons.language,
                  'Website: ${_hideMiddleCharacters(job.companyWebsite.replaceAll('https://', '').replaceAll('http://', ''))}',
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSizer.deviceHeight1),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showSaveConfirmation(context, job.title);
                  },
                  icon: Icon(Icons.bookmark_border, size: AppSizer.deviceSp16),
                  label: Text(
                    'Save',
                    style: TextStyle(fontSize: AppSizer.deviceSp16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth1),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (canApply) {
                      _showApplyDialog(context, job.title, job, () {
                        viewModel.applyForJob(job.id);
                      });
                    } else {
                      _showSubscriptionPrompt(context);
                    }
                  },
                  icon: Icon(
                    canApply ? Icons.lock_open : Icons.lock,
                    size: AppSizer.deviceSp16,
                  ),
                  label: Text(
                    canApply ? 'Unlock Now' : 'Premium',
                    style: TextStyle(fontSize: AppSizer.deviceSp16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: canApply ? AppColors.primaryColor : Colors.amber,
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Helper function to hide middle characters for all sensitive data
String _hideMiddleCharacters(String text) {
  if (text.length <= 2) {
    return text; // Return as is if too short
  }
  
  // For email addresses - hide both username and domain
  if (text.contains('@')) {
    final parts = text.split('@');
    if (parts.length == 2) {
      final username = parts[0];
      final domainParts = parts[1].split('.');
      
      String hiddenUsername;
      if (username.length <= 2) {
        hiddenUsername = username;
      } else {
        hiddenUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
      }
      
      // Hide domain name too (except TLD)
      if (domainParts.length >= 2) {
        final domainName = domainParts[0];
        final tld = domainParts.sublist(1).join('.');
        
        String hiddenDomainName;
        if (domainName.length <= 2) {
          hiddenDomainName = domainName;
        } else {
          hiddenDomainName = '${domainName[0]}${'*' * (domainName.length - 2)}${domainName[domainName.length - 1]}';
        }
        
        return '$hiddenUsername@$hiddenDomainName.$tld';
      }
    }
  }
  
  // For phone numbers
  if (text.contains('+')) {
    if (text.length <= 4) {
      return text;
    }
    return '${text.substring(0, 3)}${'*' * (text.length - 4)}${text.substring(text.length - 1)}';
  }
  
  // For website URLs - remove protocol and hide domain
  if (text.contains('://')) {
    final uri = Uri.tryParse(text);
    if (uri != null) {
      final host = uri.host;
      if (host.contains('.')) {
        final hostParts = host.split('.');
        if (hostParts.length >= 2) {
          final domainName = hostParts[0];
          final tld = hostParts.sublist(1).join('.');
          
          String hiddenDomainName;
          if (domainName.length <= 2) {
            hiddenDomainName = domainName;
          } else {
            hiddenDomainName = '${domainName[0]}${'*' * (domainName.length - 2)}${domainName[domainName.length - 1]}';
          }
          
          return '$hiddenDomainName.$tld';
        }
      }
    }
  }
  
  // For regular text (company name, etc.)
  return '${text[0]}${'*' * (text.length - 2)}${text[text.length - 1]}';
}

// Updated detail item for hidden text
Widget _buildHiddenDetailItem(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        size: AppSizer.deviceSp18,
        color: Colors.grey[600],
      ),
      SizedBox(width: AppSizer.deviceWidth2),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizer.deviceSp16,
            color: Colors.grey[600],
          ),
          SizedBox(width: AppSizer.deviceWidth1),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

 void _showApplyDialog(BuildContext context, String jobTitle, JobDetail job, VoidCallback onApply) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Unlock for Job'),
      content: Text('Are you sure you want to apply for $jobTitle?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context); // Dialog close karo
            onApply(); // Job apply logic execute karo
            _navigateToJobDetails(context, job); // JobDetailsPage open karo
          },
          child: Text('Unlock'),
        ),
      ],
    ),
  );
}

void _navigateToJobDetails(BuildContext context, JobDetail job) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => JobDetailsPage(job: job),
    ),
  );
}

  void _showSubscriptionPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          SizedBox(width: AppSizer.deviceWidth2),
          Text('Upgrade to Premium'),
        ],
      ),
      content: Text('You have used all your 3 free job applications. Subscribe to our premium plan to apply for unlimited jobs.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Maybe Later'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _navigateToSubscriptionPage(context);
          },
          child: Text('Upgrade Now'),
        ),
      ],
    ),
  );
}

void _navigateToSubscriptionPage(BuildContext context) {
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (context) => SubscriptionPage())
  );
}

  void _showSaveConfirmation(BuildContext context, String jobTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$jobTitle saved to your list'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      ),
    );
  }
}