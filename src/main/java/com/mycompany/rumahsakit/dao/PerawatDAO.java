package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Perawat;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel perawat. */
public class PerawatDAO {

    private static final String SELECT_DENGAN_JOIN =
            "SELECT p.*, u.username FROM perawat p "
            + "LEFT JOIN pengguna u ON u.id_pengguna = p.id_pengguna ";

    private Perawat map(ResultSet rs) throws SQLException {
        Perawat p = new Perawat();
        p.setIdPerawat(rs.getInt("id_perawat"));
        int idPengguna = rs.getInt("id_pengguna");
        p.setIdPengguna(rs.wasNull() ? null : idPengguna);
        p.setNip(rs.getString("nip"));
        p.setNamaPerawat(rs.getString("nama_perawat"));
        p.setJenisKelamin(rs.getString("jenis_kelamin"));
        p.setTempatLahir(rs.getString("tempat_lahir"));
        p.setTanggalLahir(rs.getObject("tanggal_lahir", java.time.LocalDate.class));
        p.setPendidikan(rs.getString("pendidikan"));
        p.setAlamat(rs.getString("alamat"));
        p.setNoTelepon(rs.getString("no_telepon"));
        p.setShift(rs.getString("shift"));
        p.setRuangan(rs.getString("ruangan"));
        p.setStatus(rs.getString("status"));
        p.setUsername(rs.getString("username"));
        return p;
    }

    /** Daftar perawat dengan pencarian (nama / NIP / ruangan) dan filter shift + status. */
    public List<Perawat> semua(String q, String shift, String status) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (p.nama_perawat LIKE ? OR p.nip LIKE ? OR p.ruangan LIKE ? OR p.no_telepon LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (shift != null && !shift.isBlank()) {
            sql.append(" AND p.shift = ?");
            param.add(shift);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND p.status = ?");
            param.add(status);
        }
        sql.append(" ORDER BY p.nama_perawat");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Perawat> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar perawat.", e);
        }
    }

    public Perawat findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE p.id_perawat = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data perawat.", e);
        }
    }

    /** Mencari perawat berdasarkan akun pengguna (dipakai login role PERAWAT). */
    public Perawat findByPengguna(int idPengguna) {
        String sql = SELECT_DENGAN_JOIN + " WHERE p.id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idPengguna);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data perawat.", e);
        }
    }

    /** Semua perawat aktif untuk pilihan pada form. */
    public List<Perawat> daftarAktif() {
        String sql = SELECT_DENGAN_JOIN + " WHERE p.status = 'AKTIF' ORDER BY p.nama_perawat";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Perawat> daftar = new ArrayList<>();
            while (rs.next()) {
                daftar.add(map(rs));
            }
            return daftar;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar perawat aktif.", e);
        }
    }

    public boolean tambah(Perawat p) {
        String sql = "INSERT INTO perawat (id_pengguna, nip, nama_perawat, jenis_kelamin, tempat_lahir, tanggal_lahir, "
                + "pendidikan, alamat, no_telepon, shift, ruangan, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, p.getIdPengguna());
            ps.setString(2, p.getNip());
            ps.setString(3, p.getNamaPerawat());
            ps.setString(4, p.getJenisKelamin());
            ps.setString(5, p.getTempatLahir());
            ps.setObject(6, p.getTanggalLahir());
            ps.setString(7, p.getPendidikan());
            ps.setString(8, p.getAlamat());
            ps.setString(9, p.getNoTelepon());
            ps.setString(10, p.getShift());
            ps.setString(11, p.getRuangan());
            ps.setString(12, p.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah perawat.", e);
        }
    }

    public boolean ubah(Perawat p) {
        String sql = "UPDATE perawat SET id_pengguna = ?, nip = ?, nama_perawat = ?, jenis_kelamin = ?, tempat_lahir = ?, "
                + "tanggal_lahir = ?, pendidikan = ?, alamat = ?, no_telepon = ?, shift = ?, ruangan = ?, status = ? "
                + "WHERE id_perawat = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, p.getIdPengguna());
            ps.setString(2, p.getNip());
            ps.setString(3, p.getNamaPerawat());
            ps.setString(4, p.getJenisKelamin());
            ps.setString(5, p.getTempatLahir());
            ps.setObject(6, p.getTanggalLahir());
            ps.setString(7, p.getPendidikan());
            ps.setString(8, p.getAlamat());
            ps.setString(9, p.getNoTelepon());
            ps.setString(10, p.getShift());
            ps.setString(11, p.getRuangan());
            ps.setString(12, p.getStatus());
            ps.setInt(13, p.getIdPerawat());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui perawat.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM perawat WHERE id_perawat = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus perawat.", e);
        }
    }

    /** Mengecek NIP sudah dipakai perawat lain (kecuali id tertentu). */
    public boolean nipDipakai(String nip, Integer kecualiId) {
        String sql = "SELECT COUNT(*) FROM perawat WHERE nip = ? AND id_perawat <> ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, nip);
            ps.setInt(2, kecualiId == null ? -1 : kecualiId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memeriksa NIP.", e);
        }
    }

    public int jumlahTotal() {
        String sql = "SELECT COUNT(*) FROM perawat WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung perawat.", e);
        }
    }
}
