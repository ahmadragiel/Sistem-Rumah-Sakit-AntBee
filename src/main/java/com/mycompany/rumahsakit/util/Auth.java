package com.mycompany.rumahsakit.util;

import com.mycompany.rumahsakit.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Helper otorisasi berbasis session untuk dipakai di setiap servlet.
 *
 * Aturan main:
 * - Belum login  -> redirect ke halaman login
 * - Sudah login tetapi role tidak berhak -> redirect ke halaman akses ditolak
 */
public final class Auth {

    public static final String ATRIBUT_USER = "user";
    public static final String ATRIBUT_ID_DOKTER = "idDokter";
    public static final String ATRIBUT_ID_PERAWAT = "idPerawat";
    public static final String ATRIBUT_ID_PASIEN = "idPasien";

    private Auth() {
    }

    /** Mengambil user yang sedang login, atau null bila belum login. */
    public static User pengguna(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute(ATRIBUT_USER);
    }

    /** Mengecek apakah role user termasuk salah satu role yang diizinkan. */
    public static boolean punyaRole(User user, String... roles) {
        if (user == null) {
            return false;
        }
        for (String role : roles) {
            if (role.equalsIgnoreCase(user.getRole())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Mengecek login. Bila belum login, redirect ke /login dan kembalikan null.
     * Servlet wajib berhenti bila hasilnya null.
     */
    public static User wajibLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = pengguna(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return user;
    }

    /**
     * Mengecek role user. Bila tidak berhak, redirect ke /access-denied.jsp
     * dan kembalikan false.
     */
    public static boolean wajibRole(HttpServletRequest request, HttpServletResponse response,
            User user, String... roles) throws IOException {
        if (punyaRole(user, roles)) {
            return true;
        }
        response.sendRedirect(request.getContextPath() + "/access-denied.jsp");
        return false;
    }

    /** id dokter milik akun yang sedang login (null bila akun bukan dokter). */
    public static Integer idDokter(HttpServletRequest request) {
        return (Integer) request.getSession(false).getAttribute(ATRIBUT_ID_DOKTER);
    }

    /** id perawat milik akun yang sedang login (null bila akun bukan perawat). */
    public static Integer idPerawat(HttpServletRequest request) {
        return (Integer) request.getSession(false).getAttribute(ATRIBUT_ID_PERAWAT);
    }

    /** id pasien milik akun yang sedang login (null bila akun bukan pasien). */
    public static Integer idPasien(HttpServletRequest request) {
        return (Integer) request.getSession(false).getAttribute(ATRIBUT_ID_PASIEN);
    }

    /** Menyimpan pesan sukses ke session agar tampil sebagai toast setelah redirect. */
    public static void sukses(HttpServletRequest request, String pesan) {
        simpanPesan(request, "sukses", pesan);
    }

    /** Menyimpan pesan gagal/peringatan ke session agar tampil setelah redirect. */
    public static void gagal(HttpServletRequest request, String pesan) {
        simpanPesan(request, "gagal", pesan);
    }

    private static void simpanPesan(HttpServletRequest request, String tipe, String pesan) {
        HttpSession session = request.getSession();
        session.setAttribute("pesan", pesan);
        session.setAttribute("tipePesan", tipe);
    }
}
