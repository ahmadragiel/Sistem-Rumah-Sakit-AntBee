package com.mycompany.rumahsakit.util;

import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.model.Pembayaran;
import com.mycompany.rumahsakit.model.Pemeriksaan;
import com.mycompany.rumahsakit.model.RawatInap;
import java.util.ArrayList;
import java.util.List;

/**
 * Menyusun daftar notifikasi milik satu pasien berdasarkan data terbaru
 * (pemeriksaan, rawat inap, dan tagihan). Semua data diambil dari database,
 * bukan data statis.
 */
public final class Notifikasi {

    private Notifikasi() {
    }

    public static List<String> daftar(int idPasien) {
        List<String> hasil = new ArrayList<>();
        PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();
        RawatInapDAO rawatInapDAO = new RawatInapDAO();
        PembayaranDAO pembayaranDAO = new PembayaranDAO();

        // 1. Tagihan yang belum lunas
        for (Pembayaran b : pembayaranDAO.byPasien(idPasien)) {
            if (!"LUNAS".equals(b.getStatusPembayaran())) {
                hasil.add("Tagihan " + rupiah(b.getTotalBiaya()) + " berstatus " + b.getStatusPembayaran() + ".");
                if (hasil.size() >= 3) {
                    break;
                }
            }
        }

        // 2. Status rawat inap
        for (RawatInap r : rawatInapDAO.byPasien(idPasien)) {
            if ("DIRAWAT".equals(r.getStatusRawat())) {
                hasil.add("Anda sedang dirawat di kamar " + r.getNomorKamar()
                        + " (" + r.getNamaRuangan() + ") sejak " + r.getTanggalMasuk() + ".");
            } else if ("MENUNGGU".equals(r.getStatusRawat())) {
                hasil.add("Pengajuan rawat inap di kamar " + r.getNomorKamar() + " masih menunggu proses.");
            }
        }

        // 3. Jadwal pemeriksaan mendatang
        for (Pemeriksaan p : pemeriksaanDAO.jadwalMendatang(idPasien)) {
            hasil.add("Jadwal pemeriksaan " + p.getTanggalPemeriksaan()
                    + " bersama " + nullAman(p.getNamaDokter()) + ".");
            if (hasil.size() >= 8) {
                break;
            }
        }

        // 4. Pemeriksaan terbaru
        List<Pemeriksaan> terbaru = pemeriksaanDAO.byPasien(idPasien);
        if (!terbaru.isEmpty()) {
            Pemeriksaan p = terbaru.get(0);
            hasil.add("Pemeriksaan terbaru " + p.getTanggalPemeriksaan()
                    + ": " + nullAman(p.getDiagnosa()) + ".");
        }

        return hasil;
    }

    private static String nullAman(String teks) {
        return teks == null || teks.isBlank() ? "-" : teks;
    }

    private static String rupiah(java.math.BigDecimal nilai) {
        if (nilai == null) {
            return "Rp0";
        }
        java.text.NumberFormat nf = java.text.NumberFormat.getIntegerInstance(new java.util.Locale("id", "ID"));
        return "Rp" + nf.format(nilai);
    }
}
