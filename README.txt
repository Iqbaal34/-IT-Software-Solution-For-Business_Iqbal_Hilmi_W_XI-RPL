Nama : Iqbal Hilmi Wibowo
Kelas : XI RPL

Intruksi Penggunakan Projek CekStok Mobile App

Syarat
1. Flutter
2. Visual Studio Code
3. Android Studio

Cara Install Flutter ( Khusus yang Belum Download Flutter )
1. Unduh Flutter SDK
Kunjungi https://flutter.dev/ Download dan unduh Flutter untuk sistem operasi kamu.

Ekstrak file ZIP ke folder, misalnya C:\src\flutter (Windows) atau ~/flutter (macOS/Linux).

2. Menambahkan Flutter ke Path
Windows:

Buka Environment Variables.

Tambahkan path ke folder flutter/bin, misalnya C:\src\flutter\bin pada variabel Path.

macOS/Linux:

Buka terminal dan edit file konfigurasi shell (~/.bash_profile atau ~/.zshrc).

Tambahkan:

bash
Copy
Edit
export PATH="$PATH:/path/to/flutter/bin"
Simpan dan jalankan source ~/.bash_profile (atau source ~/.zshrc).

3. Cek Instalasi dengan flutter doctor
Jalankan terminal atau command prompt, lalu ketik:

nginx
Copy
Edit
flutter doctor
Ikuti instruksi untuk menyelesaikan instalasi, jika ada masalah.

4. (Opsional) Install Android Studio
Unduh Android Studio dari sini, dan install plugin Flutter dan Dart.


Cara Run Project CekStok

1. Clone / Download Projek
Pastikan kamu sudah memiliki folder project CekStok di dalam komputer.

Buka folder tersebut di VS Code atau Android Studio.

2. Buka Terminal / Command Line
Di dalam VS Code, buka Terminal > New Terminal

Jalankan perintah berikut:

bash
Copy
Edit
flutter pub get
Perintah ini akan mengunduh semua dependency (package) yang dibutuhkan oleh aplikasi.

3. Update Flutter SDK (Opsional)
Jika terjadi error atau warning yang berkaitan dengan versi Flutter, kamu bisa update dengan:

bash
Copy
Edit
flutter upgrade
4. Menjalankan Aplikasi
Hubungkan HP kamu atau jalankan emulator Android

Lalu jalankan aplikasi dengan perintah:

bash
Copy
Edit
flutter run
