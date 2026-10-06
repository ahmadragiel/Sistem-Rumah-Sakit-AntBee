package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.CatatanPerawatanDAO;
import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.dao.PenyakitDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.dao.UserDAO;
import com.mycompany.rumahsakit.model.Pasien;
import com.mycompany.rumahsakit.model.User;
import com.mycompany.rumahsakit.util.Auth;
import com.mycompany.rumahsakit.util.PasswordUtil;
import com.mycompany.rumahsakit.util.Validasi;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/** Servlet modul data pasien: daftar, tambah, ubah, hapus, detail. */
@WebServlet(name = "PasienServlet", urlPatterns = {"/pasien"})
public class PasienServlet extends HttpServlet {

    private final PasienDAO pasienDAO = new PasienDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final PenyakitDAO penyakitDAO = new PenyakitDAO();
    private final UserDAO userDAO = new UserDAO();
    private final RawatInapDAO rawatInapDAO = new RawatInapDAO();
    private final PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();
    private final CatatanPerawatanDAO catatanDAO = new CatatanPerawatanDAO();
    private final PembayaranDAO pembayaranDAO = new PembayaranDAO();

    private static final String[] ROLE_BACA = {"ADMIN", "PETUGAS", "DOKTER", "PERAWAT"};
    private static final String[] ROLE_TULIS = {"ADMIN", "PETUGAS"};
    private static final String[] STATUS_PASIEN = {"RAWAT JALAN", "DIRAWAT", "PULANG"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_BACA)) {
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String aksi = param(request, "aksi", "daftar");

        switch (aksi) {
            case "tambah":
                if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", new Pasien());
                request.getRequestDispatcher("/pasien/tambah-pasien.jsp").forward(request, response);
                break;
            case "edit":
                if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                    return;
                }
                edit(request, response);
                break;
            case "detail":
                detail(request, response);
                break;
            default:
                daftar(request, response, user);
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

        try {
            switch (aksi) {
                case "simpan":
                case "update":
                    if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                        return;
                    }
                    simpan(request, response, aksi.equals("update"));
                    break;
                case "hapus":
                    if (!Auth.wajibRole(request, response, user, "ADMIN")) {
                        return;
                    }
                    hapus(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/pasien");
            }
        } catch (RuntimeException e) {
            e.printStackTrace();
            request.setAttribute("pesanError", "Terjadi kesalahan saat memproses data pasien.");
            if ("simpan".equals(aksi) || "update".equals(aksi)) {
                siapkanForm(request);
                request.getRequestDispatcher("update".equals(aksi)
                        ? "/pasien/edit-pasien.jsp" : "/pasien/tambah-pasien.jsp")
                        .forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/pasien");
            }
        }
    }

    /** Menampilkan daftar pasien + pencarian + filter. */
    private void daftar(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        String q = param(request, "q", "");
        String status = param(request, "status", "");
        Integer idDokterFilter = Validasi.id(request.getParameter("idDokter"));

        // Dokter hanya melihat pasien yang ditanganinya sendiri.
        if ("DOKTER".equals(user.getRole())) {
            idDokterFilter = Auth.idDokter(request);
        }

        request.setAttribute("daftarPasien", pasienDAO.semua(q, idDokterFilter, status));
        request.setAttribute("daftarDokter", dokterDAO.daftarAktif());
        request.setAttribute("q", q);
        request.setAttribute("status", status);
        request.setAttribute("idDokter", idDokterFilter);
        request.getRequestDispatcher("/pasien/pasien.jsp").forward(request, response);
    }

    private void edit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer id = Validasi.id(request.getParameter("id"));
        Pasien pasien = id == null ? null : pasienDAO.findById(id);
        if (pasien == null) {
            Auth.gagal(request, "Data pasien tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/pasien");
            return;
        }
        siapkanForm(request);
        request.setAttribute("data", pasien);
        request.getRequestDispatcher("/pasien/edit-pasien.jsp").forward(request, response);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer id = Validasi.id(request.getParameter("id"));
        Pasien pasien = id == null ? null : pasienDAO.findById(id);
        if (pasien == null) {
            Auth.gagal(request, "Data pasien tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/pasien");
            return;
        }
        request.setAttribute("data", pasien);
        request.setAttribute("riwayatRawatInap", rawatInapDAO.byPasien(pasien.getIdPasien()));
        request.setAttribute("riwayatPemeriksaan", pemeriksaanDAO.byPasien(pasien.getIdPasien()));
        request.setAttribute("riwayatCatatan", catatanDAO.byPasien(pasien.getIdPasien()));
        request.setAttribute("riwayatPembayaran", pembayaranDAO.byPasien(pasien.getIdPasien()));
        request.getRequestDispatcher("/pasien/detail-pasien.jsp").forward(request, response);
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Pasien data = ambilData(request, errors);
        validasi(data, ubah ? data.getIdPasien() : null, errors);

        if (ubah && data.getIdPasien() == null) {
            errors.put("id", "Data pasien tidak ditemukan.");
        }

        // Pembuatan akun login (hanya saat menambah)
        String usernameAkun = Validasi.teks(request.getParameter("usernameAkun"));
        String passwordAkun = Validasi.teks(request.getParameter("passwordAkun"));
        if (!ubah && (usernameAkun != null || passwordAkun != null)) {
            if (usernameAkun == null || passwordAkun == null) {
                errors.put("usernameAkun", "Username dan password akun harus diisi bersamaan.");
            } else if (passwordAkun.length() < 6) {
                errors.put("passwordAkun", "Password akun minimal 6 karakter.");
            } else if (userDAO.findByUsername(usernameAkun) != null) {
                errors.put("usernameAkun", "Username sudah dipakai akun lain.");
            }
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/pasien/edit-pasien.jsp" : "/pasien/tambah-pasien.jsp")
                    .forward(request, response);
            return;
        }

        if (ubah) {
            if (!pasienDAO.ubah(data)) {
                Auth.gagal(request, "Data pasien gagal diperbarui.");
            } else {
                Auth.sukses(request, "Data pasien berhasil diperbarui.");
            }
        } else {
            if (usernameAkun != null && passwordAkun != null) {
                User akun = new User();
                akun.setUsername(usernameAkun);
                akun.setPassword(PasswordUtil.hash(passwordAkun));
                akun.setNamaLengkap(data.getNamaPasien());
                akun.setRole("PASIEN");
                akun.setStatus("AKTIF");
                userDAO.tambah(akun);
                data.setIdPengguna(akun.getIdPengguna());
            }
            if (!pasienDAO.tambah(data)) {
                Auth.gagal(request, "Data pasien gagal ditambahkan.");
            } else {
                Auth.sukses(request, "Data pasien berhasil ditambahkan.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/pasien");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || pasienDAO.findById(id) == null) {
            Auth.gagal(request, "Data pasien tidak ditemukan.");
        } else {
            try {
                pasienDAO.hapus(id);
                Auth.sukses(request, "Data pasien berhasil dihapus.");
            } catch (RuntimeException e) {
                Auth.gagal(request, "Data pasien tidak dapat dihapus karena masih memiliki riwayat rawat inap, "
                        + "pemeriksaan, atau pembayaran.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/pasien");
    }

    private Pasien ambilData(HttpServletRequest request, Map<String, String> errors) {
        Pasien p = new Pasien();
        p.setIdPasien(Validasi.id(request.getParameter("id")));
        p.setNik(param(request, "nik", ""));
        p.setNamaPasien(param(request, "namaPasien", ""));
        p.setJenisKelamin(param(request, "jenisKelamin", ""));
        p.setTempatLahir(param(request, "tempatLahir", ""));
        p.setAlamat(param(request, "alamat", ""));
        p.setNoTelepon(param(request, "noTelepon", ""));
        p.setGolonganDarah(param(request, "golonganDarah", ""));
        p.setIdPenyakit(Validasi.id(request.getParameter("idPenyakit")));
        p.setIdDokter(Validasi.id(request.getParameter("idDokter")));
        p.setIdPengguna(Validasi.id(request.getParameter("idPengguna")));
        p.setStatusPasien(param(request, "statusPasien", ""));

        p.setTanggalLahir(Validasi.tanggal(request.getParameter("tanggalLahir"),
                "tanggalLahir", "Tanggal lahir", errors));
        p.setTanggalMasuk(Validasi.tanggal(request.getParameter("tanggalMasuk"),
                "tanggalMasuk", "Tanggal masuk", errors));
        p.setTanggalKeluar(Validasi.tanggalOpsional(request.getParameter("tanggalKeluar"),
                "tanggalKeluar", "Tanggal keluar", errors));

        if (p.getTanggalMasuk() != null && p.getTanggalKeluar() != null
                && p.getTanggalKeluar().isBefore(p.getTanggalMasuk())) {
            errors.put("tanggalKeluar", "Tanggal keluar tidak boleh sebelum tanggal masuk.");
        }
        return p;
    }

    private void validasi(Pasien p, Integer idSekarang, Map<String, String> errors) {
        if (Validasi.wajib(p.getNik(), "nik", "NIK", errors) != null) {
            if (!Validasi.angka(p.getNik(), 16)) {
                errors.put("nik", "NIK harus terdiri dari 16 digit angka.");
            } else if (pasienDAO.nikDipakai(p.getNik(), idSekarang)) {
                errors.put("nik", "NIK sudah terdaftar pada pasien lain.");
            }
        }
        Validasi.wajib(p.getNamaPasien(), "namaPasien", "Nama pasien", errors);
        Validasi.pilihan(p.getJenisKelamin(), new String[]{"Laki-laki", "Perempuan"},
                "jenisKelamin", "Jenis kelamin", errors);
        Validasi.wajib(p.getTempatLahir(), "tempatLahir", "Tempat lahir", errors);
        Validasi.telepon(p.getNoTelepon(), "noTelepon", "No telepon", errors);
        Validasi.pilihan(p.getStatusPasien(), STATUS_PASIEN, "statusPasien", "Status pasien", errors);

        if (p.getIdDokter() != null && dokterDAO.findById(p.getIdDokter()) == null) {
            errors.put("idDokter", "Dokter yang dipilih tidak ditemukan.");
        }
        if (p.getIdPenyakit() != null && penyakitDAO.findById(p.getIdPenyakit()) == null) {
            errors.put("idPenyakit", "Penyakit yang dipilih tidak ditemukan.");
        }
        if (p.getIdPengguna() != null && userDAO.findById(p.getIdPengguna()) == null) {
            errors.put("idPengguna", "Akun pengguna yang dipilih tidak ditemukan.");
        }
    }

    /** Data pendukung untuk form (dropdown). */
    private void siapkanForm(HttpServletRequest request) {
        request.setAttribute("daftarDokter", dokterDAO.daftarAktif());
        request.setAttribute("daftarPenyakit", penyakitDAO.semua(null, null));
        request.setAttribute("daftarAkunPasien", userDAO.semua("PASIEN"));
        request.setAttribute("tanggalHariIni", java.time.LocalDate.now().toString());
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
