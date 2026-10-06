package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.dao.RuanganDAO;
import com.mycompany.rumahsakit.model.Pembayaran;
import com.mycompany.rumahsakit.model.RawatInap;
import com.mycompany.rumahsakit.model.Ruangan;
import com.mycompany.rumahsakit.model.User;
import com.mycompany.rumahsakit.util.Auth;
import com.mycompany.rumahsakit.util.Validasi;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Servlet modul pembayaran.
 *
 * total_biaya SELALU dihitung sistem dari lima komponen biaya,
 * bukan diambil dari input user.
 * Role: ADMIN dan PETUGAS.
 */
@WebServlet(name = "PembayaranServlet", urlPatterns = {"/pembayaran"})
public class PembayaranServlet extends HttpServlet {

    private final PembayaranDAO pembayaranDAO = new PembayaranDAO();
    private final PasienDAO pasienDAO = new PasienDAO();
    private final RawatInapDAO rawatInapDAO = new RawatInapDAO();
    private final RuanganDAO ruanganDAO = new RuanganDAO();

    private static final String[] ROLE_IZIN = {"ADMIN", "PETUGAS"};
    private static final String[] STATUS_BAYAR = {"BELUM DIBAYAR", "MENUNGGU", "LUNAS"};
    private static final String[] METODE = {"Tunai", "Transfer Bank", "Kartu Debit", "QRIS", "BPJS", "Asuransi"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_IZIN)) {
            return;
        }
        String aksi = param(request, "aksi", "daftar");

        switch (aksi) {
            case "tambah":
                siapkanForm(request);
                Pembayaran baru = new Pembayaran();
                baru.setTanggalPembayaran(LocalDate.now());
                baru.setStatusPembayaran("BELUM DIBAYAR");
                baru.setBiayaKamar(BigDecimal.ZERO);
                baru.setBiayaDokter(BigDecimal.ZERO);
                baru.setBiayaObat(BigDecimal.ZERO);
                baru.setBiayaTindakan(BigDecimal.ZERO);
                baru.setBiayaLain(BigDecimal.ZERO);
                baru.setTotalBiaya(BigDecimal.ZERO);
                request.setAttribute("data", baru);
                request.getRequestDispatcher("/pembayaran/tambah-pembayaran.jsp").forward(request, response);
                break;
            case "edit":
                Pembayaran diedit = cari(request, response);
                if (diedit == null) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/pembayaran/edit-pembayaran.jsp").forward(request, response);
                break;
            case "detail":
                Pembayaran data = cari(request, response);
                if (data == null) {
                    return;
                }
                request.setAttribute("data", data);
                request.getRequestDispatcher("/pembayaran/detail-pembayaran.jsp").forward(request, response);
                break;
            case "cetak":
                Pembayaran dicetak = cari(request, response);
                if (dicetak == null) {
                    return;
                }
                request.setAttribute("data", dicetak);
                request.getRequestDispatcher("/pembayaran/cetak-bukti.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("daftarPembayaran", pembayaranDAO.semua(
                        param(request, "q", ""),
                        param(request, "status", ""),
                        param(request, "dari", ""),
                        param(request, "sampai", "")));
                request.setAttribute("q", param(request, "q", ""));
                request.setAttribute("status", param(request, "status", ""));
                request.setAttribute("dari", param(request, "dari", ""));
                request.setAttribute("sampai", param(request, "sampai", ""));
                request.setAttribute("totalLunas", pembayaranDAO.totalLunas());
                request.getRequestDispatcher("/pembayaran/pembayaran.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_IZIN)) {
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String aksi = param(request, "aksi", "");

        if ("hapus".equals(aksi)) {
            if (!Auth.wajibRole(request, response, user, "ADMIN")) {
                return;
            }
            hapus(request, response);
            return;
        }
        if ("simpan".equals(aksi) || "update".equals(aksi)) {
            simpan(request, response, "update".equals(aksi));
            return;
        }
        response.sendRedirect(request.getContextPath() + "/pembayaran");
    }

    private Pembayaran cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        Pembayaran data = id == null ? null : pembayaranDAO.findById(id);
        if (data == null) {
            Auth.gagal(request, "Data pembayaran tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/pembayaran");
        }
        return data;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Pembayaran data = new Pembayaran();
        data.setIdPembayaran(Validasi.id(request.getParameter("id")));
        data.setIdPasien(Validasi.id(request.getParameter("idPasien")));
        data.setIdRawatInap(Validasi.id(request.getParameter("idRawatInap")));
        data.setMetodePembayaran(Validasi.pilihan(param(request, "metodePembayaran", ""),
                METODE, "metodePembayaran", "Metode pembayaran", errors));
        data.setTanggalPembayaran(Validasi.tanggal(request.getParameter("tanggalPembayaran"),
                "tanggalPembayaran", "Tanggal pembayaran", errors));
        data.setStatusPembayaran(Validasi.pilihan(param(request, "statusPembayaran", ""),
                STATUS_BAYAR, "statusPembayaran", "Status pembayaran", errors));

        if (data.getIdPasien() == null || pasienDAO.findById(data.getIdPasien()) == null) {
            errors.put("idPasien", "Pasien wajib dipilih dan harus tersedia.");
        }

        // Biaya: tidak boleh negatif, biaya kamar dapat dihitung otomatis dari kamar rawat inap
        data.setBiayaKamar(Validasi.desimalOpsional(param(request, "biayaKamar", ""),
                "biayaKamar", "Biaya kamar", errors));
        data.setBiayaDokter(Validasi.desimalOpsional(param(request, "biayaDokter", ""),
                "biayaDokter", "Biaya dokter", errors));
        data.setBiayaObat(Validasi.desimalOpsional(param(request, "biayaObat", ""),
                "biayaObat", "Biaya obat", errors));
        data.setBiayaTindakan(Validasi.desimalOpsional(param(request, "biayaTindakan", ""),
                "biayaTindakan", "Biaya tindakan", errors));
        data.setBiayaLain(Validasi.desimalOpsional(param(request, "biayaLain", ""),
                "biayaLain", "Biaya lain", errors));

        if (data.getIdRawatInap() != null) {
            RawatInap ri = rawatInapDAO.findById(data.getIdRawatInap());
            if (ri == null) {
                errors.put("idRawatInap", "Rawat inap tidak ditemukan.");
            } else if (data.getIdPasien() != null && !Objects.equals(ri.getIdPasien(), data.getIdPasien())) {
                errors.put("idRawatInap", "Rawat inap tersebut bukan milik pasien yang dipilih.");
            } else if (data.getBiayaKamar() == null || data.getBiayaKamar().signum() == 0) {
                // Isi otomatis: tarif kamar x lama rawat
                Ruangan ruangan = ruanganDAO.findById(ri.getIdRuangan());
                if (ruangan != null && ruangan.getTarifPerHari() != null) {
                    int lama = ri.getLamaRawat() == null ? 1 : Math.max(1, ri.getLamaRawat());
                    data.setBiayaKamar(ruangan.getTarifPerHari()
                            .multiply(BigDecimal.valueOf(lama)));
                }
            }
        }

        // Total SELALU dihitung sistem
        data.setTotalBiaya(data.hitungTotal());

        if (ubah && data.getIdPembayaran() == null) {
            errors.put("id", "Data pembayaran tidak ditemukan.");
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/pembayaran/edit-pembayaran.jsp"
                    : "/pembayaran/tambah-pembayaran.jsp").forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = pembayaranDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Data pembayaran berhasil diperbarui."
                    : "Data pembayaran gagal diperbarui.");
        } else {
            berhasil = pembayaranDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data pembayaran berhasil ditambahkan."
                    : "Data pembayaran gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/pembayaran");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || pembayaranDAO.findById(id) == null) {
            Auth.gagal(request, "Data pembayaran tidak ditemukan.");
        } else {
            pembayaranDAO.hapus(id);
            Auth.sukses(request, "Data pembayaran berhasil dihapus.");
        }
        response.sendRedirect(request.getContextPath() + "/pembayaran");
    }

    private void siapkanForm(HttpServletRequest request) {
        List<com.mycompany.rumahsakit.model.Pasien> pasien = pasienDAO.semua(null, null, null);
        List<RawatInap> rawatInap = rawatInapDAO.semua(null, null);
        request.setAttribute("daftarPasien", pasien);
        request.setAttribute("daftarRawatInap", rawatInap);
        request.setAttribute("tanggalHariIni", LocalDate.now().toString());
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
