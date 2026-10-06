package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.CatatanPerawatanDAO;
import com.mycompany.rumahsakit.dao.PerawatDAO;
import com.mycompany.rumahsakit.dao.UserDAO;
import com.mycompany.rumahsakit.model.Perawat;
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

/** Servlet modul data perawat: daftar, tambah, ubah, hapus, detail. Hanya ADMIN. */
@WebServlet(name = "PerawatServlet", urlPatterns = {"/perawat"})
public class PerawatServlet extends HttpServlet {

    private final PerawatDAO perawatDAO = new PerawatDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CatatanPerawatanDAO catatanDAO = new CatatanPerawatanDAO();

    private static final String[] ROLE_ADMIN = {"ADMIN"};
    private static final String[] STATUS_PERAWAT = {"AKTIF", "NONAKTIF"};
    private static final String[] JENIS_KELAMIN = {"Laki-laki", "Perempuan"};
    private static final String[] SHIFT = {"Pagi", "Siang", "Malam"};

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
                request.setAttribute("data", new Perawat());
                request.getRequestDispatcher("/perawat/tambah-perawat.jsp").forward(request, response);
                break;
            case "edit":
                Perawat diedit = cari(request, response);
                if (diedit == null) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/perawat/edit-perawat.jsp").forward(request, response);
                break;
            case "detail":
                Perawat p = cari(request, response);
                if (p == null) {
                    return;
                }
                request.setAttribute("data", p);
                request.setAttribute("daftarCatatan", catatanDAO.byPerawat(p.getIdPerawat()));
                request.getRequestDispatcher("/perawat/detail-perawat.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("daftarPerawat", perawatDAO.semua(
                        param(request, "q", ""),
                        param(request, "shift", ""),
                        param(request, "status", "")));
                request.setAttribute("q", param(request, "q", ""));
                request.setAttribute("shift", param(request, "shift", ""));
                request.setAttribute("status", param(request, "status", ""));
                request.getRequestDispatcher("/perawat/perawat.jsp").forward(request, response);
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
        response.sendRedirect(request.getContextPath() + "/perawat");
    }

    private Perawat cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        Perawat perawat = id == null ? null : perawatDAO.findById(id);
        if (perawat == null) {
            Auth.gagal(request, "Data perawat tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/perawat");
        }
        return perawat;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Perawat data = new Perawat();
        data.setIdPerawat(Validasi.id(request.getParameter("id")));
        data.setNip(Validasi.wajib(param(request, "nip", ""), "nip", "NIP", errors));
        data.setNamaPerawat(Validasi.wajib(param(request, "namaPerawat", ""),
                "namaPerawat", "Nama perawat", errors));
        data.setJenisKelamin(Validasi.pilihan(param(request, "jenisKelamin", ""),
                JENIS_KELAMIN, "jenisKelamin", "Jenis kelamin", errors));
        data.setTempatLahir(Validasi.wajib(param(request, "tempatLahir", ""),
                "tempatLahir", "Tempat lahir", errors));
        data.setPendidikan(Validasi.wajib(param(request, "pendidikan", ""),
                "pendidikan", "Pendidikan", errors));
        data.setAlamat(param(request, "alamat", ""));
        data.setNoTelepon(param(request, "noTelepon", ""));
        data.setShift(Validasi.pilihan(param(request, "shift", ""), SHIFT, "shift", "Shift", errors));
        data.setRuangan(Validasi.wajib(param(request, "ruangan", ""), "ruangan", "Ruangan tugas", errors));
        data.setStatus(Validasi.pilihan(param(request, "status", ""), STATUS_PERAWAT,
                "status", "Status perawat", errors));
        data.setIdPengguna(Validasi.id(request.getParameter("idPengguna")));
        data.setTanggalLahir(Validasi.tanggal(request.getParameter("tanggalLahir"),
                "tanggalLahir", "Tanggal lahir", errors));

        if (data.getNip() != null) {
            if (data.getNip().length() < 5) {
                errors.put("nip", "NIP minimal 5 karakter.");
            } else if (perawatDAO.nipDipakai(data.getNip(), data.getIdPerawat())) {
                errors.put("nip", "NIP sudah dipakai perawat lain.");
            }
        }
        Validasi.telepon(data.getNoTelepon(), "noTelepon", "No telepon", errors);
        if (data.getIdPengguna() != null && userDAO.findById(data.getIdPengguna()) == null) {
            errors.put("idPengguna", "Akun pengguna yang dipilih tidak ditemukan.");
        }

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
        if (ubah && data.getIdPerawat() == null) {
            errors.put("id", "Data perawat tidak ditemukan.");
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/perawat/edit-perawat.jsp" : "/perawat/tambah-perawat.jsp")
                    .forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = perawatDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Data perawat berhasil diperbarui."
                    : "Data perawat gagal diperbarui.");
        } else {
            if (usernameAkun != null) {
                User akun = new User();
                akun.setUsername(usernameAkun);
                akun.setPassword(PasswordUtil.hash(passwordAkun));
                akun.setNamaLengkap(data.getNamaPerawat());
                akun.setNoTelepon(data.getNoTelepon());
                akun.setRole("PERAWAT");
                akun.setStatus("AKTIF");
                userDAO.tambah(akun);
                data.setIdPengguna(akun.getIdPengguna());
            }
            berhasil = perawatDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data perawat berhasil ditambahkan."
                    : "Data perawat gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/perawat");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || perawatDAO.findById(id) == null) {
            Auth.gagal(request, "Data perawat tidak ditemukan.");
        } else {
            try {
                perawatDAO.hapus(id);
                Auth.sukses(request, "Data perawat berhasil dihapus.");
            } catch (RuntimeException e) {
                Auth.gagal(request, "Data perawat tidak dapat dihapus karena masih memiliki catatan perawatan.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/perawat");
    }

    private void siapkanForm(HttpServletRequest request) {
        request.setAttribute("daftarAkunPerawat", userDAO.semua("PERAWAT"));
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
