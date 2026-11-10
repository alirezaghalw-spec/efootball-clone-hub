import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EFootballCloneApp());
}

class EFootballCloneApp extends StatelessWidget {
  const EFootballCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eFootball Clone Hub',
      theme: ThemeData(
        // تنظیمات اصلی سبک ورزشی و چمنی
        primaryColor: const Color(0xFF2E7D32), // سبز چمنی تیره
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // سبز خیلی روشن پس‌زمینه
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF1B5E20), // سبز سیر
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20), // سبز تیره استادیوم
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32), // سبز دکمه‌ها
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Color(0xFF111111)),
        ),
      ),
      home: const SportyDashboardScreen(),
    );
  }
}

class SportyDashboardScreen extends StatefulWidget {
  const SportyDashboardScreen({super.key});

  @override
  State<SportyDashboardScreen> createState() => _SportyDashboardScreenState();
}

class _SportyDashboardScreenState extends State<SportyDashboardScreen> {
  final _secureStorage = const FlutterSecureStorage();
  String _activeAccount = 'در حال بارگذاری...';
  int _launchCount = 0;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('launch_count') ?? 0;
    count++;
    await prefs.setInt('launch_count', count);

    String? account = await _secureStorage.read(key: 'active_account');
    setState(() {
      _activeAccount = account ?? 'اکانت اصلی (Verified)';
      _launchCount = count;
    });
  }

  Future<void> _switchAccount(String name) async {
    await _secureStorage.write(key: 'active_account', value: name);
    setState(() {
      _activeAccount = name;
    });
    _showSnackBar('اکانت شما با موفقیت تغییر کرد');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1B5E20), // سبز تیره اسنک‌بار
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchGoogleAuth() async {
    final Uri url = Uri.parse('https://accounts.google.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('خطا در باز کردن درگاه ورود گوگل');
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() => _isCheckingUpdate = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/flutter/flutter/releases/latest'),
      ).timeout(const Duration(seconds: 8));

      setState(() => _isCheckingUpdate = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String tagName = data['tag_name'] ?? 'v1.0.0';
        _showUpdateDialog(tagName, data['html_url']);
      } else {
        _showSnackBar('خطا در ارتباط با سرور گیت‌هاب');
      }
    } catch (e) {
      setState(() => _isCheckingUpdate = false);
      _showSnackBar('عدم دسترسی به اینترنت');
    }
  }

  void _showUpdateDialog(String version, String? url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('به‌روزرسانی جدید', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        content: Text('نسخه v1.0.0\nآخرین نسخه موجود در گیت‌هاب: $version\n\nآیا می‌خواهید به صفحه دانلود منتقل شوید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (url != null) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('دانلود از گیت‌هاب'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_soccer, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'eFootball Clone Hub',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بنر وضعیت کلون (استایل ورزشی)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'وضعیت کلون:',
                        style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('ایزوله', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'اکانت فعال: $_activeAccount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تعداد دفعات اجرا در این نسخه: $_launchCount بار',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // بخش مدیریت اکانت‌ها
            const Text(
              'جابه‌جایی بین اکانت‌ها',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1B5E20),
                      elevation: 2,
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () => _switchAccount('اکانت اصلی (Verified)'),
                    icon: const Icon(Icons.person, color: Color(0xFF2E7D32)),
                    label: const Text('اکانت اصلی'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1B5E20),
                      elevation: 2,
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () => _switchAccount('اکانت دوم (Alt)'),
                    icon: const Icon(Icons.person_outline, color: Color(0xFF1B5E20)),
                    label: const Text('اکانت ۲'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // ابزارها و قابلیت‌های کلون
            const Text(
              'ابزار‌های کمکی و سیستم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 12),

            // دکمه بررسی آپدیت (استایل ورزشی)
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                onTap: _isCheckingUpdate ? null : _checkForUpdates,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.system_update, color: Color(0xFF2E7D32), size: 26),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('به‌روزرسانی گیت‌هاب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text('چک کردن نسخه جدید APK', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          ],
                        ),
                      ),
                      _isCheckingUpdate
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B5E20)))
                          : const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // دکمه ورود با گوگل
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                onTap: _launchGoogleAuth,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.login, color: Color(0xFF2E7D32), size: 26),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ورود با حساب گوگل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                            const SizedBox(height: 4),
                            Text('احراز هویت امن eFootball', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),

            // دکمه پاکسازی پایگاه داده
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade800,
                side: BorderSide(color: Colors.red.shade800, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await _secureStorage.deleteAll();
                setState(() {
                  _activeAccount = 'پاک‌سازی شده';
                  _launchCount = 0;
                });
                _showSnackBar('تمام داده‌های برنامه با موفقیت ریست شد');
              },
              icon: const Icon(Icons.delete_sweep),
              label: const Text('ریست کامل و پاک‌سازی داده‌های برنامه', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
