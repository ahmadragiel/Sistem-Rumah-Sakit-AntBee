package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Pasien;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel pasien. */
public class PasienDAO {

    private static final String SELECT_DENGAN_JOIN =
            "SELECT p.*, d.nama_dokter, y.nama_penyakit, u.username "
            + "FROM pasien p "
            + "LEFT JOIN dokter d ON d.id_dokter = p.id_dokter "
            + "LEFT JOIN penyakit y ON y.id_penyakit = p.id_penyakit "
            + "LEFT JOIN pengguna u ON u.id_pengguna = p.id_pengguna ";

    private Pasien map(ResultSet rs) throws SQLException {
        Pasien p = new Pasien();
        p.setIdPasien(rs.getInt("id_pasien"));
        int idPengguna = rs.getInt("id_pengguna");
        p.setIdPengguna(rs.wasNull() ? null : idPengguna);
        p.setNik(rs.getString("nik"));
        p.setNamaPasien(rs.getString("nama_pasien"));
        p.setJenisKelamin(rs.getString("jenis_kelamin"));
        p.setTempatLahir(rs.getString("tempat_lahir"));
        p.setTanggalLahir(rs.getObject("tanggal_lahir", java.time.LocalDate.class));
        p.setAlamat(rs.getString("alamat"));
        p.setNoTelepon(rs.getString("no_telepon"));
        p.setGolonganDarah(rs.getString("golongan_darah"));
        int idPenyakit = rs.getInt("id_penyakit");
        p.setIdPenyakit(rs.wasNull() ? null : idPenyakit);
        int idDokter = rs.getInt("id_dokter");
        p.setIdDokter(rs.wasNull() ? null : idDokter);
        p.setTanggalMasuk(rs.getObject("tanggal_masuk", java.time.LocalDate.class));
        p.setTanggalKeluar(rs.getObject("tanggal_keluar", java.time.LocalDate.class));
        p.setStatusPasien(rs.getString("status_pasien"));
        p.setNamaDokter(rs.getString("nama_dokter"));
        p.setNamaPenyakit(rs.getString("nama_penyakit"));
        p.setUsername(rs.getString("username"));
        return p;
    }

    /**
     * Daftar pasien dengan pencarian (nama / NIK / nama dokter) dan filter dokter + status.
     * Nilai parameter boleh null atau kosong untuk mengabaikan filter.
     */
    public List<Pasien> semua(String q, Integer idDokter, String status) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (p.nama_pasien LIKE ? OR p.nik LIKE ? OR d.nama_dokter LIKE ? OR p.no_telepon LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (idDokter != null) {
            sql.append(" AND p.id_dokter = ?");
            param.add(idDokter);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND p.status_pasien = ?");
            param.add(status);
        }
        sql.append(" ORDER BY p.id_pasien DESC");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Pasien> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar pasien.", e);
        }
    }

    public Pasien findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE p.id_pasien = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data pasien.", e);
        }
    }

    /** Mencari pasien berdasarkan akun pengguna (dipakai login role PASIEN). */
    public Pasien findByPengguna(int idPengguna) {
        String sql = SELECT_DENGAN_JOIN + " WHERE p.id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idPengguna);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data pasien.", e);
        }
    }

    /** Pasien yang ditangani dokter tertentu (menu "Pasien Saya"). */
    public List<Pasien> byDokter(int idDokter) {
        String sql = SELECT_DENGAN_JOIN + " WHERE p.id_dokter = ? ORDER BY p.id_pasien DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idDokter);
            try (ResultSet rs = ps.executeQuery()) {
                List<Pasien> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar pasien dokter.", e);
        }
    }

    public boolean tambah(Pasien p) {
        String sql = "INSERT INTO pasien (id_pengguna, nik, nama_pasien, jenis_kelamin, tempat_lahir, tanggal_lahir, "
                + "alamat, no_telepon, golongan_darah, id_penyakit, id_dokter, tanggal_masuk, tanggal_keluar, status_pasien) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, p.getIdPengguna());
            ps.setString(2, p.getNik());
            ps.setString(3, p.getNamaPasien());
            ps.setString(4, p.getJenisKelamin());
            ps.setString(5, p.getTempatLahir());
            ps.setObject(6, p.getTanggalLahir());
            ps.setString(7, p.getAlamat());
            ps.setString(8, p.getNoTelepon());
            ps.setString(9, p.getGolonganDarah());
            ps.setObject(10, p.getIdPenyakit());
            ps.setObject(11, p.getIdDokter());
            ps.setObject(12, p.getTanggalMasuk());
            ps.setObject(13, p.getTanggalKeluar());
            ps.setString(14, p.getStatusPasien());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah pasien.", e);
        }
    }

    public boolean ubah(Pasien p) {
        String sql = "UPDATE pasien SET id_pengguna = ?, nik = ?, nama_pasien = ?, jenis_kelamin = ?, tempat_lahir = ?, "
                + "tanggal_lahir = ?, alamat = ?, no_telepon = ?, golongan_darah = ?, id_penyakit = ?, id_dokter = ?, "
                + "tanggal_masuk = ?, tanggal_keluar = ?, status_pasien = ? WHERE id_pasien = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, p.getIdPengguna());
            ps.setString(2, p.getNik());
            ps.setString(3, p.getNamaPasien());
            ps.setString(4, p.getJenisKelamin());
            ps.setString(5, p.getTempatLahir());
            ps.setObject(6, p.getTanggalLahir());
            ps.setString(7, p.getAlamat());
            ps.setString(8, p.getNoTelepon());
            ps.setString(9, p.getGolonganDarah());
            ps.setObject(10, p.getIdPenyakit());
            ps.setObject(11, p.getIdDokter());
            ps.setObject(12, p.getTanggalMasuk());
            ps.setObject(13, p.getTanggalKeluar());
            ps.setString(14, p.getStatusPasien());
            ps.setInt(15, p.getIdPasien());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui pasien.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM pasien WHERE id_pasien = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus pasien.", e);
        }
    }

    /**
     * Mengubah status pasien (dipakai alur rawat inap).
     * Tanggal keluar hanya diisi bila diisi (null diabaikan).
     */
    public boolean ubahStatus(int idPasien, String status, java.time.LocalDate tanggalKeluar) {
        String sql = "UPDATE pasien SET status_pasien = ?, tanggal_keluar = COALESCE(?, tanggal_keluar) "
                + "WHERE id_pasien = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setObject(2, tanggalKeluar);
            ps.setInt(3, idPasien);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui status pasien.", e);
        }
    }

    /** Mengecek NIK sudah dipakai pasien lain (kecuali id tertentu). */
    public boolean nikDipakai(String nik, Integer kecualiId) {
        String sql = "SELECT COUNT(*) FROM pasien WHERE nik = ? AND id_pasien <> ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, nik);
            ps.setInt(2, kecualiId == null ? -1 : kecualiId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memeriksa NIK.", e);
        }
    }

    private int hitung(String sql, Object param) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung data pasien.", e);
        }
    }

    public int jumlahTotal() {
        return hitung("SELECT COUNT(*) FROM pasien WHERE 1=?", 1);
    }

    public int jumlahStatus(String status) {
        return hitung("SELECT COUNT(*) FROM pasien WHERE status_pasien=?", status);
    }

    public int jumlahMasukHariIni() {
        String sql = "SELECT COUNT(*) FROM pasien WHERE tanggal_masuk = CURDATE()";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung pasien hari ini.", e);
        }
    }

    /** Jumlah pasien yang terkait dengan satu penyakit. */
    public int jumlahByIdPenyakit(int idPenyakit) {
        String sql = "SELECT COUNT(*) FROM pasien WHERE id_penyakit = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idPenyakit);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung pasien penyakit.", e);
        }
    }
}
