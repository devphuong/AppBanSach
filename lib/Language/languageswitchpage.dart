import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSwitchPage extends StatefulWidget {
  const LanguageSwitchPage({Key? key}) : super(key: key);

  @override
  _LanguageSwitchPageState createState() => _LanguageSwitchPageState();
}

class _LanguageSwitchPageState extends State<LanguageSwitchPage> {
  String _currentLanguageCode = 'vi';
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  // Hàm để tải ngôn ngữ đã lưu từ SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode =
        prefs.getString('languageCode') ?? 'vi'; // Mặc định là 'vi' nếu chưa có
    setState(() {
      _currentLanguageCode = languageCode;
    });
    print("Ngôn ngữ hiện tại: $_currentLanguageCode");
  }

  // Hàm lưu ngôn ngữ đã chọn vào SharedPreferences
  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    print("Ngôn ngữ đã được lưu: $languageCode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Ngôn Ngữ'),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Ngôn Ngữ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                await _changeLanguage(context, 'vi');
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Tiếng Việt',
                      style: TextStyle(
                        fontSize: 20,
                        color: _currentLanguageCode == 'vi'
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await _changeLanguage(context, 'en');
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'English',
                      style: TextStyle(
                        fontSize: 20,
                        color: _currentLanguageCode == 'en'
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(
      BuildContext context, String languageCode) async {
    // Hiển thị hiệu ứng loading và dịch ngôn ngữ song song
    final results = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(languageCode: languageCode);
      },
    );

    // Xử lý sau khi hoàn tất
    if (results != null) {
      setState(() {
        _currentLanguageCode = languageCode; // Update the current language
      });
      await _saveLanguage(languageCode); // Lưu ngôn ngữ đã chọn
      Navigator.pop(context, results);
    }
  }
}

class LoadingDialog extends StatefulWidget {
  final String languageCode;

  const LoadingDialog({Key? key, required this.languageCode}) : super(key: key);

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int _progress = 0;
  final Map<String, String> _translations = {};
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _startLoadingAndTranslation();
  }

  Future<void> _startLoadingAndTranslation() async {
    final translationsToFetch = {
      'title': 'Log-in',
      'email': 'Email',
      'emailtxt': 'Your Email',
      'password': 'Password',
      'passwordtxt': 'Your Password',
      'forgetPassword': 'Forget password?',
      'signUp': 'Sign-up',
      'dontHaveAccount': "Don't have an account ?",
      'buttonlogin': 'Login',
    };

    final totalSteps = translationsToFetch.length;
    int currentStep = 0;

    for (final entry in translationsToFetch.entries) {
      final translated = await _translator.translate(
        entry.value,
        to: widget.languageCode,
      );
      _translations[entry.key] = translated.text;

      // Cập nhật tiến trình
      currentStep++;
      setState(() {
        _progress = (currentStep / totalSteps * 100).toInt();
      });
    }

    // Đóng dialog khi hoàn tất
    Navigator.pop(context, _translations);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Loading $_progress%'),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: _progress / 100,
          ),
        ],
      ),
    );
  }
}
