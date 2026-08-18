import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/course_purchase_page.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/veiw_model/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionDetailPage extends StatefulWidget {
  final SubscriptionPlan plan;

  const SubscriptionDetailPage({Key? key, required this.plan}) : super(key: key);

  @override
  State<SubscriptionDetailPage> createState() => _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState extends State<SubscriptionDetailPage> {
  SubscriptionPlan? _detailedPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = SubscriptionViewModel();
    final details = await viewModel.getSubscriptionDetails(widget.plan.id);
    if (mounted) {
      setState(() {
        _detailedPlan = details ?? widget.plan;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _detailedPlan ?? widget.plan;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Details'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(plan),
                  _buildBenefits(plan),
                  if (plan.includedCourses.isNotEmpty) _buildIncludedCourses(plan),
                  SizedBox(height: AppSizer.deviceHeight10),
                ],
              ),
            ),
      bottomNavigationBar: _isLoading ? null : _buildBottomButton(context, plan),
    );
  }

  Widget _buildHeader(SubscriptionPlan plan) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizer.deviceWidth6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.7)],
        ),
      ),
      child: Column(
        children: [
          Text(
            plan.planType.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizer.deviceSp24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          Text(
            '₹${plan.price.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizer.deviceSp32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            plan.duration,
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizer.deviceSp16,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizer.deviceWidth4,
              vertical: AppSizer.deviceHeight1,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${plan.totalStudents} Students Enrolled',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(SubscriptionPlan plan) {
    return Padding(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Benefits',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          ...plan.planBenefits.map((benefit) => Padding(
            padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.successColor),
                SizedBox(width: AppSizer.deviceWidth3),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(fontSize: AppSizer.deviceSp16),
                  ),
                ),
              ],
            ),
          )),
          if (plan.freeJobs > 0) ...[
            SizedBox(height: AppSizer.deviceHeight1),
            Row(
              children: [
                Icon(Icons.work, color: AppColors.primaryColor),
                SizedBox(width: AppSizer.deviceWidth3),
                Text(
                  '${plan.freeJobs} Free Job Applications',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncludedCourses(SubscriptionPlan plan) {
    return Padding(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Included Courses (${plan.includedCourses.length})',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          ...plan.includedCourses.map((course) => Card(
            margin: EdgeInsets.only(bottom: AppSizer.deviceHeight3),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSizer.deviceWidth25,
                        height: AppSizer.deviceWidth18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: course.thumbnail.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(course.thumbnail),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: AppColors.surfaceVariant,
                        ),
                        child: course.thumbnail.isEmpty
                            ? Icon(Icons.school, color: AppColors.primaryColor, size: AppSizer.deviceSp32)
                            : null,
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizer.deviceSp16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizer.deviceHeight0_5),
                            Text(
                              course.technology,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: AppSizer.deviceSp14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceHeight0_5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth2,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                color: course.isFree ? AppColors.successColor.withOpacity(0.1) : AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.isFree ? 'FREE' : '₹${course.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp12,
                                  fontWeight: FontWeight.bold,
                                  color: course.isFree ? AppColors.successColor : AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (course.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSizer.deviceHeight2),
                        Text(
                          course.description,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  if (course.whatYouWillLearn.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSizer.deviceHeight2),
                        Text(
                          'What you\'ll learn:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizer.deviceSp15,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        ...course.whatYouWillLearn.take(3).map((item) => Padding(
                          padding: EdgeInsets.only(bottom: AppSizer.deviceHeight0_5),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: AppColors.successColor),
                              SizedBox(width: AppSizer.deviceWidth2),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: AppSizer.deviceSp13),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  if (course.faqs.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSizer.deviceHeight2),
                        Text(
                          'FAQs:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizer.deviceSp15,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        ...course.faqs.take(2).map((faq) => Padding(
                          padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q: ${faq.question}',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight0_5),
                              Text(
                                'A: ${faq.answer}',
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  if (course.reviews.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSizer.deviceHeight2),
                        Text(
                          'Reviews:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizer.deviceSp15,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        ...course.reviews.take(2).map((review) => Padding(
                          padding: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: AppSizer.deviceWidth1),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.studentName,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      review.comment,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, SubscriptionPlan plan) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            final courseForCheckout = Course(
              id: plan.id,
              title: plan.planType,
              description: plan.planBenefits.join(', '),
              instructor: 'Coders Adda',
              price: plan.price,
              thumbnail: '',
              category: 'Subscription',
              technology: 'All',
              isFree: plan.isFree,
              rating: 5.0,
              totalStudents: plan.totalStudents,
              duration: plan.duration,
              totalLessons: plan.includedCourses.length,
              createdAt: DateTime.now(),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseCheckoutPage(
                  course: courseForCheckout,
                  itemType: 'subscription',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
          ),
          child: Text(
            plan.isFree ? 'SUBSCRIBE FOR FREE' : 'SUBSCRIBE NOW - ₹${plan.price.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizer.deviceSp16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
