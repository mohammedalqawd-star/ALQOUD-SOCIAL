# ALQOUD SOCIAL — Product Specification

## Product decision
- Product: ALQOUD SOCIAL (القعود)
- Initial release platform: Android
- Product scope: Complete social video and creator platform, delivered in tested phases
- Primary UI language: Arabic (RTL); architecture must support additional locales
- Visual identity: emerald, deep green, gold, and ivory
- Backend: Firebase Authentication, Cloud Firestore, Firebase Storage, Cloud Functions, Firebase Cloud Messaging, and App Check where appropriate

## Product principles
1. Real functionality only: no demo counters or fake engagement in production screens.
2. Secure by default: client apps cannot grant themselves moderator privileges, publish pending content, or write trusted analytics.
3. Safety and privacy: clear reporting, blocking, moderation, privacy controls, age-appropriate defaults, and data deletion workflows.
4. Reliability: loading, empty, offline, permission-denied, and retry states for every network-backed screen.
5. Accessibility and localization: semantic labels, scalable text, RTL/LTR layouts, and translated strings.
6. Cost-aware media: upload limits, thumbnail generation, adaptive playback strategy, and abuse/rate controls.

## Main application areas

### 1. Authentication and account
- Email/password registration and sign-in.
- Email verification, password reset, sign-out, and account deletion request.
- Profile: display name, username, avatar, bio, privacy setting, locale.
- Input validation, duplicate username handling, and clear auth error messages.
- Do not expose email addresses or private profile fields publicly.

### 2. Home video feed
- Vertical swipe feed with autoplay/pause lifecycle handling.
- Tabs: For You and Following.
- Published content only; pagination and pull-to-refresh.
- Image/video playback, captions, creator attribution, follow, like, comment, save, share, and report.
- Record view events with server-side validation and deduplication; never trust client-supplied aggregate counts.
- Handle deleted, unavailable, blocked, and moderated content.

### 3. Discovery and search
- Search users, captions, and hashtags.
- Explore categories and trending tags.
- Sort by recent and curated popularity with spam controls.
- Search must respect privacy, blocks, and moderation status.

### 4. Publishing and media editor
- Select image or video, preview, caption, hashtags, and audience visibility.
- Client-side validation for file type, size, duration, and upload progress.
- Draft, upload, pending review, approved/published, rejected, and removed states.
- Basic editor: trim/crop where supported, cover selection, caption overlay, mute/volume controls.
- Advanced editing (filters, timeline, transitions, music licensing) is a later milestone.
- No upload should become public before trusted moderation approval.

### 5. Social interactions
- Like/unlike, comments, save/unsave, follow/unfollow, share links.
- Block and unblock users.
- Report posts, comments, profiles, and live sessions.
- Comments are rate-limited and moderated; provide deletion/report controls.
- No anonymous open chat in the initial release.

### 6. Creator center and analytics
- Creator dashboard with post status and per-post performance.
- Views, unique viewers where privacy-safe, watch time, completion rate, likes, comments, saves, shares, follower change.
- Date filters and clear metric definitions.
- Analytics aggregates are written by trusted backend functions, not by arbitrary clients.
- Do not expose personal viewer identities to creators.

### 7. Recommendations
- Start with a transparent, rules-based ranking: language, followed creators, selected interests, recency, quality signals, and diversity.
- Exclude pending/rejected/removed content, blocked accounts, and already hidden content.
- Add abuse resistance and limits against artificial engagement.
- Later evaluate ranking quality with privacy-preserving aggregate metrics.
- Do not claim machine-learning personalization until a real model and evaluation exist.

### 8. Live streaming
- Separate live provider/service integration; Firebase alone is not a media streaming transport.
- Approved/eligible hosts only; staged rollout behind a feature flag.
- Host controls: start, end, mute, camera controls, audience settings.
- Viewer controls: report, block, leave, and moderation notices.
- Live moderation tools, rate limits, incident response, and recording/retention policy must exist before public launch.
- No gifts, cash-out, or paid interactions in the initial release.
- Disable public live access until provider, safety, legal, and operational checks pass.

### 9. Notifications
- FCM device registration and token rotation.
- In-app notification inbox for follows, approved comments, likes, moderation decisions, and account security.
- Notification preferences and quiet controls.
- Send notifications from trusted backend functions; avoid exposing tokens to other users.

### 10. Admin and moderation console
- Separate trusted admin surface and server-side authorization using Firebase custom claims.
- Queues for posts, comments, reports, and live incidents.
- Actions: approve, reject with reason, remove, restrict, suspend, restore, and resolve report.
- Immutable audit log with actor, action, target, timestamp, and reason.
- Least-privilege roles; no admin role can be assigned by a client.
- Moderator actions must be callable only through authenticated, authorized backend functions.

### 11. Localization
- Arabic first, with English as the next locale and architecture for additional languages.
- All user-facing strings externalized; locale-aware dates, numbers, and text direction.
- Language selector and persisted preference.

## Data domains
- users and private user settings
- posts and media metadata
- follows and blocks
- likes, comments, saves, reports
- notifications and device tokens
- view events and trusted analytics aggregates
- creator summaries
- live sessions and moderation events
- admin roles and immutable audit logs
- feature flags and taxonomy (categories/hashtags)

## Release gates
A feature is not complete until:
- UI, service, schema, and authorization rules exist.
- Loading, empty, error, and offline states are implemented.
- Unit/widget/integration tests cover critical paths.
- Firestore and Storage rules are emulator-tested.
- Abuse, privacy, and moderation behavior is reviewed.
- Android release build succeeds and is smoke-tested on a physical device.
- No secrets or production credentials are committed to the public repository.
