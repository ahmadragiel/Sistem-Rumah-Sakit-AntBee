Add-Type -AssemblyName System.Net.Http
$base = 'http://localhost:8080/rumahsakit/'
function New-Client {
    $h = New-Object System.Net.Http.HttpClientHandler
    $h.AllowAutoRedirect = $false; $h.UseCookies = $true
    $h.CookieContainer = New-Object System.Net.CookieContainer
    $c = New-Object System.Net.Http.HttpClient($h); $c.BaseAddress = New-Object System.Uri($base); return $c
}
function GET($c, $url) { try { $r = $c.GetAsync($url.TrimStart('/')).Result; return @{ code=[int]$r.StatusCode; text=$r.Content.ReadAsStringAsync().Result } } catch { return @{ code=0; text='' } } }
function POST($c, $url, $body) {
    $enc = New-Object System.Net.Http.StringContent($body, [Text.Encoding]::UTF8, 'application/x-www-form-urlencoded')
    $r = $c.PostAsync($url.TrimStart('/'), $enc).Result; return @{ code=[int]$r.StatusCode; text=$r.Content.ReadAsStringAsync().Result }
}
function Enc([hashtable]$h) { $p=@(); foreach ($k in $h.Keys) { $p += [Uri]::EscapeDataString($k)+'='+[Uri]::EscapeDataString([string]$h[$k]) }; $p -join '&' }

$pw = [ordered]@{ 'admin'='admin123'; 'dokter01'='dokter123'; 'perawat01'='perawat123'; 'petugas01'='petugas123'; 'pasien01'='pasien123' }
$halaman = @{}
$halaman['admin'] = @('/dashboard','/pasien','/pasien?aksi=tambah','/pasien?aksi=detail&id=1','/pasien?aksi=edit&id=1','/dokter','/dokter?aksi=detail&id=1','/dokter?aksi=tambah','/perawat','/perawat?aksi=detail&id=1','/perawat?aksi=tambah','/penyakit','/penyakit?aksi=detail&id=1','/penyakit?aksi=tambah','/ruangan','/ruangan?aksi=detail&id=1','/ruangan?aksi=tambah','/rawat-inap','/rawat-inap?aksi=detail&id=1','/rawat-inap?aksi=tambah','/pemeriksaan','/pemeriksaan?aksi=detail&id=1','/pemeriksaan?aksi=tambah','/catatan-perawatan','/catatan-perawatan?aksi=detail&id=1','/catatan-perawatan?aksi=tambah','/pembayaran','/pembayaran?aksi=detail&id=1','/pembayaran?aksi=tambah','/pembayaran?aksi=cetak&id=1','/pengguna','/pengguna?aksi=tambah','/pengguna?aksi=edit&id=1','/profil')
$halaman['dokter01'] = @('/dashboard','/pasien','/pasien?aksi=detail&id=1','/pemeriksaan','/pemeriksaan?aksi=tambah','/pemeriksaan?aksi=detail&id=1','/catatan-perawatan','/catatan-perawatan?aksi=tambah','/rawat-inap','/rawat-inap?aksi=detail&id=1','/profil')
$halaman['perawat01'] = @('/dashboard','/pasien','/ruangan','/ruangan?aksi=detail&id=1','/rawat-inap','/catatan-perawatan','/catatan-perawatan?aksi=tambah','/profil')
$halaman['petugas01'] = @('/dashboard','/pasien','/pasien?aksi=tambah','/rawat-inap','/pembayaran','/pembayaran?aksi=tambah','/profil')
$halaman['pasien01'] = @('/dashboard','/saya?aksi=jadwal','/saya?aksi=pemeriksaan','/saya?aksi=rawat-inap','/saya?aksi=pembayaran','/saya?aksi=tagihan','/saya?aksi=notifikasi','/profil')
$laporan = @('/laporan?jenis=pasien','/laporan?jenis=dokter','/laporan?jenis=rawat-inap','/laporan?jenis=penyakit','/laporan?jenis=pembayaran','/laporan?jenis=ruangan')

$dilarang = [regex]'Lorem|Ipsum|>Submit<|>Save<|>Cancel<|>Delete<|>Search<|>Add New<|>Sign in<|>Sign out<|TODO|FIXME|placeholder text'
$masalah = 0; $dicek = 0; $lapor = @()

foreach ($u in $pw.Keys) {
    $c = New-Client
    $r = POST $c '/login' (Enc @{ username = $u; password = $pw[$u] })
    $daftar = @($halaman[$u])
    if ($u -eq 'admin') { $daftar += $laporan }
    foreach ($p in $daftar) {
        $dicek++
        $g = GET $c $p
        $ket = @()
        if ($g.code -in 301,302,401,403) {
            # Ditolak filter/servlet (RBAC) -> perilaku yang benar, lewati cek tampilan
            continue
        }
        if ($g.code -ne 200) { $ket += "HTTP $($g.code)" }
        if ($g.text -match '<%[-=@]|<c:set var="judulHalaman"') { $ket += 'kode JSP mentah bocor' }
        if ($g.text -notmatch '<!DOCTYPE html>') { $ket += 'DOCTYPE hilang' }
        if ($g.text -notmatch '</html>') { $ket += 'closing html hilang' }
        if ($u -ne 'pasien01' -and $p -ne '/logout' -and $g.text -notmatch 'app-wrapper') { $ket += 'layout wrapper hilang' }
        if ($dilarang.IsMatch($g.text)) { $m = $dilarang.Match($g.text).Value; $ket += "teks terlarang: $m" }
        if ($g.text -match '<title>\s*</title>') { $ket += 'title kosong' }
        if ($ket.Count -gt 0) { $masalah++; $lapor += "  [$u] $p -> " + ($ket -join ', ') }
    }
}
Write-Output "Halaman dicek: $dicek | bermasalah: $masalah"
$lapor | ForEach-Object { Write-Output $_ }
