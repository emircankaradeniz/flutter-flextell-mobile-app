Bağlantıların içindeki uygulamalar kısmından Flextell Mobile APP uygulamasını oluşturdum. customers:read, tenants:read, users:read ve account:read yetkilerini açtım. Bir adet hasta oluşturdum. 
OAuth2 kimlik doğrulama akışını, güvenli token saklamayı, refresh token yenilemeyi, tenant yönetimini ve customer API entegrasyonunu yaptım.

Projenin amacı: Kullanıcının Flextell hesabı ile güvenli şekilde giriş yapmasını sağlar. Giriş başarılı olduktan sonra alınan access_token, refresh_token, expires_in ve token_type bilgileri ekranda gösterilir. Daha sonra kullanıcıya bağlı tenant bilgisi alınır ve seçilen tenant ID değeri ile Flextell customer API isteği yapılır.
Uygulamada panelde oluşturulan müşteri kayıtları liste yapısında görüntülenir.

Tamamlanan Özellikler

- OAuth2 login akışı
- Authorization code üzerinden token alma
- Access token, refresh token, expires in ve token type gösterimi
- Refresh token ile session yenileme
- Tokenları güvenli şekilde cihazda saklama
- Logout ile local token temizleme
- Tenant listesini API üzerinden alma
- Aktif tenant ID değerini customer isteğinde X-Tenant olarak gönderme
- Customer listesini API üzerinden çekme
- Loading, success ve error state yönetimi
- Debug modda API hata detaylarını gösterme
- BLoC/Cubit ile state management
- Modern ve sade mobil UI

Kullanılan Teknolojiler

- Flutter
- Dart
- flutter_appauth
- flutter_secure_storage
- flutter_bloc
- equatable
- dio

Projeyi ayağa kaldırmak için gerekli kurulum adımları

Projeyi ayağa kaldırmak için öncelikle bilgisayarda Flutter sdk kurulu olmalı, bu proje flutter stable 3.19.3 sürümü ile geliştirildiği için aynı sürümle çalıştırılması daha sağlıklı olur, Android cihazda test etmek için android studio, android sdk ve jdk 17 kurulumları yapılmış olmalı, daha sonra projeyi github üzerinden https://github.com/emircankaradeniz/flutter-flextell-mobile-app uzantısından  klonlanlanır ve cd flutter-flextell-mobile-app komutu ile proje klasörüne girilir, ardından flutter pub get komutu çalıştırılarak gerekli paketler yüklenir . Flextell developer panel üzerinden OAuth uygulaması oluşturulurken redirect URI olarak com.example.flextellcase://oauth-callback değeri girilmelidir ve OAuth uygulamasında account:read, tenants:read ve customers:read yetkileri aktif olmalıdır. 


flutter run `
  --dart-define=FLEXTELL_CLIENT_ID=019e2ba4-6645-73b3-a914-7018c31dd2e6 `
  --dart-define=FLEXTELL_CLIENT_SECRET=verdigim-secretkey-buraya `
  --dart-define=FLEXTELL_AUTHORIZATION_ENDPOINT=https://dev.flextell.ai/oauth/authorize `
  --dart-define=FLEXTELL_TOKEN_ENDPOINT=https://dev.flextell.ai/oauth/token `
  --dart-define=FLEXTELL_API_BASE_URL=https://dev.flextell.ai `
  --dart-define=FLEXTELL_ACCOUNT_TENANTS_PATH=/api/v1/account/tenants `
  --dart-define=FLEXTELL_CUSTOMERS_PATH=/api/v1/customers `
  --dart-define="FLEXTELL_SCOPES=account:read tenants:read customers:read"

secret keyi güvenlik için buraya yazmadım.

Bu komut ile çalıştırılabilir, kurulumdan sonra uygulama flextell giriş ekranına yönlenir, giriş başarılı olunca token bilgileri ekranda gösterilir, kullanıcıya bağlı tenant listesi alınır ve seçilen tenant ID ile müşteri listesi ekranda görüntülenir.