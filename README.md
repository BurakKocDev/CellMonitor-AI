<div align="center">

# CellMonitor AI

### Sentetik biyoreaktör sensör verileriyle çalışan yapay zekâ destekli izleme ve kontrol simülasyonu

Türkçe · [English](README.en.md)

![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B?logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi&logoColor=white)
![XGBoost](https://img.shields.io/badge/XGBoost-Current%20Prediction-FF6600)
![TensorFlow](https://img.shields.io/badge/TensorFlow-LSTM-FF6F00?logo=tensorflow&logoColor=white)

</div>

---

## Proje Özeti

CellMonitor AI, biyoreaktör hücre kültürü süreçlerini temsil eden **sentetik sensör verilerini** izleyen ve iki farklı yapay zekâ modeliyle hücre canlılığı tahmini üreten bir mobil kontrol paneli prototipidir.

Proje gerçek bir endüstriyel biyoreaktöre bağlı değildir. Amaç; yapay zekâ modellerinin, REST API'nin, mobil görselleştirmenin ve kontrol senaryolarının tek bir uçtan uca prototipte nasıl birleştirilebileceğini göstermektir.

---

## Temel Özellikler

- Dört reaktörü aynı anda gösteren filo paneli
- pH, sıcaklık, çözünmüş oksijen, glikoz, laktat ve karıştırma hızı simülasyonu
- XGBoost ile anlık canlılık tahmini
- LSTM ile zaman serisi tabanlı ileriye dönük tahmin
- Reaktör detay ekranı ve canlı grafikler
- Manuel müdahale senaryoları
- Otonom kontrol davranışını temsil eden Auto-Pilot simülasyonu
- Flutter Provider tabanlı durum yönetimi
- FastAPI üzerinden tahmin endpoint'leri

---

## Uygulama Görünümü

<div align="center">

<img src="https://github.com/user-attachments/assets/fcd31c69-ee1e-451b-afb0-38f250edc3f0" width="360" alt="CellMonitor AI dashboard">

<img src="https://github.com/user-attachments/assets/e52713c7-f098-4378-a9e9-2f96255f34e4" width="360" alt="CellMonitor AI reactor detail">

</div>

---

## Mimari

```mermaid
flowchart LR
    A[Flutter Mobil Uygulama] --> B[Simüle Sensör Verileri]
    B --> C[FastAPI Backend]
    C --> D[XGBoost]
    C --> E[LSTM]
    D --> F[Anlık Canlılık Tahmini]
    E --> G[İleriye Dönük Tahmin]
    F --> H[Dashboard ve Müdahale Paneli]
    G --> H
```

---

## Teknoloji Yığını

### Mobil Uygulama

- Flutter
- Dart
- Provider
- HTTP
- Canlı grafik ve dashboard bileşenleri

### Backend ve Yapay Zekâ

- Python
- FastAPI
- XGBoost
- TensorFlow / Keras
- LSTM
- Pandas
- NumPy
- scikit-learn
- joblib

---

## API Endpoint'leri

```text
POST /predict_current
POST /predict_forecast
```

- `/predict_current`: Sensör değerlerinden anlık canlılık tahmini üretir.
- `/predict_forecast`: Kısa zaman serisi geçmişinden ileriye dönük canlılık tahmini üretir.

---

## Çalıştırma

### Backend

```bash
cd backend
pip install -r requirements.txt
python -m uvicorn main:app --reload
```

### Flutter

```bash
cd mobile_app/cellmonitor
flutter pub get
flutter run
```

Android emülatörü için API adresi:

```text
http://10.0.2.2:8000
```

---

## Simülasyon Senaryoları

- **Normal çalışma:** Stabil sensör değerleri ve yüksek canlılık
- **Uyarı durumu:** pH, sıcaklık veya oksijen değerlerinde bozulma
- **Kritik durum:** Düşük canlılık tahmini ve müdahale gereksinimi
- **Manuel müdahale:** Glikoz ekleme, laktat temizleme veya oksijen artırma
- **Auto-Pilot simülasyonu:** Belirlenen eşiklerde otomatik iyileştirme davranışı

---

## Sınırlılıklar

- Sensör verileri sentetiktir.
- Proje gerçek bir biyoreaktör, valf veya endüstriyel IoT sistemiyle entegre değildir.
- Auto-Pilot bölümü fiziksel müdahale değil, uygulama içi kontrol simülasyonudur.
- Model çıktıları laboratuvar veya üretim ortamında doğrulanmamıştır.
- Proje eğitim, prototipleme ve portföy amacıyla geliştirilmiştir.

---

## Amaç

CellMonitor AI; veri simülasyonu, makine öğrenmesi, zaman serisi tahmini, REST API ve mobil dashboard geliştirme becerilerini tek bir projede birleştiren uçtan uca bir yapay zekâ prototipidir.
