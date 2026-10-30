# Product Requirements Document — AI Skin Disease Detection & Nearby Care App

**Product Name:** SkinCare AI
**Version:** 1.0
**Platform:** Mobile application
**Primary Users:** General users seeking preliminary skin-condition information and nearby healthcare providers
**Status:** MVP → Future expansion

## 1. Product Overview

SkinCare AI is a mobile application that allows users to:

1. Create and manage a personal profile.
2. Upload or capture a photo of a skin concern.
3. Receive an **AI-generated preliminary classification** of the image.
4. View educational information related to the result.
5. Save and review previous analyses.
6. Find nearby dermatologists and hospitals using a map.
7. View provider information and obtain directions.
8. Manage privacy, notifications, and account settings.

The application **must not represent the AI result as a definitive medical diagnosis**. It should clearly communicate that users should consult a qualified healthcare professional for diagnosis and treatment.

---

# 2. Goals

### Primary goals

- Make skin-image analysis simple and accessible.
- Provide understandable AI-generated results.
- Help users move from an AI result to appropriate professional care.
- Make nearby dermatologists and hospitals easy to discover.
- Provide a clean, trustworthy healthcare-oriented interface.
- Protect user images and personal information.

### Success criteria

For an MVP:

- User can register and log in.
- User can upload/capture an image.
- Image can be sent to the AI model.
- User receives a result.
- User can view previous analyses.
- User can manage their profile.
- User can find nearby healthcare providers.
- User can open directions to a selected provider.

---

# 3. Target Users

### User A — General user

Wants to understand whether a skin problem may require professional attention.

### User B — Health-conscious user

Wants to monitor changes in a recurring skin concern over time.

### User C — User looking for care

Has received an AI result and wants to find a nearby dermatologist or hospital.

---

# 4. Core User Journey

```
Sign Up / Login
       ↓
    Dashboard
       ↓
  Skin Analysis
       ↓
Take Photo / Upload Image
       ↓
 Image Quality Check
       ↓
    AI Analysis
       ↓
    Result Page
       ↓
Educational Information
       ↓
Find Nearby Care
       ↓
Doctor / Hospital
       ↓
Map & Directions

```

---

# 5. Application Navigation

Recommended bottom navigation:

```
┌─────────────────────────────────────────────┐
│                                             │
│              Application                    │
│                                             │
├─────────────────────────────────────────────┤
│  🏠 Home │ 🔬 Analyze │ 📍 Nearby │ 👤 Me │
└─────────────────────────────────────────────┘

```

Additional screens such as History and Settings can be accessed from **Profile** or the Dashboard.

---

# 6. Functional Requirements

## 6.1 Authentication

### Features

- Sign up
- Login
- Logout
- Forgot password
- Reset password
- Email verification
- Optional Google authentication
- Session management

### Requirements

**AUTH-001:** User must be able to create an account.

**AUTH-002:** User must be able to securely log in.

**AUTH-003:** User must be able to reset a forgotten password.

**AUTH-004:** User must be able to log out from all relevant sessions.

---

# 7. Dashboard

The dashboard is the application's primary landing page after login.

### Components

- User greeting
- Profile image
- Analyze Skin CTA
- Recent analysis
- Nearby care shortcut
- Analysis history shortcut
- Educational content
- Notifications

Example:

```
Good morning, Alex 👋

How can we help today?

┌─────────────────────────────┐
│       🔬 Skin Analysis      │
│                             │
│ Upload a photo to begin     │
│                             │
│       [ Analyze Now ]       │
└─────────────────────────────┘

Recent Analysis
────────────────────
Acne
12 Aug 2026
87% confidence

[ View Result ]

📍 Find Care Nearby
Find dermatologists and hospitals
near your location.

```

---

# 8. Skin Analysis Module

This is the core feature.

## 8.1 Image Input

Users can:

- Take a photograph.
- Select an image from their device.
- Preview the image.
- Retake/select another image.
- Submit the image for analysis.

### Image guidance

The app should tell users:

- Use good lighting.
- Keep the affected area visible.
- Avoid excessive blur.
- Avoid filters.
- Don't upload unrelated images.

---

## 8.2 Image Validation

Before sending the image to the AI model:

```
Image
  ↓
Format validation
  ↓
