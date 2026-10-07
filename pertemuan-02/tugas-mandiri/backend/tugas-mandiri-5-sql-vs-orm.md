# Tugas Mandiri 5 — Membandingkan SQL Mentah dan ORM

## 1. Tujuan

Tugas ini bertujuan untuk memahami perbedaan antara penggunaan **SQL mentah (raw SQL)** dan **ORM (Object-Relational Mapping)** dalam mengakses database.

Operasi database yang digunakan adalah **mengambil satu data jadwal berdasarkan ID** dari tabel `jadwal`.

---

## 2. Contoh Struktur Tabel

Pada tugas ini digunakan tabel `jadwal` dengan contoh struktur sebagai berikut:

```sql
CREATE TABLE jadwal (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mata_kuliah VARCHAR(100),
    dosen VARCHAR(100),
    hari VARCHAR(20),
    jam_mulai TIME,
    jam_selesai TIME
);
```

Contoh data:

```sql
INSERT INTO jadwal 
(mata_kuliah, dosen, hari, jam_mulai, jam_selesai)
VALUES
('Pemrograman Platform', 'Ahmad', 'Senin', '08:00:00', '10:00:00');
```

---

# 3. A. SQL Mentah

SQL mentah adalah pendekatan ketika programmer menuliskan perintah SQL secara langsung untuk berkomunikasi dengan database.

Contoh SQL:

```sql
SELECT *
FROM jadwal
WHERE id = ?;
```

Tanda `?` digunakan sebagai placeholder untuk nilai ID yang akan diberikan ketika query dijalankan.

Jika menggunakan Node.js dan library `mysql2`, implementasinya dapat ditulis sebagai berikut:

```javascript
const mysql = require('mysql2/promise');

const connection = await mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'kampus'
});

const id = 1;

const [rows] = await connection.execute(
  'SELECT * FROM jadwal WHERE id = ?',
  [id]
);

console.log(rows);

await connection.end();
```

Pada kode tersebut, nilai `id` dikirim melalui parameter `[id]`, bukan digabungkan langsung ke dalam string SQL.

---

# 4. B. ORM dengan Prisma

ORM atau **Object-Relational Mapping** memungkinkan programmer mengakses database menggunakan objek dan method yang disediakan oleh ORM tanpa harus menulis seluruh SQL secara langsung.

Contoh menggunakan Prisma:

```javascript
const jadwal = await prisma.jadwal.findUnique({
  where: {
    id: 1
  }
});

console.log(jadwal);
```

Kode tersebut memiliki tujuan yang sama dengan SQL:

```sql
SELECT *
FROM jadwal
WHERE id = 1;
```

Perbedaannya adalah Prisma menyediakan method `findUnique()` untuk mengambil satu data berdasarkan nilai yang unik, dalam hal ini `id`.

---

# 5. Perbandingan SQL Mentah dan ORM

| Aspek                  | SQL Mentah                                     | ORM                                                 |
| ---------------------- | ---------------------------------------------- | --------------------------------------------------- |
| Cara penggunaan        | Menulis perintah SQL secara langsung           | Menggunakan object dan method ORM                   |
| Kontrol terhadap query | Sangat tinggi                                  | Lebih banyak menggunakan abstraksi ORM              |
| Kemudahan penggunaan   | Membutuhkan pemahaman SQL                      | Lebih mudah untuk operasi umum                      |
| Fleksibilitas          | Sangat fleksibel                               | Bergantung pada fitur ORM                           |
| Kecepatan pengembangan | Dapat lebih lama untuk kode yang kompleks      | Umumnya lebih cepat untuk CRUD                      |
| Pemeliharaan kode      | Query SQL perlu dikelola sendiri               | Struktur kode lebih terorganisasi melalui model ORM |
| Keamanan               | Harus menggunakan parameter query dengan benar | Banyak ORM membantu menangani parameterisasi query  |

---

# 6. Jawaban Pertanyaan

## 6.1 Apa perbedaan SQL mentah dan ORM?

SQL mentah adalah pendekatan dengan menuliskan perintah SQL secara langsung untuk melakukan operasi terhadap database. Programmer memiliki kontrol yang lebih besar terhadap query yang dijalankan.

Sedangkan ORM menyediakan abstraksi antara aplikasi dan database. Programmer dapat menggunakan object, model, dan method seperti `findUnique()`, `findMany()`, `create()`, `update()`, dan `delete()` untuk melakukan operasi database.

Contohnya:

**SQL mentah:**

```sql
SELECT *
FROM jadwal
WHERE id = ?;
```

**ORM Prisma:**

```javascript
const jadwal = await prisma.jadwal.findUnique({
  where: {
    id: 1
  }
});
```

Keduanya memiliki tujuan yang sama, yaitu mengambil data `jadwal` berdasarkan `id`.

---

## 6.2 Apa kelebihan SQL mentah?

Kelebihan SQL mentah antara lain:

1. Memberikan kontrol penuh terhadap query yang dijalankan.
2. Dapat digunakan untuk query yang kompleks.
3. Programmer dapat menggunakan fitur khusus yang tersedia pada database.
4. Programmer dapat mengoptimalkan query secara langsung.
5. Tidak terlalu bergantung pada fitur atau sintaks ORM tertentu.

---

## 6.3 Apa kelebihan ORM?

Kelebihan ORM antara lain:

1. Kode lebih mudah dibaca karena menggunakan model dan method.
2. Mempermudah operasi CRUD.
3. Mengurangi kebutuhan menulis SQL secara manual.
4. Membantu mengelola relasi antar tabel.
5. Membuat kode aplikasi lebih terstruktur.
6. ORM seperti Prisma dapat membantu melakukan validasi dan parameterisasi query.

---

## 6.4 Apa risiko SQL Injection?

SQL Injection adalah serangan ketika input dari pengguna dimasukkan ke dalam query SQL dengan cara yang tidak aman sehingga penyerang dapat memanipulasi query tersebut.

Contoh kode yang tidak aman:

```javascript
const id = req.query.id;

const query = `SELECT * FROM jadwal WHERE id = ${id}`;

const [rows] = await connection.query(query);
```

Jika input pengguna tidak divalidasi dengan benar, input tersebut dapat digunakan untuk memanipulasi perintah SQL.

Oleh karena itu, data dari pengguna tidak sebaiknya langsung digabungkan ke dalam string query SQL.

---

## 6.5 Mengapa penggunaan parameter query dapat mengurangi risiko SQL Injection?

Parameter query memisahkan **perintah SQL** dari **data yang diberikan pengguna**.

Contohnya:

```javascript
const id = req.query.id;

const [rows] = await connection.execute(
  'SELECT * FROM jadwal WHERE id = ?',
  [id]
);
```

Pada kode tersebut, `?` merupakan placeholder dan nilai `id` diberikan secara terpisah.

Dengan cara ini, nilai yang diberikan pengguna diperlakukan sebagai **data**, bukan sebagai bagian dari perintah SQL.

Parameter query dapat mengurangi risiko SQL Injection, tetapi tetap diperlukan validasi input dan praktik keamanan lainnya.

---

## 6.6 Bagaimana ORM membantu programmer dalam mengakses database?

ORM membantu programmer dengan menyediakan interface berupa model dan method untuk melakukan operasi database.

Sebagai contoh, untuk mengambil satu jadwal berdasarkan ID, programmer cukup menggunakan:

```javascript
const jadwal = await prisma.jadwal.findUnique({
  where: {
    id: 1
  }
});
```

Programmer tidak perlu menulis query SQL secara langsung untuk operasi tersebut.

ORM juga dapat membantu dalam:

* melakukan operasi CRUD;
* mengelola relasi antar tabel;
* melakukan query berdasarkan kondisi tertentu;
* mengurangi penulisan SQL berulang;
* menjaga kode database agar lebih terstruktur.

---

# 7. Kesimpulan

SQL mentah dan ORM sama-sama dapat digunakan untuk mengakses database, tetapi keduanya memiliki pendekatan yang berbeda. SQL mentah memberikan kontrol yang lebih besar terhadap query, sedangkan ORM memberikan abstraksi sehingga programmer dapat mengakses database menggunakan model dan method yang lebih mudah digunakan.

Dalam contoh pengambilan data tabel `jadwal`, SQL mentah menggunakan:

```sql
SELECT *
FROM jadwal
WHERE id = ?;
```

Sedangkan Prisma menggunakan:

```javascript
const jadwal = await prisma.jadwal.findUnique({
  where: {
    id: 1
  }
});
```

SQL mentah cocok ketika programmer membutuhkan kontrol penuh terhadap query, sedangkan ORM cocok untuk mempercepat pengembangan aplikasi dan mempermudah pengelolaan operasi database. Dalam kedua pendekatan tersebut, penggunaan parameter query dan praktik keamanan yang tepat penting untuk mengurangi risiko SQL Injection.
