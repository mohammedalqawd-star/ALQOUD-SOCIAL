import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/app_backend.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool createAccount = false, busy = false, obscure = true;
  String? error;

  @override
  void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    try {
      if (createAccount) {
        await AppBackend.register(displayName: name.text, email: email.text, password: password.text);
      } else {
        await AppBackend.signIn(email: email.text, password: password.text);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = _message(e.code));
    } catch (_) {
      setState(() => error = 'تعذر إكمال العملية. تحقق من الاتصال وإعدادات Firebase.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _message(String code) {
    switch (code) {
      case 'email-already-in-use': return 'هذا البريد مستخدم من قبل.';
      case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'weak-password': return 'كلمة المرور ضعيفة؛ استخدم 8 أحرف على الأقل.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': return 'بيانات الدخول غير صحيحة.';
      case 'network-request-failed': return 'تحقق من اتصال الإنترنت.';
      default: return 'تعذر تسجيل الدخول حالياً (' + code + ').';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Form(
          key: formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 76, height: 76, alignment: Alignment.center,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC9A227), Color(0xFFE8D9A0)]), borderRadius: BorderRadius.circular(24)),
              child: const Text('ق', style: TextStyle(color: Color(0xFF061B15), fontSize: 48, fontWeight: FontWeight.w900))),
            const SizedBox(height: 24),
            const Text('أهلاً بك في القعود', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('مساحة عربية للإبداع والمشاركة', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 30),
            if (createAccount) ...[
              TextFormField(controller: name, textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'الاسم الظاهر', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.trim().length < 2) ? 'اكتب اسماً من حرفين على الأقل.' : null),
              const SizedBox(height: 14),
            ],
            TextFormField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) => (v == null || !v.contains('@')) ? 'أدخل بريداً إلكترونياً صحيحاً.' : null),
            const SizedBox(height: 14),
            TextFormField(controller: password, obscureText: obscure,
              decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
              validator: (v) => (v == null || v.length < 8) ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.' : null),
            if (error != null) ...[const SizedBox(height: 14), Text(error!, style: const TextStyle(color: Colors.redAccent))],
            const SizedBox(height: 22),
            FilledButton(onPressed: busy ? null : submit,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC9A227), foregroundColor: const Color(0xFF061B15), padding: const EdgeInsets.symmetric(vertical: 15)),
              child: busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(createAccount ? 'إنشاء الحساب' : 'تسجيل الدخول', style: const TextStyle(fontWeight: FontWeight.w900))),
            TextButton(onPressed: busy ? null : () => setState(() { createAccount = !createAccount; error = null; }),
              child: Text(createAccount ? 'لديك حساب؟ سجّل الدخول' : 'ليس لديك حساب؟ أنشئ حساباً')),
            const SizedBox(height: 12),
            const Text('احمِ كلمة مرورك ولا تشاركها مع أي شخص. استخدم المنصة باحترام وحافظ على خصوصيتك.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6)),
          ]),
        )),
      ))),
    );
  }
}
