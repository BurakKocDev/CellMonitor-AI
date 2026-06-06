🔬 CellMonitor AI: Predictive Bioreactor Platform

Endüstri 4.0 standartlarında, biyoreaktör hücre kültürlerini gerçek zamanlı izleyen ve Hibrit Yapay Zeka (XGBoost + LSTM) ile hücre canlılığını geleceğe dönük tahmin eden IoT platformu simülasyonu.


(Buraya projeni çalıştırdığında aldığın yan yana veya alt alta güzel bir ekran görüntüsünü ekleyebilirsin)

🚀 Proje Vizyonu

Bu proje, sensör verilerindeki anlık gürültüleri filtreleyerek "Şu an ne oluyor?" sorusunu XGBoost ile yanıtlarken, "5 Dakika sonra ne olacak?" sorusunu Derin Öğrenme (LSTM) ile öngörür. Operatörlere, hücreler ölmeden önce müdahale etme şansı tanıyan "Predictive Maintenance" (Kestirimci Bakım) mantığıyla tasarlanmıştır.

🧠 Mimari ve Kullanılan Teknolojiler

1. Yapay Zeka ve Veri Bilimi

Sentetik Veri Üretimi: Biyolojik kurallara (pH, Sıcaklık, Laktat toleransları) uygun olarak Pandas ve NumPy ile gerçekçi sensör verileri simüle edildi.

XGBoost (Anlık Durum): O anki sensör değerlerine bakarak hücre canlılığını tahmin eder.

LSTM - Long Short-Term Memory (Gelecek Öngörüsü): Son 10 sensör ölçümünü (Zaman Serisi) analiz ederek 5 dakika sonraki hücre canlılığını tahmin eder.

Stateless Calibration Layer: Sensörlerdeki anlık (Out-of-Distribution) sapmalara karşı modeli biyolojik kurallarla dizginleyen özel kalibrasyon katmanı.

2. Backend (FastAPI)

Yapay zeka modelleri (TensorFlow/Keras ve joblib) FastAPI üzerinden RESTful servislere dönüştürüldü.

Endpointler: /predict_current ve /predict_forecast

3. Frontend (Flutter)

Fleet Dashboard: Aynı anda 4 farklı reaktörü izleyebilen "Kontrol Odası" ekranı.

Detay Ekranı: Canlı akan sensör grafikleri (fl_chart), hibrit yapay zeka göstergeleri ve manuel müdahale butonları.

Glassmorphism UI: Modern, karanlık tema tabanlı ve cam efekti kullanılan akışkan arayüz tasarımı.

🛠️ Kurulum ve Çalıştırma (Nasıl Denenir?)

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin.

Bölüm 1: Backend (FastAPI ve Yapay Zeka) Kurulumu

Repoyu bilgisayarınıza klonlayın ve backend klasörüne girin.

Gerekli Python kütüphanelerini yükleyin:

pip install -r requirements.txt


Uvicorn ile sunucuyu başlatın:

python -m uvicorn main:app --reload


Sunucu http://127.0.0.1:8000 adresinde çalışmaya başlayacaktır.

Bölüm 2: Frontend (Flutter) Kurulumu

Yeni bir terminal açın ve uygulamanın bulunduğu klasöre (frontend veya uygulamanızın adı) gidin.

Flutter paketlerini çekin:

flutter pub get


Emülatörde veya gerçek cihazda başlatın:
(Android emülatörü kullanıyorsanız API istekleri otomatik olarak 10.0.2.2 üzerinden lokal sunucunuza yönlendirilir).

flutter run


💡 Özellikler ve Senaryolar

Anlık İzleme ve Müdahale: Simülasyon çalışırken Laktat seviyesi arttığında canlılık (XGBoost tahmini) düşer. "Laktat Temizle" butonuna basarak sistemi kurtarabilirsiniz.

Zaman Serisi Analizi: Sistem ilk açıldığında LSTM 40 saniye boyunca veri biriktirir. Yeterli veri oluştuğunda geleceğe dair trendleri göstermeye başlar.

PDF Raporlama: Sağ üstteki indirme butonuna tıklayarak o anki sensör değerlerini ve AI tahminlerini PDF formatında dışa aktarabilirsiniz.

Bu proje, Veri Bilimi modellerinin uçtan uca bir mobil IoT platformuna nasıl entegre edilebileceğini göstermek amacıyla geliştirilmiştir.

uygulamadan bazı görseller:





<img width="379" height="811" alt="Ekran görüntüsü 2026-06-06 232124" src="https://github.com/user-attachments/assets/fcd31c69-ee1e-451b-afb0-38f250edc3f0" />
<img width="376" height="791" alt="Ekran görüntüsü 2026-06-06 232113" src="https://github.com/user-attachments/assets/e52713c7-f098-4378-a9e9-2f96255f34e4" />
