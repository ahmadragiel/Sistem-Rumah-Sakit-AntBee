package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PerawatDAO;
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

/** Servlet profil: melihat dan memperbarui data diri + mengganti password. */
@WebServlet(name = "ProfilServlet", urlPatterns = {"/profil"})
public class ProfilServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final PerawatDAO perawatDAO = new PerawatDAO();
    private final PasienDAO pasienDAO = new PasienDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null) {
            return;
        }
        isiProfil(request, user);
        request.getRequestDispatcher("/profil/profil.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null) {
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String aksi = request.getParameter("aksi") == null ? "" : request.getParameter("aksi").trim();

        if ("ubahData".equals(aksi)) {
            ubahData(request, response, user);
        } else if ("gantiPassword".equals(aksi)) {
            gantiPassword(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/profil");
        }
    }

    private void isiProfil(HttpServletRequest request, User user) {
        request.setAttribute("data", user);
        switch (user.getRole()) {
            case "DOKTER":
                request.setAttribute("jabatan", dokterDAO.findByPengguna(user.getIdPengguna()));
                request.setAttribute("labelJabatan", "Data Dokter");
                break;
            case "PERAWAT":
                request.setAttribute("jabatan", perawatDAO.findByPengguna(user.getIdPengguna()));
                request.setAttribute("labelJabatan", "Data Perawat");
                break;
            case "PASIEN":
                request.setAttribute("jabatan", pasienDAO.findByPengguna(user.getIdPengguna()));
                request.setAttribute("labelJabatan", "Data Pasien");
                break;
            default:
                request.setAttribute("labelJabatan", "Data Akun");
        }
    }

    private void ubahData(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        User data = new User();
        data.setIdPengguna(user.getIdPengguna());
        data.setUsername(user.getUsername());
        data.setRole(user.getRole());
        data.setStatus(user.getStatus());
        data.setNamaLengkap(Validasi.wajib(param(request, "namaLengkap", ""),
                "namaLengkap", "Nama lengkap", errors));
        data.setEmail(param(request, "email", ""));
        data.setNoTelepon(param(request, "noTelepon", ""));
        data.setAlamat(param(request, "alamat", ""));

        if (data.getEmail() != null && !Validasi.email(data.getEmail())) {
            errors.put("email", "Format email tidak valid.");
        }
        Validasi.telepon(data.getNoTelepon(), "noTelepon", "No telepon", errors);

        if (Validasi.adaError(errors)) {
            isiProfil(request, user);
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            request.setAttribute("tabUbahData", true);
            request.getRequestDispatcher("/profil/profil.jsp").forward(request, response);
            return;
        }

        if (userDAO.ubah(data)) {
            // Perbarui session agar nama di topbar ikut berubah
            user.setNamaLengkap(data.getNamaLengkap());
            user.setEmail(data.getEmail());
            user.setNoTelepon(data.getNoTelepon());
            user.setAlamat(data.getAlamat());
            request.getSession().setAttribute(Auth.ATRIBUT_USER, user);
            Auth.sukses(request, "Data profil berhasil diperbarui.");
        } else {
            Auth.gagal(request, "Data profil gagal diperbarui.");
        }
        response.sendRedirect(request.getContextPath() + "/profil");
    }

    private void gantiPassword(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        String lama = request.getParameter("passwordLama") == null ? "" : request.getParameter("passwordLama");
        String baru = request.getParameter("passwordBaru") == null ? "" : request.getParameter("passwordBaru");
        String ulangi = request.getParameter("ulangiPassword") == null ? "" : request.getParameter("ulangiPassword");

        if (lama.isEmpty()) {
            errors.put("passwordLama", "Password lama wajib diisi.");
        } else if (!PasswordUtil.cocok(lama, user.getPassword())) {
            errors.put("passwordLama", "Password lama tidak sesuai.");
        }
        if (baru.isEmpty()) {
            errors.put("passwordBaru", "Password baru wajib diisi.");
        } else if (baru.length() < 6) {
            errors.put("passwordBaru", "Password baru minimal 6 karakter.");
        }
        if (!baru.equals(ulangi)) {
            errors.put("ulangiPassword", "Ulangi password tidak sama dengan password baru.");
        }

        if (Validasi.adaError(errors)) {
            isiProfil(request, user);
            request.setAttribute("errors", errors);
            request.setAttribute("tabGantiPassword", true);
            request.getRequestDispatcher("/profil/profil.jsp").forward(request, response);
            return;
        }

        userDAO.ubahPassword(user.getIdPengguna(), PasswordUtil.hash(baru));
        Auth.sukses(request, "Password berhasil diganti.");
        response.sendRedirect(request.getContextPath() + "/profil");
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
