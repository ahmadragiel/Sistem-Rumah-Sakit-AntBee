package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.model.Pemeriksaan;
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
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet modul pemeriksaan.
 *
 * ADMIN: penuh. DOKTER: membuat/mengubah pemeriksaan miliknya sendiri,
 * tidak bisa mengubah pemeriksaan dokter lain.
 */
@WebServlet(name = "PemeriksaanServlet", urlPatterns = {"/pemeriksaan"})
public class PemeriksaanServlet extends HttpServlet {

    private final PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();
    private final PasienDAO pasienDAO = new PasienDAO();
    private final DokterDAO dokterDAO = new DokterDAO();

    private static final String[] ROLE_BACA = {"ADMIN", "DOKTER"};
    private static final String[] ROLE_TULIS = {"ADMIN", "DOKTER"};

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
                Pemeriksaan baru = new Pemeriksaan();
                baru.setTanggalPemeriksaan(LocalDate.now());
                baru.setIdDokter("DOKTER".equals(user.getRole()) ? Auth.idDokter(request) : null);
                request.setAttribute("data", baru);
                request.getRequestDispatcher("/pemeriksaan/tambah-pemeriksaan.jsp").forward(request, response);
                break;
            case "edit":
                if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                    return;
                }
                Pemeriksaan diedit = cariMilikSendiri(request, response, user);
                if (diedit == null) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/pemeriksaan/edit-pemeriksaan.jsp").forward(request, response);
                break;
            case "detail":
                Pemeriksaan data = cari(request, response);
                if (data == null) {
                    return;
                }
                request.setAttribute("data", data);
                request.getRequestDispatcher("/pemeriksaan/detail-pemeriksaan.jsp").forward(request, response);
                break;
            default:
                daftar(request, response, user);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_TULIS)) {
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
            simpan(request, response, "update".equals(aksi), user);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/pemeriksaan");
    }

    private void daftar(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Integer idDokterFilter = "DOKTER".equals(user.getRole()) ? Auth.idDokter(request)
                : Validasi.id(request.getParameter("idDokter"));
        String q = param(request, "q", "");
        String dari = param(request, "dari", "");
        String sampai = param(request, "sampai", "");

        request.setAttribute("daftarPemeriksaan", pemeriksaanDAO.semua(q, idDokterFilter, null, dari, sampai));
        request.setAttribute("q", q);
        request.setAttribute("dari", dari);
        request.setAttribute("sampai", sampai);
        if (!"DOKTER".equals(user.getRole())) {
            request.setAttribute("daftarDokter", dokterDAO.daftarAktif());
            request.setAttribute("idDokter", idDokterFilter);
        }
        request.getRequestDispatcher("/pemeriksaan/pemeriksaan.jsp").forward(request, response);
    }

    private Pemeriksaan cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        Pemeriksaan data = id == null ? null : pemeriksaanDAO.findById(id);
        if (data == null) {
            Auth.gagal(request, "Data pemeriksaan tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/pemeriksaan");
        }
        return data;
    }

    /** Dipakai saat edit: dokter hanya boleh mengubah pemeriksaan buatannya sendiri. */
    private Pemeriksaan cariMilikSendiri(HttpServletRequest request, HttpServletResponse response,
            User user) throws IOException {

        Pemeriksaan data = cari(request, response);
        if (data == null) {
            return null;
        }
        if ("DOKTER".equals(user.getRole())) {
            Integer idDokter = Auth.idDokter(request);
            if (idDokter == null || !idDokter.equals(data.getIdDokter())) {
                Auth.gagal(request, "Anda hanya dapat mengubah pemeriksaan yang Anda buat sendiri.");
                response.sendRedirect(request.getContextPath() + "/pemeriksaan");
                return null;
            }
        }
        return data;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah, User user)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Pemeriksaan data = new Pemeriksaan();
        data.setIdPemeriksaan(Validasi.id(request.getParameter("id")));
        data.setIdPasien(Validasi.id(request.getParameter("idPasien")));
        data.setTanggalPemeriksaan(Validasi.tanggal(request.getParameter("tanggalPemeriksaan"),
                "tanggalPemeriksaan", "Tanggal pemeriksaan", errors));
        data.setKeluhan(Validasi.wajib(param(request, "keluhan", ""), "keluhan", "Keluhan", errors));
        data.setTekananDarah(param(request, "tekananDarah", ""));
        data.setDiagnosa(Validasi.wajib(param(request, "diagnosa", ""), "diagnosa", "Diagnosa", errors));
        data.setTindakan(param(request, "tindakan", ""));
        data.setCatatan(param(request, "catatan", ""));

        // Dokter selalu terikat pada datanya sendiri; admin boleh memilih dokter.
        if ("DOKTER".equals(user.getRole())) {
            data.setIdDokter(Auth.idDokter(request));
        } else {
            data.setIdDokter(Validasi.id(request.getParameter("idDokter")));
            if (data.getIdDokter() == null || dokterDAO.findById(data.getIdDokter()) == null) {
                errors.put("idDokter", "Dokter wajib dipilih dan harus tersedia.");
            }
        }

        if (data.getIdPasien() == null || pasienDAO.findById(data.getIdPasien()) == null) {
            errors.put("idPasien", "Pasien wajib dipilih dan harus tersedia.");
        }

        // Suhu dan berat badan wajib berada dalam rentang wajar
        String suhuTeks = param(request, "suhu", "");
        if (!suhuTeks.isEmpty()) {
            java.math.BigDecimal suhu = Validasi.desimal(suhuTeks, "suhu", "Suhu", errors);
            if (suhu != null && (suhu.compareTo(new java.math.BigDecimal("30")) < 0
                    || suhu.compareTo(new java.math.BigDecimal("45")) > 0)) {
                errors.put("suhu", "Suhu harus antara 30 sampai 45 derajat Celcius.");
            }
            data.setSuhu(suhu);
        }
        String beratTeks = param(request, "beratBadan", "");
        if (!beratTeks.isEmpty()) {
            java.math.BigDecimal berat = Validasi.desimal(beratTeks, "beratBadan", "Berat badan", errors);
            if (berat != null && (berat.compareTo(new java.math.BigDecimal("1")) < 0
                    || berat.compareTo(new java.math.BigDecimal("300")) > 0)) {
                errors.put("beratBadan", "Berat badan harus antara 1 sampai 300 kg.");
            }
            data.setBeratBadan(berat);
        }

        if (data.getTekananDarah() != null && !data.getTekananDarah().isEmpty()
                && !data.getTekananDarah().matches("\\d{2,3}/\\d{2,3}")) {
            errors.put("tekananDarah", "Tekanan darah harus berformat angka/angka, contoh 120/80.");
        }

        // Saat edit, pastikan pemeriksaan benar-benar milik dokter yang login
        if (ubah) {
            Pemeriksaan lama = data.getIdPemeriksaan() == null ? null
                    : pemeriksaanDAO.findById(data.getIdPemeriksaan());
            if (lama == null) {
                errors.put("id", "Data pemeriksaan tidak ditemukan.");
            } else if ("DOKTER".equals(user.getRole())
                    && !java.util.Objects.equals(lama.getIdDokter(), Auth.idDokter(request))) {
                response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                return;
            }
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/pemeriksaan/edit-pemeriksaan.jsp"
                    : "/pemeriksaan/tambah-pemeriksaan.jsp").forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = pemeriksaanDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Data pemeriksaan berhasil diperbarui."
                    : "Data pemeriksaan gagal diperbarui.");
        } else {
            berhasil = pemeriksaanDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data pemeriksaan berhasil ditambahkan."
                    : "Data pemeriksaan gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/pemeriksaan");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || pemeriksaanDAO.findById(id) == null) {
            Auth.gagal(request, "Data pemeriksaan tidak ditemukan.");
        } else {
            pemeriksaanDAO.hapus(id);
            Auth.sukses(request, "Data pemeriksaan berhasil dihapus.");
        }
        response.sendRedirect(request.getContextPath() + "/pemeriksaan");
    }

    private void siapkanForm(HttpServletRequest request) {
        request.setAttribute("daftarPasien", pasienDAO.semua(null, null, null));
        request.setAttribute("daftarDokter", dokterDAO.daftarAktif());
        request.setAttribute("tanggalHariIni", LocalDate.now().toString());
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
