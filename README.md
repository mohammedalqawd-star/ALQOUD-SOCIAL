# ALQOUD – القعود

منصة اجتماعية عربية أولاً لمشاركة الفيديوهات القصيرة والمحتوى الإبداعي، مبنية باستخدام Flutter.

## مواصفات المنتج وخطة التنفيذ
- [مواصفات المنتج الكاملة](docs/PRODUCT_SPEC.md)
- [خارطة التنفيذ ومراحل التسليم ومعايير الإطلاق](docs/IMPLEMENTATION_ROADMAP.md)

المنصة المستهدفة في الإصدار الأول: Android. تشمل الرؤية الكاملة مركز المبدعين، التوصيات، البث المباشر المقيد بضوابط السلامة، الإشعارات، لوحة الإدارة والمراجعة، تعدد اللغات، محرر الفيديو، والتحليلات. هذه عناصر نطاق معتمدة وليست كلها منفذة بعد؛ راجع خارطة التنفيذ لمعرفة حالة كل مرحلة.

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

## Android cloud APK build

The Android project is configured for a GitHub Actions debug APK build.

1. In the repository, open **Settings → Secrets and variables → Actions → New repository secret**.
2. Set the secret name to `GOOGLE_SERVICES_JSON`.
3. Paste the complete contents of the Firebase Android `google-services.json` file as the secret value. Do not commit that file to the repository.
4. Open **Actions → Android APK → Run workflow** (or push a change to the configured paths).
5. When the run succeeds, open the run summary and download the `alqoud-social-debug-apk` artifact. Extract the ZIP to get `app-debug.apk`.

The workflow runs dependency resolution, Flutter analysis, tests, and a debug APK build. This is a development build, not a signed production release.


## Trusted content moderation backend

The `functions/` directory contains callable Firebase Functions for approving or rejecting pending posts and comments. Only Firebase Auth users with a trusted custom claim (`admin: true` or `moderator: true`) can call these endpoints. The mobile app cannot grant these claims to itself. Assign moderator claims only from a secured administrator environment using the Firebase Admin SDK, and protect that environment's credentials.

Deploy the backend and rules from a trusted development environment with Firebase CLI:
```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions,firestore:rules
```

**Billing note:** deploying Cloud Functions may require the Firebase project to use the Blaze plan. Review the current Firebase pricing and set budget alerts with the project owner before enabling billing. Do not enable billing or deploy production services without the account owner's approval.

The moderation endpoints are not yet connected to an in-app moderator dashboard. Until a trusted moderator claim is assigned and the functions are deployed, new posts remain in `pending_review`.
