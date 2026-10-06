/* Script utama SIMRS: sidebar mobile, modal konfirmasi, pratinjau total biaya. */

document.addEventListener('DOMContentLoaded', function () {

    /* ---------- Sidebar off-canvas untuk layar kecil ---------- */
    var tombolMenu = document.getElementById('menuToggle');
    var tombolTutup = document.getElementById('sidebarClose');
    var overlay = document.getElementById('sidebarOverlay');

    if (tombolMenu) {
        tombolMenu.addEventListener('click', function () {
            document.body.classList.add('sidebar-terbuka');
        });
    }
    if (tombolTutup) {
        tombolTutup.addEventListener('click', function () {
            document.body.classList.remove('sidebar-terbuka');
        });
    }
    if (overlay) {
        overlay.addEventListener('click', function () {
            document.body.classList.remove('sidebar-terbuka');
        });
    }

    /* ---------- Modal konfirmasi aksi berbahaya ---------- */
    var modal = document.getElementById('modalKonfirmasi');
    var teks = document.getElementById('modalKonfirmasiTeks');
    var tombolBatal = document.getElementById('modalKonfirmasiBatal');
    var tombolYa = document.getElementById('modalKonfirmasiYa');
    var formDisimpan = null;

    document.querySelectorAll('[data-konfirmasi]').forEach(function (elemen) {
        elemen.addEventListener('click', function (peristiwa) {
            if (!modal) return;
            peristiwa.preventDefault();
            teks.textContent = elemen.getAttribute('data-konfirmasi');
            // Dukung dua jenis aksi: tautan (href) dan formulir POST
            formDisimpan = elemen.form ? elemen.form : null;
            if (formDisimpan) {
                tombolYa.removeAttribute('href');
            } else {
                tombolYa.setAttribute('href', elemen.getAttribute('href'));
            }
            modal.hidden = false;
        });
    });

    if (tombolYa) {
        tombolYa.addEventListener('click', function (peristiwa) {
            if (formDisimpan) {
                peristiwa.preventDefault();
                formDisimpan.submit();
            }
        });
    }
    if (tombolBatal) {
        tombolBatal.addEventListener('click', function () {
            modal.hidden = true;
            formDisimpan = null;
        });
    }
    if (modal) {
        modal.addEventListener('click', function (peristiwa) {
            if (peristiwa.target === modal) {
                modal.hidden = true;
                formDisimpan = null;
            }
        });
    }

    /* ---------- Alert sukses/gagal disembunyikan otomatis ---------- */
    document.querySelectorAll('.alert-dismissible').forEach(function (alert) {
        setTimeout(function () {
            if (window.bootstrap && bootstrap.Alert) {
                try { bootstrap.Alert.getOrCreateInstance(alert).close(); } catch (e) { /* abaikan */ }
            }
        }, 6000);
    });

    /* ---------- Pratinjau total biaya (pembayaran) ---------- */
    var daftarBiaya = document.querySelectorAll('[data-biaya]');
    var pratinjau = document.getElementById('pratinjauTotal');
    if (daftarBiaya.length && pratinjau) {
        var hitung = function () {
            var total = 0;
            daftarBiaya.forEach(function (input) {
                var nilai = parseFloat(String(input.value).replace(',', '.'));
                if (!isNaN(nilai)) total += nilai;
            });
            pratinjau.textContent = formatRupiah(total);
        };
        daftarBiaya.forEach(function (input) {
            input.addEventListener('input', hitung);
        });
        hitung();
    }

    /* ---------- Isi otomatis biaya kamar dari pilihan rawat inap ---------- */
    var pilihanRawatInap = document.getElementById('idRawatInap');
    var kolomBiayaKamar = document.getElementById('biayaKamar');
    if (pilihanRawatInap && kolomBiayaKamar) {
        pilihanRawatInap.addEventListener('change', function () {
            var opsi = pilihanRawatInap.options[pilihanRawatInap.selectedIndex];
            var tarif = parseFloat(opsi.getAttribute('data-tarif') || '0');
            var lama = parseInt(opsi.getAttribute('data-lama') || '0', 10);
            if (tarif > 0) {
                if (lama < 1) lama = 1;
                kolomBiayaKamar.value = (tarif * lama).toFixed(0);
                kolomBiayaKamar.dispatchEvent(new Event('input'));
            }
        });
    }
});

function formatRupiah(angka) {
    var bulat = Math.round(isNaN(angka) ? 0 : angka);
    return 'Rp' + bulat.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}
