package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.PenyakitDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.dao.RuanganDAO;
import com.mycompany.rumahsakit.model.RawatInap;
import com.mycompany.rumahsakit.model.User;
import com.mycompany.rumahsakit.util.Auth;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Servlet laporan: menyiapkan data laporan sesuai jenis + filter. Hanya ADMIN. */
@WebServlet(name = "LaporanServlet", urlPatterns = {"/laporan"})
public class LaporanServlet extends HttpServlet {

    private final PasienDAO pasienDAO = new PasienDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final PenyakitDAO penyakitDAO = new PenyakitDAO();
    private final RawatInapDAO rawatInapDAO = new RawatInapDAO();
    private final PembayaranDAO pembayaranDAO = new PembayaranDAO();
    private final RuanganDAO ruanganDAO = new RuanganDAO();

    private static final String[] ROLE_ADMIN = {"ADMIN"};
    private static final String[] JENIS_LAPORAN = {
        "pasien", "dokter", "rawat-inap", "penyakit", "pembayaran", "ruangan"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null || !Auth.wajibRole(request, response, user, ROLE_ADMIN)) {
            return;
        }

        String jenis = request.getParameter("jenis");
        if (jenis == null || !List.of(JENIS_LAPORAN).contains(jenis)) {
            jenis = "pasien";
        }

        String q = param(request, "q", "");
        String dari = param(request, "dari", "");
        String sampai = param(request, "sampai", "");
        String status = param(request, "status", "");

        request.setAttribute("jenis", jenis);
        request.setAttribute("q", q);
        request.setAttribute("dari", dari);
        request.setAttribute("sampai", sampai);
        request.setAttribute("status", status);
        request.setAttribute("tanggalCetak", LocalDate.now());

        String halaman;
        switch (jenis) {
            case "dokter":
                request.setAttribute("daftar", dokterDAO.semua(q, "", status));
                halaman = "/laporan/laporan-dokter.jsp";
                break;
            case "rawat-inap":
                request.setAttribute("daftar", saringTanggal(rawatInapDAO.semua(q, status), dari, sampai));
                halaman = "/laporan/laporan-rawat-inap.jsp";
                break;
            case "penyakit":
                request.setAttribute("daftar", penyakitDAO.semua(q, status));
                halaman = "/laporan/laporan-penyakit.jsp";
                break;
            case "pembayaran":
                request.setAttribute("daftar", pembayaranDAO.semua(q, status, dari, sampai));
                request.setAttribute("totalBiaya", pembayaranDAO.totalSemua());
                halaman = "/laporan/laporan-pembayaran.jsp";
                break;
            case "ruangan":
                request.setAttribute("daftar", ruanganDAO.semua(q, "", status));
                request.setAttribute("totalKamarTersedia", ruanganDAO.jumlahKamarTersedia());
                halaman = "/laporan/laporan-ruangan.jsp";
                break;
            default:
                request.setAttribute("daftar", pasienDAO.semua(q, null, status));
                halaman = "/laporan/laporan-pasien.jsp";
        }

        request.getRequestDispatcher(halaman).forward(request, response);
    }

    /** Menyaring rawat inap berdasarkan rentang tanggal masuk (format yyyy-MM-dd). */
    private List<RawatInap> saringTanggal(List<RawatInap> daftar, String dari, String sampai) {
        if ((dari == null || dari.isBlank()) && (sampai == null || sampai.isBlank())) {
            return daftar;
        }
        LocalDate tglDari = (dari == null || dari.isBlank()) ? null : LocalDate.parse(dari);
        LocalDate tglSampai = (sampai == null || sampai.isBlank()) ? null : LocalDate.parse(sampai);
        List<RawatInap> hasil = new ArrayList<>();
        for (RawatInap r : daftar) {
            if (r.getTanggalMasuk() == null) {
                continue;
            }
            if (tglDari != null && r.getTanggalMasuk().isBefore(tglDari)) {
                continue;
            }
            if (tglSampai != null && r.getTanggalMasuk().isAfter(tglSampai)) {
                continue;
            }
            hasil.add(r);
        }
        return hasil;
    }

    private static String param(HttpServletRequest request, String nama, String bawaan) {
        String nilai = request.getParameter(nama);
        return nilai == null ? bawaan : nilai.trim();
    }
}
