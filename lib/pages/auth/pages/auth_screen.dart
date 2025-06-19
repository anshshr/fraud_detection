import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Theme colors
  final Color _primaryGreen = const Color(0xFF2E7D32); // Dark green
  final Color _accentGreen = const Color(0xFF43A047); // Medium green
  final Color _lightGreen = const Color(0xFF81C784); // Light green
  final Color _darkBackground = const Color(0xFF121212); // Near black
  final Color _cardColor = const Color(0xFF1E1E1E); // Dark gray
  final Color _textColor = Colors.white;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _hasBiometrics = false;
  bool _isLoading = true;
  String _authMessage = "Checking authentication methods...";
  final TextEditingController _passwordController = TextEditingController();
  bool _showPasswordInput = false;
  String? _storedPassword;
  List<BiometricType> _availableBiometrics = [];
  bool _biometricOnly = true;

  @override
  void initState() {
    super.initState();
    _initializeAuthentication();
  }

  Future<void> _initializeAuthentication() async {
    try {
      await _checkBiometrics();
      await _loadPassword();
      setState(() => _isLoading = false);

      // If biometrics are available and no password is set, prompt for password first
      if (_hasBiometrics && _storedPassword == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSetPasswordDialog();
        });
      } else if (_hasBiometrics) {
        // Try biometric auth first if available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _authenticate();
        });
      }
    } catch (e) {
      print("Error initializing authentication: $e");
      setState(() {
        _isLoading = false;
        _showPasswordInput = true;
        _authMessage = "Error setting up authentication. Please use password.";
      });
    }
  }

  Future<void> _loadPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _storedPassword = prefs.getString('app_password');
      });
    } catch (e) {
      print("Error loading password: $e");
      setState(() {
        _showPasswordInput = true;
        _authMessage = "Error loading saved password. Please set a new one.";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSetPasswordDialog();
      });
    }
  }

  Future<void> _savePassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_password', password);
      setState(() => _storedPassword = password);
    } catch (e) {
      print("Error saving password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      // First check if device supports biometrics
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        setState(() {
          _hasBiometrics = false;
          _showPasswordInput = true;
          _authMessage = "Device doesn't support biometric authentication";
        });
        return;
      }

      // Then check if biometrics are enrolled
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        setState(() {
          _hasBiometrics = false;
          _showPasswordInput = true;
          _authMessage = "No biometrics enrolled on this device";
        });
        return;
      }

      // Get available biometric types
      _availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _hasBiometrics = _availableBiometrics.isNotEmpty;
        if (!_hasBiometrics) {
          _showPasswordInput = true;
          _authMessage = "No biometric sensors available";
        }
      });

      print("Available biometrics: $_availableBiometrics");
    } on PlatformException catch (e) {
      print("Error checking biometrics: ${e.code} - ${e.message}");
      setState(() {
        _hasBiometrics = false;
        _showPasswordInput = true;
        _authMessage = "Error checking biometric capabilities";
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authMessage = "Authenticating...";
    });

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: _biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        _onAuthenticationSuccess();
      } else {
        setState(() {
          _authMessage = "Authentication failed or canceled";
          _showPasswordInput = true;
        });
      }
    } on PlatformException catch (e) {
      print("Authentication error: ${e.code} - ${e.message}");
      _handleAuthError(e.code);
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _authMessage = "Authentication error. Please try again.";
        _showPasswordInput = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  void _handleAuthError(String errorCode) {
    String message;
    bool showPassword = false;

    switch (errorCode) {
      case auth_error.notAvailable:
        message = "Biometrics not available";
        showPassword = true;
        break;
      case auth_error.notEnrolled:
        message = "No biometrics enrolled. Please set up in device settings.";
        showPassword = true;
        break;
      case auth_error.passcodeNotSet:
        message = "No device security set up. Please set a screen lock.";
        showPassword = true;
        break;
      case auth_error.lockedOut:
        message = "Too many attempts. Try again later or use password.";
        showPassword = true;
        break;
      case auth_error.permanentlyLockedOut:
        message = "Biometrics permanently locked. Use password.";
        showPassword = true;
        _biometricOnly = false;
        break;
      default:
        message = "Authentication failed. Please try again.";
        showPassword = true;
    }

    if (mounted) {
      setState(() {
        _authMessage = message;
        _showPasswordInput = showPassword;
      });
    }
  }

  void _verifyPassword() {
    if (_passwordController.text == _storedPassword) {
      _onAuthenticationSuccess();
    } else {
      setState(() {
        _authMessage = "Incorrect password. Please try again.";
        _passwordController.clear();
      });
    }
  }

  void _onAuthenticationSuccess() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _showSetPasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: _cardColor,
            title: Text(
              'Set App Password',
              style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please set a secure password:',
                    style: TextStyle(color: _textColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: TextStyle(color: _textColor),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(color: _lightGreen),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _accentGreen),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _accentGreen),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: _accentGreen),
                      filled: true,
                      fillColor: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: _textColor),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: _lightGreen),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: _accentGreen),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _accentGreen),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: _accentGreen),
                      filled: true,
                      fillColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final newPass = newPasswordController.text;
                  final confirmPass = confirmPasswordController.text;

                  if (newPass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password cannot be empty'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPass != confirmPass) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Passwords do not match'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  _savePassword(newPass);
                  Navigator.of(context).pop();
                  setState(() {
                    _showPasswordInput = true;
                    _authMessage = "Password set. Please authenticate.";
                  });
                },
                style: TextButton.styleFrom(foregroundColor: _primaryGreen),
                child: Text(
                  'SET PASSWORD',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: _primaryGreen,
        scaffoldBackgroundColor: _darkBackground,
        colorScheme: ColorScheme.dark(
          primary: _primaryGreen,
          secondary: _accentGreen,
          background: _darkBackground,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(color: _accentGreen),
                    )
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      _darkBackground,
                                      Color(0xFF0E1E0E), // Very dark green tint
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      // Shield logo with fingerprint
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: _cardColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _accentGreen.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.fingerprint,
                                          size: 80,
                                          color: _accentGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // App title
                                      Text(
                                        'Auth Shield',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: _textColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Tagline
                                      Text(
                                        'Fraud Detection & Prevention',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _lightGreen,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      // Auth message in a card
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _cardColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _accentGreen.withOpacity(
                                              0.3,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _isAuthenticating
                                                  ? Icons.pending_outlined
                                                  : _showPasswordInput
                                                  ? Icons.info_outline
                                                  : Icons.shield_outlined,
                                              color: _accentGreen,
                                            ),
                                            SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                _authMessage,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: _textColor.withOpacity(
                                                    0.9,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // Password field
                                      if (_showPasswordInput) ...[
                                        TextField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: TextStyle(color: _textColor),
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              color: _lightGreen,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: _accentGreen,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: _primaryGreen,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              color: _accentGreen,
                                            ),
                                            filled: true,
                                            fillColor: Colors.black45,
                                          ),
                                          onSubmitted: (_) => _verifyPassword(),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _verifyPassword,
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(
                                              double.infinity,
                                              56,
                                            ),
                                            backgroundColor: _primaryGreen,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            'VERIFY PASSWORD',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 20),
                                      // Biometric button
                                      if (_hasBiometrics &&
                                          !_isAuthenticating) ...[
                                        ElevatedButton.icon(
                                          onPressed: _authenticate,
                                          icon: Icon(
                                            _availableBiometrics.contains(
                                                  BiometricType.face,
                                                )
                                                ? Icons.face
                                                : Icons.fingerprint,
                                            size: 28,
                                          ),
                                          label: Text(
                                            _availableBiometrics.contains(
                                                  BiometricType.face,
                                                )
                                                ? 'AUTHENTICATE WITH FACE ID'
                                                : 'AUTHENTICATE WITH FINGERPRINT',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(
                                              double.infinity,
                                              60,
                                            ),
                                            backgroundColor: _accentGreen,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 3,
                                            shadowColor: _accentGreen
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.security,
                                              size: 14,
                                              color: _lightGreen.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Secure biometric authentication",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _lightGreen.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      // Loading indicator
                                      if (_isAuthenticating) ...[
                                        const SizedBox(height: 30),
                                        CircularProgressIndicator(
                                          color: _accentGreen,
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Verifying your identity...",
                                          style: TextStyle(
                                            color: _lightGreen,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      Spacer(),
                                      // Footer
                                      Text(
                                        "© 2025 Auth Shield",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ),
      ),
    );
  }
}
