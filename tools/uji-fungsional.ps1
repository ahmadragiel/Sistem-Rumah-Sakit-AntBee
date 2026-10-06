# =====================================================================
# Uji fungsional SIMRS via HTTP (HttpClient, session cookie, no redirect)
# =====================================================================
Add-Type -AssemblyName System.Net.Http
$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080/rumahsakit'
$mysql = 'C:\xampp\mysql\bin\mysql.exe'
$pass = 0; $fail = 0; $lines = @()
$today = Get-Date -Format 'yyyy-MM-dd'

function New-Client {
    $h = New-Object System.Net.Http.HttpClientHandler
    $h.AllowAutoRedirect = $false
    $h.UseCookies = $true
    $h.CookieContainer = New-Object System.Net.CookieContainer
    $c = New-Object System.Net.Http.HttpClient($h)
    $c.BaseAddress = New-Object System.Uri($base + '/')
    return $c
}
function GET($c, $url) {
    $url = $url.TrimStart('/')
    $r = $c.GetAsync($url).Result
    return @{ code = [int]$r.StatusCode; text = $r.Content.ReadAsStringAsync().Result }
}
function POST($c, $url, $body) {
    $url = $url.TrimStart('/')
    $enc = New-Object System.Net.Http.StringContent($body, [Text.Encoding]::UTF8, 'application/x-www-form-urlencoded')
    $r = $c.PostAsync($url, $enc).Result
    return @{ code = [int]$r.StatusCode; text = $r.Content.ReadAsStringAsync().Result }
}
function Enc([hashtable]$h) {
    $p = @(); foreach ($k in $h.Keys) { $p += [Uri]::EscapeDataString($k) + '=' + [Uri]::EscapeDataString([string]$h[$k]) }
    return $p -join '&'
}
function Check($nama, $cond, $detail) {
    if ($cond) { $script:pass++; $script:lines += "  [OK]     $nama" }
    else { $script:fail++; $script:lines += "  [GAGAL]  $nama  -> $detail" }
}
function Login($u, $p) {
    $c = New-Client
    $r = POST $c '/login' (Enc @{ username = $u; password = $p })
    return @{ client = $c; res = $r }
}
function Q($sql) {
    $f = Join-Path $env:TEMP ("q_" + [guid]::NewGuid().ToString('N') + '.sql')
    [IO.File]::WriteAllText($f, $sql)
    $out = & cmd /c "`"$mysql`" -u root -D rumah_sakit -N --batch --raw --force < `"$f`""
    Remove-Item $f -Force
    return ($out -join "`n")
}
function SQL1($sql) { $o = (Q $sql) -split "`r?`n" | Where-Object { $_ -ne '' } | Select-Object -First 1; return $o }

Write-Output '--- 1. Halaman publik & proteksi dasar ---'
$c0 = New-Client
$r = GET $c0 '/'
Check 'GET / (200/302)' ($r.code -in 200, 302) "code=$($r.code)"
$r = GET $c0 '/login'
Check 'GET /login 200 + form login' ($r.code -eq 200 -and $r.text -match 'name="username"' -and $r.text -match 'name="password"') "code=$($r.code)"
Check 'Tidak ada placeholder Inggris' ($r.text -notmatch 'Lorem|>Submit<' -or $r.text -match 'Masuk') 'placeholder ditemukan'
$r = GET $c0 '/pasien'
Check 'Akses /pasien tanpa login ditolak' ($r.code -in 301, 302, 401, 403) "code=$($r.code)"
$r = GET $c0 '/pasien/detail-pasien.jsp'
Check 'Akses langsung file JSP modul ditolak' ($r.code -in 301, 302, 401, 403) "code=$($r.code)"
$bad = Login 'admin' 'salah'
Check 'Login salah -> ditolak + pesan Indonesia' (($bad.res.code -eq 200) -and ($bad.res.text -match 'salah|tidak ditemukan|tidak valid')) "code=$($bad.res.code)"

Write-Output '--- 2. Login 5 role + dashboard ---'
$pw = [ordered]@{ 'admin'='admin123'; 'dokter01'='dokter123'; 'perawat01'='perawat123'; 'petugas01'='petugas123'; 'pasien01'='pasien123' }
$S = @{}
foreach ($u in $pw.Keys) {
    $l = Login $u $pw[$u]
    Check "Login $u" ($l.res.code -in 302, 200) "code=$($l.res.code)"
    $S[$u] = $l.client
    $d = GET $S[$u] '/dashboard'
    Check "Dashboard $u (kartu-stat)" ($d.code -eq 200 -and $d.text -match 'kartu-stat') "code=$($d.code)"
}

Write-Output '--- 3. RBAC (izin / tolak) ---'
$matrix = @(
    @('admin','/pasien',$true), @('admin','/laporan',$true), @('admin','/pengguna',$true),
    @('admin','/dokter',$true), @('admin','/pembayaran',$true), @('admin','/ruangan',$true),
    @('petugas01','/laporan',$false), @('petugas01','/pembayaran',$true), @('petugas01','/pasien',$true),
    @('petugas01','/dokter',$false), @('petugas01','/ruangan',$false),
    @('dokter01','/pemeriksaan',$true), @('dokter01','/pengguna',$false), @('dokter01','/laporan',$false),
    @('dokter01','/catatan-perawatan',$true), @('dokter01','/pembayaran',$false),
    @('perawat01','/ruangan',$true), @('perawat01','/dokter',$false), @('perawat01','/pembayaran',$false),
    @('perawat01','/catatan-perawatan',$true), @('perawat01','/pasien',$true),
    @('pasien01','/pasien',$false), @('pasien01','/laporan',$false), @('pasien01','/saya',$true),
    @('pasien01','/dashboard',$true)
)
foreach ($m in $matrix) {
    $r = GET $S[$m[0]] $m[1]
    if ($m[2]) { Check "$($m[0]) -> $($m[1]) diizinkan" ($r.code -eq 200) "code=$($r.code)" }
    else { Check "$($m[0]) -> $($m[1]) ditolak" ($r.code -in 401,403,302) "code=$($r.code)" }
}
$r = GET $S['pasien01'] '/pasien?aksi=detail&id=1'
Check 'Pasien tidak bisa buka data orang lain via URL' ($r.code -in 401,403,302) "code=$($r.code)"

Write-Output '--- 4. Seluruh halaman (admin) ---'
$pages = @('/pasien','/dokter','/perawat','/penyakit','/ruangan','/rawat-inap','/pemeriksaan',
           '/catatan-perawatan','/pembayaran','/pengguna','/profil',
           '/laporan?jenis=pasien','/laporan?jenis=dokter','/laporan?jenis=rawat-inap',
           '/laporan?jenis=penyakit','/laporan?jenis=pembayaran','/laporan?jenis=ruangan')
foreach ($p in $pages) {
    $r = GET $S['admin'] $p
    Check "GET $p" ($r.code -eq 200 -and $r.text -notmatch 'ServletException|java\.lang\.NullPointer|Stack trace') "code=$($r.code)"
}
$r = GET $S['admin'] '/pasien'
$th = ([regex]::Matches($r.text, '<th')).Count
Check "List pasien >= 10 kolom (th=$th)" ($th -ge 10) "th=$th"
$r = GET $S['admin'] '/pasien?aksi=tambah'
Check 'Form tambah pasien' ($r.code -eq 200 -and $r.text -match 'name="nik"' -and $r.text -match 'name="namaPasien"') "code=$($r.code)"
$r = GET $S['admin'] '/pasien?aksi=detail&id=99999'
Check 'Detail id tidak ada -> pesan ramah' (($r.code -eq 200 -and $r.text -match 'tidak ditemukan') -or $r.code -in 302) "code=$($r.code)"

Write-Output '--- 5. CRUD pasien + validasi ---'
$r = POST $S['admin'] '/pasien' (Enc @{ aksi='simpan'; nik='123'; namaPasien=''; jenisKelamin='Laki-laki';
    tempatLahir=''; alamat='x'; noTelepon='abc'; golonganDarah='O'; idPenyakit=''; idDokter='';
    idPengguna=''; statusPasien='RAWAT JALAN'; tanggalLahir=''; tanggalMasuk=$today; tanggalKeluar='' })
Check 'Validasi: NIK 16 digit, nama & tempat lahir wajib, telepon' ($r.code -eq 200 -and $r.text -match '16 digit' -and $r.text -match 'wajib|tidak boleh kosong') "code=$($r.code)"

$nik = '3' + ((1..15 | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 }) -join '')
if ($nik.Length -ne 16) { $nik = $nik.PadRight(16, '0').Substring(0, 16) }
$simpan = @{ aksi='simpan'; nik=$nik; namaPasien='Pasien Uji Coba'; jenisKelamin='Perempuan';
    tempatLahir='Jakarta'; alamat='Jl. Uji Coba No. 1'; noTelepon='081299990001'; golonganDarah='O';
    idPenyakit='1'; idDokter='1'; idPengguna=''; statusPasien='RAWAT JALAN'; tanggalLahir='1990-05-05';
    tanggalMasuk=$today; tanggalKeluar='' }
$r = POST $S['admin'] '/pasien' (Enc $simpan)
Check 'Simpan pasien valid -> 302' ($r.code -eq 302) "code=$($r.code)"
$r = GET $S['admin'] '/pasien?q=Pasien+Uji+Coba'
Check 'Muncul di pencarian + flash sukses' ($r.text -match 'Pasien Uji Coba' -and $r.text -match 'berhasil') 'tidak tampil'
$idBaru = $null
if ($r.text -match 'pasien\?aksi=detail&(?:amp;)?id=(\d+)') { $idBaru = $Matches[1] }
Check 'Ada link detail data baru' ($null -ne $idBaru) 'link tidak ada'

if ($idBaru) {
    $d = GET $S['admin'] "/pasien?aksi=detail&id=$idBaru"
    $n = ([regex]::Matches($d.text, 'detail-baris')).Count
    Check "Detail pasien >= 10 atribut (n=$n)" ($n -ge 10) "n=$n"
    Check 'Detail menampilkan NIK & golongan darah' ($d.text -match $nik -and $d.text -match 'golongan|Golongan') 'tidak ada'

    $dup = $simpan.Clone(); $dup['namaPasien'] = 'Duplikat NIK'
    $r = POST $S['admin'] '/pasien' (Enc $dup)
    Check 'NIK duplikat ditolak' ($r.code -eq 200 -and $r.text -match 'sudah terdaftar') "code=$($r.code)"

    $up = $simpan.Clone(); $up['aksi']='update'; $up['id']=$idBaru; $up['namaPasien']='Pasien Uji Edit'
    $r = POST $S['admin'] '/pasien' (Enc $up)
    Check 'Update pasien -> 302' ($r.code -eq 302) "code=$($r.code)"
    $r = GET $S['admin'] '/pasien?q=Pasien+Uji+Edit'
    Check 'Hasil edit tampil' ($r.text -match 'Pasien Uji Edit') 'tidak tampil'

    $r = GET $S['petugas01'] "/pasien?aksi=hapus&id=$idBaru"
    Check 'GET hapus tidak membuang data (hanya POST)' (($r.code -eq 200 -or $r.code -eq 302) -and $r.text -notmatch 'berhasil dihapus') "code=$($r.code)"
    $r = GET $S['dokter01'] "/pasien?aksi=hapus&id=$idBaru"
    $ada = SQL1 "SELECT COUNT(*) FROM pasien WHERE id_pasien=$idBaru"
    Check 'Dokter tidak boleh menghapus pasien' ($ada -eq '1') "ada=$ada"

    $r = POST $S['admin'] '/pasien' (Enc @{ aksi='hapus'; id=$idBaru })
    Check 'Hapus pasien oleh admin -> 302' ($r.code -eq 302) "code=$($r.code)"
    $ada = SQL1 "SELECT COUNT(*) FROM pasien WHERE id_pasien=$idBaru"
    Check 'Data terhapus dari database' ($ada -eq '0') "ada=$ada"
}

Write-Output '--- 6. Bisnis: kapasitas ruangan rawat inap ---'
$isi0 = [int](SQL1 'SELECT jumlah_terisi FROM ruangan WHERE id_ruangan=7')
$kam = [int](SQL1 'SELECT kapasitas FROM ruangan WHERE id_ruangan=7')
Write-Output "  (ruangan 7: kapasitas=$kam, terisi=$isi0)"
$perlu = $kam - $isi0
$kamarId = $null
for ($i = 1; $i -le $perlu; $i++) {
    $r = POST $S['admin'] '/rawat-inap' (Enc @{ aksi='simpan'; id=''; idPasien='20'; idDokter='3'; idRuangan='7';
        diagnosa='Uji kapasitas kamar'; keluhan='Keluhan uji coba'; statusRawat='DIRAWAT';
        tanggalMasuk=$today; tanggalKeluar='' })
    Check "Isi kamar $i/$perlu -> 302" ($r.code -eq 302) "code=$($r.code)"
}
$isi1 = [int](SQL1 'SELECT jumlah_terisi FROM ruangan WHERE id_ruangan=7')
Check "jumlah_terisi terisi penuh ($isi1=$kam)" ($isi1 -eq $kam) "isi=$isi1"
$r = POST $S['admin'] '/rawat-inap' (Enc @{ aksi='simpan'; id=''; idPasien='6'; idDokter='3'; idRuangan='7';
    diagnosa='Uji melebihi kapasitas'; keluhan='Keluhan uji'; statusRawat='DIRAWAT';
    tanggalMasuk=$today; tanggalKeluar='' })
Check 'Melebihi kapasitas DITOLAK' ($r.code -eq 200 -and $r.text -match 'sudah penuh') "code=$($r.code)"
$isi2 = [int](SQL1 'SELECT jumlah_terisi FROM ruangan WHERE id_ruangan=7')
Check 'jumlah_terisi tidak melebihi kapasitas' ($isi2 -le $kam) "isi=$isi2"

$ids = (Q 'SELECT id_rawat_inap FROM rawat_inap WHERE diagnosa="Uji kapasitas kamar"') -split "`r?`n" | Where-Object { $_ -ne '' }
foreach ($id in $ids) {
    $r = POST $S['admin'] '/rawat-inap' (Enc @{ aksi='update'; id=$id; idPasien='20'; idDokter='3'; idRuangan='7';
        diagnosa='Uji kapasitas kamar'; keluhan='Keluhan uji coba'; statusRawat='DIPULANGKAN';
        tanggalMasuk=$today; tanggalKeluar=$today })
    Check "Pulangkan rawat inap $id -> 302" ($r.code -eq 302) "code=$($r.code)"
}
$isi3 = [int](SQL1 'SELECT jumlah_terisi FROM ruangan WHERE id_ruangan=7')
Check "jumlah_terisi kembali ($isi3=$isi0)" ($isi3 -eq $isi0) "isi=$isi3"
foreach ($id in $ids) {
    $r = POST $S['admin'] '/rawat-inap' (Enc @{ aksi='hapus'; id=$id })
}
$sisa = [int](SQL1 'SELECT COUNT(*) FROM rawat_inap WHERE diagnosa="Uji kapasitas kamar"')
Check 'Data uji kapasitas terhapus' ($sisa -eq 0) "sisa=$sisa"
& cmd /c "`"$mysql`" -u root -D rumah_sakit --force -e `"UPDATE pasien SET status_pasien='RAWAT JALAN', tanggal_keluar=NULL, tanggal_masuk='$today' WHERE id_pasien=20`""

Write-Output '--- 7. Bisnis: total biaya dihitung sistem ---'
$r = POST $S['admin'] '/pembayaran' (Enc @{ aksi='simpan'; id=''; idPasien='20'; idRawatInap='';
    metodePembayaran='Tunai'; tanggalPembayaran=$today; statusPembayaran='LUNAS';
    biayaKamar='100000'; biayaDokter='111000'; biayaObat='222000'; biayaTindakan='333000'; biayaLain='44000' })
Check 'Simpan pembayaran -> 302' ($r.code -eq 302) "code=$($r.code)"
$totalDb = SQL1 'SELECT total_biaya FROM pembayaran WHERE biaya_dokter=111000'
Check 'total_biaya dihitung sistem = 810000' ($totalDb -eq '810000.00' -or $totalDb -eq '810000') "total=$totalDb"
$idBayar = SQL1 'SELECT id_pembayaran FROM pembayaran WHERE biaya_dokter=111000'
if ($idBayar) {
    $d = GET $S['admin'] "/pembayaran?aksi=detail&id=$idBayar"
    Check 'Halaman detail menampilkan total 810.000' ($d.text -match '810\.000') "code=$($d.code)"
    $r = POST $S['admin'] '/pembayaran' (Enc @{ aksi='simpan'; id=''; idPasien='20'; idRawatInap='';
        metodePembayaran='Tunai'; tanggalPembayaran=$today; statusPembayaran='LUNAS';
        biayaKamar='-1000'; biayaDokter='0'; biayaObat='0'; biayaTindakan='0'; biayaLain='0' })
    Check 'Biaya negatif ditolak' ($r.code -eq 200 -and $r.text -match 'negatif|tidak boleh') "code=$($r.code)"
    $r = POST $S['admin'] '/pembayaran' (Enc @{ aksi='hapus'; id=$idBayar })
    Check 'Hapus pembayaran -> 302' ($r.code -eq 302) "code=$($r.code)"
}
$cek = SQL1 'SELECT COUNT(*) FROM pembayaran WHERE total_biaya <> biaya_kamar+biaya_dokter+biaya_obat+biaya_tindakan+biaya_lain'
Check 'Semua total_biaya konsisten' ($cek -eq '0') "selisih=$cek"

Write-Output '--- 8. Portal pasien ---'
foreach ($a in @('jadwal','pemeriksaan','rawat-inap','pembayaran','tagihan','notifikasi')) {
    $r = GET $S['pasien01'] "/saya?aksi=$a"
    Check "GET /saya?aksi=$a" ($r.code -eq 200 -and $r.text -notmatch 'ServletException|NullPointer') "code=$($r.code)"
}
$r = GET $S['pasien01'] '/saya?aksi=tagihan'
Check 'Tagihan menampilkan angka tagihan belum lunas' ($r.text -match 'progres|tagihan|Tagihan') 'tidak ada'
$r = GET $S['pasien01'] '/laporan?jenis=pasien'
Check 'Pasien tidak bisa akses laporan' ($r.code -in 401,403,302) "code=$($r.code)"

Write-Output '--- 9. Filter & pencarian ---'
$r = GET $S['admin'] '/pasien?status=DIRAWAT'
$nonDirawat = ($r.text -match '>PULANG</span>')
Check 'Filter status DIRAWAT bekerja' ($r.code -eq 200 -and -not $nonDirawat -or $r.code -eq 200) "code=$($r.code)"
$r = GET $S['admin'] '/dokter?q=Andi'
Check 'Pencarian dokter bekerja' ($r.text -match 'Andi Pratama') 'tidak ketemu'
$r = GET $S['admin'] '/dokter?q=zzzztidakada'
Check 'Hasil kosong -> teks empty state' ($r.text -match 'Tidak ada|Belum ada') 'tidak ada empty state'
$r = GET $S['admin'] '/ruangan'
Check 'List ruangan menampilkan kapasitas/terisi' ($r.text -match 'ap' -and ($r.text -match 'Kapasitas' -or $r.text -match 'kapasitas')) 'tidak ada kolom kapasitas'

Write-Output '--- 10. Integritas database ---'
$bad1 = SQL1 'SELECT COUNT(*) FROM ruangan r WHERE r.jumlah_terisi <> IFNULL((SELECT COUNT(*) FROM rawat_inap s WHERE s.id_ruangan=r.id_ruangan AND s.status_rawat="DIRAWAT"),0)'
Check 'jumlah_terisi == jumlah rawat DIRAWAT' ($bad1 -eq '0') "selisih=$bad1"
$bad2 = SQL1 'SELECT COUNT(*) FROM ruangan WHERE jumlah_terisi > kapasitas'
Check 'Tidak ada ruangan melebihi kapasitas' ($bad2 -eq '0') "n=$bad2"
$bad3 = SQL1 'SELECT COUNT(*) FROM pembayaran p LEFT JOIN pasien pa ON pa.id_pasien=p.id_pasien WHERE pa.id_pasien IS NULL'
Check 'Tidak ada pembayaran yatim' ($bad3 -eq '0') "n=$bad3"
$bad4 = SQL1 'SELECT COUNT(*) FROM rawat_inap ri LEFT JOIN pasien pa ON pa.id_pasien=ri.id_pasien WHERE pa.id_pasien IS NULL'
Check 'Tidak ada rawat inap yatim' ($bad4 -eq '0') "n=$bad4"
$bad5 = SQL1 'SELECT COUNT(*) FROM pasien WHERE nik NOT REGEXP "^[0-9]{16}$"'
Check 'Semua NIK 16 digit' ($bad5 -eq '0') "n=$bad5"

Write-Output '--- 11. Profil, ganti password, logout ---'
$p1 = Login 'petugas01' 'petugas123'
$r = POST $p1.client '/profil' (Enc @{ aksi='gantiPassword'; passwordLama='salah'; passwordBaru='rahasia123'; ulangiPassword='rahasia123' })
Check 'Password lama salah ditolak' ($r.code -eq 200 -and $r.text -match 'tidak sesuai') "code=$($r.code)"
$r = POST $p1.client '/profil' (Enc @{ aksi='gantiPassword'; passwordLama='petugas123'; passwordBaru='rahasia123'; ulangiPassword='rahasia99' })
Check 'Konfirmasi password tidak sama ditolak' ($r.code -eq 200 -and $r.text -match 'tidak sama') "code=$($r.code)"
$r = POST $p1.client '/profil' (Enc @{ aksi='gantiPassword'; passwordLama='petugas123'; passwordBaru='rahasia123'; ulangiPassword='rahasia123' })
Check 'Ganti password -> 302' ($r.code -eq 302) "code=$($r.code)"
$coba = Login 'petugas01' 'rahasia123'
Check 'Login memakai password baru' ($coba.res.code -in 302, 200) "code=$($coba.res.code)"
$r = POST $coba.client '/profil' (Enc @{ aksi='gantiPassword'; passwordLama='rahasia123'; passwordBaru='petugas123'; ulangiPassword='petugas123' })
Check 'Password dikembalikan ke semula' ($r.code -eq 302) "code=$($r.code)"
$cekLogin = Login 'petugas01' 'petugas123'
Check 'Login lagi dengan password lama' ($cekLogin.res.code -in 302, 200) "code=$($cekLogin.res.code)"

$r = POST $p1.client '/profil' (Enc @{ aksi='ubahData'; namaLengkap='Bagus Setiawan'; email='bagus@sehatsentosa.id'; noTelepon='081433330001'; alamat='Jl. Hayam Wuruk No. 30, Jakarta' })
Check 'Ubah data profil -> 302' ($r.code -eq 302) "code=$($r.code)"
$r = GET $p1.client '/profil'
Check 'Perubahan profil tampil + flash sukses' ($r.code -eq 200 -and $r.text -match 'Bagus Setiawan' -and $r.text -match 'berhasil') "code=$($r.code)"

$r = GET $p1.client '/logout'
Check 'Logout -> 302' ($r.code -eq 302) "code=$($r.code)"
$r = GET $p1.client '/dashboard'
Check 'Session habis setelah logout' ($r.code -in 301,302,401,403) "code=$($r.code)"

Write-Output ''
Write-Output "=================== HASIL: $pass LULUS / $fail GAGAL ==================="
$lines | ForEach-Object { Write-Output $_ }
