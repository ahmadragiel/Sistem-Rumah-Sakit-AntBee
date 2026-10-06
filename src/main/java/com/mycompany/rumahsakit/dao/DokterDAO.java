package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Dokter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel dokter. */
public class DokterDAO {

    private Dokter map(ResultSet rs) throws SQLException {
        Dokter d = new Dokter();
        d.setIdDokter(rs.getInt("id_dokter"));
        int idPengguna = rs.getInt("id_pengguna");
        d.setIdPengguna(rs.wasNull() ? null : idPengguna);
        d.setNip(rs.getString("nip"));
        d.setNamaDokter(rs.getString("nama_dokter"));
        d.setJenisKelamin(rs.getString("jenis_kelamin"));
        d.setTempatLahir(rs.getString("tempat_lahir"));
        d.setTanggalLahir(rs.getObject("tanggal_lahir", java.time.LocalDate.class));
        d.setSpesialisasi(rs.getString("spesialisasi"));
        d.setAlamat(rs.getString("alamat"));
        d.setNoTelepon(rs.getString("no_telepon"));
        d.setEmail(rs.getString("email"));
        d.setJadwalPraktik(rs.getString("jadwal_praktik"));
        d.setStatus(rs.getString("status"));
        d.setUsername(rs.getString("username"));
        return d;
    }

    private static final String SELECT_DENGAN_JOIN =
            "SELECT d.*, u.username FROM dokter d "
            + "LEFT JOIN pengguna u ON u.id_pengguna = d.id_pengguna ";

    /** Daftar dokter dengan pencarian (nama / NIP / spesialisasi) dan filter spesialisasi + status. */
    public List<Dokter> semua(String q, String spesialisasi, String status) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (d.nama_dokter LIKE ? OR d.nip LIKE ? OR d.spesialisasi LIKE ? OR d.no_telepon LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (spesialisasi != null && !spesialisasi.isBlank()) {
            sql.append(" AND d.spesialisasi = ?");
            param.add(spesialisasi);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND d.status = ?");
            param.add(status);
        }
        sql.append(" ORDER BY d.nama_dokter");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Dokter> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar dokter.", e);
        }
    }

    public Dokter findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE d.id_dokter = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data dokter.", e);
        }
    }

    /** Mencari dokter berdasarkan akun pengguna (dipakai login role DOKTER). */
    public Dokter findByPengguna(int idPengguna) {
        String sql = SELECT_DENGAN_JOIN + " WHERE d.id_pengguna = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idPengguna);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data dokter.", e);
        }
    }

    /** Semua dokter aktif, dipakai untuk pilihan pada form (dropdown). */
    public List<Dokter> daftarAktif() {
        String sql = SELECT_DENGAN_JOIN + " WHERE d.status = 'AKTIF' ORDER BY d.nama_dokter";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Dokter> daftar = new ArrayList<>();
            while (rs.next()) {
                daftar.add(map(rs));
            }
            return daftar;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar dokter aktif.", e);
        }
    }

    /** Daftar spesialisasi unik untuk filter. */
    public List<String> daftarSpesialisasi() {
        String sql = "SELECT DISTINCT spesialisasi FROM dokter WHERE spesialisasi IS NOT NULL ORDER BY spesialisasi";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<String> daftar = new ArrayList<>();
            while (rs.next()) {
                daftar.add(rs.getString(1));
            }
            return daftar;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar spesialisasi.", e);
        }
    }

    public boolean tambah(Dokter d) {
        String sql = "INSERT INTO dokter (id_pengguna, nip, nama_dokter, jenis_kelamin, tempat_lahir, tanggal_lahir, "
                + "spesialisasi, alamat, no_telepon, email, jadwal_praktik, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, d.getIdPengguna());
            ps.setString(2, d.getNip());
            ps.setString(3, d.getNamaDokter());
            ps.setString(4, d.getJenisKelamin());
            ps.setString(5, d.getTempatLahir());
            ps.setObject(6, d.getTanggalLahir());
            ps.setString(7, d.getSpesialisasi());
            ps.setString(8, d.getAlamat());
            ps.setString(9, d.getNoTelepon());
            ps.setString(10, d.getEmail());
            ps.setString(11, d.getJadwalPraktik());
            ps.setString(12, d.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah dokter.", e);
        }
    }

    public boolean ubah(Dokter d) {
        String sql = "UPDATE dokter SET id_pengguna = ?, nip = ?, nama_dokter = ?, jenis_kelamin = ?, tempat_lahir = ?, "
                + "tanggal_lahir = ?, spesialisasi = ?, alamat = ?, no_telepon = ?, email = ?, jadwal_praktik = ?, status = ? "
                + "WHERE id_dokter = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, d.getIdPengguna());
            ps.setString(2, d.getNip());
            ps.setString(3, d.getNamaDokter());
            ps.setString(4, d.getJenisKelamin());
            ps.setString(5, d.getTempatLahir());
            ps.setObject(6, d.getTanggalLahir());
            ps.setString(7, d.getSpesialisasi());
            ps.setString(8, d.getAlamat());
            ps.setString(9, d.getNoTelepon());
            ps.setString(10, d.getEmail());
            ps.setString(11, d.getJadwalPraktik());
            ps.setString(12, d.getStatus());
            ps.setInt(13, d.getIdDokter());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui dokter.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM dokter WHERE id_dokter = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus dokter.", e);
        }
    }

    /** Mengecek NIP sudah dipakai dokter lain (kecuali id tertentu). */
    public boolean nipDipakai(String nip, Integer kecualiId) {
        String sql = "SELECT COUNT(*) FROM dokter WHERE nip = ? AND id_dokter <> ?";
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
        String sql = "SELECT COUNT(*) FROM dokter WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung dokter.", e);
        }
    }
}
