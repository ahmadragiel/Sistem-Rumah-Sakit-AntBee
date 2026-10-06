package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.RuanganDAO;
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
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet modul ruangan.
 * ADMIN: penuh (lihat, tambah, ubah, hapus). PERAWAT: hanya melihat.
 */
@WebServlet(name = "RuanganServlet", urlPatterns = {"/ruangan"})
public class RuanganServlet extends HttpServlet {

    private final RuanganDAO ruanganDAO = new RuanganDAO();

    private static final String[] ROLE_BACA = {"ADMIN", "PERAWAT"};
    private static final String[] JENIS_RUANGAN = {"Kelas I", "Kelas II", "Kelas III", "ICU", "Anak", "Isolasi"};
    private static final String[] STATUS_RUANGAN = {"TERSEDIA", "TERISI", "PERAWATAN"};

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
                if (!Auth.wajibRole(request, response, user, "ADMIN")) {
                    return;
                }
                request.setAttribute("data", baru());
                request.getRequestDispatcher("/ruangan/tambah-ruangan.jsp").forward(request, response);
                break;
            case "edit":
                if (!Auth.wajibRole(request, response, user, "ADMIN")) {
                    return;
                }
                Ruangan diedit = cari(request, response);
                if (diedit == null) {
                    return;
                }
                request.setAttribute("data", diedit);
                request.getRequestDispatcher("/ruangan/edit-ruangan.jsp").forward(request, response);
                break;
            case "detail":
                Ruangan r = cari(request, response);
                if (r == null) {
                    return;
                }
                request.setAttribute("data", r);
                request.getRequestDispatcher("/ruangan/detail-ruangan.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("daftarRuangan", ruanganDAO.semua(
                        param(request, "q", ""), param(request, "jenis", ""), param(request, "status", "")));
                request.setAttribute("q", param(request, "q", ""));
                request.setAttribute("jenis", param(request, "jenis", ""));
                request.setAttribute("status", param(request, "status", ""));
                request.setAttribute("totalKamarTersedia", ruanganDAO.jumlahKamarTersedia());
                request.getRequestDispatcher("/ruangan/ruangan.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, "ADMIN")) {
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
        response.sendRedirect(request.getContextPath() + "/ruangan");
    }

    private Ruangan baru() {
        Ruangan r = new Ruangan();
        r.setJumlahTerisi(0);
        return r;
    }

    private Ruangan cari(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        Ruangan ruangan = id == null ? null : ruanganDAO.findById(id);
        if (ruangan == null) {
            Auth.gagal(request, "Data ruangan tidak ditemukan.");
            response.sendRedirect(request.getContextPath() + "/ruangan");
        }
        return ruangan;
    }

    private void simpan(HttpServletRequest request, HttpServletResponse response, boolean ubah)
            throws ServletException, IOException {

        Map<String, String> errors = new HashMap<>();
        Ruangan data = new Ruangan();
        data.setIdRuangan(Validasi.id(request.getParameter("id")));
        data.setNamaRuangan(Validasi.wajib(param(request, "namaRuangan", ""),
                "namaRuangan", "Nama ruangan", errors));
        data.setJenisRuangan(Validasi.pilihan(param(request, "jenisRuangan", ""),
                JENIS_RUANGAN, "jenisRuangan", "Jenis ruangan", errors));
        data.setNomorKamar(Validasi.wajib(param(request, "nomorKamar", ""),
                "nomorKamar", "Nomor kamar", errors));
        data.setLantai(Validasi.bulat(param(request, "lantai", ""), "lantai", "Lantai", errors));
        data.setKapasitas(Validasi.bulat(param(request, "kapasitas", ""), "kapasitas", "Kapasitas", errors));
        data.setJumlahTerisi(Validasi.bulatOpsional(param(request, "jumlahTerisi", ""),
                "jumlahTerisi", "Jumlah terisi", errors));
        data.setTarifPerHari(Validasi.desimal(param(request, "tarifPerHari", ""),
                "tarifPerHari", "Tarif per hari", errors));
        data.setFasilitas(param(request, "fasilitas", ""));
        data.setStatusRuangan(Validasi.pilihan(param(request, "statusRuangan", ""),
                STATUS_RUANGAN, "statusRuangan", "Status ruangan", errors));

        // Validasi kapasitas
        if (data.getKapasitas() != null) {
            if (data.getKapasitas() < 1) {
                errors.put("kapasitas", "Kapasitas minimal 1 tempat tidur.");
            } else if (data.getJumlahTerisi() != null && data.getJumlahTerisi() > data.getKapasitas()) {
                errors.put("jumlahTerisi", "Jumlah terisi tidak boleh melebihi kapasitas.");
            }
        }
        if (data.getLantai() != null && data.getLantai() < 1) {
            errors.put("lantai", "Nomor lantai minimal 1.");
        }
        if (data.getJumlahTerisi() != null && data.getJumlahTerisi() < 0) {
            errors.put("jumlahTerisi", "Jumlah terisi tidak boleh negatif.");
        }
        if (ubah && data.getIdRuangan() == null) {
            errors.put("id", "Data ruangan tidak ditemukan.");
        }
        // Saat ubah, jumlah terisi yang lama tidak boleh dilepas
        if (ubah) {
            Ruangan lama = ruanganDAO.findById(data.getIdRuangan());
            if (lama != null && lama.getJumlahTerisi() != null) {
                if (data.getJumlahTerisi() == null) {
                    data.setJumlahTerisi(lama.getJumlahTerisi());
                }
                if (data.getKapasitas() != null && lama.getJumlahTerisi() > data.getKapasitas()) {
                    errors.put("kapasitas", "Kapasitas tidak boleh lebih kecil dari jumlah kamar yang terisi ("
                            + lama.getJumlahTerisi() + ").");
                }
            }
        }

        if (Validasi.adaError(errors)) {
            request.setAttribute("errors", errors);
            request.setAttribute("data", data);
            request.getRequestDispatcher(ubah ? "/ruangan/edit-ruangan.jsp" : "/ruangan/tambah-ruangan.jsp")
                    .forward(request, response);
            return;
        }

        if (data.getJumlahTerisi() == null) {
            data.setJumlahTerisi(0);
        }

        boolean berhasil;
        if (ubah) {
            berhasil = ruanganDAO.ubah(data);
            Auth.sukses(request, berhasil ? "Data ruangan berhasil diperbarui."
                    : "Data ruangan gagal diperbarui.");
        } else {
            berhasil = ruanganDAO.tambah(data);
            Auth.sukses(request, berhasil ? "Data ruangan berhasil ditambahkan."
                    : "Data ruangan gagal ditambahkan.");
        }
        response.sendRedirect(request.getContextPath() + "/ruangan");
    }

    private void hapus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = Validasi.id(request.getParameter("id"));
        if (id == null || ruanganDAO.findById(id) == null) {
            Auth.gagal(request, "Data ruangan tidak ditemukan.");
        } else {
            try {
                ruanganDAO.hapus(id);
                Auth.sukses(request, "Data ruangan berhasil dihapus.");
            } catch (RuntimeException e) {
                Auth.gagal(request, "Data ruangan tidak dapat dihapus karena masih dipakai data rawat inap.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/ruangan");
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
