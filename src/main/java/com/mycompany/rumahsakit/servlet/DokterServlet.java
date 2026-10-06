package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.dao.UserDAO;
import com.mycompany.rumahsakit.model.Dokter;
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

/** Servlet modul data dokter: daftar, tambah, ubah, hapus, detail. Hanya ADMIN. */
@WebServlet(name = "DokterServlet", urlPatterns = {"/dokter"})
public class DokterServlet extends HttpServlet {

    private final DokterDAO dokterDAO = new DokterDAO();
    private final UserDAO userDAO = new UserDAO();
    private final PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();

    private static final String[] ROLE_ADMIN = {"ADMIN"};
    private static final String[] STATUS_DOKTER = {"AKTIF", "NONAKTIF"};
    private static final String[] JENIS_KELAMIN = {"Laki-laki", "Perempuan"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_ADMIN)) {
            return;
        }
        String aksi = param(request, "aksi", "daftar");

        switch (aksi) {
            case "tambah":
                siapkanForm(request);
                request.setAttribute("data", new Dokter());
                request.getRequestDispatcher("/dokter/tambah-dokter.jsp").forward(request, response);
                break;
            case "edit":
                Dokter diedit = cari(request, response);
                if (diedit == null) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/dokter/edit-dokter.jsp").forward(request, response);
                break;
            case "detail":
                Dokter d = cari(request, response);
                if (d == null) {
                    return;
                }
                request.setAttribute("data", d);
                request.setAttribute("daftarPemeriksaan", pemeriksaanDAO.byDokter(d.getIdDokter()));
                request.getRequestDispatcher("/dokter/detail-dokter.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("daftarDokter", dokterDAO.semua(
                        param(request, "q", ""),
                        param(request, "spesialisasi", ""),
                        param(request, "status", "")));
                request.setAttribute("daftarSpesialisasi", dokterDAO.daftarSpesialisasi());
                request.setAttribute("q", param(request, "q", ""));
                request.setAttribute("spesialisasi", param(request, "spesialisasi", ""));
                request.setAttribute("status", param(request, "status", ""));
                request.getRequestDispatcher("/dokter/dokter.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_ADMIN)) {
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String aksi = param(request, "aksi", "");

        if ("hapus".equals(aksi)) {
            hapus(request, response);
            return;
        }
        if ("simpan".equals(aksi) || "update".equals(aksi)) {
            simpan(request, response, "update".equals(aksi));
            return;
        }
        response.sendRedirect(request.getContextPath() + "/dokter");
    }

    private Dokter cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        Dokter dokter = id == null ? null : dokterDAO.findById(id);
        if (dokter == null) {
            Auth.gagal(request, "Data dokter tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/dokter");
        }
        return dokter;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Dokter data = new Dokter();
        data.setIdDokter(Validasi.id(request.getParameter("id")));
        data.setNip(Validasi.wajib(param(request, "nip", ""), "nip", "NIP", errors));
        data.setNamaDokter(Validasi.wajib(param(request, "namaDokter", ""), "namaDokter", "Nama dokter", errors));
        data.setJenisKelamin(Validasi.pilihan(param(request, "jenisKelamin", ""),
                JENIS_KELAMIN, "jenisKelamin", "Jenis kelamin", errors));
        data.setTempatLahir(param(request, "tempatLahir", ""));
        data.setSpesialisasi(Validasi.wajib(param(request, "spesialisasi", ""),
                "spesialisasi", "Spesialisasi", errors));
        data.setAlamat(param(request, "alamat", ""));
        data.setNoTelepon(param(request, "noTelepon", ""));
        data.setEmail(param(request, "email", ""));
        data.setJadwalPraktik(param(request, "jadwalPraktik", ""));
        data.setStatus(Validasi.pilihan(param(request, "status", ""), STATUS_DOKTER,
                "status", "Status dokter", errors));
        data.setIdPengguna(Validasi.id(request.getParameter("idPengguna")));
        data.setTanggalLahir(Validasi.tanggalOpsional(request.getParameter("tanggalLahir"),
                "tanggalLahir", "Tanggal lahir", errors));

        if (data.getNip() != null) {
            if (data.getNip().length() < 5) {
                errors.put("nip", "NIP minimal 5 karakter.");
            } else if (dokterDAO.nipDipakai(data.getNip(), data.getIdDokter())) {
                errors.put("nip", "NIP sudah dipakai dokter lain.");
            }
        }
        if (data.getTempatLahir() == null) {
            errors.put("tempatLahir", "Tempat lahir wajib diisi.");
        }
        Validasi.telepon(data.getNoTelepon(), "noTelepon", "No telepon", errors);
        if (data.getEmail() != null && !Validasi.email(data.getEmail())) {
            errors.put("email", "Format email tidak valid.");
        }
        if (data.getIdPengguna() != null && userDAO.findById(data.getIdPengguna()) == null) {
            errors.put("idPengguna", "Akun pengguna yang dipilih tidak ditemukan.");
        }

        // Pembuatan akun login (saat menambah)
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
        if (ubah && data.getIdDokter() == null) {
            errors.put("id", "Data dokter tidak ditemukan.");
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/dokter/edit-dokter.jsp" : "/dokter/tambah-dokter.jsp")
                    .forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = dokterDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Data dokter berhasil diperbarui."
                    : "Data dokter gagal diperbarui.");
        } else {
            if (usernameAkun != null) {
                User akun = new User();
                akun.setUsername(usernameAkun);
                akun.setPassword(PasswordUtil.hash(passwordAkun));
                akun.setNamaLengkap(data.getNamaDokter());
                akun.setEmail(data.getEmail());
                akun.setNoTelepon(data.getNoTelepon());
                akun.setRole("DOKTER");
                akun.setStatus("AKTIF");
                userDAO.tambah(akun);
                data.setIdPengguna(akun.getIdPengguna());
            }
            berhasil = dokterDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data dokter berhasil ditambahkan."
                    : "Data dokter gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/dokter");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || dokterDAO.findById(id) == null) {
            Auth.gagal(request, "Data dokter tidak ditemukan.");
        } else {
            try {
                dokterDAO.hapus(id);
                Auth.sukses(request, "Data dokter berhasil dihapus.");
            } catch (RuntimeException e) {
                Auth.gagal(request, "Data dokter tidak dapat dihapus karena masih terkait "
                        + "dengan data pasien, rawat inap, atau pemeriksaan.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/dokter");
    }

    private void siapkanForm(HttpServletRequest request) {
        request.setAttribute("daftarAkunDokter", userDAO.semua("DOKTER"));
        request.setAttribute("tanggalHariIni", java.time.LocalDate.now().toString());
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
