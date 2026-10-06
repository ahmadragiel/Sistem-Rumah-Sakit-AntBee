package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.model.Dokter;
import com.mycompany.rumahsakit.model.Pasien;
import com.mycompany.rumahsakit.model.Pembayaran;
import com.mycompany.rumahsakit.model.Pemeriksaan;
import com.mycompany.rumahsakit.model.RawatInap;
import com.mycompany.rumahsakit.model.User;
import com.mycompany.rumahsakit.util.Auth;
import com.mycompany.rumahsakit.util.Notifikasi;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Objects;

/**
 * Portal pasien (/saya).
 *
 * Semua data diambil berdasarkan id_pasien dari session akun yang login,
 * TIDAK pernah dari parameter URL - sehingga pasien tidak bisa membuka
 * data pasien lain.
 */
@WebServlet(name = "SayaServlet", urlPatterns = {"/saya"})
public class SayaServlet extends HttpServlet {

    private final PasienDAO pasienDAO = new PasienDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();
    private final RawatInapDAO rawatInapDAO = new RawatInapDAO();
    private final PembayaranDAO pembayaranDAO = new PembayaranDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, "PASIEN")) {
            return;
        }

        Integer idPasien = Auth.idPasien(request);
        if (idPasien == null) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }
        Pasien pasien = pasienDAO.findById(idPasien);
        if (pasien == null) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }

        String aksi = request.getParameter("aksi") == null ? "jadwal" : request.getParameter("aksi").trim();
        request.setAttribute("pasien", pasien);

        String halaman;
        switch (aksi) {
            case "pemeriksaan":
                request.setAttribute("daftar", pemeriksaanDAO.byPasien(idPasien));
                halaman = "/saya/pemeriksaan.jsp";
                break;
            case "rawat-inap":
                request.setAttribute("daftar", rawatInapDAO.byPasien(idPasien));
                halaman = "/saya/rawat-inap.jsp";
                break;
            case "pembayaran":
                List<Pembayaran> pembayaran = pembayaranDAO.byPasien(idPasien);
                request.setAttribute("daftar", pembayaran);
                request.setAttribute("totalSemua", hitung(pembayaran, true));
                request.setAttribute("totalLunas", hitung(pembayaran, false));
                halaman = "/saya/pembayaran.jsp";
                break;
            case "tagihan":
                List<Pembayaran> tagihan = pembayaranDAO.byPasien(idPasien);
                request.setAttribute("daftar", tagihan);
                request.setAttribute("tagihanBelum", pembayaranDAO.totalBelumLunasByPasien(idPasien));
                halaman = "/saya/tagihan.jsp";
                break;
            case "notifikasi":
                request.setAttribute("daftarNotifikasi", Notifikasi.daftar(idPasien));
                halaman = "/saya/notifikasi.jsp";
                break;
            default:
                request.setAttribute("jadwal", pemeriksaanDAO.jadwalMendatang(idPasien));
                Dokter dokterPenanggung = pasien.getIdDokter() == null
                        ? null : dokterDAO.findById(pasien.getIdDokter());
                request.setAttribute("dokterPenanggung", dokterPenanggung);
                halaman = "/saya/jadwal.jsp";
        }

        request.getRequestDispatcher(halaman).forward(request, response);
    }

    private java.math.BigDecimal hitung(List<Pembayaran> daftar, boolean semua) {
        java.math.BigDecimal total = java.math.BigDecimal.ZERO;
        for (Pembayaran b : daftar) {
            if (semua || Objects.equals(b.getStatusPembayaran(), "LUNAS")) {
                total = total.add(b.getTotalBiaya() == null ? java.math.BigDecimal.ZERO : b.getTotalBiaya());
            }
        }
        return total;
    }
}
