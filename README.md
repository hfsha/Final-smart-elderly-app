# 🏠 SmartElder - Smart Elderly Activity & Safety Monitor

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.5.4-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.4-blue?style=for-the-badge&logo=dart)
![ESP32](https://img.shields.io/badge/ESP32-WiFi%20IoT-orange?style=for-the-badge&logo=arduino)
![PHP](https://img.shields.io/badge/PHP-API%20Backend-purple?style=for-the-badge&logo=php)
![MySQL](https://img.shields.io/badge/MySQL-Database-blue?style=for-the-badge&logo=mysql)

**A comprehensive IoT solution for real-time elderly monitoring and safety alerts**

[📱 Features](#-features) • [🛠️ Tech Stack](#️-tech-stack) • [🏗️ Architecture](#️-architecture) • [📋 Setup](#-setup) • [🎥 Demo](#-demo)

</div>

---

## 🎯 Project Overview

**SmartElder** is an innovative IoT-based monitoring system designed to enhance the safety and well-being of elderly individuals living alone. The system combines hardware sensors with a modern Flutter mobile application to provide real-time monitoring, instant alerts, and comprehensive data analytics.

### 🚨 Problem Statement
Elderly individuals, particularly those living alone, face significant risks from:
- **Delayed emergency response** due to unnoticed falls
- **Fire hazards** that can escalate quickly
- **Health-related inactivity** that goes undetected
- **Environmental hazards** from extreme temperature conditions

### 🎯 Solution Objectives
- ✅ **Real-time fall detection** using vibration sensors
- ✅ **Fire hazard monitoring** with flame sensors  
- ✅ **Activity tracking** via PIR motion sensors
- ✅ **Environmental monitoring** with temperature/humidity sensors
- ✅ **Instant alert system** with mobile notifications
- ✅ **Remote monitoring dashboard** for caregivers
- ✅ **Automated relay control** for emergency responses

---

## 🚀 Features

### 📱 Mobile Application
- **🔐 Secure Authentication** - User registration and login system
- **📊 Real-time Dashboard** - Live sensor data visualization
- **🚨 Emergency Alerts** - Instant notifications for falls and fires
- **📈 Data Analytics** - Historical trends and patterns
- **⚙️ Device Control** - Remote relay management
- **📋 Activity Logs** - Comprehensive event tracking
- **🎨 Modern UI/UX** - Beautiful, intuitive interface

### 🔧 Hardware Components
- **ESP32 Microcontroller** - WiFi-enabled IoT hub
- **PIR Motion Sensor** - Human activity detection
- **Vibration Sensor** - Fall and impact detection
- **Flame Sensor** - Fire hazard detection
- **DHT11 Sensor** - Temperature & humidity monitoring
- **OLED Display** - Local status indicators
- **Relay Module** - Automated emergency responses

### 🌐 Backend Services
- **RESTful API** - PHP-based backend services
- **MySQL Database** - Reliable data storage
- **Real-time Processing** - Instant alert generation
- **Device Management** - Multi-device support

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
```yaml
Framework: Flutter 3.5.4
Language: Dart
State Management: Provider
UI Components: Material Design 3
Charts: fl_chart, Syncfusion Gauges
Animations: flutter_animate
Icons: Font Awesome, Material Icons
```

### Backend (API Services)
```yaml
Language: PHP
Database: MySQL
Architecture: RESTful API
Authentication: JWT-based
Hosting: Web Server
```

### Hardware (IoT System)
```yaml
Microcontroller: ESP32
Sensors: PIR, Vibration, Flame, DHT11
Display: OLED I2C
Connectivity: WiFi
Power: 3.3V/5V DC
```


## 📋 Hardware Setup

### 🔌 Wiring Configuration

| Sensor | ESP32 Pin | Sensor Pin  
|--------|-----------|--------------|
| **Flame** | VCC | 5V | 
| | GND | GND |
| | DO | GPIO34 | 
| **Vibration** | VCC | 3.3V | 
| | GND | GND | 
| | DO | GPIO33 | 
| **PIR** | VCC | 3.3V | 
| | GND | GND | 
| | OUTPUT | GPIO32 | 
| **DHT11** | VCC | 3.3V |
| | GND | GND | 
| | Data | GPIO4 | 
| **OLED** | VCC | 3.3V | 
| | GND | GND |
| | SDA | GPIO21 | 
| | SCK | GPIO22 |
| **Relay** | VCC | 3.3V |
| | GND | GND |
| | IN | GPIO25 |

### 📐 Schematic Diagram
**Interactive Circuit Design:** [View Full Schematic](https://app.cirkitdesigner.com/project/8e6cde29-f9d2-4ec3-9092-87674ec125f1)

---

## 🚀 Getting Started

### 📱 Mobile App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/hfsha/Final-smart-elderly-app.git
   cd smart_elderly_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   - Update `lib/api/endpoints.dart` with your backend URL
   - Ensure database connection is properly configured

4. **Run the application**
   ```bash
   flutter run
   ```

### 🔧 Hardware Setup

![Image](https://github.com/user-attachments/assets/dea092d7-6387-419c-a02f-501738b71833)

1. **Upload Arduino Code**
   - Download the ESP32 code from: [Arduino Code](https://github.com/hfsha/Final-smart-elderly-app/blob/main/Arduino/smart-elderly-app.ino)
   - Configure WiFi credentials in the code
   - Upload to ESP32 using Arduino IDE

2. **Connect Sensors**
   - Follow the wiring diagram above
   - Ensure proper power supply (3.3V/5V)
   - Test each sensor individually

3. **Configure Backend**
   - Set up PHP server with MySQL database
   - Import database schema
   - Configure API endpoints


## 📱 App Screenshots

### 🔐 Authentication
![Image](https://github.com/user-attachments/assets/8c715479-75f3-40fa-8969-3cf4f707e5fb)

### 📊 Dashboard Overview
![Image](https://github.com/user-attachments/assets/b298f646-7fd6-46dc-bf92-208bc2bb2c17)
![Image](https://github.com/user-attachments/assets/7be19e3f-1e1a-4c00-9d50-4a19fb272d82)
---

## 🎥 Demo & Documentation

### 📺 YouTube Demo
**[Watch Full Demo Video](https://www.youtube.com/watch?v=CtgSwQ1ow0o)**


## 👨‍💻 Development Team

| Role | Name | 
|------|------|
| **Developer** | Shahidatul Hidayah binti Ahmad Faizal |

---

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and enhancement requests.


<div align="center">

**Made with ❤️ for elderly care and safety**

[⬆️ Back to Top](#-smartelder---smart-elderly-activity--safety-monitor)

</div>
