# 🎤 TrustCircle: Comprehensive Hackathon Presentation Guide

This guide structures your pitch to walk the judges through the **entire app architecture**, demonstrating every feature from onboarding to conflict resolution. 

---

## 1. The Hook & The Problem (1 Minute)

**Script Idea:**
> *"Hi everyone, my name is Avishkar, and I’m the solo developer behind **TrustCircle**. Today, we are more digitally connected than ever, yet we suffer from unprecedented loneliness and relationship decay. We forget to check in on our parents, we let unresolved conflicts with friends fester, and we lose touch with the people who matter most."*

> *"Our phones are designed for endless consumption. I built TrustCircle to change that. TrustCircle is a proactive, AI-powered relationship manager that monitors the health of your closest circles, detects when you're drifting apart, and provides actionable AI conflict resolution."*

---

## 2. Walkthrough & Circle Management (1 Minute)

**Action: Open the app to the initial launch screen.**

**Script Idea:**
> *"When a user first opens TrustCircle, they are greeted by a beautiful 5-page onboarding walkthrough that explains our core philosophy: Consistency builds trust."*

**Action: Log in and show the Home Dashboard.**
> *"Everything is securely authenticated via Firebase. Once inside, you see the Dashboard. Users can create or join private **Circles**—like a 'Family' group or a 'Best Friends' group. The Dashboard aggregates everyone's emotional data to calculate a live **Trust Score** for the entire circle, giving you a bird's-eye view of your relationship health."*

---

## 3. The Core Loop: Voice Check-In & Hybrid AI (1.5 Minutes)

**Action: Tap into a Circle and click "Check In". Turn ON the "Use On-Device AI" toggle and turn ON Airplane Mode.**

**Script Idea:**
> *"The core engine of TrustCircle is the Daily Trust Pulse. But filling out surveys is boring, so I integrated **Voice Check-ins**. You simply tap the mic and talk."*

> *"Now, emotional data is highly sensitive. To ensure absolute privacy, I built a **Hybrid AI Architecture** using Zetic MLange. Notice I am currently offline in Airplane Mode, and I've toggled On-Device AI on."*

**Action: Tap the Mic and say:** *"I am feeling very happy today and very respected as well. I feel safe and connected."*

> *"Even offline, the app routes my voice transcript locally to a TinyLlama model running natively on the device's hardware. It parses my exact emotions and automatically adjusts the Trust, Respect, and Safety sliders for me. When I hit submit, Firestore caches the pulse locally and automatically syncs it to the cloud the moment I reconnect."*

---

## 4. Proactive Alerts: Nudges, Silence & Gratitude (1 Minute)

**Action: Turn off Airplane Mode. Show the Notifications tab or mention the background system.**

**Script Idea:**
> *"TrustCircle isn’t just a passive tracker; it's an active guardian of your relationships. It includes a smart notification system with **Hourly Nudges**—if you forget to check in, it gently reminds you every hour until you do, automatically canceling the moment your pulse is submitted."*

> *"It also features a **Silence Detector**. If someone in your Family Circle hasn't logged a pulse in over 3 days, the app triggers a high-priority, WhatsApp-style push notification urging the rest of the circle to reach out to them. If it detects that *you* are the one who has gone silent, the UI dynamically changes the copy to say: 'You — 4 days silent. Your family is waiting to hear from you.' We also have a dedicated **Gratitude Tracker** to encourage users to log positive moments, further boosting the Circle's overall Trust Score."*

---

## 5. The Climax: Resolve Mode (1 Minute)

**Action: Show a Circle where the Trust Score is below 50% to trigger Resolve Mode.**

**Script Idea:**
> *"Finally, what happens when things go wrong? If a Circle’s overall Trust Score drops below 50%, the app automatically triggers **Resolve Mode**."*

> *"Resolve Mode pulls the specific metrics dragging the score down—for example, if 'Safety' and 'Respect' are low—and feeds that context into the Gemini Cloud API. Gemini then generates a beautifully formatted, highly personalized **Conflict Resolution Guide**. It acts as an AI mediator, giving the circle step-by-step, actionable advice on how to communicate, de-escalate, and repair the relationship."*

---

## 6. Conclusion (30 Seconds)

**Script Idea:**
> *"To summarize: TrustCircle uses Firebase for real-time syncing, Gemini for deep conflict mediation, and Zetic Local AI for absolute offline privacy. It transforms your phone from a distraction device into a tool that actively repairs and strengthens your most valuable relationships. Thank you!"*

---

## 📝 Demo Checklist Before You Go On Stage
- [ ] **Device Setup:** Connect your phone to a screen mirroring software (Vysor / Scrcpy) so the judges can see.
- [ ] **Data Prep:** Ensure you have multiple users in a Circle to show the Dashboard graph properly.
- [ ] **Resolve Mode Prep:** Ensure you have at least one Circle deliberately pushed below a 50% trust score to quickly show the Resolve Mode UI and the Gemini-generated Markdown guide.
- [ ] **Offline Prep:** Practice the Airplane Mode transition smoothly so there is no awkward silence while the Wi-Fi disconnects.
