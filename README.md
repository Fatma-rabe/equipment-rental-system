# ⛏️ Equipment Rental System - Flutter Web

A full-featured equipment rental management system built with **Flutter Web** and **Firebase**. Designed for mining and construction companies to efficiently handle equipment rentals, warehouse items, maintenance, workers, chat, and financial reports.

## 📦 Features

### 👤 Role-based Access
- **Admin** and **User** login
- Firebase Auth integrated
- Secure access with Firebase Security Rules

### 🚜 Equipment Rental
- View available equipment
- Rent by **hour** or **meter**
- Real-time total cost calculation
- Admin approval workflow

### 🏪 Warehouse Management
- Admin: Add/Edit/Delete warehouse items
- Users: Request items with quantity & auto pricing
- Admin: Approve/Reject requests

### 🧑‍🔧 Workers Management
- Admin: Manage workers list
- Users: Request workers and calculate total cost

### 🛠️ Maintenance Requests
- Users can report issues
- Admin can approve or reject requests

### 💬 Realtime Chat System
- Built-in chat between users and admin
- Image sending support

### 📊 Financial Reports
- Admin dashboard for daily & monthly totals
- Covers: Equipment, Warehouse, Maintenance, Workers
- Export as PDF

---

## 🛠️ Tech Stack

- **Flutter Web** (Frontend)
- **Firebase**
  - Firestore (Database)
  - Firebase Auth (Authentication)
  - Firebase Hosting (Deployment)
- **PDF & Printing Packages** (for reports)

---

🔐 Firebase Setup

Authentication: Email/Password enabled

Firestore Rules:

Admin can read/write all
Users can only access their own data

Demo Video
https://www.loom.com/share/88033fcf7d364f5b844adf4e2fce04b8?sid=ba2ed097-c9e4-449a-8f3f-940b49bf4f9b
---

📌 Notes

Developed as a complete admin-user system
Designed for real-world deployment
Easily extendable for mobile (Flutter cross-platform)



---
