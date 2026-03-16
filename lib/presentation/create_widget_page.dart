import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:widget_ai/model/app_project_details.dart';
import 'package:widget_ai/presentation/ai_chat_window/chat_window.dart';
import 'package:widget_ai/utility/theme.dart';
import 'package:widget_ai/utility/widget/common_button.dart';
import 'package:widget_ai/utility/widget/common_textfield.dart';

class CreateWidgetPage extends StatefulWidget {
  const CreateWidgetPage({super.key});

  @override
  State<CreateWidgetPage> createState() => _CreateWidgetPageState();
}

class _CreateWidgetPageState extends State<CreateWidgetPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ValueNotifier<String?> _selectedImagePath = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isGeneratingAI = ValueNotifier<bool>(false);
  final ValueNotifier<String> _selectedModel = ValueNotifier<String>('gemini');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _selectedImagePath.dispose();
    _isGeneratingAI.dispose();
    _selectedModel.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      _selectedImagePath.value = result.files.single.path;
    }
  }

  // Future<void> _generateAIImage() async {
  //   _isGeneratingAI.value = true;
  //   // Simulate AI Generation
  //   await Future.delayed(const Duration(seconds: 2));
  //   _isGeneratingAI.value = false;
  //   // In a real app, you'd set the path to the generated image
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Image Generation prompted!")));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create App Widget", style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "App Icon",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            SizedBox(height: 12.h),
            _buildImagePickerSection(),
            SizedBox(height: 24.h),
            CommonTextField(
              controller: _nameController,
              hintText: "Enter app name",
              labelText: "App Name",
              prefixIcon: const Icon(Icons.apps_rounded, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            CommonTextField(
              controller: _descriptionController,
              hintText: "Enter the prompt for app building using AI. Describe features, layout, and purpose...",
              labelText: "AI App Building Prompt",
              maxLines: 6,
              // prefixIcon: const Icon(Icons.description_rounded, color: AppColors.primary),
            ),
            SizedBox(height: 24.h),
            _buildModelSelection(),
            SizedBox(height: 40.h),
            CommonButton(
              text: "Create Widget",
              onPressed: () {
                final name = _nameController.text.trim();
                final desc = _descriptionController.text.trim();
                if (name.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Please fill in App Name and Description.')));
                  return;
                }
                final details = AppProjectDetails(
                  appName: name,
                  description: desc,
                  iconImagePath: _selectedImagePath.value,
                  llmModel: _selectedModel.value,
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatWindow(projectDetails: details)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select LLM Model",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        ValueListenableBuilder<String>(
          valueListenable: _selectedModel,
          builder: (context, model, _) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(12.r)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: model,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _selectedModel.value = newValue;
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'gemini',
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.primary),
                          SizedBox(width: 12.w),
                          const Text("Gemini 3 (Google)"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'anthropic',
                      child: Row(
                        children: [
                          const Icon(Icons.psychology, color: AppColors.primary),
                          SizedBox(width: 12.w),
                          const Text("Claude Sonnet 4.5 (Anthropic)"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImagePickerSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _pickImage,
            child: DottedBorder(
              options: CircularDottedBorderOptions(
                color: AppColors.primary.withValues(alpha: 0.5),
                strokeWidth: 2,
                dashPattern: const [8, 4],
              ),
              child: ValueListenableBuilder<String?>(
                valueListenable: _selectedImagePath,
                builder: (context, path, _) {
                  return Container(
                    height: 120.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: path != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(File(path), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 32.sp, color: AppColors.primary),
                              SizedBox(height: 8.h),
                              Text(
                                "Upload Icon",
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        ),
        // SizedBox(width: 16.w),
        // Expanded(
        //   flex: 1,
        //   child: ValueListenableBuilder<bool>(
        //     valueListenable: _isGeneratingAI,
        //     builder: (context, isGenerating, _) {
        //       return GestureDetector(
        //         onTap: isGenerating ? null : _generateAIImage,
        //         child: Container(
        //           height: 120.h,
        //           decoration: BoxDecoration(
        //             color: AppColors.primary.withValues(alpha: 0.1),
        //             borderRadius: BorderRadius.circular(16.r),
        //             border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        //           ),
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               isGenerating
        //                   ? SizedBox(
        //                       height: 24.h,
        //                       width: 24.h,
        //                       child: const CircularProgressIndicator(
        //                         strokeWidth: 2,
        //                         valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        //                       ),
        //                     )
        //                   : Icon(Icons.auto_awesome_rounded, size: 32.sp, color: AppColors.primary),
        //               SizedBox(height: 8.h),
        //               Text(
        //                 "AI Generate",
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
