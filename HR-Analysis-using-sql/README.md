# HR Analytics dengan SQL: Attrition, Rekrutmen, dan Kompensasi

Analisis data karyawan menggunakan **MySQL 8** untuk menjawab pertanyaan HR: di mana orang paling banyak keluar, dari sumber rekrutmen mana karyawan paling bertahan, dan apakah ada pola pada gaji.

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![Tools](https://img.shields.io/badge/Tools-MySQL%20Workbench-orange)
![Status](https://img.shields.io/badge/Status-Selesai-brightgreen)

## Daftar Isi

1. [Project Overview](#1-project-overview)
2. [Business Question](#2-business-question)
3. [Dataset](#3-dataset)
4. [Project Workflow](#4-project-workflow)
5. [Result](#5-result)
6. [Insight](#6-insight)
7. [Keterbatasan](#7-keterbatasan)
8. [Struktur Repository dan Cara Menjalankan](#8-struktur-repository-dan-cara-menjalankan)
9. [Lisensi dan Kredit](#9-lisensi-dan-kredit)

---

## 1. Project Overview

Project ini adalah latihan analisis HR end-to-end hanya dengan SQL, dari data mentah sampai insight yang bisa ditindaklanjuti. Alurnya:

- membersihkan data mentah menjadi satu tabel analisis (`acuan_analisis`),
- menjawab 11 tahap pertanyaan, dari dasar (`GROUP BY`) sampai lanjutan (`CTE` dan window function),
- merangkum temuan menjadi 4 insight, masing-masing dengan **bukti query, batas data, dan tindakan HR**.

---

## 2. Business Question

| # | Pertanyaan | Tahap |
|---|---|---|
| 1 | Apakah data sudah bersih dan jumlah barisnya benar? | 0 |
| 2 | Berapa headcount aktif vs keluar, per department dan gender? | 1 |
| 3 | Berapa rentang gaji per department dan per posisi? | 2 |
| 4 | Department mana yang paling sering kehilangan karyawan? | 3 |
| 5 | Mengapa orang keluar: sukarela atau dipecat? | 4 |
| 6 | Sumber rekrutmen mana yang menghasilkan karyawan bertahan, dan bagaimana komposisi rasnya? | 5 |
| 7 | Apakah ada hubungan antara manager dengan performa dan attrition? | 6 |
| 8 | Kapan orang paling rentan keluar (masa kerja dan umur)? | 7 |
| 9 | Apakah ada ketimpangan gaji antar gender atau ras pada posisi yang sama? | 8 |
| 10 | Apakah performa, absensi, keterlambatan, dan kepuasan saling terkait? | 9 |
| 11 | Siapa yang banyak berkontribusi (proyek khusus) tetapi gajinya di separuh bawah department? | 10 |
| 12 | Insight apa yang paling layak ditindaklanjuti HR? | 11 |

---

## 3. Dataset

**Sumber:** *Human Resources Data Set* (versi 14) oleh Dr. Carla Patalano dan Dr. Rich Huebner, tersedia di Kaggle. Codebook: <https://rpubs.com/rhuebner/hrd_cb_v14>

| Item | Keterangan |
|---|---|
| Perusahaan | Fiktif (data sintetis untuk pengajaran) |
| Ukuran | 311 baris, 36 kolom |
| Periode | Hire 2006-2018, terminasi 2010-2018, data berhenti sekitar awal 2019 |
| Format file | CSV dengan delimiter titik koma (`;`) |

**Tabel yang dipakai**

| Tabel | Fungsi |
|---|---|
| `hrdataset` | Data mentah, tidak diubah |
| `hrdataset2` | Salinan backup untuk pembersihan |
| `acuan_analisis` | Tabel bersih, 311 baris dan 19 kolom, dasar semua analisa |

**19 kolom yang dipakai:** `emp_id`, `termd`, `term_reason`, `sex`, `DOB`, `employment_status`, `salary`, `department`, `position`, `manager_name`, `race_desc`, `recruitment_source`, `performance_score`, `date_of_hire`, `date_of_termination`, `absences`, `days_late_last_30`, `emp_satisfaction`, `SpecialProjectsCount`. Sisanya (17 kolom) dibuang karena redundan (versi angka dari kolom teks), tidak konsisten, atau tidak dipakai.

**Gambaran umum**

- 311 karyawan: **207 aktif (66,6%)** dan **104 keluar (33,4%)**. Dari 104 yang keluar, 88 sukarela dan 16 dipecat.
- Department: Production 209, IT/IS 50, Sales 31, Software Engineering 11, Admin Offices 9, Executive Office 1.
- Gender: 176 perempuan, 135 laki-laki.

**Masalah kualitas data yang ditangani (Tahap 0)**

| Masalah | Solusi |
|---|---|
| Spasi berlebih di `department`, `sex`, `position`, `manager_name` | `TRIM` |
| Tanggal bertipe teks dengan format campuran | `STR_TO_DATE` |
| `DOB` campuran tahun 4 dan 2 digit, tahun 51-69 dibaca MySQL sebagai 2051-2069 | `CASE WHEN` dan kurangi 100 tahun |
| `date_of_termination` kosong untuk 207 karyawan aktif | `NULLIF` lalu `STR_TO_DATE` |
| `manager_id` kosong di 8 baris dan tidak konsisten | Import sebagai `TEXT`, analisa memakai `manager_name` |
| Kolom ID tidak cocok dengan kolom teks (`emp_status_id`, `dept_id`) | Memakai kolom teks |

---

## 4. Project Workflow

```
Data mentah (CSV)  →  Import ke MySQL  →  Backup (hrdataset2)  →  Cleaning  →  acuan_analisis
                                                                                      │
        Insight akhir  ←  Analisa Tahap 1-10 (dasar → lanjutan)  ←─────────────────────┘
```

| Tahap | Topik | Level | Konsep SQL utama |
|---|---|---|---|
| 0 | Import dan pembersihan | Dasar | `TRIM`, `STR_TO_DATE`, `NULLIF`, `CASE WHEN` |
| 1 | Headcount aktif vs keluar | Dasar | `GROUP BY`, `COUNT`, pivot manual |
| 2 | Rentang gaji per department dan posisi | Dasar | `AVG`, `MIN`, `MAX`, `ROUND`, flag `CASE WHEN` |
| 3 | Attrition per department | Menengah | `SUM(termd)`, `AVG(termd)`, `SUM() OVER ()` |
| 4 | Sukarela vs dipecat | Dasar | `WHERE`, `PARTITION BY` |
| 5 | Sumber rekrutmen dan komposisi ras | Menengah | `GROUP BY` dua kolom, CTE |
| 6 | Performa dan attrition per manager | Menengah | `AVG(kondisi)`, `IN`, `HAVING` |
| 7 | Tenure dan umur | Menengah | `TIMESTAMPDIFF`, CTE, tanggal acuan tetap |
| 8 | Ketimpangan gaji gender dan ras | Menengah | `AVG(CASE WHEN)`, `HAVING` |
| 9 | Performa, absensi, keterlambatan, kepuasan | Menengah | `FIELD()`, `AVG(kondisi)` |
| 10 | Peringkat gaji dan kontribusi | Lanjutan | `RANK`, `DENSE_RANK`, `PARTITION BY` |
| 11 | Merangkum 4 insight akhir | Dasar | Validasi dan rapikan query |

Semua query ada di [`hr_analytics_queries.sql`](hr_analytics_queries.sql), diurutkan per tahap dan diberi komentar hasil.

**Contoh query (Tahap 3: attrition per department):**

```sql
SELECT
    department,
    COUNT(*)                              AS jumlah_karyawan,
    SUM(termd)                            AS jumlah_keluar,
    ROUND(SUM(termd) / COUNT(*) * 100, 1) AS pct_attrition,
    SUM(COUNT(*))   OVER ()               AS total_karyawan,
    SUM(SUM(termd)) OVER ()               AS total_keluar
FROM acuan_analisis
GROUP BY department
ORDER BY pct_attrition DESC;
```

---

## 5. Result

### Attrition per department (Tahap 3)

| Department | Karyawan | Keluar | % Attrition |
|---|---:|---:|---:|
| Production | 209 | 83 | **39,7%** |
| IT/IS | 50 | 10 | 20,0% |
| Sales | 31 | 5 | 16,1% |
| Software Engineering* | 11 | 4 | 36,4% |
| Admin Offices* | 9 | 2 | 22,2% |
| Executive Office* | 1 | 0 | 0,0% |
| **Perusahaan** | **311** | **104** | **33,4%** |

\* Terlalu kecil untuk disimpulkan.

### Alasan keluar (Tahap 4)

| Status | Jumlah | Alasan terbanyak |
|---|---:|---|
| Voluntarily Terminated | 88 (84,6%) | Another position (20), unhappy (14), more money (11) |
| Terminated for Cause | 16 (15,4%) | attendance (6), no-call no-show (4), performance (3) |

### Attrition per sumber rekrutmen (Tahap 5, semua department)

| Sumber | Rekrut | Keluar | % Keluar |
|---|---:|---:|---:|
| Website* | 13 | 1 | 7,69% |
| Employee Referral | 31 | 5 | 16,13% |
| Indeed | 87 | 21 | 24,14% |
| Diversity Job Fair | 29 | 16 | 55,17% |
| Google Search | 49 | 30 | 61,22% |

\* Sampel kecil. Semua 29 rekrut Diversity Job Fair adalah Black or African American.

### Attrition per manager, tim minimal 20 orang (Tahap 6)

| Manager | Tim | Keluar | % Keluar |
|---|---:|---:|---:|
| Amy Dunn | 21 | 13 | 61,90% |
| Webster Butler | 21 | 13 | 61,90% |
| Kissy Sullivan | 22 | 12 | 54,55% |
| Michael Albert | 22 | 9 | 40,91% |
| Elijah Gray | 22 | 8 | 36,36% |
| David Stanley | 21 | 6 | 28,57% |
| Brannon Miller | 22 | 6 | 27,27% |
| Kelley Spirea | 22 | 6 | 27,27% |
| Ketsia Liebig | 21 | 5 | 23,81% |

### Tenure dan umur (Tahap 7)

- Rata-rata tenure karyawan yang keluar: **41,1 bulan** (rentang 0-114). 82 dari 104 (78,8%) keluar sebelum 5 tahun.
- Persen keluar per kelompok umur: **<30 tahun 62,50%** (30 dari 48), 30-39 tahun 25,17%, 40-49 tahun 32,10%, 50+ tahun 30,77%.

### Sinyal dini pada karyawan aktif (Tahap 9)

| Performa | Karyawan | Pernah telat |
|---|---:|---:|
| Exceeds | 29 | 0 |
| Fully Meets | 162 | 2 |
| Needs Improvement | 8 | 7 |
| PIP | 8 | 8 |

Absensi (`absences`) tidak menunjukkan pola terhadap performa, kepuasan, maupun keterlambatan.

---

## 6. Insight

Setiap insight mengikuti format **temuan, bukti, batas, tindakan HR**.

### Insight 1: Attrition terkonsentrasi di Production

- **Temuan:** Production 39,7% (83 dari 209), dibanding IT/IS 20,0% (10 dari 50) dan Sales 16,1% (5 dari 31).
- **Batas:** Software Engineering (11), Admin (9), dan Executive Office (1) terlalu kecil untuk disimpulkan. Production adalah mayoritas karyawan sehingga mendominasi angka total. Angka ini proporsi karyawan yang pernah keluar selama 2006-2018, bukan attrition tahunan.
- **Tindakan HR:** prioritaskan investigasi retensi di Production.

### Insight 2: Di dalam Production, retensi berbeda jauh antar sumber rekrutmen

- **Temuan:** Employee Referral 12,5% (2 dari 16) dan LinkedIn 23,0% (14 dari 61), dibanding Google Search 61,4% (27 dari 44) dan Diversity Job Fair 64,7% (11 dari 17).
- **Batas:** sudah dikontrol departemen, belum dikontrol tahun hire, posisi, dan manager. Sampel Referral (16) dan Job Fair (17) kecil.
- **Tindakan HR:** periksa seleksi dan onboarding untuk sumber dengan attrition tinggi. Untuk Job Fair, ini sinyal untuk memeriksa proses setelah karyawan masuk, bukan alasan mengurangi sumbernya.

### Insight 3: Selisih rata-rata gaji gender belum bisa dijelaskan penuh (hipotesis)

- **Temuan:** rata-rata gaji perempuan 67.787 (176 orang) lebih rendah dari laki-laki 70.629 (135 orang), selisih sekitar 4%. Di dalam posisi arahnya campur: perempuan lebih rendah di Area Sales Manager (63.794 vs 65.844) dan Production Manager (72.947 vs 77.055), tetapi sedikit lebih tinggi di Production Technician I (56.082 vs 54.667) dan II (65.398 vs 63.957).
- **Batas:** arah selisih tidak berbalik di semua posisi, jadi ini bukan Simpson's paradox yang bersih. Masa kerja, performa, dan komposisi gender per department belum dikontrol. Hanya posisi dengan minimal 5 orang per gender yang dibandingkan.
- **Tindakan HR:** tinjau gaji Area Sales Manager dan Production Manager berdasarkan masa kerja dan performa sebelum menyimpulkan ada ketimpangan.

### Insight 4: 7 dari 166 karyawan aktif layak ditinjau gajinya

- **Temuan:** 7 karyawan aktif (6 di IT/IS, 1 di Production) punya jumlah proyek khusus di 2 nilai tertinggi departemennya, tetapi gaji di separuh bawah departemen. Penyebut 166 = IT/IS 40 + Production 126.
- **Batas:** Sales dan departemen kecil tidak ikut (filter minimal 30 orang). "Tinggi" bersifat relatif (nilai tertinggi proyek di Production hanya 3). Gaji dibandingkan tanpa memperhitungkan posisi dan masa kerja.
- **Tindakan HR:** kandidat untuk ditinjau satu per satu, bukan bukti ketidakadilan.

### Temuan pendukung

- **Keterlambatan adalah sinyal paling konsisten.** Di karyawan aktif, 15 dari 16 orang di kelompok Needs Improvement dan PIP pernah telat, dibanding 2 dari 162 di Fully Meets dan 0 dari 29 di Exceeds.
- **Sebagian besar keluar sebelum 5 tahun**, dan kelompok umur di bawah 30 tahun punya persen keluar tertinggi (kelompok kecil, 48 orang).
- **Persen keluar antar manager berbeda jauh** (23,81% sampai 61,90%), tetapi belum dikontrol department dan sumber rekrutmen, jadi tidak bisa disimpulkan manager sebagai penyebab.
- **Tidak ada pola gaji yang merugikan satu ras** pada posisi dengan sampel memadai (Tahap 8).

---

## 7. Keterbatasan

- **Data sintetis.** Dataset dibuat untuk pengajaran, pola belum tentu mencerminkan perusahaan nyata.
- **Korelasi, bukan sebab-akibat.** Tidak ada temuan yang membuktikan penyebab.
- **Sampel kecil.** Beberapa segmen sangat kecil (Executive Office 1, Admin 9, Software Engineering 11, banyak manager dengan tim di bawah 20). Segmen ini sengaja tidak disimpulkan.
- **Bukan attrition tahunan.** Persentase adalah proporsi karyawan yang pernah keluar dalam periode 2006-2018.
- **Variabel yang belum dikontrol.** Masa kerja, performa, dan departemen belum dikontrol pada analisis gaji dan manager.
- **Gaji karyawan yang keluar** adalah gaji saat keluar (2010-2018), bukan gaji 2019. Karena itu analisis gaji memakai karyawan aktif, dan 311 orang hanya sebagai pembanding.
- **Umur memakai tanggal acuan tetap** `2019-02-28` untuk karyawan aktif, sehingga kelompok muda bisa tampak sedikit lebih tinggi.
- **`days_late_last_30`** tidak dijelaskan di codebook untuk karyawan yang sudah keluar.

---

## 8. Struktur Repository dan Cara Menjalankan

```
.
├── README.md
└── hr_analytics_queries.sql    # semua query, diurutkan per tahap
└── dataset # dataset mentah
```

**Cara menjalankan ulang**

1. Unduh dataset dari repository.
2. Di MySQL Workbench, import CSV ke tabel `hrdataset` lewat *Table Data Import Wizard*. Gunakan delimiter `;` dan impor kolom `manager_id` sebagai `TEXT`.
3. Jalankan [`hr_analytics_queries.sql`](hr_analytics_queries.sql) dari atas. Bagian Tahap 0 membuat `hrdataset2` dan `acuan_analisis`, lalu tahap berikutnya bisa dijalankan satu per satu.
4. Cocokkan hasil dengan angka (mis. 311 baris, 207 aktif, 104 keluar).

---

## 9. Lisensi dan Kredit

Dataset dibuat oleh **Dr. Carla Patalano** dan **Dr. Rich Huebner** dan dilisensikan di bawah [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) untuk keperluan belajar dan mengajar. Repository ini tidak menyertakan file data. Silakan unduh dari sumber aslinya.

**Author:** Ali Shiddiq · [LinkedIn] https://www.linkedin.com/in/alishiddiq · [GitHub](https://github.com/Aliwest001)
