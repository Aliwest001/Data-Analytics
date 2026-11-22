# Bakery Sales, Customer & Inventory Analysis

> Analisis penjualan, pelanggan, produk, promosi, dan persediaan pada bisnis bakery menggunakan dataset sintetis periode 2023–2024.

## 1. Project Overview

Project ini bertujuan memahami performa bisnis bakery melalui analisis data transaksi, karakteristik pelanggan, penjualan produk, metode pembayaran, promosi, serta indikator persediaan dan potensi waste.

Analisis dilakukan menggunakan workbook Excel yang berisi data mentah, tabel analisis, ringkasan KPI, dan dashboard. Hasilnya digunakan untuk menjawab pertanyaan bisnis dan menemukan pola yang dapat menjadi bahan pertimbangan dalam pengambilan keputusan.

**Periode analisis:** 1 Januari 2023 – 31 Desember 2024  
**Cakupan:** 3 store, 35 produk, dan 10 kategori produk  
**Jumlah baris transaksi pada workbook:** 16.569

## 2. Business Questions

Project ini berfokus pada pertanyaan bisnis berikut.

### Sales
1. Bagaimana tren penjualan dan profit berdasarkan bulan dan tahun selama 2023–2024?
2. Seberapa efektif penerapan diskon terhadap volume penjualan?
3. Bagaimana pertumbuhan bisnis pada 2024 dibandingkan 2023?

### Product
1. Produk apa saja yang paling laris berdasarkan jumlah unit terjual?
2. Berapa nilai penjualan yang dihasilkan oleh produk-produk terlaris?

### Customer
1. Metode pembayaran apa yang paling sering digunakan pelanggan?
2. Hari apa yang memiliki aktivitas transaksi paling tinggi?
3. Kelompok usia mana yang menjadi kontributor transaksi terbesar?

## 3. Dataset

### Source

Dataset yang digunakan adalah **Historical Bakery Sales Dataset** dari Kaggle:

- [Historical Bakery Sales Dataset – Kaggle](https://www.kaggle.com/datasets/sdcloud/historical-bakery-sales-dataset)
- File kerja: `Project_Analysis_Dataset_bakerystore.xlsx`
- Dokumentasi dataset: `about_dataset.md`

Dataset ini merupakan **synthetic dataset** untuk kebutuhan edukasi, analisis, dan eksperimen. Data tidak dapat dianggap sebagai catatan transaksi nyata dari bisnis bakery.

### Dataset Structure

Berdasarkan sheet `Data Mentah` pada workbook:

| Informasi | Keterangan |
|---|---:|
| Rentang tanggal | 2023-01-01 s.d. 2024-12-31 |
| Baris data | 16.569 |
| Kolom | 40 field? |

Field pada data mencakup beberapa kelompok informasi:

- **Transaction:** `Transaction_ID`, `Date`, `Time`
- **Customer:** `Customer_ID`, `Customer_Age`, `Customer_Gender`, `Customer_Segment`, `Loyalty_Member`, `Customer_Rating`
- **Product:** `Product`, `Category`, `Shelf_Life_Days`, `Storage_Type` (jika tersedia pada sumber)
- **Sales & pricing:** `Quantity`, `Unit_Price`, `Discount_Percentage`, `Discount_Amount`, `Selling_Price`, `Total_Bill`, `Profit`
- **Payment & promotion:** `Payment_Method`, `Promotion_Applied`, `Promotion_Type`, `Promotion_Score`
- **Time & external factors:** `Day_of_Week`, `Weekend`, `Season`, `Weather`, `Temperature`, `Festival`
- **Inventory & waste:** `Stock_Available`, `Units_Produced`, `Units_Sold`, `Unsold_Units`, `Expiry_Risk`, `Waste_Cost`
- **Store & employee:** `Store_ID`, `Employee_ID`

Workbook juga memiliki sheet analisis seperti `Question`, `KPI new`, `Sales new`, `Produk`, `Customer`, `Dataset_Analysis`, dan `Dashboard`.

> **Catatan konsistensi sumber:** file `about_dataset.md` menyebutkan 19.321 records dan 40 columns. Namun, sheet `Data Mentah` pada workbook project yang dianalisis berisi 16.569 baris data dan 41 kolom (termasuk header pada tampilan Excel). README ini menggunakan jumlah baris dan struktur yang benar-benar ditemukan pada workbook project. Perbedaan tersebut sebaiknya dikonfirmasi terhadap versi dataset sumber sebelum analisis direplikasi.

## 4. Analysis Results

Angka pada bagian ini dirangkum dari sheet analisis workbook dan pemeriksaan ulang data mentah. Nilai revenue pada tabel KPI workbook dibulatkan ke satuan terdekat; perhitungan langsung dari kolom `Total_Bill` menghasilkan total sekitar 3.444.112,95.

### 4.1 Sales Performance

| KPI | Hasil |
|---|---:|
| Total revenue (KPI workbook) | 3.444.160 |
| Average revenue per row / AOV workbook | 207,87 |
| Revenue 2023 (KPI workbook) | 1.723.817 |
| Revenue 2024 (KPI workbook) | 1.720.343 |
| Revenue growth 2024 vs 2023 | -0,20% |

Penjualan tahunan relatif stabil, tetapi revenue 2024 sedikit lebih rendah dibandingkan 2023.

**Bulan dengan revenue tertinggi dan terendah** berdasarkan ringkasan bulanan workbook:

- Tertinggi: Oktober, sekitar 322.017.
- Terendah: Februari, sekitar 243.792.

### 4.2 Product Performance

Berdasarkan sheet `Produk`, lima produk yang ditampilkan dalam ringkasan best-selling berdasarkan quantity adalah:

| Produk | Quantity | Total Bill |
|---|---:|---:|
| Bread | 2.807 | 105.148 |
| Coffee | 2.240 | 104.275 |
| Eggs | 1.534 | 85.515 |
| Butter | 1.497 | 77.120 |
| Jam | 1.481 | 151.309 |

*Catatan: urutan tabel di atas disusun berdasarkan quantity tertinggi. Nilai pada workbook dibulatkan.*

Pemeriksaan data mentah juga menunjukkan bahwa kategori **Cakes** menghasilkan revenue terbesar, sekitar 1.288.747 atau 37,4% dari total revenue hasil penjumlahan data mentah. Produk **Chocolate Cake** dan **Black Forest Cake** merupakan kontributor revenue individual terbesar pada pemeriksaan tersebut.

Dengan demikian, produk dengan volume unit tinggi tidak selalu menjadi produk dengan nilai revenue tertinggi.

### 4.3 Customer & Transaction Behavior

**Metode pembayaran**

| Metode | Jumlah transaksi | Persentase |
|---|---:|---:|
| UPI | 7.541 | 45,5% |
| Card | 3.994 | 24,1% |
| Cash | 3.305 | 19,9% |
| Wallet | 1.729 | 10,4% |

UPI merupakan metode pembayaran yang paling sering digunakan.

**Aktivitas transaksi berdasarkan hari**

| Hari | Jumlah transaksi |
|---|---:|
| Saturday | 4.124 |
| Sunday | 3.734 |
| Friday | 2.040 |
| Tuesday | 1.788 |
| Thursday | 1.764 |
| Wednesday | 1.736 |
| Monday | 1.383 |

Sabtu merupakan hari dengan jumlah transaksi tertinggi, disusul Minggu. Senin menjadi hari dengan aktivitas transaksi terendah.

**Kelompok usia**

| Kelompok usia | Jumlah transaksi |
|---|---:|
| 15–25 tahun | 5.896 |
| 26–35 tahun | 5.012 |
| 36–45 tahun | 1.865 |
| 46–55 tahun* | 1.817 |
| 56+ tahun | 1.979 |

Kelompok usia 15–25 tahun menjadi kontributor transaksi terbesar, diikuti kelompok 26–35 tahun.

*Workbook menuliskan kelompok keempat sebagai “45–55”; angka 46–55 digunakan di sini agar kelompok usia tidak tumpang tindih dengan kelompok 36–45.*

### 4.4 Profit & Inventory Signals

Pemeriksaan agregasi pada data mentah menghasilkan beberapa indikator yang perlu diperhatikan:

| Indikator | Hasil pemeriksaan |
|---|---:|
| Total `Profit` | -230.339,25 |
| Total `Units_Produced` | 126.710 |
| Total `Units_Sold` | 81.184 |
| Total `Unsold_Units` | 45.526 |
| Unsold units / units produced | sekitar 35,9% |
| Total `Waste_Cost` | 1.388.812,80 |

Nilai agregat `Profit` yang negatif dan jumlah unit tidak terjual menunjukkan adanya sinyal yang perlu ditelaah lebih lanjut. Namun, karena dataset bersifat sintetis, indikator tersebut tidak boleh langsung ditafsirkan sebagai kondisi aktual suatu bisnis.

### 4.5 Discount Analysis

Workbook menyediakan ringkasan quantity berdasarkan kelompok diskon:

| Kelompok diskon | Quantity |
|---|---:|
| 0% | 14.647 |
| 1%–10% | 18.048 |
| 11%–25% | 8.149 |
| >25% | 2.080 |
| **Total** | **42.924** |

Kelompok diskon 1%–10% memiliki quantity terbesar pada ringkasan workbook. Akan tetapi, angka ini belum cukup untuk menyimpulkan bahwa diskon menyebabkan kenaikan penjualan. Analisis efektivitas diskon perlu mempertimbangkan baseline penjualan, harga, produk, periode promosi, dan profitabilitas secara bersamaan.

## 5. Key Insights

1. **Revenue cenderung stagnan.** Revenue 2024 turun sekitar 0,20% dibandingkan 2023. Pertumbuhan belum menunjukkan peningkatan yang berarti.
2. **Oktober merupakan bulan terkuat.** Sementara itu, Februari menjadi bulan dengan revenue terendah pada ringkasan bulanan. Pola ini dapat menjadi dasar untuk analisis musiman dan perencanaan promosi.
3. **Bread unggul dalam volume, Cakes unggul dalam revenue kategori.** Produk dengan jumlah unit terjual tertinggi belum tentu menghasilkan revenue tertinggi.
4. **Akhir pekan merupakan periode ramai.** Sabtu dan Minggu menyumbang aktivitas transaksi terbesar sehingga kapasitas operasional dan ketersediaan stok dapat dievaluasi untuk periode tersebut.
5. **UPI mendominasi metode pembayaran.** Hampir setengah transaksi menggunakan UPI, sehingga metode pembayaran digital ini penting dalam pengalaman pelanggan.
6. **Pelanggan muda mendominasi transaksi.** Kelompok 15–25 dan 26–35 tahun merupakan dua kelompok usia dengan jumlah transaksi terbesar.
7. **Diskon perlu dievaluasi berdasarkan profit, bukan quantity saja.** Quantity tertinggi pada kelompok diskon 1%–10% tidak otomatis berarti strategi diskon paling menguntungkan.
8. **Persediaan dan waste perlu mendapat perhatian.** Data mentah mencatat sekitar 35,9% unit produksi sebagai unsold units. Angka ini merupakan sinyal eksplorasi, bukan estimasi waste aktual yang telah tervalidasi.

## 6. Tools & Methods

Tools yang digunakan atau relevan dengan workbook project:

- **Microsoft Excel** – pengolahan data, pivot table, ringkasan KPI, dan dashboard.
- **Data analysis** – agregasi revenue, quantity, transaksi, produk, pelanggan, dan inventory.
- **Exploratory Data Analysis (EDA)** – identifikasi tren, distribusi, perbandingan, dan pola.

## 7. Limitations

- Dataset merupakan data sintetis, bukan transaksi bisnis nyata.
- Perbedaan jumlah record antara dokumentasi dataset dan workbook project perlu dikonfirmasi.
- Terdapat selisih kecil antara total revenue pada KPI workbook dan penjumlahan langsung `Total_Bill` dari sheet data mentah. Angka KPI workbook dan hasil pemeriksaan data mentah telah diberi konteks secara terpisah.
- Hubungan antara diskon dan quantity tidak membuktikan hubungan sebab-akibat.
- Nilai `Profit`, `Waste_Cost`, dan inventory perlu divalidasi definisi serta rumus pembentukannya sebelum digunakan untuk rekomendasi operasional.
- Hasil analisis tidak dapat langsung digeneralisasi ke bisnis bakery nyata tanpa validasi menggunakan data aktual.

## 8. Conclusion

Project ini memberikan gambaran analitis mengenai performa penjualan, produk, perilaku pelanggan, metode pembayaran, diskon, dan persediaan pada dataset bakery periode 2023–2024.

Temuan utama menunjukkan revenue yang relatif stagnan, aktivitas transaksi yang lebih tinggi pada akhir pekan, dominasi pembayaran UPI, serta perbedaan antara produk dengan volume penjualan tertinggi dan kategori dengan revenue terbesar. Analisis juga mengidentifikasi sinyal terkait profit dan unsold inventory yang layak diteliti lebih lanjut.

Secara keseluruhan, project ini merupakan latihan **retail business analytics** untuk menerjemahkan data transaksi menjadi informasi yang lebih mudah dipahami dan digunakan sebagai dasar pertanyaan bisnis berikutnya.

---