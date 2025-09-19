
# Sneaker Shop App

## 📖 Overview
Sneaker Shop là một ứng dụng **Fullstack** bao gồm:
- **Frontend:** Flutter (Android/iOS/Web)
- **Backend:** Node.js + Express + Prisma + PostgreSQL
- **Database:** PostgreSQL

Ứng dụng hỗ trợ:
- 🛒 Quản lý sản phẩm (CRUD)
- 👤 Đăng nhập / Đăng ký / Phân quyền (User, Staff, Admin)
- 📦 Quản lý đơn hàng, xác nhận thanh toán
- 🖼️ Upload ảnh sản phẩm
- 📱 Giao diện hiện đại, responsive

---

## 📂 Project Structure

```
sneaker-shop/
│── backend/                     # Node.js + Prisma backend
│   │── src/
│   │   ├── routes/               # API routes (auth, products, orders...)
│   │   ├── middlewares/          # Auth, error handling
│   │   ├── controllers/          # Controllers xử lý logic
│   │   ├── prisma/               # Prisma schema & migrations
│   │   └── index.ts              # Server khởi động chính
│   │── package.json
│   │── .env.example
│   └── README.md (tùy chọn)
│
│── frontend/                     # Flutter app
│   │── lib/
│   │   ├── features/             # Mỗi tính năng: auth, products, orders...
│   │   ├── widgets/              # Widgets tái sử dụng
│   │   ├── models/               # Models cho dữ liệu (Product, Order...)
│   │   ├── core/                 # Api config, constants
│   │   └── main.dart             # Entry point Flutter
│   │── pubspec.yaml
│   └── README.md (tùy chọn)
│
│── README.md                     # File mô tả chính (file này)
```

---

## 🚀 Installation & Setup

### 1️⃣ Backend (Node.js + Prisma)
```bash
cd backend
npm install
npx prisma migrate dev
npm run dev
```

Tạo file `.env`:
```
DATABASE_URL="postgresql://user:password@localhost:5432/sneaker_shop"
PORT=8080
JWT_SECRET=your_jwt_secret
```

---

### 2️⃣ Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

Cấu hình **API URL** trong `lib/core/config.dart`:
```dart
class AppConfig {
  static const baseUrl = "http://10.0.2.2:8080";
}
```

---

## 🛠️ Features

- [x] Đăng nhập / Đăng ký với JWT
- [x] Quản lý sản phẩm (CRUD)
- [x] Quản lý đơn hàng (Admin / Staff)
- [x] Upload ảnh sản phẩm
- [x] Giao diện Flutter hiện đại (Grid, Filter, Search)
- [x] Role-based UI (User / Admin / Staff)


