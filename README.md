# ALQOUD – القعود

منصة اجتماعية عربية أولاً لمشاركة الفيديوهات القصيرة والمحتوى الإبداعي، مبنية باستخدام Flutter.

## الموجود في نسخة التطوير الحالية
- واجهة عربية RTL بهوية زمردية وذهبية.
- تسجيل حساب وتسجيل دخول بالبريد الإلكتروني عبر Firebase Authentication.
- إنشاء ملف مستخدم أساسي في Cloud Firestore.
- اختيار صورة أو فيديو من الجهاز ورفعه إلى Firebase Storage.
- حفظ بيانات المنشور في Firestore بحالة `pending_review`.
- موجز مباشر يقرأ المنشورات المعتمدة فقط (`published`).
- تشغيل الفيديو داخل التطبيق عبر `video_player`.
- إعجابات فورية، وحفظ المنشورات، وإرسال التعليقات إلى المراجعة.
- الإبلاغ عن المنشورات مع تخزين البلاغات للمراجعة.
- إعدادات أولية لقواعد Firestore وStorage.

## مهم قبل التشغيل
مستودع GitHub لا يحتوي على بيانات مشروع Firebase. يجب إنشاء مشروع Firebase باسم تختاره أنت من Firebase Console وربطه بحسابك. لم يتم إنشاء مشروع Firebase أو تفعيل الفوترة أو إضافة مفاتيح خاصة نيابةً عنك.

## إعداد Firebase
1. أنشئ مشروعاً في Firebase Console.
2. أضف تطبيق Android بمعرّف الحزمة الذي تستخدمه في مشروع Flutter. إذا لم يكن لديك مشروع Flutter مولّد بعد، أنشئه أولاً بالأمر `flutter create .` داخل مجلد المشروع.
3. أضف تطبيق iOS إذا كنت ستبني نسخة iPhone.
4. فعّل Email/Password من Authentication.
5. أنشئ Cloud Firestore في وضع الإنتاج.
6. فعّل Firebase Storage.
7. ثبّت Firebase CLI وFlutterFire CLI ثم سجّل الدخول:
   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
8. انشر قواعد الحماية والفهارس من جذر المشروع:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```

انسخ `.firebaserc.example` إلى `.firebaserc` واستبدل `YOUR_FIREBASE_PROJECT_ID` بمعرّف مشروعك، أو نفّذ `firebase use --add`. راجع ملفات `firebase.json` و`firestore.rules` و`storage.rules` قبل النشر. لا تستخدم قواعد تسمح بالقراءة أو الكتابة العامة.

## تشغيل Flutter
يتطلب المشروع Flutter حديثاً وDart 3.12 أو أحدث بسبب إصدارات بعض الحزم.
```bash
flutter pub get
flutter run
```

## بناء APK
```bash
flutter build apk --release
```
المسار المعتاد:
`build/app/outputs/flutter-apk/app-release.apk`

بناء iOS يحتاج macOS وXcode.

## ما الذي لم يكتمل بعد؟
- نظام مراجعة وإدارة المنشورات؛ لذلك المنشورات الجديدة تبقى قيد المراجعة ولا تظهر في الموجز العام حتى تعتمدها خدمة إدارة موثوقة.
- نظام متابعة الحسابات وإدارة الموافقات على التعليقات والمنشورات.
- الرسائل الخاصة والإشعارات.
- البحث الشامل والوسوم والترشيح الذكي.
- معالجة الفيديو على الخادم (ضغط وترميز متعدد الدقات وصور مصغرة وشبكة توزيع محتوى).
- لوحة إدارة ومركز مبدعين وتحليلات.
- اختبارات فعلية على أجهزة Android وiOS.

## أمان وخصوصية
- لا ترفع ملفات `google-services.json` أو `GoogleService-Info.plist` أو أسراراً إلى مستودع عام.
- لا تفتح صلاحيات Firestore أو Storage للجميع.
- لا تفعّل الرسائل العامة أو البث المباشر قبل تجهيز الحظر والإبلاغ ومراجعة المحتوى وضوابط الخصوصية.
- قواعد Firebase الحالية بداية تحتاج مراجعة واختباراً أمنياً قبل إطلاق التطبيق للمستخدمين.
