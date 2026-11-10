import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
      title: 'eFootball Pro Clone',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
      ),
      home: const CloneDashboardScreen(),
    );
  }
}

class CloneDashboardScreen extends StatefulWidget {
  const CloneDashboardScreen({super.key});

  @override
  State<CloneDashboardScreen> createState() => _CloneDashboardScreenState();
}

class _CloneDashboardScreenState extends State<CloneDashboardScreen> {
  final _secureStorage = const FlutterSecureStorage();
  String _activeAccount = 'در حال بارگذاری از پایگاه داده...';
  bool _isAntiDetectionActive = true;
  int _launchCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDataFromLocalDatabase();
  }

  // خواندن اطلاعات از پایگاه داده محلی
  Future<void> _loadDataFromLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    
    // خواندن تعداد دفعات اجرا از پایگاه داده محلی
    int currentCount = prefs.getInt('launch_count') ?? 0;
    currentCount++;
    await prefs.setInt('launch_count', currentCount);

    // خواندن اکانت فعال ذخیره شده
    String? savedAccount = await _secureStorage.read(key: 'active_account');
    
    setState(() {
      _activeAccount = savedAccount ?? 'اکانت پیش‌فرض (تایید شده)';
      _launchCount = currentCount;
    });
  }

  // ذخیره اکانت جدید در پایگاه داده محلی و امن
  Future<void> _switchAccount(String accountName) async {
    await _secureStorage.write(key: 'active_account', value: accountName);
    setState(() {
      _activeAccount = accountName;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('در پایگاه داده محلی ثبت شد: سوییچ روی $accountName')),
    );
  }

  // شبیه‌سازی اتصال به سرویس گوگل
  Future<void> _launchGoogleAuth() async {
    final Uri url = Uri.parse('https://accounts.google.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در باز کردن درگاه ورود گوگل')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کلون با پایگاه داده محلی'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت نمایش وضعیت پایگاه داده و دفعات اجرا
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'وضعیت پایگاه داده محلی (Local DB)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تعداد دفعات اجرای برنامه: $_launchCount بار',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isAntiDetectionActive ? 'وضعیت امنيت: ایزوله و مخفی' : 'وضعیت: عادی',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // اکانت فعال
            Text(
              'اکانت فعال فعلی: $_activeAccount',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),

            // دکمه‌های سوییچ اکانت
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchAccount('اکانت اول (Main)'),
                    child: const Text('اکانت ۱'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchAccount('اکانت دوم (Alt)'),
                    child: const Text('اکانت ۲'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // دکمه اتصال به گوگل
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.blueAccent),
              ),
              onPressed: _launchGoogleAuth,
              icon: const Icon(Icons.login, color: Colors.blueAccent),
              label: const Text('ورود و همگام‌سازی با گوگل'),
            ),
            
            const Spacer(),

            // دکمه پاکسازی پایگاه داده
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await _secureStorage.deleteAll();
                setState(() {
                  _activeAccount = 'پاکسازی شد';
                  _launchCount = 0;
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('پایگاه داده محلی کاملاً ریست و پاکسازی شد.')),
                );
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('ریست و پاکسازی پایگاه داده محلی'),
            ),
          ],
        ),
      ),
    );
  }
}
