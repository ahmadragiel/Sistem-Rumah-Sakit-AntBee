package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Ruangan;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel ruangan. */
public class RuanganDAO {

    private Ruangan map(ResultSet rs) throws SQLException {
        Ruangan r = new Ruangan();
        r.setIdRuangan(rs.getInt("id_ruangan"));
        r.setNamaRuangan(rs.getString("nama_ruangan"));
        r.setJenisRuangan(rs.getString("jenis_ruangan"));
        r.setNomorKamar(rs.getString("nomor_kamar"));
        r.setLantai(rs.getInt("lantai"));
        r.setKapasitas(rs.getInt("kapasitas"));
        r.setJumlahTerisi(rs.getInt("jumlah_terisi"));
        r.setTarifPerHari(rs.getBigDecimal("tarif_per_hari"));
        r.setFasilitas(rs.getString("fasilitas"));
        r.setStatusRuangan(rs.getString("status_ruangan"));
        return r;
    }

    /** Daftar ruangan dengan pencarian (nama / nomor kamar / fasilitas) dan filter jenis + status. */
    public List<Ruangan> semua(String q, String jenis, String status) {
        StringBuilder sql = new StringBuilder("SELECT * FROM ruangan WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (nama_ruangan LIKE ? OR nomor_kamar LIKE ? OR fasilitas LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 3; i++) {
                param.add(like);
            }
        }
        if (jenis != null && !jenis.isBlank()) {
            sql.append(" AND jenis_ruangan = ?");
            param.add(jenis);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND status_ruangan = ?");
            param.add(status);
        }
        sql.append(" ORDER BY nomor_kamar");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Ruangan> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar ruangan.", e);
        }
    }

    public Ruangan findById(int id) {
        String sql = "SELECT * FROM ruangan WHERE id_ruangan = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data ruangan.", e);
        }
    }

    /** Semua ruangan untuk pilihan pada form (tanpa filter). */
    public List<Ruangan> daftarSemua() {
        return semua(null, null, null);
    }

    public boolean tambah(Ruangan r) {
        String sql = "INSERT INTO ruangan (nama_ruangan, jenis_ruangan, nomor_kamar, lantai, kapasitas, jumlah_terisi, "
                + "tarif_per_hari, fasilitas, status_ruangan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, r.getNamaRuangan());
            ps.setString(2, r.getJenisRuangan());
            ps.setString(3, r.getNomorKamar());
            ps.setInt(4, r.getLantai());
            ps.setInt(5, r.getKapasitas());
            ps.setInt(6, r.getJumlahTerisi());
            ps.setBigDecimal(7, r.getTarifPerHari());
            ps.setString(8, r.getFasilitas());
            ps.setString(9, r.getStatusRuangan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah ruangan.", e);
        }
    }

    public boolean ubah(Ruangan r) {
        String sql = "UPDATE ruangan SET nama_ruangan = ?, jenis_ruangan = ?, nomor_kamar = ?, lantai = ?, kapasitas = ?, "
                + "jumlah_terisi = ?, tarif_per_hari = ?, fasilitas = ?, status_ruangan = ? WHERE id_ruangan = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, r.getNamaRuangan());
            ps.setString(2, r.getJenisRuangan());
            ps.setString(3, r.getNomorKamar());
            ps.setInt(4, r.getLantai());
            ps.setInt(5, r.getKapasitas());
            ps.setInt(6, r.getJumlahTerisi());
            ps.setBigDecimal(7, r.getTarifPerHari());
            ps.setString(8, r.getFasilitas());
            ps.setString(9, r.getStatusRuangan());
            ps.setInt(10, r.getIdRuangan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui ruangan.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM ruangan WHERE id_ruangan = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus ruangan.", e);
        }
    }

    /**
     * Menambah (delta positif) atau mengurangi (delta negatif) jumlah kamar terisi.
     * Hasilnya dijaga tetap antara 0 dan kapasitas.
     */
    public boolean ubahJumlahTerisi(int idRuangan, int delta) {
        String sql = "UPDATE ruangan SET jumlah_terisi = GREATEST(0, LEAST(kapasitas, jumlah_terisi + ?)) "
                + "WHERE id_ruangan = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setInt(2, idRuangan);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui jumlah kamar terisi.", e);
        }
    }

    /** Mengecek apakah kamar sudah penuh (jumlah_terisi >= kapasitas). */
    public boolean penuh(int idRuangan) {
        String sql = "SELECT COUNT(*) FROM ruangan WHERE id_ruangan = ? AND jumlah_terisi >= kapasitas";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idRuangan);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memeriksa kapasitas ruangan.", e);
        }
    }

    public int jumlahTotal() {
        return hitungAngka("SELECT COUNT(*) FROM ruangan WHERE 1=?", 1);
    }

    /** Jumlah ruangan yang masih punya sisa kapasitas. */
    public int jumlahKamarTersedia() {
        return hitungAngka("SELECT COUNT(*) FROM ruangan WHERE jumlah_terisi < kapasitas AND status_ruangan <> 'PERAWATAN' AND 1=?", 1);
    }

    public int jumlahKamarTerisi() {
        return hitungAngka("SELECT COUNT(*) FROM ruangan WHERE jumlah_terisi > 0 AND 1=?", 1);
    }

    /** Total pasien yang sedang mengisi kamar. */
    public int totalTerisi() {
        return hitungAngka("SELECT COALESCE(SUM(jumlah_terisi), 0) FROM ruangan WHERE 1=?", 1);
    }

    /** Total daya tampung seluruh ruangan. */
    public int totalKapasitas() {
        return hitungAngka("SELECT COALESCE(SUM(kapasitas), 0) FROM ruangan WHERE 1=?", 1);
    }

    private int hitungAngka(String sql, int param) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung data ruangan.", e);
        }
    }
}
