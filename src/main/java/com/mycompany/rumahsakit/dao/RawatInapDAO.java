package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.RawatInap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel rawat_inap. */
public class RawatInapDAO {

    private static final String SELECT_DENGAN_JOIN =
            "SELECT r.*, p.nama_pasien, d.nama_dokter, u.nama_ruangan, u.jenis_ruangan "
            + "FROM rawat_inap r "
            + "JOIN pasien p ON p.id_pasien = r.id_pasien "
            + "LEFT JOIN dokter d ON d.id_dokter = r.id_dokter "
            + "LEFT JOIN ruangan u ON u.id_ruangan = r.id_ruangan ";

    private RawatInap map(ResultSet rs) throws SQLException {
        RawatInap r = new RawatInap();
        r.setIdRawatInap(rs.getInt("id_rawat_inap"));
        r.setIdPasien(rs.getInt("id_pasien"));
        int idDokter = rs.getInt("id_dokter");
        r.setIdDokter(rs.wasNull() ? null : idDokter);
        int idRuangan = rs.getInt("id_ruangan");
        r.setIdRuangan(rs.wasNull() ? null : idRuangan);
        r.setNomorKamar(rs.getString("nomor_kamar"));
        r.setDiagnosa(rs.getString("diagnosa"));
        r.setKeluhan(rs.getString("keluhan"));
        r.setTanggalMasuk(rs.getObject("tanggal_masuk", java.time.LocalDate.class));
        r.setTanggalKeluar(rs.getObject("tanggal_keluar", java.time.LocalDate.class));
        r.setLamaRawat(rs.getInt("lama_rawat"));
        r.setStatusRawat(rs.getString("status_rawat"));
        r.setNamaPasien(rs.getString("nama_pasien"));
        r.setNamaDokter(rs.getString("nama_dokter"));
        r.setNamaRuangan(rs.getString("nama_ruangan"));
        r.setJenisRuangan(rs.getString("jenis_ruangan"));
        return r;
    }

    /** Daftar rawat inap dengan pencarian (pasien / nomor kamar) dan filter status. */
    public List<RawatInap> semua(String q, String status) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (p.nama_pasien LIKE ? OR r.nomor_kamar LIKE ? OR r.diagnosa LIKE ? OR d.nama_dokter LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND r.status_rawat = ?");
            param.add(status);
        }
        sql.append(" ORDER BY r.id_rawat_inap DESC");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<RawatInap> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar rawat inap.", e);
        }
    }

    public RawatInap findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE r.id_rawat_inap = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data rawat inap.", e);
        }
    }

    public List<RawatInap> byPasien(int idPasien) {
        String sql = SELECT_DENGAN_JOIN + " WHERE r.id_pasien = ? ORDER BY r.tanggal_masuk DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idPasien);
            try (ResultSet rs = ps.executeQuery()) {
                List<RawatInap> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca riwayat rawat inap pasien.", e);
        }
    }

    public List<RawatInap> byDokter(int idDokter) {
        String sql = SELECT_DENGAN_JOIN + " WHERE r.id_dokter = ? ORDER BY r.tanggal_masuk DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idDokter);
            try (ResultSet rs = ps.executeQuery()) {
                List<RawatInap> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca rawat inap dokter.", e);
        }
    }

    /** Data rawat inap terbaru untuk ditampilkan di dashboard. */
    public List<RawatInap> terbaru(int batas) {
        String sql = SELECT_DENGAN_JOIN + " ORDER BY r.id_rawat_inap DESC LIMIT ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, batas);
            try (ResultSet rs = ps.executeQuery()) {
                List<RawatInap> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca rawat inap terbaru.", e);
        }
    }

    public boolean tambah(RawatInap r) {
        String sql = "INSERT INTO rawat_inap (id_pasien, id_dokter, id_ruangan, nomor_kamar, diagnosa, keluhan, "
                + "tanggal_masuk, tanggal_keluar, lama_rawat, status_rawat) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, r.getIdPasien());
            ps.setObject(2, r.getIdDokter());
            ps.setObject(3, r.getIdRuangan());
            ps.setString(4, r.getNomorKamar());
            ps.setString(5, r.getDiagnosa());
            ps.setString(6, r.getKeluhan());
            ps.setObject(7, r.getTanggalMasuk());
            ps.setObject(8, r.getTanggalKeluar());
            ps.setObject(9, r.getLamaRawat());
            ps.setString(10, r.getStatusRawat());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah rawat inap.", e);
        }
    }

    public boolean ubah(RawatInap r) {
        String sql = "UPDATE rawat_inap SET id_pasien = ?, id_dokter = ?, id_ruangan = ?, nomor_kamar = ?, diagnosa = ?, "
                + "keluhan = ?, tanggal_masuk = ?, tanggal_keluar = ?, lama_rawat = ?, status_rawat = ? "
                + "WHERE id_rawat_inap = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, r.getIdPasien());
            ps.setObject(2, r.getIdDokter());
            ps.setObject(3, r.getIdRuangan());
            ps.setString(4, r.getNomorKamar());
            ps.setString(5, r.getDiagnosa());
            ps.setString(6, r.getKeluhan());
            ps.setObject(7, r.getTanggalMasuk());
            ps.setObject(8, r.getTanggalKeluar());
            ps.setObject(9, r.getLamaRawat());
            ps.setString(10, r.getStatusRawat());
            ps.setInt(11, r.getIdRawatInap());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui rawat inap.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM rawat_inap WHERE id_rawat_inap = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus rawat inap.", e);
        }
    }

    public int jumlahStatus(String status) {
        String sql = "SELECT COUNT(*) FROM rawat_inap WHERE status_rawat = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung rawat inap.", e);
        }
    }

    public int jumlahTotal() {
        String sql = "SELECT COUNT(*) FROM rawat_inap WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung rawat inap.", e);
        }
    }

    /** Jumlah pasien yang masuk hari ini (untuk dashboard petugas). */
    public int jumlahMasukHariIni() {
        String sql = "SELECT COUNT(*) FROM rawat_inap WHERE tanggal_masuk = CURDATE()";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung rawat inap hari ini.", e);
        }
    }
}
