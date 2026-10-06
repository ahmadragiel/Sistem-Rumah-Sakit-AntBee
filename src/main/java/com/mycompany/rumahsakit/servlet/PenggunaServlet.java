package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.UserDAO;
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

/** Servlet manajemen pengguna (akun login). Hanya ADMIN. */
@WebServlet(name = "PenggunaServlet", urlPatterns = {"/pengguna"})
public class PenggunaServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    private static final String[] ROLE_ADMIN = {"ADMIN"};
    private static final String[] SEMUA_ROLE = {"ADMIN", "DOKTER", "PERAWAT", "PETUGAS", "PASIEN"};
    private static final String[] STATUS_AKUN = {"AKTIF", "NONAKTIF"};

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
                request.setAttribute("data", baru());
                request.getRequestDispatcher("/pengguna/tambah-pengguna.jsp").forward(request, response);
                break;
            case "edit":
                Integer id = Validasi.id(request.getParameter("id"));
                User diedit = id == null ? null : userDAO.findById(id);
                if (diedit == null) {
                    Auth.gagal(request, "Data pengguna tidak ditemukan.");
                    response.sendRedirect(request.getContextPath() + "/pengguna");
                    return;
                }
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/pengguna/edit-pengguna.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("daftarPengguna", userDAO.semua(param(request, "q", "")));
                request.setAttribute("q", param(request, "q", ""));
                request.getRequestDispatcher("/pengguna/pengguna.jsp").forward(request, response);
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
            hapus(request, response, user);
            return;
        }
        if ("simpan".equals(aksi) || "update".equals(aksi)) {
            simpan(request, response, "update".equals(aksi), user);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/pengguna");
    }

    private User baru() {
        User u = new User();
        u.setStatus("AKTIF");
        u.setRole("PASIEN");
        return u;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah, User admin)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        User data = new User();
        data.setIdPengguna(Validasi.id(request.getParameter("id")));
        data.setUsername(Validasi.wajib(param(request, "username", ""), "username", "Username", errors));
        data.setNamaLengkap(Validasi.wajib(param(request, "namaLengkap", ""),
                "namaLengkap", "Nama lengkap", errors));
        data.setEmail(param(request, "email", ""));
        data.setNoTelepon(param(request, "noTelepon", ""));
        data.setAlamat(param(request, "alamat", ""));
        data.setRole(Validasi.pilihan(param(request, "role", ""), SEMUA_ROLE, "role", "Role", errors));
        data.setStatus(Validasi.pilihan(param(request, "status", ""), STATUS_AKUN,
                "status", "Status akun", errors));

        String password = Validasi.teks(request.getParameter("password"));
        String ulangiPassword = Validasi.teks(request.getParameter("ulangiPassword"));

        if (data.getUsername() != null && !data.getUsername().matches("[A-Za-z0-9._]{4,50}")) {
            errors.put("username", "Username minimal 4 karakter dan hanya boleh berisi huruf, angka, titik, atau garis bawah.");
        } else if (data.getUsername() != null
                && userDAO.usernameDipakai(data.getUsername(), data.getIdPengguna())) {
            errors.put("username", "Username sudah dipakai akun lain.");
        }
        if (data.getEmail() != null && !Validasi.email(data.getEmail())) {
            errors.put("email", "Format email tidak valid.");
        }
        Validasi.telepon(data.getNoTelepon(), "noTelepon", "No telepon", errors);

        if (!ubah) {
            if (password == null) {
                errors.put("password", "Password wajib diisi.");
            } else if (password.length() < 6) {
                errors.put("password", "Password minimal 6 karakter.");
            } else if (ulangiPassword == null || !password.equals(ulangiPassword)) {
                errors.put("ulangiPassword", "Ulangi password tidak sama dengan password.");
            }
        } else if (password != null) {
            if (password.length() < 6) {
                errors.put("password", "Password minimal 6 karakter.");
            } else if (ulangiPassword == null || !password.equals(ulangiPassword)) {
                errors.put("ulangiPassword", "Ulangi password tidak sama dengan password.");
            }
        }

        // Cegah admin menonaktifkan atau menghapus akunnya sendiri
        if (ubah && admin.getIdPengguna().equals(data.getIdPengguna())
                && !STATUS_AKUN[0].equals(data.getStatus())) {
            errors.put("status", "Anda tidak dapat menonaktifkan akun yang sedang digunakan.");
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            request.getRequestDispatcher(ubah ? "/pengguna/edit-pengguna.jsp" : "/pengguna/tambah-pengguna.jsp")
                    .forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            data.setPassword(null);
            berhasil = userDAO.ubah(data);
            if (berhasil && password != null) {
                userDAO.ubahPassword(data.getIdPengguna(), PasswordUtil.hash(password));
            }
            Auth.sukses(request, berhasil ? "Data pengguna berhasil diperbarui."
                    : "Data pengguna gagal diperbarui.");
        } else {
            data.setPassword(PasswordUtil.hash(password));
            berhasil = userDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data pengguna berhasil ditambahkan."
                    : "Data pengguna gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/pengguna");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || userDAO.findById(id) == null) {
            Auth.gagal(request, "Data pengguna tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/pengguna");
            return;
        }
        if (admin.getIdPengguna().equals(id)) {
            Auth.gagal(request, "Anda tidak dapat menghapus akun yang sedang digunakan.");
            response.sendRedirect(request.getContextPath() + "/pengguna");
            return;
        }
        try {
            userDAO.hapus(id);
            Auth.sukses(request, "Data pengguna berhasil dihapus.");
        } catch (RuntimeException e) {
            Auth.gagal(request, "Data pengguna tidak dapat dihapus karena masih terhubung ke data lain.");
        }
        response.sendRedirect(request.getContextPath() + "/pengguna");
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
