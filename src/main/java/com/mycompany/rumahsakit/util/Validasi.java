package com.mycompany.rumahsakit.util;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Map;

/**
 * Helper validasi form. Semua pesan error ditulis dalam Bahasa Indonesia
 * yang mudah dipahami, bukan pesan teknis seperti SQL Exception.
 */
public final class Validasi {

    private Validasi() {
    }

    /** Mengecek teks wajib diisi. Mengembalikan nilai bersih, atau null bila kosong. */
    public static String wajib(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            errors.put(kunci, nama + " wajib diisi.");
            return null;
        }
        return bersih;
    }

    /** Membersihkan teks (trim). Mengembalikan null bila kosong. */
    public static String teks(String nilai) {
        if (nilai == null) {
            return null;
        }
        String bersih = nilai.trim();
        return bersih.isEmpty() ? null : bersih;
    }

    /** Mengecek hanya berisi angka dengan panjang tertentu. */
    public static boolean angka(String nilai, int panjang) {
        if (nilai == null || nilai.isEmpty()) {
            return false;
        }
        if (nilai.length() != panjang) {
            return false;
        }
        for (char c : nilai.toCharArray()) {
            if (!Character.isDigit(c)) {
                return false;
            }
        }
        return true;
    }

    /** Mengecek hanya berisi angka (panjang bebas). */
    public static boolean hanyaAngka(String nilai) {
        if (nilai == null || nilai.isEmpty()) {
            return false;
        }
        for (char c : nilai.toCharArray()) {
            if (!Character.isDigit(c)) {
                return false;
            }
        }
        return true;
    }

    /** Mengecek format email sederhana. */
    public static boolean email(String nilai) {
        if (nilai == null || nilai.isEmpty()) {
            return false;
        }
        int pada = nilai.indexOf('@');
        return pada > 0 && pada < nilai.length() - 1 && nilai.indexOf('.', pada) > pada + 1;
    }

    /** Validasi nomor telepon: 8-15 digit angka. */
    public static void telepon(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            return; // nomor telepon tidak wajib
        }
        String polos = bersih.replaceAll("[^0-9]", "");
        if (polos.length() < 8 || polos.length() > 15) {
            errors.put(kunci, nama + " harus berupa angka sepanjang 8-15 digit.");
        }
    }

    /** Validasi tanggal dari input type="date" (format yyyy-MM-dd). */
    public static LocalDate tanggal(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            errors.put(kunci, nama + " wajib diisi.");
            return null;
        }
        try {
            return LocalDate.parse(bersih);
        } catch (DateTimeParseException e) {
            errors.put(kunci, nama + " tidak valid. Gunakan format tanggal yang benar.");
            return null;
        }
    }

    /** Validasi tanggal opsional (boleh kosong). */
    public static LocalDate tanggalOpsional(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            return null;
        }
        return tanggal(nilai, kunci, nama, errors);
    }

    /** Validasi angka bulat (lantai, kapasitas). */
    public static Integer bulat(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            errors.put(kunci, nama + " wajib diisi.");
            return null;
        }
        try {
            return Integer.valueOf(bersih);
        } catch (NumberFormatException e) {
            errors.put(kunci, nama + " harus berupa angka bulat.");
            return null;
        }
    }

    /** Validasi angka bulat opsional; null bila kosong. */
    public static Integer bulatOpsional(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            return null;
        }
        return bulat(nilai, kunci, nama, errors);
    }

    /** Validasi angka desimal (biaya, berat badan, suhu) - tidak boleh negatif. */
    public static BigDecimal desimal(String nilai, String kunci, String nama, Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            errors.put(kunci, nama + " wajib diisi.");
            return null;
        }
        BigDecimal nilaiAkhir;
        try {
            nilaiAkhir = new BigDecimal(bersih.replace(",", "."));
        } catch (NumberFormatException e) {
            errors.put(kunci, nama + " harus berupa angka.");
            return null;
        }
        if (nilaiAkhir.signum() < 0) {
            errors.put(kunci, nama + " tidak boleh negatif.");
            return null;
        }
        return nilaiAkhir;
    }

    /** Validasi angka desimal opsional; hasilkan BigDecimal.ZERO bila kosong. */
    public static BigDecimal desimalOpsional(String nilai, String kunci, String nama,
            Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            return BigDecimal.ZERO;
        }
        return desimal(nilai, kunci, nama, errors);
    }

    /** Validasi nilai harus salah satu dari pilihan yang diizinkan. */
    public static String pilihan(String nilai, String[] opsi, String kunci, String nama,
            Map<String, String> errors) {
        String bersih = teks(nilai);
        if (bersih == null) {
            errors.put(kunci, nama + " wajib dipilih.");
            return null;
        }
        for (String opsi1 : opsi) {
            if (opsi1.equals(bersih)) {
                return bersih;
            }
        }
        errors.put(kunci, nama + " tidak valid.");
        return null;
    }

    /** Mengecek apakah ada error pada form. */
    public static boolean adaError(Map<String, String> errors) {
        return errors != null && !errors.isEmpty();
    }

    /** Membaca id dari parameter request menjadi Integer (null bila kosong/tidak valid). */
    public static Integer id(String nilai) {
        if (nilai == null || nilai.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(nilai.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
