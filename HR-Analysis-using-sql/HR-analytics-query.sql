/* =============================================================================
   HR ANALYTICS - MySQL 8;
   -----------------------------------------------------------------------------
   Dataset : HR Dataset v14 (Kaggle) - Dr. Carla Patalano & Dr. Rich Huebner
             Data sintetis untuk pembelajaran. 311 baris, 36 kolom.
   Tools   : MySQL 8, MySQL Workbench
   Tabel   : hrdataset       -> tabel mentah (tidak diubah)
             hrdataset2      -> salinan backup untuk pembersihan
             acuan_analisis  -> tabel bersih (311 baris, 19 kolom), dasar semua analisa

   DAFTAR ISI
     Tahap 0  : Import dan pembersihan data
     Tahap 1  : Headcount aktif vs keluar
     Tahap 2  : Rentang gaji per department dan position
     Tahap 3  : Attrition per department
     Tahap 4  : Keluar sukarela vs dipecat, dan alasannya
     Tahap 5  : Sumber rekrutmen dan komposisi ras
     Tahap 6  : Performa dan attrition per manager
     Tahap 7  : Tenure dan umur
     Tahap 8  : Ketimpangan gaji gender dan ras
     Tahap 9  : Performa, absensi, keterlambatan, kepuasan
     Tahap 10 : Peringkat gaji dan kontribusi (window function)
     Tahap 11 : Query pendukung 4 insight akhir

   CATATAN
     - termd = 1 berarti karyawan sudah keluar, termd = 0 berarti masih aktif.
   ========================================================================== */


/* =============================================================================
   TAHAP 0 - IMPORT DAN PEMBERSIHAN DATA
   Pertanyaan: apakah data sudah bersih dan jumlah baris benar (311)?
   ========================================================================== */

-- Cek berapakah jumlah baris? = 311
SELECT COUNT(*) FROM hrdataset;

-- Cek berapa id unik pada data? = 311 artinya semua data unik
SELECT COUNT(DISTINCT emp_id) AS unique_emp_id
FROM hrdataset;

-- Berapa jumlah karyawan yang sudah keluar? = 104
SELECT COUNT(*) AS jumlah_termd
FROM hrdataset
WHERE termd = 1;

-- Berapakah jumlah karyawan aktif? = 207
SELECT COUNT(*) AS jumlah_termd
FROM hrdataset
WHERE termd = 0;

-- Cek apakah terdapat missing value pada data?
-- hasil semua kolom 0 null, tapi ada yang aneh. date_of_termination terlihat kosong. Itu artinya terdapat karakter string kosong
SELECT
  COUNT(*) - COUNT(employee_name)       AS jumlah_null_employee_name,
  COUNT(*) - COUNT(termd)               AS jumlah_null_termd,
  COUNT(*) - COUNT(salary)              AS jumlah_null__salary,
  COUNT(*) - COUNT(position)            AS jumlah_null_position,
  COUNT(*) - COUNT(DOB)                 AS jumlah_null_DOB,
  COUNT(*) - COUNT(sex)                 AS jumlah_null_sex,
  COUNT(*) - COUNT(race_desc)           AS jumlah_null_race_desc,
  COUNT(*) - COUNT(date_of_hire)        AS jumlah_null_DOH,
  COUNT(*) - COUNT(date_of_termination) AS jumlah_null_DOT,
  COUNT(*) - COUNT(term_reason)         AS jumlah_null_termd_reason,
  COUNT(*) - COUNT(employment_status)   AS jumlah_null_employ_status,
  COUNT(*) - COUNT(department)          AS jumlah_null_department,
  COUNT(*) - COUNT(manager_name)        AS jumlah_null_manager_name,
  COUNT(*) - COUNT(performance_score)   AS jumlah_null_perform_score
FROM hrdataset;

-- Alternatif lain. Pengecekan missing values
-- Dari semua kolom hanya date_of_termination yang memiliki karakter string kosong = 207
SELECT
  SUM(CASE WHEN employee_name IS NULL OR TRIM(employee_name) = '' THEN 1 ELSE 0 END)                 AS jumlah_null_employee_name,
  SUM(CASE WHEN termd IS NULL OR TRIM(termd) = '' THEN 1 ELSE 0 END)                                 AS jumlah_null_termd,
  SUM(CASE WHEN salary IS NULL OR TRIM(salary) = '' THEN 1 ELSE 0 END)                               AS jumlah_null_salary,
  SUM(CASE WHEN position IS NULL OR TRIM(position) = '' THEN 1 ELSE 0 END)                           AS jumlah_null_position,
  SUM(CASE WHEN DOB IS NULL OR TRIM(DOB) = '' THEN 1 ELSE 0 END)                                     AS jumlah_null_DOB,
  SUM(CASE WHEN sex IS NULL OR TRIM(sex) = '' THEN 1 ELSE 0 END)                                     AS jumlah_null_sex,
  SUM(CASE WHEN race_desc IS NULL OR TRIM(race_desc) = '' THEN 1 ELSE 0 END)                         AS jumlah_null_race_desc,
  SUM(CASE WHEN date_of_hire IS NULL OR TRIM(date_of_hire) = '' THEN 1 ELSE 0 END)                   AS jumlah_null_DOH,
  SUM(CASE WHEN date_of_termination IS NULL OR TRIM(date_of_termination) = '' THEN 1 ELSE 0 END)     AS jumlah_null_DOT,
  SUM(CASE WHEN term_reason IS NULL OR TRIM(term_reason) = '' THEN 1 ELSE 0 END)                     AS jumlah_null_term_reason,
  SUM(CASE WHEN employment_status IS NULL OR TRIM(employment_status) = '' THEN 1 ELSE 0 END)         AS jumlah_null_employee_status,
  SUM(CASE WHEN department IS NULL OR TRIM(department) = '' THEN 1 ELSE 0 END)                       AS jumlah_null_department,
  SUM(CASE WHEN manager_name IS NULL OR TRIM(manager_name) = '' THEN 1 ELSE 0 END)                   AS jumlah_null_manager_name,
  SUM(CASE WHEN recruitment_source IS NULL OR TRIM(recruitment_source) = '' THEN 1 ELSE 0 END)       AS jumlah_null_recruit_source,
  SUM(CASE WHEN performance_score IS NULL OR TRIM(performance_score) = '' THEN 1 ELSE 0 END)         AS jumlah_null_performance_score
FROM hrdataset;

-- Pengecekan lanjutan terkait string kosong pada kolom 
-- Hasil: date_of_termination yang memiliki string kosong dimiliki hanya pada karyawan aktif.
--        Artinya, yang terisi hanya pada karyawan yang sudah keluar
SELECT employee_name, emp_id,
       employment_status, term_reason,
       date_of_hire, date_of_termination
FROM hrdataset
WHERE termd = 0;

-- pengecekan, apakah terdapat date_of_hire yang lebih besar dari date_of_termination
-- berfungsi agar saat perhitungan masa kerja tidak menghasilkan nilai -
SELECT date_of_hire, date_of_termination
FROM acuan_analisis
WHERE date_of_hire > date_of_termination;

-- Backup tabel mentah
DROP TABLE IF EXISTS hrdataset2;
CREATE TABLE hrdataset2 AS
SELECT * FROM hrdataset;

-- Tabel bersih untuk analisa
DROP TABLE IF EXISTS acuan_analisis;

CREATE TABLE acuan_analisis AS
SELECT
    emp_id,
    termd,
    term_reason,
    TRIM(sex) AS sex,
    CASE
        WHEN LENGTH(TRIM(DOB)) = 10 THEN STR_TO_DATE(TRIM(DOB), '%m/%d/%Y')
        WHEN STR_TO_DATE(TRIM(DOB), '%m/%d/%y') > '2019-01-01' THEN DATE_SUB(STR_TO_DATE(TRIM(DOB), '%m/%d/%y'), INTERVAL 100 YEAR)
        ELSE STR_TO_DATE(TRIM(DOB), '%m/%d/%y')
    END AS DOB,
    employment_status,
    salary,
    TRIM(department)   AS department,
    TRIM(position)     AS position,
    TRIM(manager_name) AS manager_name,
    race_desc,
    recruitment_source,
    performance_score,
    STR_TO_DATE(date_of_hire, '%m/%d/%Y')                     AS date_of_hire,
    STR_TO_DATE(NULLIF(date_of_termination, ''), '%m/%d/%Y')  AS date_of_termination,
    absences,
    days_late_last_30,
    emp_satisfaction,
    SpecialProjectsCount
FROM hrdataset2;

/* =============================================================================
   TAHAP 1 - HEADCOUNT AKTIF VS KELUAR
   Pertanyaan: berapa headcount aktif vs keluar, per department dan gender?
   ========================================================================== */

-- 1a. Headcount per department
SELECT department,
	   COUNT(*) AS jumlah_karyawan
FROM acuan_analisis
GROUP BY department
ORDER BY jumlah_karyawan DESC;

-- 1b. Headcount per jenis kelamin
SELECT sex,
       COUNT(*) AS jumlah_karyawan
FROM acuan_analisis
GROUP BY sex
ORDER BY jumlah_karyawan DESC;

-- 1c. Headcount per status karyawan
SELECT employment_status,
       COUNT(*) AS jumlah_karyawan
FROM acuan_analisis
GROUP BY employment_status
ORDER BY jumlah_karyawan DESC;

-- 1d. Headcount per status, department, dan jenis kelamin
SELECT department,
    SUM(CASE WHEN employment_status = 'Active'                 THEN 1 ELSE 0 END) AS aktif,
    SUM(CASE WHEN employment_status = 'Voluntarily Terminated' THEN 1 ELSE 0 END) AS keluar_sukarela,
    SUM(CASE WHEN employment_status = 'Terminated for Cause'   THEN 1 ELSE 0 END) AS dipecat,
    COUNT(*)                                                                      AS total
FROM acuan_analisis
GROUP BY department
ORDER BY total DESC;


/* =============================================================================
   TAHAP 2 - RENTANG GAJI PER DEPARTMENT DAN POSITION
   Pertanyaan: berapa rentang gaji per department dan per position?
   Catatan   : kelompok kurang dari 5 orang diberi flag 'sedikit' (tidak dibuang,
               supaya total tetap 311)
   ========================================================================== */

-- 2a. Gaji per department
SELECT
    department,
    COUNT(*)                                                 AS jumlah_karyawan,
    MIN(salary)                                              AS gaji_terendah,
    MAX(salary)                                              AS gaji_tertinggi,
    ROUND(AVG(salary), 0)                                    AS rata_rata_gaji,
    CASE WHEN COUNT(*) < 5 THEN 'sedikit' ELSE 'banyak' END  AS flag_jumlah_karyawan
FROM acuan_analisis
GROUP BY department
ORDER BY jumlah_karyawan DESC;

-- 2b. Gaji per position
SELECT position,
       COUNT(*)                                                 AS jumlah_karyawan,
       MIN(salary)                                              AS gaji_terendah,
       MAX(salary)                                              AS gaji_tertinggi,
       ROUND(AVG(salary), 0)                                    AS rata_rata_gaji,
       CASE WHEN COUNT(*) < 5 THEN 'sedikit' ELSE 'banyak' END  AS flag_jumlah_karyawan
FROM acuan_analisis
GROUP BY position
ORDER BY jumlah_karyawan DESC;

-- 2c. Gaji per department dan position
SELECT department, position,
    COUNT(*)                                                AS jumlah_karyawan,
    MIN(salary)                                             AS gaji_terendah,
    MAX(salary)                                             AS gaji_tertinggi,
    ROUND(AVG(salary), 0)                                   AS rata_rata_gaji,
    CASE WHEN COUNT(*) < 5 THEN 'sedikit' ELSE 'banyak' END AS flag_jumlah_karyawan
FROM acuan_analisis
GROUP BY department, position
ORDER BY jumlah_karyawan DESC, department, position;

/* =============================================================================
   TAHAP 3 - ATTRITION PER DEPARTMENT
   Pertanyaan: berapa persen karyawan yang keluar di tiap department?
   Catatan   : termd hanya berisi 0 dan 1, jadi SUM(termd) = jumlah yang keluar
               dan AVG(termd) = proporsi yang keluar.
   ========================================================================== */

SELECT department,
       COUNT(*)                              AS jumlah_karyawan,
       SUM(termd)                            AS jumlah_keluar,
       ROUND(SUM(termd) / COUNT(*) * 100, 1) AS pct_attrition,
	   SUM(COUNT(*))   OVER ()               AS total_karyawan,
       SUM(SUM(termd)) OVER ()               AS total_keluar
FROM acuan_analisis
GROUP BY department
ORDER BY pct_attrition DESC;

/* =============================================================================
   TAHAP 4 - KELUAR SUKARELA VS DIPECAT
   Pertanyaan: mengapa orang keluar?
   ========================================================================== */

SELECT
    employment_status, term_reason,
    COUNT(*)                                            AS jumlah_per_alasan,
    SUM(COUNT(*)) OVER (PARTITION BY employment_status) AS jumlah_per_status,
    SUM(COUNT(*)) OVER ()                               AS total_keluar,
    ROUND(SUM(COUNT(*)) OVER (PARTITION BY employment_status) / SUM(COUNT(*)) OVER () * 100, 1) AS pct_status_dari_total,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY employment_status) * 100, 1)              AS pct_alasan_dalam_status
FROM acuan_analisis
WHERE termd = 1
GROUP BY employment_status, term_reason
ORDER BY
    jumlah_per_status DESC,
    jumlah_per_alasan DESC,
    term_reason;

/* =============================================================================
   TAHAP 5 - SUMBER REKRUTMEN DAN KOMPOSISI RAS
   Pertanyaan: sumber rekrutmen mana yang menghasilkan karyawan bertahan,
               dan bagaimana komposisi ras per sumber?
   ========================================================================== */

-- 5a. Retensi per sumber rekrutmen
SELECT recruitment_source,
       COUNT(*)                   AS jumlah_rekrut,
       COUNT(*) - SUM(termd)      AS jumlah_bertahan,
       SUM(termd)                 AS jumlah_keluar,
       ROUND(AVG(termd) * 100, 2) AS pct_keluar
FROM acuan_analisis
GROUP BY recruitment_source
ORDER BY pct_keluar ASC, jumlah_rekrut DESC;

-- 5b. Komposisi ras per sumber rekrutmen
WITH komposisi AS (
  SELECT
    recruitment_source,
	race_desc,
	COUNT(*)                                            AS jumlah_per_ras,
	SUM(COUNT(*)) OVER (PARTITION BY recruitment_source) AS total_per_sumber
  FROM acuan_analisis
  GROUP BY recruitment_source, race_desc
)
SELECT recruitment_source, race_desc,
       jumlah_per_ras, total_per_sumber,
       ROUND(jumlah_per_ras * 100.0 / total_per_sumber, 2) AS pct_ras
FROM komposisi
ORDER BY recruitment_source, jumlah_per_ras DESC, race_desc;

/* =============================================================================
   TAHAP 6 - PERFORMA DAN ATTRITION PER MANAGER
   Pertanyaan: apakah ada hubungan manager dengan performa dan attrition?
   Catatan   : - Hanya manager dengan tim >= 20 orang yang dianalisis.
               - 'Board of Directors' dikeluarkan (bukan tim satu manager).
   ========================================================================== */

-- 6a. Performa per manager
SELECT manager_name,
       COUNT(*) AS jumlah_tim,
       ROUND(AVG(performance_score = 'Exceeds') * 100, 2)                       AS persen_exceeds,
       ROUND(AVG(performance_score IN ('Needs Improvement', 'PIP')) * 100, 2)   AS persen_bermasalah
FROM acuan_analisis
WHERE manager_name <> 'Board of Directors'
GROUP BY manager_name
HAVING COUNT(*) >= 20
ORDER BY persen_bermasalah DESC, manager_name ASC;

-- 6b. Attrition per manager
SELECT manager_name,
       COUNT(*)                   AS jumlah_tim,
       SUM(termd)                 AS jumlah_keluar,
       ROUND(AVG(termd) * 100, 2) AS persen_keluar
FROM acuan_analisis
WHERE manager_name <> 'Board of Directors'
GROUP BY manager_name
HAVING COUNT(*) >= 20
ORDER BY persen_keluar DESC, manager_name ASC;

/* =============================================================================
   TAHAP 7 - TENURE DAN UMUR
   Pertanyaan: berapa masa kerja orang yang keluar, dan berapa umur karyawan?
   Catatan   : Umur yang keluar dihitung pada date_of_termination,
               umur yang aktif dihitung pada tanggal acuan '2019-02-28'.
   ========================================================================== */

-- 7a. Ringkasan tenure karyawan yang keluar (dalam bulan)
SELECT
    COUNT(*)                                                               AS jumlah_keluar,
    ROUND(AVG(TIMESTAMPDIFF(MONTH, date_of_hire, date_of_termination)), 1) AS rata_rata_tenure_bulan,
    MIN(TIMESTAMPDIFF(MONTH, date_of_hire, date_of_termination))           AS tenure_min_bulan,
    MAX(TIMESTAMPDIFF(MONTH, date_of_hire, date_of_termination))           AS tenure_max_bulan
FROM acuan_analisis
WHERE termd = 1;

-- 7b. Kelompok tenure karyawan yang keluar
WITH tenure_keluar AS (
  SELECT TIMESTAMPDIFF(MONTH, date_of_hire, date_of_termination) AS tenure_bulan
  FROM acuan_analisis
  WHERE termd = 1
)
SELECT
    CASE WHEN tenure_bulan <= 12 THEN '1. 0-12 bulan'
         WHEN tenure_bulan <= 36 THEN '2. 13-36 bulan'
         WHEN tenure_bulan <= 60 THEN '3. 37-60 bulan' ELSE '4. >60 bulan'
    END AS kelompok_tenure,
    COUNT(*) AS jumlah_keluar
FROM tenure_keluar
GROUP BY kelompok_tenure
ORDER BY kelompok_tenure;

-- 7c. Attrition per kelompok umur
WITH umur_karyawan AS (
  SELECT termd,
	CASE WHEN termd = 1 THEN TIMESTAMPDIFF(YEAR, DOB, date_of_termination) ELSE TIMESTAMPDIFF(YEAR, DOB, '2019-02-28')
	END AS umur
  FROM acuan_analisis
)
SELECT
    CASE WHEN umur < 30              THEN '1. <30 tahun'
         WHEN umur BETWEEN 30 AND 39 THEN '2. 30-39 tahun'
         WHEN umur BETWEEN 40 AND 49 THEN '3. 40-49 tahun' ELSE '4. 50+ tahun'
    END AS kategori_umur,
    COUNT(*)                                  AS jumlah_karyawan,
    SUM(termd)                                AS jumlah_keluar,
    ROUND(SUM(termd) * 100.0 / COUNT(*), 2)   AS persen_keluar
FROM umur_karyawan
GROUP BY kategori_umur
ORDER BY kategori_umur;

/* =============================================================================
   TAHAP 8 - KETIMPANGAN GAJI GENDER DAN RAS
   Pertanyaan: apakah ada ketimpangan gaji pada jabatan yang sama?
   Catatan   : - Dihitung untuk karyawan aktif (termd = 0, 207 orang).
               - Untuk pembanding 311 orang, hapus baris WHERE termd = 0.
   ========================================================================== */

-- 8a. Gaji per position berdasarkan gender
SELECT position,
       SUM(sex = 'F') AS jumlah_f,
       SUM(sex = 'M') AS jumlah_m,
       ROUND(AVG(CASE WHEN sex = 'F' THEN salary END), 2) AS rata_gaji_f,
       ROUND(AVG(CASE WHEN sex = 'M' THEN salary END), 2) AS rata_gaji_m,
       ROUND(AVG(CASE WHEN sex = 'M' THEN salary END) - AVG(CASE WHEN sex = 'F' THEN salary END), 2) AS selisih_m_minus_f
FROM acuan_analisis
WHERE termd = 0
GROUP BY position
HAVING SUM(sex = 'F') >= 3
   AND SUM(sex = 'M') >= 3
ORDER BY position;

-- 8b. Gaji per position berdasarkan ras
SELECT position, race_desc,
       COUNT(*)              AS jumlah_karyawan,
       ROUND(AVG(salary), 2) AS rata_rata_gaji
FROM acuan_analisis
WHERE termd = 0
GROUP BY position, race_desc
HAVING COUNT(*) >= 5
ORDER BY position, race_desc;

/* =============================================================================
   TAHAP 9 - PERFORMA, ABSENSI, KETERLAMBATAN, KEPUASAN
   Pertanyaan: apakah performa, absensi, keterlambatan, dan kepuasan saling terkait?
   Catatan   : Dihitung untuk karyawan aktif. Untuk pembanding 311 orang,
               hapus baris WHERE termd = 0.
   ========================================================================== */

-- 9a. Performa vs keterlambatan, absensi, kepuasan
SELECT performance_score,
       COUNT(*)                                   AS jumlah_karyawan,
       SUM(days_late_last_30 > 0)                 AS jumlah_telat,
       ROUND(100 * AVG(days_late_last_30 > 0), 1) AS persen_telat,
       ROUND(AVG(days_late_last_30), 2)           AS rata_rata_telat_per_orang,
       ROUND(AVG(absences), 2)                    AS rata_rata_absen,
       ROUND(AVG(emp_satisfaction), 2)            AS rata_rata_kepuasan
FROM acuan_analisis
WHERE termd = 0
GROUP BY performance_score
ORDER BY FIELD(performance_score, 'Exceeds', 'Fully Meets', 'Needs Improvement', 'PIP');

-- 9b. Kepuasan vs keterlambatan dan absensi
SELECT emp_satisfaction,
       COUNT(*)                                    AS jumlah_karyawan,
       SUM(days_late_last_30 > 0)                  AS jumlah_telat,
       ROUND(100 * AVG(days_late_last_30 > 0), 1)  AS persen_telat,
       ROUND(AVG(days_late_last_30), 2)            AS rata_rata_telat_per_orang,
       ROUND(AVG(absences), 2)                     AS rata_rata_absen
FROM acuan_analisis
WHERE termd = 0
GROUP BY emp_satisfaction
ORDER BY emp_satisfaction;

-- 9c. Keterlambatan vs absensi
SELECT
    CASE WHEN days_late_last_30 > 0 THEN 'pernah telat' ELSE 'tidak pernah telat' END AS status_telat,
    COUNT(*)                AS jumlah_karyawan,
    ROUND(AVG(absences), 2) AS rata_rata_absen
FROM acuan_analisis
WHERE termd = 0
GROUP BY status_telat
ORDER BY status_telat DESC;

/* =============================================================================
   TAHAP 10 - PERINGKAT GAJI DAN KONTRIBUSI
   Pertanyaan: siapa yang aktif ikut banyak proyek khusus tetapi gajinya
               di separuh bawah department-nya?
   Catatan   : 'Proyek khusus tinggi' bersifat relatif: 2 nilai tertinggi di department.
   ========================================================================== */

WITH peringkat AS (
  SELECT emp_id, department,
		 position, salary, SpecialProjectsCount,
         COUNT(*) OVER (PARTITION BY department)                                        AS jumlah_di_departemen,
         RANK() OVER (PARTITION BY department ORDER BY salary ASC)                      AS peringkat_gaji_terendah,
         DENSE_RANK() OVER (PARTITION BY department ORDER BY SpecialProjectsCount DESC) AS peringkat_proyek
  FROM acuan_analisis
  WHERE termd = 0
)
SELECT *
FROM peringkat
WHERE jumlah_di_departemen >= 30
  AND SpecialProjectsCount > 0
  AND peringkat_proyek <= 2
  AND peringkat_gaji_terendah <= jumlah_di_departemen / 2
ORDER BY department, peringkat_proyek, peringkat_gaji_terendah;


/* =============================================================================
   TAHAP 11 - QUERY PENDUKUNG 4 INSIGHT AKHIR
   Insight 4 memakai query Tahap 10 di atas.
   ========================================================================== */

-- Insight 1: attrition terkonsentrasi di Production
SELECT department,
       COUNT(*)                              AS jumlah_karyawan,
       SUM(termd)                            AS jumlah_keluar,
       ROUND(SUM(termd) / COUNT(*) * 100, 1) AS persen_attrition
FROM acuan_analisis
GROUP BY department
HAVING COUNT(*) >= 30
ORDER BY persen_attrition DESC;
-- Hasil: Production 209 / 83 / 39,7% | IT/IS 50 / 10 / 20,0% | Sales 31 / 5 / 16,1%

-- Insight 2: attrition per sumber rekrutmen, dikontrol ke department Production
SELECT recruitment_source,
       COUNT(*)                              AS jumlah_hire,
       SUM(termd)                            AS jumlah_keluar,
       ROUND(SUM(termd) / COUNT(*) * 100, 1) AS persen_attrition
FROM acuan_analisis
WHERE department = 'Production'
GROUP BY recruitment_source
ORDER BY persen_attrition DESC;
-- Hasil (total 209 hire, 83 keluar): Diversity Job Fair 17 / 11 / 64,7% | Google Search 44 / 27 / 61,4%
--   LinkedIn 61 / 14 / 23,0% | Employee Referral 16 / 2 / 12,5%

-- Insight 3a: rata-rata gaji per gender
SELECT sex,
    COUNT(*)              AS jumlah,
    ROUND(AVG(salary))    AS rata_gaji
FROM acuan_analisis
GROUP BY sex;
-- Hasil: M 135 orang 70.629 | F 176 orang 67.787 (selisih sekitar 4%)

-- Insight 3b: gaji per position dan gender (minimal 5 orang per kelompok)
SELECT position, sex,
       COUNT(*)            AS jumlah,
       ROUND(AVG(salary))  AS rata_gaji
FROM acuan_analisis
GROUP BY position, sex
HAVING COUNT(*) >= 5
ORDER BY position, sex;
-- Hasil: 11 baris. Arah selisih campur: F lebih rendah di Area Sales Manager dan Production Manager,
--   sedikit lebih tinggi di Production Technician I dan II.
--   Posisi kecil tersembunyi oleh HAVING (mis. Data Analyst hanya muncul untuk M).