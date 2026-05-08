import 'package:flutter/material.dart';
import '../../services/auth_service_interface.dart';
import '../../services/current_auth_service.dart';

/// Two-phase forgot-password screen.
///
/// Phase 1: Enter phone number → request reset code.
/// Phase 2: Enter reset code + new password → complete reset.
///
/// Designed without a Scaffold so it can be embedded in the patient-app
/// phone frame OR wrapped in a Scaffold for the doctor portal full-page flow.
class ForgotPasswordScreen extends StatefulWidget {
  /// Called when the user successfully resets their password.
  /// Typically navigates back to the login screen.
  final VoidCallback onSuccess;

  /// Called when the user wants to go back to login (before completing reset).
  final VoidCallback onBack;

  const ForgotPasswordScreen({
    super.key,
    required this.onSuccess,
    required this.onBack,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Phase { requestCode, enterCode }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _Phase _phase = _Phase.requestCode;

  final _phoneController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _devToken; // visible in dev/MVP; null once SMS is live
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Phone captured in Phase 1 and reused in Phase 2.
  String _submittedPhone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Phase 1 ────────────────────────────────────────────────────────────────

  Future<void> _handleRequestCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number.');
      return;
    }
    final phoneRegex = RegExp(r'^[+]?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() => _errorMessage = 'Enter a valid phone number (7–15 digits).');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await currentAuthService.forgotPassword(phone);

    if (!mounted) return;

    if (result.success) {
      // Auto-fill the code field in dev mode so testers don't have to copy it manually.
      if (result.devResetToken != null) {
        _tokenController.text = result.devResetToken!;
      }
      setState(() {
        _isLoading = false;
        _submittedPhone = phone;
        _devToken = result.devResetToken;
        _phase = _Phase.enterCode;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  // ── Phase 2 ────────────────────────────────────────────────────────────────

  Future<void> _handleReset() async {
    final token = _tokenController.text.trim();
    final newPwd = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (token.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }
    if (newPwd.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (newPwd != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await currentAuthService.resetPasswordWithToken(
      _submittedPhone,
      token,
      newPwd,
    );

    if (!mounted) return;

    if (success) {
      widget.onSuccess();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid or expired reset code. Please try again or request a new code.';
      });
    }
  }

  void _backToPhase1() {
    setState(() {
      _phase = _Phase.requestCode;
      _errorMessage = null;
      _tokenController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _phase == _Phase.requestCode
                ? _buildPhase1()
                : _buildPhase2(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            _phase == _Phase.requestCode ? 'Forgot Password' : 'Enter Reset Code',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _phase == _Phase.requestCode
                ? 'Enter your registered phone number to receive a reset code.'
                : 'Enter the code sent to your phone and choose a new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.blue[100], height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Phone Number',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '9876543210',
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(_errorMessage!),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRequestCode,
          style: _primaryButtonStyle(),
          child: _isLoading
              ? _loadingIndicator()
              : const Text('Send Reset Code',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onBack,
          child: const Text('← Back to Login',
              style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildPhase2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dev-mode token banner
        if (_devToken != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Development Mode — Reset Code',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _devToken!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'In production this code is sent via SMS.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF1565C0)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        const Text('Reset Code',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _tokenController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. ABC12345',
            prefixIcon: const Icon(Icons.key_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
        const Text('New Password',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          decoration: InputDecoration(
            hintText: 'At least 8 characters',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: _visibilityToggle(
                _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Confirm New Password',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: 'Re-enter new password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: _visibilityToggle(_obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(_errorMessage!),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleReset,
          style: _primaryButtonStyle(),
          child: _isLoading
              ? _loadingIndicator()
              : const Text('Reset Password',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _backToPhase1,
          child: const Text('← Request a new code',
              style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(color: Colors.red[700], fontSize: 13)),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  Widget _loadingIndicator() => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );

  Widget _visibilityToggle(bool obscure, VoidCallback onTap) => IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: Colors.grey[600],
        ),
        onPressed: onTap,
      );
}
