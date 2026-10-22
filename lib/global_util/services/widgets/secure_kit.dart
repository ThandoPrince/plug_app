import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';

/// Gradient page with a centred title, optional loading bar, tap-to-dismiss
/// keyboard, a scrolling body and an optional pinned footer.
class SecureScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? footer;
  final bool loading;

  const SecureScaffold({
    super.key,
    required this.title,
    required this.children,
    this.footer,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      appBar: AppBar(
        backgroundColor: Kolors.kPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: ReusableText(
          text: title,
          style: appStyle(16.sp, Colors.white, FontWeight.w700),
        ),
        bottom: loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Kolors.kSecondaryLight),
                ),
              )
            : null,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
        ),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    children: children,
                  ),
                ),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon badge + title + subtitle shown at the top of a screen.
class ScreenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isPassword;
  final String? errorText;
  final String? helper;
  final TextInputType? keyboardType;
  final TextInputAction action;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofill;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool centered; // large, letter-spaced style for OTP codes

  const GlassField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.errorText,
    this.helper,
    this.keyboardType,
    this.action = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.autofill,
    this.inputFormatters,
    this.maxLength,
    this.centered = false,
  });

  @override
  State<GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<GlassField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          enableSuggestions: !widget.isPassword,
          autocorrect: false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.action,
          autofillHints: widget.autofill,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          textAlign: widget.centered ? TextAlign.center : TextAlign.start,
          cursorColor: Kolors.kPrimary,
          style: TextStyle(
            color: Kolors.kDark,
            fontSize: widget.centered ? 20.sp : 13.5.sp,
            fontWeight: widget.centered ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: widget.centered ? 8 : 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            labelText: widget.label,
            labelStyle: TextStyle(color: Kolors.kDark, fontSize: 12.5.sp),
            floatingLabelStyle: TextStyle(
              color: Kolors.kDark,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, color: Kolors.kDark, size: 18.sp),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Kolors.kDark.withOpacity(0.7),
                      size: 18.sp,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            enabledBorder: _border(hasError
                ? Colors.red
                : Kolors.kPrimary.withOpacity(0.15)),
            focusedBorder: _border(
                hasError ? Colors.red : Kolors.kPrimary, 1.5),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Kolors.kRed, fontSize: 11.sp),
            ),
          ),
        ] else if (widget.helper != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              widget.helper!,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp),
            ),
          ),
        ],
      ],
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded,
              color: Kolors.kRed, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white, fontSize: 12.sp, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
        backgroundColor: Kolors.kPrimary,
        foregroundColor: Kolors.kWhite,
        disabledBackgroundColor: Kolors.kPrimary.withOpacity(0.55),
        disabledForegroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        shadowColor: Kolors.kPrimary.withOpacity(0.3),
      ),
      child: loading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Kolors.kWhite,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}