package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.CatatanPerawatanDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PerawatDAO;
import com.mycompany.rumahsakit.model.CatatanPerawatan;
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
import java.util.Objects;

/**
 * Servlet modul catatan perawatan.
 *
 * PERAWAT: membuat/mengubah catatan miliknya sendiri.
 * DOKTER: hanya membaca catatan (untuk melihat perkembangan pasien).
 * ADMIN: penuh.
 */
@WebServlet(name = "CatatanPerawatanServlet", urlPatterns = {"/catatan-perawatan"})
public class CatatanPerawatanServlet extends HttpServlet {

    private final CatatanPerawatanDAO catatanDAO = new CatatanPerawatanDAO();
    private final PasienDAO pasienDAO = new PasienDAO();
    private final PerawatDAO perawatDAO = new PerawatDAO();

    private static final String[] ROLE_BACA = {"ADMIN", "DOKTER", "PERAWAT"};
    private static final String[] ROLE_TULIS = {"ADMIN", "PERAWAT"};
    private static final String[] STATUS_KONDISI = {"BAIK", "SEDANG", "KRITIS"};

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
                CatatanPerawatan baru = new CatatanPerawatan();
                baru.setTanggal(LocalDate.now());
                baru.setStatus("BAIK");
                baru.setIdPerawat("PERAWAT".equals(user.getRole()) ? Auth.idPerawat(request) : null);
                request.setAttribute("data", baru);
                request.getRequestDispatcher("/catatan-perawatan/tambah-catatan.jsp").forward(request, response);
                break;
            case "edit":
                if (!Auth.wajibRole(request, response, user, ROLE_TULIS)) {
                    return;
                }
                CatatanPerawatan diedit = cariMilikSendiri(request, response, user);
                if (diedit == null) {
                    return;
                }
                siapkanForm(request);
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/catatan-perawatan/edit-catatan.jsp").forward(request, response);
                break;
            case "detail":
                Integer id = Validasi.id(request.getParameter("id"));
                CatatanPerawatan data = id == null ? null : catatanDAO.findById(id);
                if (data == null) {
                    Auth.gagal(request, "Catatan perawatan tidak ditemukan.");
                    response.sendRedirect(request.getContextPath() + "/catatan-perawatan");
                    return;
                }
                request.setAttribute("data", data);
                request.getRequestDispatcher("/catatan-perawatan/detail-catatan.jsp").forward(request, response);
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
            simpan(request, response, "update".equals(aksi), user);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/catatan-perawatan");
    }

    private void daftar(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        Integer idPerawatFilter = null;
        if ("PERAWAT".equals(user.getRole())) {
            idPerawatFilter = Auth.idPerawat(request);
        } else if (!"ADMIN".equals(user.getRole())) {
            // Dokter: tampilkan semua catatan (baca saja)
            idPerawatFilter = null;
        } else {
            idPerawatFilter = Validasi.id(request.getParameter("idPerawat"));
        }

        request.setAttribute("daftarCatatan", catatanDAO.semua(
                param(request, "q", ""), idPerawatFilter, null, param(request, "status", "")));
        request.setAttribute("q", param(request, "q", ""));
        request.setAttribute("status", param(request, "status", ""));
        if ("ADMIN".equals(user.getRole())) {
            request.setAttribute("daftarPerawat", perawatDAO.daftarAktif());
            request.setAttribute("idPerawat", idPerawatFilter);
        }
        request.getRequestDispatcher("/catatan-perawatan/catatan-perawatan.jsp").forward(request, response);
    }

    private CatatanPerawatan cariMilikSendiri(HttpServletRequest request, HttpServletResponse response,
            User user) throws IOException {

        Integer id = Validasi.id(request.getParameter("id"));
        CatatanPerawatan data = id == null ? null : catatanDAO.findById(id);
        if (data == null) {
            Auth.gagal(request, "Catatan perawatan tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/catatan-perawatan");
            return null;
        }
        if ("PERAWAT".equals(user.getRole())) {
            Integer idPerawat = Auth.idPerawat(request);
            if (idPerawat == null || !idPerawat.equals(data.getIdPerawat())) {
                Auth.gagal(request, "Anda hanya dapat mengubah catatan perawatan yang Anda buat sendiri.");
                response.sendRedirect(request.getContextPath() + "/catatan-perawatan");
                return null;
            }
        }
        return data;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah, User user)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        CatatanPerawatan data = new CatatanPerawatan();
        data.setIdCatatan(Validasi.id(request.getParameter("id")));
        data.setIdPasien(Validasi.id(request.getParameter("idPasien")));
        data.setTanggal(Validasi.tanggal(request.getParameter("tanggal"),
                "tanggal", "Tanggal catatan", errors));
        data.setKondisiPasien(Validasi.wajib(param(request, "kondisiPasien", ""),
                "kondisiPasien", "Kondisi pasien", errors));
        data.setCatatan(Validasi.wajib(param(request, "catatan", ""), "catatan", "Catatan", errors));
        data.setTindakan(Validasi.wajib(param(request, "tindakan", ""), "tindakan", "Tindakan", errors));
        data.setStatus(Validasi.pilihan(param(request, "status", ""), STATUS_KONDISI,
                "status", "Status kondisi", errors));

        // Perawat selalu terikat pada datanya sendiri; admin boleh memilih perawat.
        if ("PERAWAT".equals(user.getRole())) {
            data.setIdPerawat(Auth.idPerawat(request));
        } else {
            data.setIdPerawat(Validasi.id(request.getParameter("idPerawat")));
            if (data.getIdPerawat() == null || perawatDAO.findById(data.getIdPerawat()) == null) {
                errors.put("idPerawat", "Perawat wajib dipilih dan harus tersedia.");
            }
        }

        if (data.getIdPasien() == null || pasienDAO.findById(data.getIdPasien()) == null) {
            errors.put("idPasien", "Pasien wajib dipilih dan harus tersedia.");
        }

        if (ubah) {
            CatatanPerawatan lama = data.getIdCatatan() == null ? null : catatanDAO.findById(data.getIdCatatan());
            if (lama == null) {
                errors.put("id", "Catatan perawatan tidak ditemukan.");
            } else if ("PERAWAT".equals(user.getRole())
                    && !Objects.equals(lama.getIdPerawat(), Auth.idPerawat(request))) {
                response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                return;
            }
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            siapkanForm(request);
            request.getRequestDispatcher(ubah ? "/catatan-perawatan/edit-catatan.jsp"
                    : "/catatan-perawatan/tambah-catatan.jsp").forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = catatanDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Catatan perawatan berhasil diperbarui."
                    : "Catatan perawatan gagal diperbarui.");
        } else {
            berhasil = catatanDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Catatan perawatan berhasil ditambahkan."
                    : "Catatan perawatan gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/catatan-perawatan");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || catatanDAO.findById(id) == null) {
            Auth.gagal(request, "Catatan perawatan tidak ditemukan.");
        } else {
            catatanDAO.hapus(id);
            Auth.sukses(request, "Catatan perawatan berhasil dihapus.");
        }
        response.sendRedirect(request.getContextPath() + "/catatan-perawatan");
    }

    private void siapkanForm(HttpServletRequest request) {
        request.setAttribute("daftarPasien", pasienDAO.semua(null, null, null));
        request.setAttribute("daftarPerawat", perawatDAO.daftarAktif());
        request.setAttribute("tanggalHariIni", LocalDate.now().toString());
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
