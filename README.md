# Progress Integrasi API Cetakin

Dokumen ini merangkum status integrasi antara backend Laravel (`tis-project/cetakin-backend`) dan frontend Flutter (`flutter/println`).

## Ringkasan Progress

1. **Total Endpoint Backend**: 38 endpoint
2. **Endpoint Diimplementasikan di Flutter**: 11 endpoint
3. **Persentase Selesai**: **~29%**

---

## Endpoint yang Telah Diimplementasikan (Selesai)

### Authentication & Profil (`AuthService`)
1. `POST /api/v1/auth/login` (Login user & partner)
2. `POST /api/v1/auth/register` (Registrasi user biasa)
3. `POST /api/v1/auth/register/partner` (Registrasi mitra/partner)
4. `POST /api/v1/auth/logout` (Logout)
5. `GET /api/v1/auth/me` (Mendapatkan profil current user)
6. `PUT /api/v1/auth/me` (Update profil user)

### Manajemen Toko (Partner) (`AuthService`)
*(Saat ini implementasi menyatu di AuthService, disarankan untuk dipisah ke `ShopService`)*
1. `GET /api/v1/shops/me` (Mendapatkan data toko mitra)
2. `PUT /api/v1/shops/me` (Update data dasar toko)

### Admin Panel (`AdminService`)
1. `GET /api/v1/admin/partners` (Mendapatkan list mitra, filter by status)
2. `PATCH /api/v1/admin/partners/{id}/approve` (Menyetujui pendaftaran mitra)
3. `PATCH /api/v1/admin/partners/{id}/reject` (Menolak pendaftaran mitra)

---

## Endpoint yang Belum Diimplementasikan (To-Do)

### Authentication & Profil
1. `POST /api/v1/auth/me/avatar` (Update foto profil avatar)

### Manajemen Toko (Partner)
1. `PUT /api/v1/shops/me/services` (Update layanan print yang disediakan)
2. `PUT /api/v1/shops/me/pricing` (Update harga layanan)
3. `GET /api/v1/shops/me/atk` (Mendapatkan daftar produk ATK toko)
4. `POST /api/v1/shops/me/atk` (Menambahkan produk ATK baru)
5. `GET /api/v1/shops/me/atk/{id}` (Detail produk ATK)
6. `PUT /api/v1/shops/me/atk/{id}` (Update produk ATK)
7. `DELETE /api/v1/shops/me/atk/{id}` (Hapus produk ATK)

### Pesanan Print (User & Partner)
1. `POST /api/v1/orders/print` (User membuat pesanan print)
2. `GET /api/v1/orders/print` (User melihat daftar pesanan print-nya)
3. `GET /api/v1/orders/print/{id}` (User melihat detail pesanannya)
4. `POST /api/v1/orders/print/{id}/cancel` (User membatalkan pesanan)
5. `POST /api/v1/orders/print/{id}/review` (User memberikan ulasan print)
6. `GET /api/v1/partner/orders/print` (Mitra melihat pesanan masuk)
7. `PATCH /api/v1/partner/orders/print/{id}/status` (Mitra update status pesanan print)

### Pesanan ATK (User & Partner)
1. `POST /api/v1/orders/atk` (User membuat pesanan ATK)
2. `GET /api/v1/orders/atk` (User melihat daftar pesanan ATK-nya)
3. `GET /api/v1/orders/atk/{id}` (User melihat detail pesanannya)
4. `POST /api/v1/orders/atk/{id}/review` (User memberikan ulasan ATK)
5. `GET /api/v1/partner/orders/atk` (Mitra melihat pesanan ATK masuk)
6. `PATCH /api/v1/partner/orders/atk/{id}/status` (Mitra update status pesanan ATK)

### Discovery / Cari Toko (User)
1. `GET /api/v1/shops` (Eksplorasi dan cari toko)
2. `GET /api/v1/shops/{id}` (Lihat detail toko)
3. `GET /api/v1/shops/{id}/atk` (Lihat katalog ATK di toko tertentu)
4. `GET /api/v1/shops/{id}/reviews` (Lihat ulasan toko)

### Ulasan / Reviews (User)
1. `GET /api/v1/reviews/me` (Lihat riwayat ulasan yang pernah diberikan user)
2. `GET /api/v1/reviews/me/{id}` (Lihat detail ulasan spesifik)

### System
1. `GET /api/v1/health` (Cek kesehatan sistem)
