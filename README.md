🔬 CellMonitor AI: Predictive Bioreactor Platform (V2.0)

Endüstri 4.0 standartlarında, biyoreaktör hücre kültürlerini gerçek zamanlı izleyen ve Hibrit Yapay Zeka (XGBoost + LSTM) ile hücre canlılığını tahmin edip, Otonom (Auto-Pilot) olarak sisteme müdahale edebilen IoT platformu.

🚀 Proje Vizyonu ve V2.0 Güncellemeleri

Bu proje, sensör verilerindeki anlık gürültüleri filtreleyerek "Şu an ne oluyor?" sorusunu XGBoost ile yanıtlarken, "5 Dakika sonra ne olacak?" sorusunu Zaman Serisi (LSTM) modeliyle öngörür.

🌟 V2.0 Yenilikleri:

Tam Senkronizasyon (State Management): Uygulama Provider mimarisine geçirilerek "Filo Dashboard" ile "Detay Ekranı" arasında milisaniyelik veri senkronizasyonu sağlandı.

Auto-Pilot (Otonom Müdahale): Operatör yorgunluğunu sıfıra indiren AI Kontrol modülü eklendi. LSTM modeli 5 dakika içinde %80'in altında kritik bir düşüş öngörürse, sistem operatöre sormadan laktat temizleme gibi hayati valfleri otomatik tetikler.

🧠 Mimari ve Kullanılan Teknolojiler

1. Yapay Zeka ve Veri Bilimi

XGBoost (Anlık Durum): Sensör değerlerine bakarak hücre canlılığını anlık tahmin eder.

LSTM (Gelecek Öngörüsü): Son 40 saniyelik sensör trendlerini analiz ederek 5 dakika sonraki hücre sağlığını tahmin eder.

Stateless Calibration Layer: Sensörlerdeki anormalliklerde yapay zekanın paniklemesini engelleyen biyolojik kurallar tabanlı kalibrasyon katmanı.

2. Backend (FastAPI)

Yapay zeka modelleri (TensorFlow ve joblib) FastAPI üzerinden RESTful servislere dönüştürüldü (/predict_current ve /predict_forecast).

3. Frontend (Flutter)

Fleet Dashboard: Aynı anda 4 farklı reaktörü izleyebilen merkezi kontrol odası.

Detay Ekranı ve Otonom Kontrol: Canlı grafikler, yapay zeka göstergeleri ve yapay zekanın yetkilerini açıp kapatabildiğiniz Auto-Pilot anahtarı.

Glassmorphism UI: Fütüristik, karanlık tema tabanlı akışkan tasarım.

🛠️ Kurulum ve Çalıştırma (Local Environment)

Projeyi kendi bilgisayarınızda denemek için:

Bölüm 1: Backend

Repoyu klonlayın ve backend klasörüne girin.

Gerekli kütüphaneleri yükleyin:

pip install -r requirements.txt


API Sunucusunu başlatın:

python -m uvicorn main:app --reload


Bölüm 2: Frontend (Flutter)

mobile_app klasörüne gidin.

Paketleri çekin:

flutter pub get


Uygulamayı başlatın:

flutter run


💡 Senaryolar ve Kullanım

Manuel Müdahale: Simülasyon sırasında değerler kötüleştiğinde müdahale paneliyle değerleri elle düzenleyebilirsiniz.

Auto-Pilot Şovu: Detay ekranında sağ üstteki "Otonom AI" şalterini açın. Yapay zeka %80 altına bir düşüş öngördüğü an ekranda beliren yeşil bildirimle birlikte sistemi nasıl otomatik kurtardığını izleyin!

uygulamadan bazı görseller:





<img width="379" height="811" alt="Ekran görüntüsü 2026-06-06 232124" src="https://github.com/user-attachments/assets/fcd31c69-ee1e-451b-afb0-38f250edc3f0" />
<img width="376" height="791" alt="Ekran görüntüsü 2026-06-06 232113" src="https://github.com/user-attachments/assets/e52713c7-f098-4378-a9e9-2f96255f34e4" />
