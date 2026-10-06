package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PenyakitDAO;
import com.mycompany.rumahsakit.model.Penyakit;
import com.mycompany.rumahsakit.model.User;
import com.mycompany.rumahsakit.util.Auth;
import com.mycompany.rumahsakit.util.Validasi;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/** Servlet modul kamus penyakit: daftar, tambah, ubah, hapus, detail. Hanya ADMIN. */
@WebServlet(name = "PenyakitServlet", urlPatterns = {"/penyakit"})
public class PenyakitServlet extends HttpServlet {

    private final PenyakitDAO penyakitDAO = new PenyakitDAO();
    private final PasienDAO pasienDAO = new PasienDAO();

    private static final String[] ROLE_ADMIN = {"ADMIN"};
    private static final String[] TINGKAT = {"RINGAN", "SEDANG", "BERAT", "KRITIS"};

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
                request.setAttribute("data", new Penyakit());
                request.getRequestDispatcher("/penyakit/tambah-penyakit.jsp").forward(request, response);
                break;
            case "edit":
                Penyakit diedit = cari(request, response);
                if (diedit == null) {
                    return;
                }
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/penyakit/edit-penyakit.jsp").forward(request, response);
                break;
            case "detail":
                Penyakit p = cari(request, response);
                if (p == null) {
                    return;
                }
                request.setAttribute("data", p);
                request.setAttribute("jumlahPasien", hitungPasien(p.getIdPenyakit()));
                request.getRequestDispatcher("/penyakit/detail-penyakit.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("daftarPenyakit", penyakitDAO.semua(
                        param(request, "q", ""), param(request, "jenis", "")));
                request.setAttribute("daftarJenis", penyakitDAO.daftarJenis());
                request.setAttribute("q", param(request, "q", ""));
                request.setAttribute("jenis", param(request, "jenis", ""));
                request.getRequestDispatcher("/penyakit/penyakit.jsp").forward(request, response);
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
        response.sendRedirect(request.getContextPath() + "/penyakit");
    }

    private Penyakit cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        Penyakit penyakit = id == null ? null : penyakitDAO.findById(id);
        if (penyakit == null) {
            Auth.gagal(request, "Data penyakit tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/penyakit");
        }
        return penyakit;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Penyakit data = new Penyakit();
        data.setIdPenyakit(Validasi.id(request.getParameter("id")));
        data.setKodePenyakit(Validasi.wajib(param(request, "kodePenyakit", ""),
                "kodePenyakit", "Kode penyakit", errors));
        data.setNamaPenyakit(Validasi.wajib(param(request, "namaPenyakit", ""),
                "namaPenyakit", "Nama penyakit", errors));
        data.setJenisPenyakit(Validasi.wajib(param(request, "jenisPenyakit", ""),
                "jenisPenyakit", "Jenis penyakit", errors));
        data.setTingkatKeparahan(Validasi.pilihan(param(request, "tingkatKeparahan", ""),
                TINGKAT, "tingkatKeparahan", "Tingkat keparahan", errors));
        data.setGejala(Validasi.wajib(param(request, "gejala", ""), "gejala", "Gejala", errors));
        data.setPenyebab(param(request, "penyebab", ""));
        data.setPenanganan(Validasi.wajib(param(request, "penanganan", ""),
                "penanganan", "Penanganan", errors));
        data.setObatUtama(param(request, "obatUtama", ""));
        data.setKeterangan(param(request, "keterangan", ""));

        if (data.getKodePenyakit() != null) {
            data.setKodePenyakit(data.getKodePenyakit().toUpperCase());
            if (penyakitDAO.kodeDipakai(data.getKodePenyakit(), data.getIdPenyakit())) {
                errors.put("kodePenyakit", "Kode penyakit sudah dipakai.");
            }
        }
        if (ubah && data.getIdPenyakit() == null) {
            errors.put("id", "Data penyakit tidak ditemukan.");
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            request.getRequestDispatcher(ubah ? "/penyakit/edit-penyakit.jsp" : "/penyakit/tambah-penyakit.jsp")
                    .forward(request, response);
            return;
        }

        boolean berhasil;
        if (ubah) {
            berhasil = penyakitDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Data penyakit berhasil diperbarui."
                    : "Data penyakit gagal diperbarui.");
        } else {
            berhasil = penyakitDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data penyakit berhasil ditambahkan."
                    : "Data penyakit gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/penyakit");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || penyakitDAO.findById(id) == null) {
            Auth.gagal(request, "Data penyakit tidak ditemukan.");
        } else {
            try {
                penyakitDAO.hapus(id);
                Auth.sukses(request, "Data penyakit berhasil dihapus.");
            } catch (RuntimeException e) {
                Auth.gagal(request, "Data penyakit tidak dapat dihapus karena masih dipakai oleh data pasien.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/penyakit");
    }

    private int hitungPasien(Integer idPenyakit) {
        if (idPenyakit == null) {
            return 0;
        }
        return pasienDAO.jumlahByIdPenyakit(idPenyakit);
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
