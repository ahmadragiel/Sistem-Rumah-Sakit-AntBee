package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel pengguna. */
public class UserDAO {

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setIdPengguna(rs.getInt("id_pengguna"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setNamaLengkap(rs.getString("nama_lengkap"));
        u.setEmail(rs.getString("email"));
        u.setNoTelepon(rs.getString("no_telepon"));
        u.setAlamat(rs.getString("alamat"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getObject("created_at", java.time.LocalDateTime.class));
        return u;
    }

    /** Login: mencocokkan username dan hash password. */
    public User cariLogin(String username, String hashPassword) {
        String sql = "SELECT * FROM pengguna WHERE username = ? AND password = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashPassword);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memeriksa login.", e);
        }
    }

    public User findById(int id) {
        String sql = "SELECT * FROM pengguna WHERE id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data pengguna.", e);
        }
    }

    public User findByUsername(String username) {
        String sql = "SELECT * FROM pengguna WHERE username = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data pengguna.", e);
        }
    }

    /** Daftar pengguna dengan pencarian username / nama / email / role. */
    public List<User> semua(String q) {
        StringBuilder sql = new StringBuilder(
                "SELECT * FROM pengguna WHERE 1=1");
        List<Object> param = new ArrayList<>();
        if (q != null && !q.isBlank()) {
            sql.append(" AND (username LIKE ? OR nama_lengkap LIKE ? OR email LIKE ? OR role LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        sql.append(" ORDER BY id_pengguna DESC");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<User> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar pengguna.", e);
        }
    }

    public boolean tambah(User u) {
        String sql = "INSERT INTO pengguna (username, password, nama_lengkap, email, no_telepon, alamat, role, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getNamaLengkap());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getNoTelepon());
            ps.setString(6, u.getAlamat());
            ps.setString(7, u.getRole());
            ps.setString(8, u.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah pengguna.", e);
        }
    }

    /** Update data pengguna tanpa mengubah password. */
    public boolean ubah(User u) {
        String sql = "UPDATE pengguna SET nama_lengkap = ?, email = ?, no_telepon = ?, alamat = ?, role = ?, status = ? "
                + "WHERE id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, u.getNamaLengkap());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getNoTelepon());
            ps.setString(4, u.getAlamat());
            ps.setString(5, u.getRole());
            ps.setString(6, u.getStatus());
            ps.setInt(7, u.getIdPengguna());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui pengguna.", e);
        }
    }

    public boolean ubahPassword(int id, String hashBaru) {
        String sql = "UPDATE pengguna SET password = ? WHERE id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, hashBaru);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui password.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM pengguna WHERE id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus pengguna.", e);
        }
    }

    /** Mengecek apakah username sudah dipakai (kecuali id tertentu). */
    public boolean usernameDipakai(String username, Integer kecualiId) {
        String sql = "SELECT COUNT(*) FROM pengguna WHERE username = ? AND id_pengguna <> ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, kecualiId == null ? -1 : kecualiId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memeriksa username.", e);
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
            throw new RuntimeException("Gagal menghitung data pengguna.", e);
        }
    }

    public int jumlahTotal() {
        return hitung("SELECT COUNT(*) FROM pengguna WHERE 1=?", 1);
    }

    public int jumlahPerRole(String role) {
        return hitung("SELECT COUNT(*) FROM pengguna WHERE role=?", role);
    }

    public int jumlahAktif() {
        return hitung("SELECT COUNT(*) FROM pengguna WHERE status=?", "AKTIF");
    }
}
