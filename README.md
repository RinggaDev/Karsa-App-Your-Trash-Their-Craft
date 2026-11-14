# Karsa — "Sampahmu, Karya Mereka."

> **LOGICODIX 2026 Hackathon Submission**  
> **Category:** Mobile (Android / iOS)  
> **Sub-themes:** Green Environment & Sustainability · Local MSME & Creative Economy

---

## 1. Team

- **Team Name:** `Persevtech`
- **Members:**
  - `Dhabith Zabran Tringgana` — Flutter Developer, Backend & AI Engineer
  - `Abdurrahman Al Ghifary` — UI/UX & Product Designer

---

## 2. Application

- **Name:** Karsa
- **Category:** Mobile (Flutter — Android primary, iOS secondary)
- **Tagline (ID):** *"Sampahmu, Karya Mereka."*
- **Tagline (EN):** *"Your trash, their craft."*
- **Android Application ID:** `com.karsaapp.idndev`

---

## 3. Problem

1. **Waste contributors lack an actionable distribution channel:** Individuals who already sort household recyclable waste (plastic, wood, fabric, paper, metal) rarely know which local craft MSMEs (*UMKM kerajinan*) accept specific materials, how to coordinate handoff, or whether their small contributions create tangible impact.
2. **Local creative MSMEs lack consistent recycled raw material supply:** Craft-based MSMEs turning waste into higher-value products rely on fragmented, informal sourcing or costly middlemen.

---

## 4. Target Users

> **Note:** The personas below come from the Product Requirements Document (`karsa-prd.md`) and represent **design assumptions (unvalidated with live field testing)**.

- **Primary Persona ("Raka", 18–30 years old):** Urban university students or fresh graduates who already separate recyclable waste at home, prefer mobile-first workflows, and want visible proof of environmental and community impact.
- **Secondary Context (Curated UMKM Data in MVP):** Local Indonesian craft MSMEs (10 seeded workshops in MVP) that process recycled materials into bags, coasters, furniture items, recycled paper, and metal crafts. MSMEs do not have an app login or dashboard in this MVP.

---

## 5. Solution

Karsa is a mobile application backed by a containerized Node.js/Express REST API that connects waste contributors to matched local craft MSMEs: users log sorted waste details (material types, optional photo, weight, condition, pickup address, and date), select a matching MSME filtered from PostgreSQL, submit a distribution request, track its 4-stage progress (`pending` → `confirmed` → `picked_up` → `done`), review aggregate history, and read personalized environmental/social insights generated via Google Gemini AI.

---

## 6. Implemented Features

Every status below was verified directly against `karsa-app/karsa/lib/` and `karsa-backend/src/`:

| Feature | Status | Notes |
|---|---|---|
| **Auth (Register & Login)** | Done | `SignUpScreen` & `LoginScreen` call `POST /api/v1/auth/register` and `POST /api/v1/auth/login`; JWT persisted via `flutter_secure_storage`. |
| **Forgot Password (`Lupa Password?`)** | Mock | UI button exists on `LoginScreen` with `onPressed: null` (non-functional in MVP). |
| **Splash & Intro Slides** | Done | `SplashScreenKarsa` (1.8s) → `AuthGate` checks stored JWT → `Onboarding1` / `Onboarding2` → `LoginScreen` (or directly `MainShell` if logged in). |
| **Standalone Onboarding Profile Screen** | Partial | `OnboardingScreen` (`PUT /api/v1/users/profile`) exists in `lib/features/onboarding/screens/onboarding_screen.dart` but is unreachable in the live navigation graph because `SignUpScreen` collects `nama` and `kota` upfront and routes directly to `MainShell`. |
| **Home Dashboard & Stats** | Done | `HomeScreen` fetches `GET /api/v1/users/stats` and `GET /api/v1/submissions/active` (top 3 active items). |
| **Trash Input & Photo Upload** | Done | `InputScreen` collects 6 material chips, weight, condition, pickup point, date, notes; optional camera/gallery photo uploads via `POST /api/v1/upload/photo` (`trash-photos` bucket). |
| **UMKM Matching & Detail Sheet** | Done | `UmkmListScreen` & `UmkmDetailSheet` query `GET /api/v1/umkm?tipe_sampah=...` and `GET /api/v1/umkm/:id` (PostgreSQL tag filter, no AI). Confirmation creates submission via `POST /api/v1/submissions`. |
| **Active Deliveries & Status Tracking** | Partial | `PengantaranScreen` (`GET /api/v1/submissions/active`) and `StatusScreen` (`GET /api/v1/submissions/:id`) show live submission status across 4 stages (`pending`, `confirmed`, `picked_up`, `done`). However, `status_history[].changed_at` timestamps returned by the backend are not rendered on screen, and status progression is updated manually in Supabase for demo. |
| **Recap & History Filtering** | Done | `RiwayatScreen` fetches `GET /api/v1/recap` with client-side filter tabs (`Semua`, `Aktif`, `Selesai`) and aggregate stats. |
| **AI Micro Insight (Per Session)** | Done | `SummaryScreen` (`Lihat Dampakmu` CTA when `status === 'done'`) calls `POST /api/v1/insight/micro` backed by Gemini (`gemini-2.0-flash`) with permanent DB cache + template fallback if Gemini fails/times out. |
| **AI Macro Insight (Wawasan)** | Partial | `WawasanScreen` calls `GET /api/v1/users/stats` and `GET /api/v1/insight/macro?periode=weekly` (24h DB cache + template fallback). `periode` is hardcoded to `weekly`; no UI toggle exists for `monthly`. |
| **Profile View, Edit & Logout** | Done | `ProfileScreen` syncs `GET /api/v1/users/profile`, updates `nama`/`kota` via `PUT /api/v1/users/profile`, and clears local storage on logout. |

---

## 7. Tech Stack

Verified from `karsa-backend/package.json`, `karsa-backend/Dockerfile`, and `karsa-app/karsa/pubspec.yaml`:

### Mobile Frontend (`karsa-app/karsa`)
- **Framework:** Flutter (Dart SDK `^3.12.2`, Material 3)
- **State Management:** `flutter_riverpod` (`^2.4.0`)
- **Networking:** `dio` (`^5.11.1`)
- **Local Secure Storage:** `flutter_secure_storage` (`^9.0.0`)
- **Media & Assets:** `image_picker` (`^1.0.4`), `flutter_svg` (`^2.3.2`)
- **UI & Formatting:** `hugeicons` (`^1.2.0`), `gap` (`^3.0.1`), `intl` (`^0.18.0`), custom font `Satoshi`

### Backend & Cloud Services (`karsa-backend`)
- **Runtime & Framework:** Node.js 22 (`node:22-alpine` ESM) + `express` (`^5.3.0`)
- **Middleware & Utilities:** `cors` (`^2.8.6`), `dotenv` (`^18.0.10`), `multer` (`^2.5.0`, `memoryStorage`)
- **Database, Auth & Storage:** Supabase (`@supabase/supabase-js` `^2.119.0`) — Cloud PostgreSQL, Supabase Auth (JWT), Supabase Storage (`trash-photos` public bucket)
- **AI Service:** Google Gemini API via `@google/generative-ai` (`^0.24.1`), configured with `gemini-2.0-flash`
- **Containerization:** Docker & Docker Compose (`karsa-backend` on port `3000`)

---

## 8. Architecture Diagram

> **Security Boundary:** Flutter **never** communicates with Supabase or Gemini directly. All client requests pass through the Node.js/Express backend, which verifies the user's Supabase JWT and accesses Supabase using the server-side `SUPABASE_SERVICE_KEY`.

```text
+-------------------------------------------------------------------+
|                        Flutter Mobile App                         |
|                 (Riverpod · Dio · SecureStorage)                  |
+---------------------------------+---------------------------------+
                                  |
         HTTP REST (/api/v1/*)    |  Authorization: Bearer <JWT>
         Base URL auto-probed     |
                                  v
+-------------------------------------------------------------------+
|                   Docker Compose (Port 3000)                      |
|               karsa-backend (Node.js 22 + Express 5)              |
|                                                                   |
|  - /health                    - /api/v1/umkm      (authenticate)  |
|  - /api/v1/auth/*             - /api/v1/submissions (authenticate)|
|  - /api/v1/users/* (auth)     - /api/v1/recap     (authenticate)  |
|  - /api/v1/upload/photo (auth)- /api/v1/insight/* (authenticate)  |
+----------------+---------------------------------+----------------+
                 |                                 |
   Service Role  |                                 | Server-side
   Key (Cloud)   |                                 | API Key
                 v                                 v
+---------------------------------+   +-----------------------------+
|        Supabase (Cloud)         |   |    Google Gemini API        |
|  - Auth (getUser / signIn)      |   |  (@google/generative-ai)    |
|  - PostgreSQL (users, umkm,     |   |  Model: gemini-2.0-flash    |
|    submissions, status_history, |   |  (Micro & Macro Insights)   |
|    insights)                    |   +-----------------------------+
|  - Storage (bucket:             |
|    trash-photos [Public])       |
+---------------------------------+
```

### Core Action Request Path: Submission Creation
1. `InputScreen` (optional photo) → `POST /api/v1/upload/photo` → `authenticate` middleware → `uploadController.uploadPhoto` → `supabase.storage.from('trash-photos').upload(...)` → returns `{ foto_url }`.
2. `UmkmListScreen` → `GET /api/v1/umkm?tipe_sampah=...` → `authenticate` → `umkmController.getUmkm` → `supabase.from('umkm').select('*').contains('bahan_baku', [type])`.
3. Confirmation Dialog → `POST /api/v1/submissions` → `authenticate` → `submissionsController.createSubmission` → inserts row into `submissions` (`status: 'pending'`) + inserts initial row into `status_history` (`status: 'pending'`) → returns `201 Created`.

---

## 9. Data Flow

1. **Authentication:** User registers or logs in via `SignUpScreen` / `LoginScreen` (`POST /api/v1/auth/register` or `/login`). Backend uses `supabase.auth` via an isolated auth client, upserts a row in `public.users`, and returns `{ user, token }`. Flutter stores the JWT and user info in `StorageService` (`flutter_secure_storage` with in-memory cache fallback), and `DioClient` injects `Authorization: Bearer <token>` on subsequent requests.
2. **Home Aggregation:** `HomeScreen` invokes `homeProvider`, sending `GET /api/v1/users/stats` and `GET /api/v1/submissions/active` in parallel. Backend filters `submissions` by `req.user.id`, sums `berat_kg` of `done` records, calculates `co2_saved = +(total_kg * 1.5).toFixed(2)`, and returns the top active deliveries.
3. **Trash Grabbing & Upload:** `InputScreen` maintains form state in `inputProvider`. Picking an image compresses it (`imageQuality: 80, maxWidth: 1280`) and uploads multipart data to `POST /api/v1/upload/photo`. If photo upload fails, `foto_url` remains `null` and submission can still proceed.
4. **UMKM Matching & Submission:** `UmkmListScreen` passes selected `tipe_sampah` values as a comma-separated query to `GET /api/v1/umkm`. Backend queries `umkm.bahan_baku` per type and deduplicates by `id`. Upon confirmation, `POST /api/v1/submissions` persists the submission and initial `status_history` entry.
5. **Status Tracking:** `StatusScreen` calls `GET /api/v1/submissions/:id`. Backend verifies `user_id === req.user.id` and returns the submission joined with `umkm(*)` and `status_history[]`. When `status === 'done'`, the **"Lihat Dampakmu"** CTA unlocks.
6. **AI Insight & Recap:**
   - `SummaryScreen` calls `POST /api/v1/insight/micro` with `submission_id`. Backend returns cached insight from `insights` if present; otherwise it verifies `status === 'done'`, injects submission + UMKM context into a Gemini prompt, stores the result permanently in `insights`, and returns `{ insight }` (with deterministic template fallback on AI failure).
   - `RiwayatScreen` calls `GET /api/v1/recap`, while `WawasanScreen` calls `GET /api/v1/users/stats` and `GET /api/v1/insight/macro?periode=weekly` (cached 24 hours per user and period in `insights`).

---

## 10. Setup and Run

### Prerequisites
- **Docker** & **Docker Compose** (or **Node.js 22+** for local Node execution)
- **Flutter SDK** (Dart `^3.12.2`)
- **Android Emulator** or **Physical Android/iOS Device**
- **Supabase Project (Cloud)** and **Google AI Studio API Key**

### Step 1: Database & Storage (Supabase Cloud)
> **Note:** No `.sql` migration file is included in this repository. All tables (`users`, `umkm`, `submissions`, `status_history`, `insights`) must already be provisioned in your Supabase Cloud PostgreSQL project.

- **Storage Bucket:** Ensure a **Public** bucket named `trash-photos` exists in Supabase Storage so `uploadController.js` can upload photos and return public URLs.

### Step 2: Backend Setup
1. Create the environment file from `.env.example` (do **not** commit `.env`):
   ```bash
   cp karsa-backend/.env.example karsa-backend/.env
   ```
2. Open `karsa-backend/.env` and fill in your `GEMINI_API_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, and `PORT` (`3000`).
3. Start the backend container using Docker Compose from the monorepo root:
   ```bash
   docker compose up --build
   ```
   *(Or run directly without Docker: `cd karsa-backend && npm install && npm start`)*
4. **Seed UMKM data (MANDATORY for app to function — without this, "Cari UMKM" returns empty):**
   ```bash
   cd karsa-backend && node --env-file=.env scripts/seed-umkm.js
   ```

### Step 3: Frontend Setup (Local Run)
1. Install Flutter dependencies:
   ```bash
   cd karsa-app/karsa && flutter pub get
   ```
2. **IMPORTANT — Configure Backend Base URL for Your Machine:**  
   `localhost` and `10.0.2.2` only work on the host machine / Android Emulator. Although `DioClient` auto-probes `/health` across `emulatorBase`, `physicalBase`, `localhostBase`, and `loopbackBase`, judges running on a **physical device** over Wi-Fi MUST edit `karsa-app/karsa/lib/core/constants/api_urls.dart` and update `physicalBase` (or `baseUrl`) with their own machine's LAN IPv4 address:
   - **Android Emulator:** `http://10.0.2.2:3000/api/v1`
   - **Physical Device:** `http://<YOUR_LAN_IP>:3000/api/v1`
   - **Find your LAN IP:**
     - **Windows:** `ipconfig`
     - **macOS / Linux:** `ifconfig` (or `ip addr`)
3. Run the mobile app:
   ```bash
   flutter run
   ```

---

## 11. Environment Variables

Defined in `karsa-backend/.env.example` (variable names only — never commit real values):

| Variable | Description |
|---|---|
| `GEMINI_API_KEY` | Google AI Studio API key used by `@google/generative-ai` in `src/config/gemini.js`. |
| `SUPABASE_URL` | Base URL of your cloud Supabase project. |
| `SUPABASE_SERVICE_KEY` | Supabase `service_role` key used server-side in `src/config/supabase.js`. |
| `PORT` | Port where the Express server listens (default: `3000`). |

---

## 12. Demo Account

- **Email:** `testing1@karsa.com`
- **Password:** `kara@karsa123`

> **Note to Judge:** This account is pre-seeded with 1 `'pending'` and 1 `'done'` submission. Navigate to the `'Riwayat'` tab or `'Status'` screen to immediately test the AI Micro Insight feature without completing the full flow.

---

## 13. Video Demo Guide

- **Platform:** YouTube (**Unlisted** or **Public**, playable without login)
- **Duration:** Strictly **3:00 – 5:00 minutes**
- **Format:** Continuous screen recording of the **real running application** from the final submission commit. **No slides, no Figma prototypes, and no mockups.**
- **Required Sequence:**
  1. **App Identity & Auth:** Launch Splash screen → Onboarding / Login with demo account.
  2. **Core Distribution Flow:** Home → CTA *"Mulai Berkontribusi"* → Input trash details (+ photo) → Pick matched UMKM → Confirm submission.
  3. **Main Function Proof:** Track submission on **Status Distribusi** screen (`pending` → `confirmed` → `picked_up` → `done`).
  4. **AI Integration Demo:** Open a `done` submission → click **"Lihat Dampakmu"** → show the Gemini-generated personal insight on `SummaryScreen` (and aggregate `WawasanScreen` macro insight).

---

## 14. AI Usage Documentation

- **Provider & SDK:** Google Gemini API via `@google/generative-ai` (`^0.24.1`).
- **Model Configured in Code:** **`gemini-2.0-flash`** (`maxOutputTokens: 350`, `temperature: 0.8`) in `karsa-backend/src/config/gemini.js`.
- **Technique:** Runtime context injection (no RAG or vector database). Backend queries Supabase for user stats, waste types, weight, CO₂ estimate, and UMKM product info, then injects them into an Indonesian conversational prompt.
- **Features Using AI:**
  1. **Micro Insight (`POST /api/v1/insight/micro`):** Generates 2–3 celebratory sentences upon submission completion (`SummaryScreen`).
  2. **Macro Insight (`GET /api/v1/insight/macro`):** Generates 3–4 sentences summarizing cumulative user impact (`WawasanScreen` and banner in `RiwayatScreen`).
- **Features NOT Using AI:**
  - **UMKM Matching (`GET /api/v1/umkm`):** Pure PostgreSQL `.contains('bahan_baku', [type])` array query — not AI.
  - **Photo Upload (`POST /api/v1/upload/photo`):** Documentation storage only — no AI image classification.
  - **CO₂, Tree Equivalent & MSME Income Estimates:** Deterministic arithmetic formulas.
- **UI Labeling:** Both AI output containers explicitly disclose AI generation in the UI:
  - `SummaryScreen`: `'Catatan Dampakmu (Dihasilkan oleh AI)'`
  - `WawasanScreen`: `'Catatan Kontribusi (Dihasilkan oleh AI)'`
- **Limitations & Rate-Limit Note:**  
  *We use the free tier. If a timeout occurs on AI Insight, it is due to API rate limits, not a code bug. Please retry.*  
  *(If Gemini fails or times out, `insightController.js` and `SummaryNotifier` fall back to a deterministic template message constructed from the user's real submission/stats data so the UI stays responsive.)*

---

## 15. Attribution

### Backend Dependencies (`karsa-backend/package.json`)
- `express` (`^5.3.0`) — Web framework
- `@supabase/supabase-js` (`^2.119.0`) — Supabase client (Auth, PostgreSQL, Storage)
- `@google/generative-ai` (`^0.24.1`) — Google Gemini API Node.js SDK
- `multer` (`^2.5.0`) — Multipart form-data file upload middleware
- `cors` (`^2.8.6`) — Cross-Origin Resource Sharing middleware
- `dotenv` (`^18.0.10`) — Environment variable loader

### Frontend Dependencies (`karsa-app/karsa/pubspec.yaml`)
- `flutter` / Dart SDK (`^3.12.2`) — Mobile UI toolkit
- `flutter_riverpod` (`^2.4.0`) — State management
- `dio` (`^5.11.1`) — HTTP client & interceptors
- `flutter_secure_storage` (`^9.0.0`) — Encrypted token/credential storage
- `image_picker` (`^1.0.4`) — Camera & gallery selection
- `flutter_svg` (`^2.3.2`) — SVG rendering
- `hugeicons` (`^1.2.0`) — Stroke icon pack (`HugeIcons`)
- `gap` (`^3.0.1`) — Layout spacing helper
- `intl` (`^0.18.0`) — Formatting utilities
- `flutter_lints` (`^6.0.0`) — Dart static lint rules

### Bundled Fonts, Icons & Visual Assets (`karsa-app/karsa/assets/`)
- **Typography:** `Satoshi` (`Satoshi-Regular.otf`, `Satoshi-Medium.otf`, `Satoshi-Light.otf`, `Satoshi-Bold.otf`, `Satoshi-Black.otf` and italic variants in `assets/fonts/Satoshi/`) — `ITF Free Font License`
- **Illustrations & App Graphics (`assets/images/components/`):** `o_b_1.png`, `o_b_2.png`, `karsa_icon.png`, `karsa_icon.svg`, `feature_button.svg`, `feature_button.png`, `overlay_cta_button.svg`, `overlay_summary_screen.svg` — created/exported by Karsa team (`Asli Buatan Tim Design`).
- **Icons (`assets/icons/`):** `dev-apple.svg`, `dev-google.svg` (unused in active UI; bundled in assets).

---

## 16. Sustainability and Efficiency (Green IT)

Only measures directly verified in the codebase:
1. **AI Response Caching (`karsa-backend/src/controllers/insightController.js`):**
   - **Micro Insights** are stored in the `insights` table and cached permanently per `submission_id`, avoiding repeated LLM calls when a user revisits a completed summary.
   - **Macro Insights** are cached for **24 hours** per `user_id` and `periode` before invoking Gemini again.
2. **Client-Side Image Compression (`karsa-app/karsa/lib/core/providers/input_provider.dart`):**
   - Uploaded trash photos are resized and compressed on-device (`imageQuality: 80`, `maxWidth: 1280`) before multipart transfer to reduce mobile bandwidth and Supabase storage footprint.
3. **Lightweight Local Estimation:**
   - CO₂ savings (`berat_kg × 1.5`) and tree equivalents (`co2Saved / 21.0`) are computed with simple arithmetic without extra server or LLM requests.

---

## 17. Privacy and Security

- **Authentication & Authorization (`src/middleware/auth.js`):** All API endpoints except `/health` and `/api/v1/auth/*` require `Authorization: Bearer <token>`, verified server-side via `supabase.auth.getUser(token)`.
- **Per-User Data Isolation:** All database reads/writes for profiles, stats, submissions, recaps, and insights filter explicitly by `req.user.id` in the controllers.
- **Isolated Supabase Clients (`src/config/supabase.js`):** `createAuthClient()` isolates `signInWithPassword` calls so a user JWT never overwrites the stateless `service_role` client header.
- **Credential Hygiene:** `.env` is ignored via `.gitignore` and `.dockerignore`; `karsa-backend/.env.example` provides variable keys without secret values.
- **Local Token Storage:** Flutter stores auth tokens via `FlutterSecureStorage` (`AndroidOptions(encryptedSharedPreferences: true)`), clearing all local storage upon logout or HTTP `401` responses.
- **Known Security & Privacy Gaps (Plainly Stated):**
  1. **Backend Bypasses RLS:** Because the backend uses `SUPABASE_SERVICE_KEY` (service role), it bypasses PostgreSQL Row-Level Security (RLS). Supabase RLS policies on cloud tables cannot be verified from this repository alone.
  2. **Public Photo Bucket:** `uploadController.js` stores waste photos in the **public** `trash-photos` Supabase Storage bucket (`getPublicUrl`).
  3. **Cleartext HTTP for Local Dev:** `AndroidManifest.xml` sets `android:usesCleartextTraffic="true"` so the mobile app can reach local HTTP dev servers (`10.0.2.2:3000` / LAN IP). Production deployments must enforce HTTPS.

---

## 18. Known Limitations and Deviations

1. **Manual Status Progression:** There is no UMKM login or dashboard in this MVP; submission status transitions (`pending` → `confirmed` → `picked_up` → `done`) are updated manually in Supabase for demo purposes.
2. **CO₂ Estimation Factor:** `co2_saved` uses a rough static multiplier (`berat_kg × 1.5`), and `WawasanScreen` derives tree equivalents via `co2Saved / 21.0`. Both are estimates only — factor citation: `[ISI: sumber]`.
3. **Code vs. PRD/SPEC Deviations:**
   - **Gemini Model:** Backend code (`src/config/gemini.js`) uses `gemini-2.0-flash`, whereas PRD/SPEC specify `Gemini 1.5 Flash`.
   - **Onboarding Screen:** `OnboardingScreen` exists in `lib/` (`PUT /users/profile`), but `SignUpScreen` already collects `nama` and `kota` and navigates directly to `MainShell`.
   - **Status Timestamps:** `GET /submissions/:id` returns `status_history[]` timestamps, but `StatusScreen` renders static step copy without displaying timestamps.
   - **Wawasan Period & Extra Estimates:** `WawasanScreen` hardcodes `periode=weekly` (no UI switcher for `monthly`). `SummaryScreen` additionally displays a client-side estimated MSME income (`beratKg * 10000`) and `WawasanScreen` shows tree equivalents (`co2Saved / 21.0`), neither of which comes from the backend API.
   - **AI Fallback Labeling:** When Gemini fails or times out, backend `insightController.js` and frontend `SummaryNotifier` return a deterministic template string while keeping the `(Dihasilkan oleh AI)` UI header.
   - **UMKM Seed Coverage:** `scripts/seed-umkm.js` seeds 10 MSMEs across `plastik`, `kayu`, `kain`, `kertas`, and `logam`, with `gambar_url: null` and no MSME mapped to `lainnya`.
   - **Forgot Password:** `LoginScreen` includes a disabled `"Lupa Password?"` button (`onPressed: null`).
   - **Database Schema Files:** No `.sql` migration file is committed in the repository; schema lives in Supabase Cloud.
   - **Unused Design Tokens & Assets:** `app_colors.dart` contains `TODO` comments for unused `600`/`800` shades and `secondary500`; `assets/icons/dev-apple.svg` and `dev-google.svg` are bundled without social login UI.
4. **Commit Timeline Note:** All 32 commits in Git history were committed on `2026-11-14` (within Hacking Week: 7–14 November 2026, prior to the 23:59 WIB code freeze) using Conventional Commits prefixes (`chore:`, `feat:`, `fix:`, `perf:`, `docs:`).

---

## 19. Future Work

- **UMKM Partner Portal:** Separate UMKM authentication and dashboard to view, accept, and update incoming pickup requests in-app.
- **Automated Logistics & Maps:** Map pin picker for pickup locations and real-time courier status notifications.
- **Period Selector & Verified Impact Metrics:** Weekly/monthly toggle in `WawasanScreen`, timestamp rendering in `StatusScreen`, and peer-reviewed CO₂ conversion factors per waste material.
- **AI Photo Classification & HTTPS:** Optional material pre-classification from waste photos and TLS/HTTPS enforcement with private signed storage URLs.

---