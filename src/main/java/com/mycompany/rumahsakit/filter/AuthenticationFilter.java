package com.mycompany.rumahsakit.filter;

import com.mycompany.rumahsakit.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

/**
 * Penjaga akses berbasis URL + role (server-side).
 *
 * - Halaman publik (login, index, error) dilewatkan tanpa login.
 * - Belum login            -> redirect ke /login
 * - Role tidak berhak      -> redirect ke /access-denied.jsp
 * - Halaman modul hanya boleh dibuka lewat forward servlet,
 *   bukan langsung dari browser (mencegah form kosong / bypass alur).
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    /** Halaman yang boleh dibuka tanpa login. */
    private static final Set<String> HALAMAN_PUBLIK = Set.of(
            "", "/", "/login", "/logout", "/index.jsp", "/error.jsp", "/access-denied.jsp");

    private static final String[] AWALAN_PUBLIK = {"/assets/"};

    /** Awalan URL -> daftar role yang berhak membukanya. */
    private static final Map<String, Set<String>> ATURAN = new LinkedHashMap<>();

    static {
        ATURAN.put("/dashboard", Set.of("ADMIN", "DOKTER", "PERAWAT", "PETUGAS", "PASIEN"));
        ATURAN.put("/pasien", Set.of("ADMIN", "PETUGAS", "DOKTER", "PERAWAT"));
        ATURAN.put("/dokter", Set.of("ADMIN"));
        ATURAN.put("/perawat", Set.of("ADMIN"));
        ATURAN.put("/penyakit", Set.of("ADMIN"));
        ATURAN.put("/ruangan", Set.of("ADMIN", "PERAWAT"));
        ATURAN.put("/rawat-inap", Set.of("ADMIN", "PETUGAS", "PERAWAT", "DOKTER"));
        ATURAN.put("/pemeriksaan", Set.of("ADMIN", "DOKTER"));
        ATURAN.put("/catatan-perawatan", Set.of("ADMIN", "DOKTER", "PERAWAT"));
        ATURAN.put("/pembayaran", Set.of("ADMIN", "PETUGAS"));
        ATURAN.put("/pengguna", Set.of("ADMIN"));
        ATURAN.put("/laporan", Set.of("ADMIN"));
        ATURAN.put("/profil", Set.of("ADMIN", "DOKTER", "PERAWAT", "PETUGAS", "PASIEN"));
        ATURAN.put("/saya", Set.of("PASIEN"));
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getRequestURI().substring(request.getContextPath().length());

        if (publik(path)) {
            chain.doFilter(req, res);
            return;
        }

        // File fragment layout bukan halaman, tidak boleh dibuka langsung.
        if (path.startsWith("/fragments/")) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Set<String> roleDiizinkan = cariAturan(path);
        if (roleDiizinkan == null || !roleDiizinkan.contains(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
            return;
        }

        // Halaman modul hanya boleh ditampilkan lewat forward dari servlet.
        if (path.endsWith(".jsp") && request.getAttribute("jakarta.servlet.forward.request_uri") == null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        chain.doFilter(req, res);
    }

    private boolean publik(String path) {
        if (HALAMAN_PUBLIK.contains(path)) {
            return true;
        }
        for (String awalan : AWALAN_PUBLIK) {
            if (path.startsWith(awalan)) {
                return true;
            }
        }
        return false;
    }

    /** Mencari aturan role dengan awalan URL terpanjang agar tidak saling tumpuk. */
    private Set<String> cariAturan(String path) {
        Set<String> hasil = null;
        int panjangTerbaik = -1;
        for (Map.Entry<String, Set<String>> entri : ATURAN.entrySet()) {
            String kunci = entri.getKey();
            if (path.startsWith(kunci) && kunci.length() > panjangTerbaik) {
                hasil = entri.getValue();
                panjangTerbaik = kunci.length();
            }
        }
        return hasil;
    }
}
