# 🌾 Farmer's Connect

**Complete Agriculture Assistant App for Indian Farmers**

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Features

### 🌟 Core Features
- ✅ **Disease Detection** - AI-powered crop disease identification
- ✅ **Weather Forecast** - Real-time weather with farming advice
- ✅ **Crop Guide** - Detailed cultivation guides for 20+ crops
- ✅ **Community Forum** - Connect with fellow farmers
- ✅ **Agriculture News** - Latest farming news and updates

### 💰 Marketplace
- ✅ **Marketplace** - Buy & sell farm produce
- ✅ **Equipment Rental** - Rent farming equipment
- ✅ **Mandi Prices** - Live market prices

### 🛠️ Tools & Resources
- ✅ **Farm Calculator** - Calculate yield & profit
- ✅ **Government Schemes** - Agricultural schemes & subsidies
- ✅ **Knowledge Base** - Farming tips & best practices

### 🔐 User Management
- ✅ **Email/Password Authentication**
- ✅ **Google Sign-In**
- ✅ **Admin & User Roles**
- ✅ **User Profiles**

## 🚀 Tech Stack

- **Frontend:** Flutter 3.0+
- **Backend:** Firebase (Auth, Firestore, Storage)
- **APIs:** NewsAPI, OpenWeather, Plant.id
- **State Management:** Provider
- **Design:** Material Design 3

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- Firebase Account
- Android Studio / VS Code

### Setup

1. Clone the repository

git clone https://github.com/NavjotBhullar/kisanseva_modern.git
cd farmers-connect-app

2.Install dependencies

flutter pub get

3.Configure Firebase

flutterfire configure

4.Add API Keys (create lib/config/api_keys.dart)

class ApiKeys {
  static const String newsApi = 'YOUR_NEWS_API_KEY';
  static const String weatherApi = 'YOUR_WEATHER_API_KEY';
}

5.Run the app

flutter run

6.📸 Screenshots
[Add screenshots here]

7.🗂️ Project Structure

lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # API & Firebase services
├── widgets/         # Reusable widgets
└── main.dart        # App entry point

8.🔑 Features in Detail

Disease Detection
Offline disease database
5 common crop diseases
Treatment recommendations
Prevention tips
Organic remedies
Community
Create posts with images
Like & comment system
Category filtering
Real-time updates
Mandi Prices
Live market prices
Multiple crops
State-wise filtering
Historical data

🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

📄 License
This project is licensed under the MIT License.


GitHub: @NavjotBhullar
Email: navjotbhullar008@gmail.com

🙏 Acknowledgments
Firebase for backend services
NewsAPI for agriculture news
Flutter community
Made with ❤️ for Indian Farmers
