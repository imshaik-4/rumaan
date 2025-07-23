// Enhanced Create Coupon Tab
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/models/coupon.dart';
import 'package:rumaan/providers/auth_provider.dart';
import 'package:rumaan/providers/coupon_provider.dart';
import 'package:rumaan/widgets/barcode_display.dart';

class _CreateCouponTab extends StatefulWidget {
  const _CreateCouponTab();

  @override
  State<_CreateCouponTab> createState() => _CreateCouponTabState();
}

class _CreateCouponTabState extends State<_CreateCouponTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  CouponCategory _selectedCategory = CouponCategory.food;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isSingleUse = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createCoupon() async {
    if (_formKey.currentState!.validate()) {
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? currentUserId = authProvider.appUser?.uid;
      
      await couponProvider.createCoupon(
        title: _titleController.text,
        description: _descriptionController.text,
        discount: double.parse(_discountController.text),
        category: _selectedCategory,
        validUntil: _selectedDate,
        isSingleUse: _isSingleUse,
        createdByUid: currentUserId,
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _discountController.clear();
      setState(() {
        _selectedCategory = CouponCategory.food;
        _selectedDate = DateTime.now().add(const Duration(days: 30));
        _isSingleUse = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Coupon created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.add_circle,
                        size: 32.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Coupon',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Design attractive offers for your hotel guests',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Form
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: _titleController,
                        label: 'Coupon Title',
                        hint: 'e.g., 20% Off Spa Treatment',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      _buildFormField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'e.g., Enjoy a relaxing spa session with 20% discount.',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              controller: _discountController,
                              label: 'Discount (%)',
                              hint: 'e.g., 20',
                              icon: Icons.percent,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a discount';
                                }
                                if (double.tryParse(value) == null || 
                                    double.parse(value) <= 0 || 
                                    double.parse(value) > 100) {
                                  return 'Enter valid percentage (1-100)';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildCategoryDropdown(),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      _buildDateSelector(context),
                      
                      SizedBox(height: 24.h),
                      
                      _buildSingleUseToggle(),
                      
                      SizedBox(height: 40.h),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: couponProvider.isLoading ? null : _createCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: couponProvider.isLoading
                              ? CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle, size: 24.sp),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Create Coupon',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<CouponCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category, color: colorScheme.primary),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          items: CouponCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category.toString().split('.').last.capitalize(),
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valid Until',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.primary),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: colorScheme.onSurface.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleUseToggle() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.primary,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Single Use Coupon',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'If enabled, this coupon expires for everyone after first redemption',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isSingleUse,
            onChanged: (bool value) {
              setState(() {
                _isSingleUse = value;
              });
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

// Enhanced Manage Coupons Tab
class _ManageCouponsTab extends StatelessWidget {
  const _ManageCouponsTab();

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final allCoupons = couponProvider.allCoupons;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    size: 32.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Coupons',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'View and manage all your hotel coupons',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${allCoupons.length} Total',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          
          // Coupons List
          allCoupons.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allCoupons.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final coupon = allCoupons[index];
                    return _buildCouponCard(context, coupon, couponProvider);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.local_activity,
              size: 64.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Coupons Yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first coupon to get started with promotions.',
            style: TextStyle(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, Coupon coupon, CouponProvider couponProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: coupon.isActive 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _getCategoryColor(coupon.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getCategoryIcon(coupon.category),
                  color: _getCategoryColor(coupon.category),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${coupon.discount.toStringAsFixed(0)}% Off • ${coupon.category.toString().split('.').last.capitalize()}',
                  //    Off•${coupon.category.toString().split('.').last.capitalize()},
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: coupon.isActive 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  coupon.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: coupon.isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Valid Until',
                        coupon.formattedValidUntil,
                        Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Used By',
                        '${coupon.usedBy.length} users',
                        Icons.people,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Single Use',
                        coupon.isSingleUse ? 'Yes' : 'No',
                        Icons.info,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Category',
                        coupon.category.toString().split('.').last.capitalize(),
                        Icons.category,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Switch(
                      value: coupon.isActive,
                      onChanged: (bool value) {
                        couponProvider.updateCouponStatus(coupon, value);
                      },
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Barcode for ${coupon.title}',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                BarcodeDisplay(barcodeData: coupon.barcodeData),
                                SizedBox(height: 20.h),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.qr_code_2,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                    ),
                    tooltip: 'Show Barcode',
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          title: Text(
                            'Delete Coupon',
                            style: TextStyle(fontSize: 20.sp),
                          ),
                          content: Text(
                            'Are you sure you want to delete "${coupon.title}"? This action cannot be undone.',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                couponProvider.deleteCoupon(coupon.id);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Coupon deleted successfully'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20.sp,
                      ),
                    ),
                    tooltip: 'Delete Coupon',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(CouponCategory category) {
    switch (category) {
      case CouponCategory.food:
        return Colors.orange;
      case CouponCategory.spa:
        return Colors.purple;
      case CouponCategory.room:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(CouponCategory category) {
    switch (category) {
      case CouponCategory.food:
        return Icons.restaurant;
      case CouponCategory.spa:
        return Icons.spa;
      case CouponCategory.room:
        return Icons.hotel;
      default:
        return Icons.local_activity;
    }
  }
}

// Enhanced Scan Coupon Tab
class _ScanCouponTab extends StatefulWidget {
  const _ScanCouponTab();

  @override
  State<_ScanCouponTab> createState() => _ScanCouponTabState();
}

class _ScanCouponTabState extends State<_ScanCouponTab> {
  String? _scannedBarcodeData;
  Coupon? _foundCoupon;
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _handleScanResult(String barcodeData) {
    setState(() {
      _scannedBarcodeData = barcodeData;
      _foundCoupon = Provider.of<CouponProvider>(context, listen: false)
          .getCouponByBarcodeData(barcodeData);
    });
  }

  void _redeemScannedCoupon() async {
    if (_foundCoupon != null && _userIdController.text.isNotEmpty) {
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      await couponProvider.redeemCoupon(_foundCoupon!.id, _userIdController.text.trim());
      
      setState(() {
        _scannedBarcodeData = null;
        _foundCoupon = null;
        _userIdController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon redeemed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (_userIdController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a User ID to redeem.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700.w),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 32.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Coupon',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Scan customer coupons for redemption',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Scanner Button
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    final result = await context.push<String>('/barcode_scanner');
                    if (result != null) {
                      _handleScanResult(result);
                    }
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 48.sp,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Tap to Open Scanner',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Point camera at coupon QR code',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_scannedBarcodeData != null) ...[
                SizedBox(height: 32.h),
                
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code, color: colorScheme.primary),
                          SizedBox(width: 12.w),
                          Text(
                            'Scanned Data:',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          _scannedBarcodeData!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'monospace',
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                if (_foundCoupon != null) ...[
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coupon Found!',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Ready for redemption',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _foundCoupon!.title,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${_foundCoupon!.discount.toStringAsFixed(0)}% Off • ${_foundCoupon!.category.toString().split('.').last.capitalize()}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCouponDetail(
                                      'Valid Until',
                                      _foundCoupon!.formattedValidUntil,
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildCouponDetail(
                                      'Status',
                                      _foundCoupon!.isActive ? 'Active' : 'Inactive',
                                      Icons.info,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCouponDetail(
                                      'Single Use',
                                      _foundCoupon!.isSingleUse ? 'Yes' : 'No',
                                      Icons.repeat_one,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildCouponDetail(
                                      'Used By',
                                      '${_foundCoupon!.usedBy.length} users',
                                      Icons.people,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        TextFormField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            labelText: 'Customer User ID',
                            hintText: 'Enter customer\'s unique ID',
                            prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: couponProvider.isLoading ? null : _redeemScannedCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: couponProvider.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.redeem, size: 24.sp),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Redeem Coupon',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Coupon Not Found',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No valid coupon found for this barcode data. Please verify the QR code and try again.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponDetail(String label, String value, IconData icon) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
