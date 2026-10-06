package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Pemeriksaan;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel pemeriksaan. */
public class PemeriksaanDAO {

    private static final String SELECT_DENGAN_JOIN =
            "SELECT m.*, p.nama_pasien, p.nik, d.nama_dokter "
            + "FROM pemeriksaan m "
            + "JOIN pasien p ON p.id_pasien = m.id_pasien "
            + "LEFT JOIN dokter d ON d.id_dokter = m.id_dokter ";

    private Pemeriksaan map(ResultSet rs) throws SQLException {
        Pemeriksaan m = new Pemeriksaan();
        m.setIdPemeriksaan(rs.getInt("id_pemeriksaan"));
        m.setIdPasien(rs.getInt("id_pasien"));
        int idDokter = rs.getInt("id_dokter");
        m.setIdDokter(rs.wasNull() ? null : idDokter);
        m.setTanggalPemeriksaan(rs.getObject("tanggal_pemeriksaan", java.time.LocalDate.class));
        m.setKeluhan(rs.getString("keluhan"));
        m.setTekananDarah(rs.getString("tekanan_darah"));
        m.setSuhu(rs.getBigDecimal("suhu"));
        m.setBeratBadan(rs.getBigDecimal("berat_badan"));
        m.setDiagnosa(rs.getString("diagnosa"));
        m.setTindakan(rs.getString("tindakan"));
        m.setCatatan(rs.getString("catatan"));
        m.setNamaPasien(rs.getString("nama_pasien"));
        m.setNik(rs.getString("nik"));
        m.setNamaDokter(rs.getString("nama_dokter"));
        return m;
    }

    private List<Pemeriksaan> jalankan(String sql, List<Object> param) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Pemeriksaan> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data pemeriksaan.", e);
        }
    }

    /**
     * Daftar pemeriksaan dengan pencarian pasien/dokter/diagnosa,
     * filter dokter, filter pasien, dan rentang tanggal (format yyyy-MM-dd).
     */
    public List<Pemeriksaan> semua(String q, Integer idDokter, Integer idPasien, String dari, String sampai) {
        StringBuilder sql = new StringBuilder(SELECT_DENGAN_JOIN).append(" WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (p.nama_pasien LIKE ? OR d.nama_dokter LIKE ? OR m.diagnosa LIKE ? OR p.nik LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 4; i++) {
                param.add(like);
            }
        }
        if (idDokter != null) {
            sql.append(" AND m.id_dokter = ?");
            param.add(idDokter);
        }
        if (idPasien != null) {
            sql.append(" AND m.id_pasien = ?");
            param.add(idPasien);
        }
        if (dari != null && !dari.isBlank()) {
            sql.append(" AND m.tanggal_pemeriksaan >= ?");
            param.add(dari);
        }
        if (sampai != null && !sampai.isBlank()) {
            sql.append(" AND m.tanggal_pemeriksaan <= ?");
            param.add(sampai);
        }
        sql.append(" ORDER BY m.tanggal_pemeriksaan DESC, m.id_pemeriksaan DESC");
        return jalankan(sql.toString(), param);
    }

    public Pemeriksaan findById(int id) {
        String sql = SELECT_DENGAN_JOIN + " WHERE m.id_pemeriksaan = ?";
        List<Object> param = new ArrayList<>();
        param.add(id);
        List<Pemeriksaan> hasil = jalankan(sql, param);
        return hasil.isEmpty() ? null : hasil.get(0);
    }

    public List<Pemeriksaan> byPasien(int idPasien) {
        String sql = SELECT_DENGAN_JOIN + " WHERE m.id_pasien = ? ORDER BY m.tanggal_pemeriksaan DESC";
        List<Object> param = new ArrayList<>();
        param.add(idPasien);
        return jalankan(sql, param);
    }

    public List<Pemeriksaan> byDokter(int idDokter) {
        String sql = SELECT_DENGAN_JOIN + " WHERE m.id_dokter = ? ORDER BY m.tanggal_pemeriksaan DESC";
        List<Object> param = new ArrayList<>();
        param.add(idDokter);
        return jalankan(sql, param);
    }

    /** Pemeriksaan terbaru milik dokter (untuk dashboard). */
    public List<Pemeriksaan> terbaruByDokter(int idDokter, int batas) {
        String sql = SELECT_DENGAN_JOIN + " WHERE m.id_dokter = ? ORDER BY m.id_pemeriksaan DESC LIMIT ?";
        List<Object> param = new ArrayList<>();
        param.add(idDokter);
        param.add(batas);
        return jalankan(sql, param);
    }

    /** Pemeriksaan terbaru (untuk dashboard admin). */
    public List<Pemeriksaan> terbaru(int batas) {
        String sql = SELECT_DENGAN_JOIN + " ORDER BY m.id_pemeriksaan DESC LIMIT ?";
        List<Object> param = new ArrayList<>();
        param.add(batas);
        return jalankan(sql, param);
    }

    /** Jadwal pemeriksaan pasien yang akan datang (tanggal hari ini atau setelahnya). */
    public List<Pemeriksaan> jadwalMendatang(int idPasien) {
        String sql = SELECT_DENGAN_JOIN
                + " WHERE m.id_pasien = ? AND m.tanggal_pemeriksaan >= CURDATE() "
                + "ORDER BY m.tanggal_pemeriksaan ASC";
        List<Object> param = new ArrayList<>();
        param.add(idPasien);
        return jalankan(sql, param);
    }

    public boolean tambah(Pemeriksaan m) {
        String sql = "INSERT INTO pemeriksaan (id_pasien, id_dokter, tanggal_pemeriksaan, keluhan, tekanan_darah, "
                + "suhu, berat_badan, diagnosa, tindakan, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, m.getIdPasien());
            ps.setObject(2, m.getIdDokter());
            ps.setObject(3, m.getTanggalPemeriksaan());
            ps.setString(4, m.getKeluhan());
            ps.setString(5, m.getTekananDarah());
            ps.setBigDecimal(6, m.getSuhu());
            ps.setBigDecimal(7, m.getBeratBadan());
            ps.setString(8, m.getDiagnosa());
            ps.setString(9, m.getTindakan());
            ps.setString(10, m.getCatatan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah pemeriksaan.", e);
        }
    }

    public boolean ubah(Pemeriksaan m) {
        String sql = "UPDATE pemeriksaan SET id_pasien = ?, id_dokter = ?, tanggal_pemeriksaan = ?, keluhan = ?, "
                + "tekanan_darah = ?, suhu = ?, berat_badan = ?, diagnosa = ?, tindakan = ?, catatan = ? "
                + "WHERE id_pemeriksaan = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, m.getIdPasien());
            ps.setObject(2, m.getIdDokter());
            ps.setObject(3, m.getTanggalPemeriksaan());
            ps.setString(4, m.getKeluhan());
            ps.setString(5, m.getTekananDarah());
            ps.setBigDecimal(6, m.getSuhu());
            ps.setBigDecimal(7, m.getBeratBadan());
            ps.setString(8, m.getDiagnosa());
            ps.setString(9, m.getTindakan());
            ps.setString(10, m.getCatatan());
            ps.setInt(11, m.getIdPemeriksaan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui pemeriksaan.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM pemeriksaan WHERE id_pemeriksaan = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus pemeriksaan.", e);
        }
    }

    /** Jumlah pemeriksaan hari ini oleh dokter tertentu. */
    public int jumlahHariIni(int idDokter) {
        String sql = "SELECT COUNT(*) FROM pemeriksaan WHERE id_dokter = ? AND tanggal_pemeriksaan = CURDATE()";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idDokter);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung pemeriksaan hari ini.", e);
        }
    }

    public int jumlahTotal() {
        String sql = "SELECT COUNT(*) FROM pemeriksaan WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung pemeriksaan.", e);
        }
    }
}
