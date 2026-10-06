package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.CatatanPerawatan;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel catatan_perawatan. */
public class CatatanPerawatanDAO {

    private static final String SELECT_DENGAN_JOIN =
            "SELECT c.*, p.nama_pasien, w.nama_perawat, p.status_pasien "
            + "FROM catatan_perawatan c "
            + "JOIN pasien p ON p.id_pasien = c.id_pasien "
            + "LEFT JOIN perawat w ON w.id_perawat = c.id_perawat ";

    private CatatanPerawatan map(ResultSet rs) throws SQLException {
        CatatanPerawatan c = new CatatanPerawatan();
        c.setIdCatatan(rs.getInt("id_catatan"));
        c.setIdPasien(rs.getInt("id_pasien"));
        int idPerawat = rs.getInt("id_perawat");
        c.setIdPerawat(rs.wasNull() ? null : idPerawat);
        c.setTanggal(rs.getObject("tanggal", java.time.LocalDate.class));
        c.setKondisiPasien(rs.getString("kondisi_pasien"));
        c.setCatatan(rs.getString("catatan"));
        c.setTindakan(rs.getString("tindakan"));
        c.setStatus(rs.getString("status"));
        c.setNamaPasien(rs.getString("nama_pasien"));
        c.setNamaPerawat(rs.getString("nama_perawat"));
        c.setStatusPasien(rs.getString("status_pasien"));
        return c;
    }

    private List<CatatanPerawatan> jalankan(String sql, List<Object> param) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<CatatanPerawatan> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data catatan perawatan.", e);
        }
    }

    /** Daftar catatan dengan pencarian pasien/perawat, filter perawat, pasien, dan status. */
    public List<CatatanPerawatan> semua(String q, Integer idPerawat, Integer idPasien, String status) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (p.nama_pasien LIKE ? OR w.nama_perawat LIKE ? OR c.kondisi_pasien LIKE ? OR c.tindakan LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (idPerawat != null) {
            sql.append(" AND c.id_perawat = ?");
            param.add(idPerawat);
        }
        if (idPasien != null) {
            sql.append(" AND c.id_pasien = ?");
            param.add(idPasien);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND c.status = ?");
            param.add(status);
        }
        sql.append(" ORDER BY c.tanggal DESC, c.id_catatan DESC");
        return jalankan(sql.toString(), param);
    }

    public CatatanPerawatan findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE c.id_catatan = ?";
        List<Object> param = new ArrayList<>();
        param.add(id);
        List<CatatanPerawatan> hasil = jalankan(sql, param);
        return hasil.isEmpty() ? null : hasil.get(0);
    }

    public List<CatatanPerawatan> byPasien(int idPasien) {
        String sql = SELECT_DENGAN_JOIN + " WHERE c.id_pasien = ? ORDER BY c.tanggal DESC";
        List<Object> param = new ArrayList<>();
        param.add(idPasien);
        return jalankan(sql, param);
    }

    public List<CatatanPerawatan> byPerawat(int idPerawat) {
        String sql = SELECT_DENGAN_JOIN + " WHERE c.id_perawat = ? ORDER BY c.tanggal DESC";
        List<Object> param = new ArrayList<>();
        param.add(idPerawat);
        return jalankan(sql, param);
    }

    /** Catatan terbaru untuk ditampilkan di dashboard. */
    public List<CatatanPerawatan> terbaru(int batas) {
        String sql = SELECT_DENGAN_JOIN + " ORDER BY c.id_catatan DESC LIMIT ?";
        List<Object> param = new ArrayList<>();
        param.add(batas);
        return jalankan(sql, param);
    }

    public boolean tambah(CatatanPerawatan c) {
        String sql = "INSERT INTO catatan_perawatan (id_pasien, id_perawat, tanggal, kondisi_pasien, catatan, tindakan, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection koneksi = DBConnection.getConnection();
             PreparedStatement ps = koneksi.prepareStatement(sql)) {
            ps.setInt(1, c.getIdPasien());
            ps.setObject(2, c.getIdPerawat());
            ps.setObject(3, c.getTanggal());
            ps.setString(4, c.getKondisiPasien());
            ps.setString(5, c.getCatatan());
            ps.setString(6, c.getTindakan());
            ps.setString(7, c.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah catatan perawatan.", e);
        }
    }

    public boolean ubah(CatatanPerawatan c) {
        String sql = "UPDATE catatan_perawatan SET id_pasien = ?, id_perawat = ?, tanggal = ?, kondisi_pasien = ?, "
                + "catatan = ?, tindakan = ?, status = ? WHERE id_catatan = ?";
        try (Connection koneksi = DBConnection.getConnection();
             PreparedStatement ps = koneksi.prepareStatement(sql)) {
            ps.setInt(1, c.getIdPasien());
            ps.setObject(2, c.getIdPerawat());
            ps.setObject(3, c.getTanggal());
            ps.setString(4, c.getKondisiPasien());
            ps.setString(5, c.getCatatan());
            ps.setString(6, c.getTindakan());
            ps.setString(7, c.getStatus());
            ps.setInt(8, c.getIdCatatan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui catatan perawatan.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM catatan_perawatan WHERE id_catatan = ?";
        try (Connection koneksi = DBConnection.getConnection();
             PreparedStatement ps = koneksi.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus catatan perawatan.", e);
        }
    }

    public int jumlahByPerawat(int idPerawat) {
        String sql = "SELECT COUNT(*) FROM catatan_perawatan WHERE id_perawat = ?";
        try (Connection koneksi = DBConnection.getConnection();
             PreparedStatement ps = koneksi.prepareStatement(sql)) {
            ps.setInt(1, idPerawat);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung catatan perawatan.", e);
        }
    }

    public int jumlahTotal() {
        String sql = "SELECT COUNT(*) FROM catatan_perawatan WHERE 1=?";
        try (Connection koneksi = DBConnection.getConnection();
             PreparedStatement ps = koneksi.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung catatan perawatan.", e);
        }
    }
}
