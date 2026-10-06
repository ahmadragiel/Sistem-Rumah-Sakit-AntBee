package com.mycompany.rumahsakit.servlet;

import com.mycompany.rumahsakit.dao.CatatanPerawatanDAO;
import com.mycompany.rumahsakit.dao.DokterDAO;
import com.mycompany.rumahsakit.dao.PasienDAO;
import com.mycompany.rumahsakit.dao.PembayaranDAO;
import com.mycompany.rumahsakit.dao.PemeriksaanDAO;
import com.mycompany.rumahsakit.dao.PerawatDAO;
import com.mycompany.rumahsakit.dao.RawatInapDAO;
import com.mycompany.rumahsakit.dao.RuanganDAO;
import com.mycompany.rumahsakit.dao.UserDAO;
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

/**
 * Dashboard terpusat: menghitung statistik dari database lalu mengirimkannya
 * ke halaman dashboard sesuai role pengguna.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final PasienDAO pasienDAO = new PasienDAO();
    private final DokterDAO dokterDAO = new DokterDAO();
    private final PerawatDAO perawatDAO = new PerawatDAO();
    private final UserDAO userDAO = new UserDAO();
    private final RuanganDAO ruanganDAO = new RuanganDAO();
    private final RawatInapDAO rawatInapDAO = new RawatInapDAO();
    private final PemeriksaanDAO pemeriksaanDAO = new PemeriksaanDAO();
    private final PembayaranDAO pembayaranDAO = new PembayaranDAO();
    private final CatatanPerawatanDAO catatanDAO = new CatatanPerawatanDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = Auth.wajibLogin(request, response);
        if (user == null) {
            return;
        }

        String halaman;
        switch (user.getRole()) {
            case "ADMIN":
                isiAdmin(request);
                halaman = "/dashboard/admin.jsp";
                break;
            case "DOKTER":
                if (!isiDokter(request, response)) {
                    return;
                }
                halaman = "/dashboard/dokter.jsp";
                break;
            case "PERAWAT":
                isiPerawat(request);
                halaman = "/dashboard/perawat.jsp";
                break;
            case "PETUGAS":
                isiPetugas(request);
                halaman = "/dashboard/petugas.jsp";
                break;
            case "PASIEN":
                if (!isiPasien(request, response)) {
                    return;
                }
                halaman = "/dashboard/pasien.jsp";
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
                return;
        }

        request.getRequestDispatcher(halaman).forward(request, response);
    }

    private void isiAdmin(HttpServletRequest request) {
        request.setAttribute("totalPasien", pasienDAO.jumlahTotal());
        request.setAttribute("pasienDirawat", pasienDAO.jumlahStatus("DIRAWAT"));
        request.setAttribute("pasienPulang", pasienDAO.jumlahStatus("PULANG"));
        request.setAttribute("pasienRawatJalan", pasienDAO.jumlahStatus("RAWAT JALAN"));
        request.setAttribute("totalDokter", dokterDAO.jumlahTotal());
        request.setAttribute("totalPerawat", perawatDAO.jumlahTotal());
        request.setAttribute("totalPengguna", userDAO.jumlahTotal());
        request.setAttribute("totalRuangan", ruanganDAO.jumlahTotal());
        request.setAttribute("kamarTerisi", ruanganDAO.jumlahKamarTerisi());
        request.setAttribute("kamarTersedia", ruanganDAO.jumlahKamarTersedia());
        request.setAttribute("kapasitasTerisi", ruanganDAO.totalTerisi());
        request.setAttribute("kapasitasTotal", ruanganDAO.totalKapasitas());
        request.setAttribute("totalRawatInap", rawatInapDAO.jumlahTotal());
        request.setAttribute("rawatInapAktif", rawatInapDAO.jumlahStatus("DIRAWAT"));
        request.setAttribute("rawatInapSelesai", rawatInapDAO.jumlahStatus("SELESAI")
                + rawatInapDAO.jumlahStatus("DIPULANGKAN"));
        request.setAttribute("totalPemeriksaan", pemeriksaanDAO.jumlahTotal());
        request.setAttribute("totalCatatan", catatanDAO.jumlahTotal());
        request.setAttribute("totalPembayaran", pembayaranDAO.jumlahTotal());
        request.setAttribute("pembayaranBelum", pembayaranDAO.jumlahStatus("BELUM DIBAYAR"));
        request.setAttribute("totalPendapatan", pembayaranDAO.totalLunas());
        request.setAttribute("rawatInapTerbaru", batas(rawatInapDAO.terbaru(5), 5));
        request.setAttribute("pemeriksaanTerbaru", batas(pemeriksaanDAO.terbaru(5), 5));
        request.setAttribute("pembayaranTerbaru", batas(pembayaranDAO.terbaru(5), 5));
    }

    private boolean isiDokter(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer idDokter = Auth.idDokter(request);
        if (idDokter == null) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return false;
        }
        Dokter dokter = dokterDAO.findById(idDokter);
        List<com.mycompany.rumahsakit.model.Pasien> pasienSaya = pasienDAO.byDokter(idDokter);
        List<RawatInap> rawatInapDokter = rawatInapDAO.byDokter(idDokter);
        int pasienDirawat = 0;
        for (RawatInap r : rawatInapDokter) {
            if ("DIRAWAT".equals(r.getStatusRawat())) {
                pasienDirawat++;
            }
        }

        request.setAttribute("dokter", dokter);
        request.setAttribute("jumlahPasien", pasienSaya.size());
        request.setAttribute("pasienDirawat", pasienDirawat);
        request.setAttribute("pemeriksaanHariIni", pemeriksaanDAO.jumlahHariIni(idDokter));
        request.setAttribute("totalPemeriksaan", pemeriksaanDAO.byDokter(idDokter).size());
        request.setAttribute("jadwalPraktik", dokter == null ? "-" : dokter.getJadwalPraktik());
        request.setAttribute("pemeriksaanTerbaru", batas(pemeriksaanDAO.terbaruByDokter(idDokter, 5), 5));
        request.setAttribute("daftarPasien", batas(pasienSaya, 5));
        request.setAttribute("rawatInapTerbaru", batas(rawatInapDokter, 5));
        return true;
    }

    private void isiPerawat(HttpServletRequest request) {
        Integer idPerawat = Auth.idPerawat(request);
        request.setAttribute("perawat", idPerawat == null ? null : perawatDAO.findById(idPerawat));
        request.setAttribute("pasienRawatInap", rawatInapDAO.jumlahStatus("DIRAWAT"));
        request.setAttribute("kamarTerisi", ruanganDAO.jumlahKamarTerisi());
        request.setAttribute("kamarTersedia", ruanganDAO.jumlahKamarTersedia());
        request.setAttribute("kapasitasTerisi", ruanganDAO.totalTerisi());
        request.setAttribute("kapasitasTotal", ruanganDAO.totalKapasitas());
        request.setAttribute("pasienBaru", pasienDAO.jumlahMasukHariIni());
        request.setAttribute("totalCatatan", catatanDAO.jumlahTotal());
        request.setAttribute("catatanSaya", idPerawat == null ? 0 : catatanDAO.jumlahByPerawat(idPerawat));
        request.setAttribute("catatanTerbaru", batas(catatanDAO.terbaru(5), 5));
        request.setAttribute("rawatInapTerbaru", batas(rawatInapDAO.terbaru(5), 5));
    }

    private void isiPetugas(HttpServletRequest request) {
        request.setAttribute("registrasiHariIni", pasienDAO.jumlahMasukHariIni());
        request.setAttribute("pasienHariIni", rawatInapDAO.jumlahMasukHariIni());
        request.setAttribute("rawatInapAktif", rawatInapDAO.jumlahStatus("DIRAWAT"));
        request.setAttribute("pembayaranPending", pembayaranDAO.jumlahStatus("BELUM DIBAYAR")
                + pembayaranDAO.jumlahStatus("MENUNGGU"));
        request.setAttribute("pasienPulang", pasienDAO.jumlahStatus("PULANG"));
        request.setAttribute("totalPasien", pasienDAO.jumlahTotal());
        request.setAttribute("totalPembayaran", pembayaranDAO.jumlahTotal());
        request.setAttribute("pembayaranTerbaru", batas(pembayaranDAO.terbaru(5), 5));
        request.setAttribute("rawatInapTerbaru", batas(rawatInapDAO.terbaru(5), 5));
    }

    private boolean isiPasien(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer idPasien = Auth.idPasien(request);
        if (idPasien == null) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return false;
        }
        Pasien pasien = pasienDAO.findById(idPasien);
        if (pasien == null) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return false;
        }

        List<Pemeriksaan> pemeriksaan = pemeriksaanDAO.byPasien(idPasien);
        List<Pembayaran> pembayaran = pembayaranDAO.byPasien(idPasien);
        RawatInap sedangDirawat = null;
        for (RawatInap r : rawatInapDAO.byPasien(idPasien)) {
            if ("DIRAWAT".equals(r.getStatusRawat())) {
                sedangDirawat = r;
                break;
            }
        }
        Dokter dokterPenanggung = pasien.getIdDokter() == null ? null : dokterDAO.findById(pasien.getIdDokter());

        request.setAttribute("pasien", pasien);
        request.setAttribute("jadwal", batas(pemeriksaanDAO.jadwalMendatang(idPasien), 5));
        request.setAttribute("pemeriksaanTerbaru", batas(pemeriksaan, 5));
        request.setAttribute("rawatInapAktif", sedangDirawat);
        request.setAttribute("tagihanBelum", pembayaranDAO.totalBelumLunasByPasien(idPasien));
        request.setAttribute("pembayaranTerakhir", pembayaran.isEmpty() ? null : pembayaran.get(0));
        request.setAttribute("notifikasi", Notifikasi.daftar(idPasien));
        request.setAttribute("dokterPenanggung", dokterPenanggung);
        return true;
    }

    private static <T> List<T> batas(List<T> daftar, int jumlah) {
        return daftar.size() > jumlah ? daftar.subList(0, jumlah) : daftar;
    }
}
