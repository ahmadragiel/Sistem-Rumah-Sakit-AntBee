package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Pembayaran;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel pembayaran. */
public class PembayaranDAO {

    private static final String SELECT_DENGAN_JOIN =
            "SELECT b.*, p.nama_pasien, r.nomor_kamar "
            + "FROM pembayaran b "
            + "JOIN pasien p ON p.id_pasien = b.id_pasien "
            + "LEFT JOIN rawat_inap r ON r.id_rawat_inap = b.id_rawat_inap ";

    private Pembayaran map(ResultSet rs) throws SQLException {
        Pembayaran b = new Pembayaran();
        b.setIdPembayaran(rs.getInt("id_pembayaran"));
        b.setIdPasien(rs.getInt("id_pasien"));
        int idRawatInap = rs.getInt("id_rawat_inap");
        b.setIdRawatInap(rs.wasNull() ? null : idRawatInap);
        b.setBiayaKamar(rs.getBigDecimal("biaya_kamar"));
        b.setBiayaDokter(rs.getBigDecimal("biaya_dokter"));
        b.setBiayaObat(rs.getBigDecimal("biaya_obat"));
        b.setBiayaTindakan(rs.getBigDecimal("biaya_tindakan"));
        b.setBiayaLain(rs.getBigDecimal("biaya_lain"));
        b.setTotalBiaya(rs.getBigDecimal("total_biaya"));
        b.setMetodePembayaran(rs.getString("metode_pembayaran"));
        b.setTanggalPembayaran(rs.getObject("tanggal_pembayaran", java.time.LocalDate.class));
        b.setStatusPembayaran(rs.getString("status_pembayaran"));
        b.setNamaPasien(rs.getString("nama_pasien"));
        b.setNomorKamar(rs.getString("nomor_kamar"));
        return b;
    }

    private List<Pembayaran> jalankan(String sql, List<Object> param) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Pembayaran> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data pembayaran.", e);
        }
    }

    /** Daftar pembayaran dengan pencarian pasien, filter status, dan rentang tanggal. */
    public List<Pembayaran> semua(String q, String status, String dari, String sampai) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (p.nama_pasien LIKE ? OR b.metode_pembayaran LIKE ? OR b.status_pembayaran LIKE ? OR r.nomor_kamar LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND b.status_pembayaran = ?");
            param.add(status);
        }
        if (dari != null && !dari.isBlank()) {
            sql.append(" AND b.tanggal_pembayaran >= ?");
            param.add(dari);
        }
        if (sampai != null && !sampai.isBlank()) {
            sql.append(" AND b.tanggal_pembayaran <= ?");
            param.add(sampai);
        }
        sql.append(" ORDER BY b.id_pembayaran DESC");
        return jalankan(sql.toString(), param);
    }

    public Pembayaran findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE b.id_pembayaran = ?";
        List<Object> param = new ArrayList<>();
        param.add(id);
        List<Pembayaran> hasil = jalankan(sql, param);
        return hasil.isEmpty() ? null : hasil.get(0);
    }

    public List<Pembayaran> byPasien(int idPasien) {
        String sql = SELECT_DENGAN_JOIN + " WHERE b.id_pasien = ? ORDER BY b.id_pembayaran DESC";
        List<Object> param = new ArrayList<>();
        param.add(idPasien);
        return jalankan(sql, param);
    }

    /** Pembayaran terbaru untuk dashboard. */
    public List<Pembayaran> terbaru(int batas) {
        String sql = SELECT_DENGAN_JOIN + " ORDER BY b.id_pembayaran DESC LIMIT ?";
        List<Object> param = new ArrayList<>();
        param.add(batas);
        return jalankan(sql, param);
    }

    public boolean tambah(Pembayaran b) {
        String sql = "INSERT INTO pembayaran (id_pasien, id_rawat_inap, biaya_kamar, biaya_dokter, biaya_obat, "
                + "biaya_tindakan, biaya_lain, total_biaya, metode_pembayaran, tanggal_pembayaran, status_pembayaran) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, b.getIdPasien());
            ps.setObject(2, b.getIdRawatInap());
            ps.setBigDecimal(3, b.getBiayaKamar());
            ps.setBigDecimal(4, b.getBiayaDokter());
            ps.setBigDecimal(5, b.getBiayaObat());
            ps.setBigDecimal(6, b.getBiayaTindakan());
            ps.setBigDecimal(7, b.getBiayaLain());
            ps.setBigDecimal(8, b.getTotalBiaya());
            ps.setString(9, b.getMetodePembayaran());
            ps.setObject(10, b.getTanggalPembayaran());
            ps.setString(11, b.getStatusPembayaran());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah pembayaran.", e);
        }
    }

    public boolean ubah(Pembayaran b) {
        String sql = "UPDATE pembayaran SET id_pasien = ?, id_rawat_inap = ?, biaya_kamar = ?, biaya_dokter = ?, "
                + "biaya_obat = ?, biaya_tindakan = ?, biaya_lain = ?, total_biaya = ?, metode_pembayaran = ?, "
                + "tanggal_pembayaran = ?, status_pembayaran = ? WHERE id_pembayaran = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, b.getIdPasien());
            ps.setObject(2, b.getIdRawatInap());
            ps.setBigDecimal(3, b.getBiayaKamar());
            ps.setBigDecimal(4, b.getBiayaDokter());
            ps.setBigDecimal(5, b.getBiayaObat());
            ps.setBigDecimal(6, b.getBiayaTindakan());
            ps.setBigDecimal(7, b.getBiayaLain());
            ps.setBigDecimal(8, b.getTotalBiaya());
            ps.setString(9, b.getMetodePembayaran());
            ps.setObject(10, b.getTanggalPembayaran());
            ps.setString(11, b.getStatusPembayaran());
            ps.setInt(12, b.getIdPembayaran());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui pembayaran.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM pembayaran WHERE id_pembayaran = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus pembayaran.", e);
        }
    }

    public int jumlahStatus(String status) {
        String sql = "SELECT COUNT(*) FROM pembayaran WHERE status_pembayaran = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung pembayaran.", e);
        }
    }

    public int jumlahTotal() {
        String sql = "SELECT COUNT(*) FROM pembayaran WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung pembayaran.", e);
        }
    }

    /** Total pendapatan dari pembayaran berstatus LUNAS. */
    public BigDecimal totalLunas() {
        String sql = "SELECT COALESCE(SUM(total_biaya), 0) FROM pembayaran WHERE status_pembayaran = 'LUNAS'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung total pendapatan.", e);
        }
    }

    /** Total tagihan yang belum lunas milik satu pasien. */
    public BigDecimal totalBelumLunasByPasien(int idPasien) {
        String sql = "SELECT COALESCE(SUM(total_biaya), 0) FROM pembayaran "
                + "WHERE id_pasien = ? AND status_pembayaran <> 'LUNAS'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idPasien);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung tagihan pasien.", e);
        }
    }

    /** Total tagihan seluruh pembayaran (untuk laporan). */
    public BigDecimal totalSemua() {
        String sql = "SELECT COALESCE(SUM(total_biaya), 0) FROM pembayaran WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung total pembayaran.", e);
        }
    }
}
