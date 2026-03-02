import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_ai/bloc/chat_cubit.dart';
import 'package:widget_ai/bloc/chat_state.dart';
import 'package:widget_ai/llm/programing_assistant.dart';
import 'package:widget_ai/model/app_project_details.dart';
import 'package:widget_ai/model/chat_message.dart';
import 'package:widget_ai/model/database.dart';
import 'package:widget_ai/presentation/chat/widgets/message_bubble.dart';
import 'package:widget_ai/presentation/web_app_view.dart';
import 'package:widget_ai/service/locator.dart';
import 'package:widget_ai/utility/theme.dart';

class ChatWindow extends StatefulWidget {
  final AppProjectDetails projectDetails;

  /// Provided when reopening an existing project so the cubit can restore
  /// conversation history from the DB without sending a new message to the LLM.
  final int? projectId;

  const ChatWindow({super.key, required this.projectDetails, this.projectId});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ChatCubit(assistant: locator<ProgrammingAssistant>());

    if (widget.projectId != null) {
      // Existing project — restore the saved conversation history.
      _cubit.restoreSession(widget.projectId!);
    } else {
      // Brand-new project — kick off Phase 1 with the LLM.
      _cubit.initialise(widget.projectDetails);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _cubit.sendMessage(text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.primary),
              title: const Text('App Context Image'),
              subtitle: const Text('Send a mockup or screenshot for building context'),
              onTap: () {
                Navigator.pop(context);
                _cubit.pickFile(MessageType.image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.primary),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _cubit.pickFile(MessageType.document);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WidgetArchitect AI', style: Theme.of(context).textTheme.titleMedium),
              Text(
                widget.projectDetails.appName,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        _scrollToBottom();
        if (state is ChatCodeSaved) {
          _showCodeSavedSheet(state);
        }
      },
      builder: (context, state) {
        List<ChatMessage> messages = [];
        bool isTyping = false;

        if (state is ChatLoaded) {
          messages = state.messages;
          isTyping = state.isTyping;
        } else if (state is ChatLoading) {
          messages = state.messages;
          isTyping = true;
        } else if (state is ChatError) {
          messages = state.messages;
        } else if (state is ChatCodeSaved) {
          messages = state.messages;
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          itemCount: messages.length + (isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (isTyping && index == messages.length) {
              return _buildTypingIndicator();
            }
            return MessageBubble(message: messages[index]);
          },
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return const TypingIndicator();
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.r)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: _showAttachmentOptions,
              tooltip: 'More options',
            ),
            IconButton(
              icon: const Icon(Icons.image_outlined, color: AppColors.primary),
              onPressed: () => _cubit.pickFile(MessageType.image),
              tooltip: 'Attach Image for Context',
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.greyLight,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCodeSavedSheet(ChatCodeSaved state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 8.w),
                Text(
                  'Code Generated!',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '${state.savedFilePaths.length} file(s) saved to your device.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('View Widget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () async {
                  final projectId = _cubit.projectId;
                  if (projectId == null) return;

                  // Capture navigator before the async gap.
                  final nav = Navigator.of(context);

                  final db = locator<AppDatabase>();
                  final project = await db.getProjectById(projectId);

                  if (project == null) return;

                  nav.pop(); // close sheet
                  nav.pushReplacement(MaterialPageRoute(builder: (_) => WebAppView(project: project)));
                },
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay in Chat')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Refined Typing Indicator ───────────────────────────────────────────────

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _appearanceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _fadeAnimation = CurvedAnimation(parent: _appearanceController, curve: Curves.easeIn);

    _scaleAnimation = CurvedAnimation(parent: _appearanceController, curve: Curves.easeOutBack);

    _appearanceController.forward();
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
                bottomLeft: Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                SizedBox(width: 4.w),
                _Dot(delay: 150),
                SizedBox(width: 4.w),
                _Dot(delay: 300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 50),
    ]).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _anim.value),
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}
