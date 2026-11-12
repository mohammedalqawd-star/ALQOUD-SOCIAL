# ALQOUD SOCIAL — Implementation Roadmap

## Status key
- [x] Present in repository (not necessarily production-verified)
- [ ] Not implemented or not yet verified

## Phase 0 — Stabilize the foundation
- [x] Flutter application shell and Arabic RTL theme.
- [x] Firebase Auth email/password service and initial profile document.
- [x] Media upload path and pending-review post creation.
- [x] Firestore feed query for published posts.
- [x] Like, save, comment submission, and report primitives.
- [ ] Resolve analyzer failures and make CI green.
- [ ] Generate and commit Android platform scaffolding (without Firebase credentials).
- [ ] Pin Flutter/Dart toolchain and verify dependency compatibility.
- [ ] Add unit/widget tests and Firebase Emulator Suite rules tests.
- [ ] Add CI jobs for analyze, tests, and Android debug/release build.

**Exit criteria:** CI passes; Android project builds; Firebase initialization is configured locally; rules tests pass.

## Phase 1 — Secure accounts and profiles
- [ ] Email verification and password reset UX.
- [ ] Profile edit, avatar upload, username uniqueness.
- [ ] Privacy settings and account deletion request.
- [ ] Follow/unfollow service and screens.
- [ ] Block/unblock service and enforcement across feed/search/comments.
- [ ] Firestore schema validation and rules tests.

## Phase 2 — Production feed and publishing
- [ ] Remove all demo/sample feed content from production navigation.
- [ ] Cursor pagination and refresh.
- [ ] Playback lifecycle, preloading limits, pause when backgrounded.
- [ ] Upload progress, retry, cancellation, file validation, draft handling.
- [ ] Trusted moderation pipeline: pending -> approved/published or rejected.
- [ ] Comment moderation queue and safe display.
- [ ] Shareable post deep links and deletion/takedown handling.
- [ ] Media processing: thumbnails, metadata, and transcoding strategy.

## Phase 3 — Discovery and recommendations
- [ ] Search users, posts, and hashtags.
- [ ] Categories and trending topics.
- [ ] Initial rules-based recommendation service.
- [ ] Diversity, freshness, blocked-user exclusion, and spam resistance.
- [ ] Ranking instrumentation and offline evaluation dataset.

## Phase 4 — Creator center and analytics
- [ ] Event schema for qualified views and watch duration.
- [ ] Server-side deduplication and aggregation.
- [ ] Creator dashboard and per-post analytics.
- [ ] Metric definitions, date ranges, and privacy limits.
- [ ] Abuse detection for artificial views/likes.

## Phase 5 — Notifications
- [ ] FCM setup and Android notification channels.
- [ ] Secure device token registration and rotation.
- [ ] Backend-triggered notification delivery.
- [ ] In-app inbox, read state, preferences, and quiet controls.
- [ ] Notification tests and delivery failure handling.

## Phase 6 — Video editor
- [ ] Basic trim/crop/cover selection.
- [ ] Caption overlay and media preview.
- [ ] Upload compression and supported format matrix.
- [ ] Device capability checks and fallback behavior.
- [ ] Advanced effects only after performance and licensing review.

## Phase 7 — Live streaming (gated)
- [ ] Select and evaluate a dedicated live streaming provider.
- [ ] Cost, latency, regional availability, and privacy assessment.
- [ ] Host eligibility and feature flags.
- [ ] Live moderation, report/block, moderator tools, and incident process.
- [ ] Load tests and limited private beta.
- [ ] Public live remains disabled until all safety and operational gates pass.

## Phase 8 — Admin and moderation
- [ ] Admin web console or secure internal admin app.
- [ ] Firebase custom claims provisioned only by trusted Admin SDK process.
- [ ] Review queues and moderation actions through callable functions.
- [ ] Audit log and moderator role separation.
- [ ] Appeals and transparent moderation reasons.
- [ ] Rules and permission tests for every privileged operation.

## Phase 9 — Localization and accessibility
- [ ] Flutter localization resources and generated localization setup.
- [ ] Arabic and English complete translations.
- [ ] Locale-aware RTL/LTR and number/date formatting.
- [ ] Accessibility labels, scalable text, contrast, and screen-reader review.

## Phase 10 — Release readiness
- [ ] Privacy policy, terms, community guidelines, and support contact.
- [ ] Data retention/deletion and incident response procedures.
- [ ] Security review and Firebase App Check.
- [ ] Emulator and physical-device regression suite.
- [ ] Android release signing via protected CI secrets.
- [ ] Release APK/AAB, crash reporting, staged rollout, rollback plan.

## Immediate next tasks
1. Fix and rerun analyzer; inspect exact diagnostics from latest Actions run.
2. Add Android Gradle scaffolding and safe CI build workflow.
3. Add test harness and rules tests.
4. Replace demo-only Explore/Inbox/Profile placeholders with clearly scoped functional screens.
5. Implement follow/block/profile backend before expanding recommendation logic.
6. Build moderation backend before exposing creator uploads publicly.
