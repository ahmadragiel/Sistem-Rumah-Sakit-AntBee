package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PerawatDAO;
import com.mycompany.rumahsakit.dao.UserDAO;
import com.mycompany.rumahsakit.model.Dokter;
import com.mycompany.rumahsakit.model.Pasien;
import com.mycompany.rumahsakit.model.Perawat;
import com.mycompany.rumahsakit.model.User;
import com.mycompany.rumahsakit.util.Auth;
import com.mycompany.rumahsakit.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/** Servlet login terpadu untuk semua role. */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final PerawatDAO perawatDAO = new PerawatDAO();
    private final PasienDAO pasienDAO = new PasienDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (Auth.pengguna(request) != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username =(request.getParameter("username") == null ? "" : request.getParameter("username")).trim();
        String password = request.getParameter("password") == null ? "" : request.getParameter("password");

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Username dan password wajib diisi.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.cariLogin(username, PasswordUtil.hash(password));

        if (user == null) {
            request.setAttribute("error", "Username atau password salah. Silakan periksa kembali.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if ("NONAKTIF".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("error", "Akun Anda berstatus nonaktif. Silakan hubungi administrator.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Hubungkan akun dengan data jabatan masing-masing role.
        Integer idDokter = null;
        Integer idPerawat = null;
        Integer idPasien = null;

        if ("DOKTER".equals(user.getRole())) {
            Dokter dokter = dokterDAO.findByPengguna(user.getIdPengguna());
            if (dokter == null) {
                request.setAttribute("error", "Akun dokter ini belum terhubung ke data dokter. Hubungi administrator.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            idDokter = dokter.getIdDokter();
        } else if ("PERAWAT".equals(user.getRole())) {
            Perawat perawat = perawatDAO.findByPengguna(user.getIdPengguna());
            if (perawat == null) {
                request.setAttribute("error", "Akun perawat ini belum terhubung ke data perawat. Hubungi administrator.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            idPerawat = perawat.getIdPerawat();
        } else if ("PASIEN".equals(user.getRole())) {
            Pasien pasien = pasienDAO.findByPengguna(user.getIdPengguna());
            if (pasien == null) {
                request.setAttribute("error", "Akun pasien ini belum terhubung ke data pasien. Hubungi administrator.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            idPasien = pasien.getIdPasien();
        }

        HttpSession session = request.getSession(true);
        session.setAttribute(Auth.ATRIBUT_USER, user);
        if (idDokter != null) {
            session.setAttribute(Auth.ATRIBUT_ID_DOKTER, idDokter);
        }
        if (idPerawat != null) {
            session.setAttribute(Auth.ATRIBUT_ID_PERAWAT, idPerawat);
        }
        if (idPasien != null) {
            session.setAttribute(Auth.ATRIBUT_ID_PASIEN, idPasien);
        }

        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}
