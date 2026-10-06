package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.dao.RuanganDAO;
import com.mycompany.rumahsakit.model.Pembayaran;
import com.mycompany.rumahsakit.model.Pemeriksaan;
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
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Servlet modul rawat inap.
 *
 * Logika bisnis:
 * - Saat pasien berstatus DIRAWAT, jumlah_terisi ruangan bertambah 1.
 * - Saat pasien keluar dari status DIRAWAT, jumlah_terisi berkurang 1.
 * - jumlah_terisi tidak pernah melebihi kapasitas.
 * - lama_rawat dihitung dari tanggal masuk dan tanggal keluar (minimal 1 hari).
 */
@WebServlet(name = "RawatInapServlet", urlPatterns = {"/rawat-inap"})
public class RawatInapServlet extends HttpServlet {

    private final RawatInapDAO rawatInapDAO = new RawatInapDAO();
    private final PasienDAO pasienDAO = new PasienDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final RuanganDAO ruanganDAO = new RuanganDAO();
    private final PembayaranDAO pembayaranDAO = new PembayaranDAO();
    private final PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();

    private static final String[] ROLE_BACA = {"ADMIN", "PETUGAS", "PERAWAT", "DOKTER"};
    private static final String[] ROLE_TULIS = {"ADMIN", "PETUGAS"};
    private static final String[] STATUS_RAWAT = {"MENUNGGU", "DIRAWAT", "SELESAI", "DIPULANGKAN"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_BACA)) {
            return;
        }
        String aksi = param(request, "aksi", "daftar");

        switch (aksi) {
            case "tambah":
                if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                    return;
                }
                siapkanForm(request);
                RawatInap baru = new RawatInap();
                baru.setTanggalMasuk(LocalDate.now());
                baru.setStatusRawat("MENUNGGU");
                request.setAttribute("data", baru);
                request.getRequestDispatcher("/rawat-inap/tambah-rawat-inap.jsp").forward(request, response);
                break;
            case "edit":
                if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                    return;
                }
                RawatInap diedit = cari(request, response);
                if (diedit == null) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/rawat-inap/edit-rawat-inap.jsp").forward(request, response);
                break;
            case "detail":
                detail(request, response);
                break;
            default:
                request.setAttribute("daftarRawatInap", rawatInapDAO.semua(
                        param(request, "q", ""), param(request, "status", "")));
                request.setAttribute("q", param(request, "q", ""));
                request.setAttribute("status", param(request, "status", ""));
                request.getRequestDispatcher("/rawat-inap/rawat-inap.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null) {
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
            if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                return;
            }
            simpan(request, response, "update".equals(aksi));
            return;
        }
        response.sendRedirect(request.getContextPath() + "/rawat-inap");
    }

    private RawatInap cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        RawatInap data = id == null ? null : rawatInapDAO.findById(id);
        if (data == null) {
            Auth.gagal(request, "Data rawat inap tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/rawat-inap");
        }
        return data;
    }

    private void detail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RawatInap data = cari(request, response);
        if (data == null) {
            return;
        }
        List<Pembayaran> pembayaranTerkait = new ArrayList<>();
        for (Pembayaran b : pembayaranDAO.byPasien(data.getIdPasien())) {
            if (Objects.equals(b.getIdRawatInap(), data.getIdRawatInap())) {
                pembayaranTerkait.add(b);
            }
        }
        List<Pemeriksaan> pemeriksaan = pemeriksaanDAO.byPasien(data.getIdPasien());
        request.setAttribute("data", data);
        request.setAttribute("daftarPembayaran", pembayaranTerkait);
        request.setAttribute("daftarPemeriksaan",
                pemeriksaan.size() > 5 ? pemeriksaan.subList(0, 5) : pemeriksaan);
        request.getRequestDispatcher("/rawat-inap/detail-rawat-inap.jsp").forward(request, response);
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        RawatInap data = new RawatInap();
        data.setIdRawatInap(Validasi.id(request.getParameter("id")));
        data.setIdPasien(Validasi.id(request.getParameter("idPasien")));
        data.setIdDokter(Validasi.id(request.getParameter("idDokter")));
        data.setIdRuangan(Validasi.id(request.getParameter("idRuangan")));
        data.setDiagnosa(Validasi.wajib(param(request, "diagnosa", ""), "diagnosa", "Diagnosa", errors));
        data.setKeluhan(param(request, "keluhan", ""));
        data.setStatusRawat(Validasi.pilihan(param(request, "statusRawat", ""), STATUS_RAWAT,
                "statusRawat", "Status rawat inap", errors));
        data.setTanggalMasuk(Validasi.tanggal(request.getParameter("tanggalMasuk"),
                "tanggalMasuk", "Tanggal masuk", errors));
        data.setTanggalKeluar(Validasi.tanggalOpsional(request.getParameter("tanggalKeluar"),
                "tanggalKeluar", "Tanggal keluar", errors));

        if (data.getIdPasien() == null || pasienDAO.findById(data.getIdPasien()) == null) {
            errors.put("idPasien", "Pasien wajib dipilih dan harus tersedia.");
        }
        if (data.getIdDokter() == null || dokterDAO.findById(data.getIdDokter()) == null) {
            errors.put("idDokter", "Dokter wajib dipilih dan harus tersedia.");
        }

        Ruangan ruangan = data.getIdRuangan() == null ? null : ruanganDAO.findById(data.getIdRuangan());
        if (ruangan == null) {
            errors.put("idRuangan", "Ruangan wajib dipilih dan harus tersedia.");
        } else {
            data.setNomorKamar(ruangan.getNomorKamar());
        }

        // Status selesai/pulang wajib punya tanggal keluar
        if (("SELESAI".equals(data.getStatusRawat()) || "DIPULANGKAN".equals(data.getStatusRawat()))
                && data.getTanggalKeluar() == null) {
            errors.put("tanggalKeluar", "Tanggal keluar wajib diisi untuk status "
                    + data.getStatusRawat() + ".");
        }
        if (data.getTanggalMasuk() != null && data.getTanggalKeluar() != null
                && data.getTanggalKeluar().isBefore(data.getTanggalMasuk())) {
            errors.put("tanggalKeluar", "Tanggal keluar tidak boleh sebelum tanggal masuk.");
        }

        // Hitung lama rawat
        int lamaRawat = 0;
        if (data.getTanggalMasuk() != null) {
            LocalDate akhir = data.getTanggalKeluar() != null ? data.getTanggalKeluar() : LocalDate.now();
            long hari = ChronoUnit.DAYS.between(data.getTanggalMasuk(), akhir);
            if (hari < 0) {
                errors.put("tanggalMasuk", "Tanggal masuk tidak boleh melewati tanggal keluar/hari ini.");
            } else {
                lamaRawat = (int) Math.max(1, hari);
            }
        }
        data.setLamaRawat(lamaRawat);

        // Data lama untuk membandingkan perubahan status & kamar
        RawatInap lama = null;
        if (ubah) {
            lama = data.getIdRawatInap() == null ? null : rawatInapDAO.findById(data.getIdRawatInap());
            if (lama == null) {
                errors.put("id", "Data rawat inap tidak ditemukan.");
            }
        }
        boolean lamaAktif = lama != null && "DIRAWAT".equals(lama.getStatusRawat());
        boolean baruAktif = "DIRAWAT".equals(data.getStatusRawat());
        boolean gantiKamar = lamaAktif && baruAktif
                && !Objects.equals(lama.getIdRuangan(), data.getIdRuangan());

        // Cek kapasitas ruangan sebelum menyimpan
        if (ruangan != null && ((!lamaAktif && baruAktif) || gantiKamar)) {
            if (ruanganDAO.penuh(ruangan.getIdRuangan())) {
                errors.put("idRuangan", "Kamar " + ruangan.getNomorKamar() + " (" + ruangan.getNamaRuangan()
                        + ") sudah penuh. Pilih kamar lain.");
            }
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/rawat-inap/edit-rawat-inap.jsp"
                    : "/rawat-inap/tambah-rawat-inap.jsp").forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = rawatInapDAO.ubah(data);
        } else {
            berhasil = rawatInapDAO.tambah(data);
        }
        if (!berhasil) {
            Auth.gagal(request, "Data rawat inap gagal disimpan.");
            response.sendRedirect(request.getContextPath() + "/rawat-inap");
            return;
        }

        // Terapkan efek ke jumlah terisi ruangan
        if (ubah) {
            if (lamaAktif && baruAktif && gantiKamar) {
                ruanganDAO.ubahJumlahTerisi(lama.getIdRuangan(), -1);
                ruanganDAO.ubahJumlahTerisi(data.getIdRuangan(), 1);
            } else if (lamaAktif && !baruAktif) {
                ruanganDAO.ubahJumlahTerisi(lama.getIdRuangan(), -1);
            } else if (!lamaAktif && baruAktif) {
                ruanganDAO.ubahJumlahTerisi(data.getIdRuangan(), 1);
            }
        } else if (baruAktif) {
            ruanganDAO.ubahJumlahTerisi(data.getIdRuangan(), 1);
        }

        // Sinkronkan status pasien
        if (baruAktif) {
            pasienDAO.ubahStatus(data.getIdPasien(), "DIRAWAT", null);
        } else if ("SELESAI".equals(data.getStatusRawat()) || "DIPULANGKAN".equals(data.getStatusRawat())) {
            LocalDate keluar = data.getTanggalKeluar() != null ? data.getTanggalKeluar() : LocalDate.now();
            pasienDAO.ubahStatus(data.getIdPasien(), "PULANG", keluar);
        }

        Auth.sukses(request, ubah ? "Data rawat inap berhasil diperbarui."
                : "Data rawat inap berhasil ditambahkan.");
        response.sendRedirect(request.getContextPath() + "/rawat-inap");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        RawatInap data = id == null ? null : rawatInapDAO.findById(id);
        if (data == null) {
            Auth.gagal(request, "Data rawat inap tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/rawat-inap");
            return;
        }
        try {
            if ("DIRAWAT".equals(data.getStatusRawat())) {
                ruanganDAO.ubahJumlahTerisi(data.getIdRuangan(), -1);
                pasienDAO.ubahStatus(data.getIdPasien(), "PULANG", LocalDate.now());
            }
            rawatInapDAO.hapus(id);
            Auth.sukses(request, "Data rawat inap berhasil dihapus.");
        } catch (RuntimeException e) {
            Auth.gagal(request, "Data rawat inap tidak dapat dihapus karena sudah terkait data pembayaran.");
        }
        response.sendRedirect(request.getContextPath() + "/rawat-inap");
    }

    private void siapkanForm(HttpServletRequest request) {
        request.setAttribute("daftarPasien", pasienDAO.semua(null, null, null));
        request.setAttribute("daftarDokter", dokterDAO.daftarAktif());
        request.setAttribute("daftarRuangan", ruanganDAO.daftarSemua());
        request.setAttribute("tanggalHariIni", LocalDate.now().toString());
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
