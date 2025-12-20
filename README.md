# rumahku

Rumahku adalah platform manajemen proyek konstruksi dan renovasi berbasis mobile yang mengintegrasikan komunikasi antara pemilik bangunan, mandor, dan kepala proyek dalam satu ekosistem digital. Aplikasi ini dibangun dengan arsitektur Full-stack REST API menggunakan Flutter dan CodeIgniter 4

## fitur

Aplikasi ini mendukung sistem Multi-Role dengan hak akses yang berbeda melalui pengamanan JWT (JSON Web Token):

Administrator: Mengelola data pengguna dan mendistribusikan proyek kepada tim lapangan
Mandor: Melaporkan progres harian lengkap dengan dokumentasi foto lapangan
Kepala Proyek: Memantau beberapa proyek sekaligus dan memverifikasi laporan dari mandor
Pemilik Bangunan: Memantau perkembangan rumah mereka

### Frontend
<li>Flutter: Framework utama</li>
<li>GetX: State management, routing, dan dependency</li>
<li>HTTP: Komunikasi data asinkron dengan REST API</li>

### Backend
<li>CodeIgniter 4: Framework</li>
<li>Firebase JWT: Otentikasi</li>
<li>CORS Filter: Akses API perangkat mobile</li>
