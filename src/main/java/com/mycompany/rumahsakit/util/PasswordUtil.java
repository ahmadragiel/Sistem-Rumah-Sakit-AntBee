package com.mycompany.rumahsakit.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utilitas password untuk project akademik.
 *
 * Password disimpan dalam bentuk hash SHA-256 (bukan teks biasa).
 * Ini bukan metode keamanan production - project ini hanya untuk tugas kuliah.
 * Untuk sistem sungguhan gunakan BCrypt/Argon2 dan penanganan khusus seperti salt.
 */
public final class PasswordUtil {

    private PasswordUtil() {
    }

    /** Mengubah teks password menjadi hash SHA-256 dalam bentuk heksadesimal. */
    public static String hash(String teks) {
        if (teks == null) {
            return "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hasil = digest.digest(teks.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(hasil.length * 2);
            for (byte b : hasil) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Algoritma hash SHA-256 tidak tersedia.", e);
        }
    }

    /** Membandingkan password teks biasa dengan hash tersimpan. */
    public static boolean cocok(String teks, String hashTersimpan) {
        if (teks == null || hashTersimpan == null) {
            return false;
        }
        return hash(teks).equals(hashTersimpan);
    }
}
