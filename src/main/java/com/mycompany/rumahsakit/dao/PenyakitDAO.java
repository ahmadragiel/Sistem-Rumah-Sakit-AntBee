package com.mycompany.rumahsakit.dao;

import com.mycompany.rumahsakit.config.DBConnection;
import com.mycompany.rumahsakit.model.Penyakit;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data Access Object untuk tabel penyakit. */
public class PenyakitDAO {

    private Penyakit map(ResultSet rs) throws SQLException {
        Penyakit p = new Penyakit();
        p.setIdPenyakit(rs.getInt("id_penyakit"));
        p.setKodePenyakit(rs.getString("kode_penyakit"));
        p.setNamaPenyakit(rs.getString("nama_penyakit"));
        p.setJenisPenyakit(rs.getString("jenis_penyakit"));
        p.setGejala(rs.getString("gejala"));
        p.setPenyebab(rs.getString("penyebab"));
        p.setTingkatKeparahan(rs.getString("tingkat_keparahan"));
        p.setPenanganan(rs.getString("penanganan"));
        p.setObatUtama(rs.getString("obat_utama"));
        p.setKeterangan(rs.getString("keterangan"));
        return p;
    }

    /** Daftar penyakit dengan pencarian (kode / nama) dan filter jenis. */
    public List<Penyakit> semua(String q, String jenis) {
        StringBuilder sql = new StringBuilder("SELECT * FROM penyakit WHERE 1=1");
        List<Object> param = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (kode_penyakit LIKE ? OR nama_penyakit LIKE ? OR gejala LIKE ?)");
            String like = "%" + q.trim() + "%";
            for (int i = 0; i < 3; i++) {
                param.add(like);
            }
        }
        if (jenis != null && !jenis.isBlank()) {
            sql.append(" AND jenis_penyakit = ?");
            param.add(jenis);
        }
        sql.append(" ORDER BY kode_penyakit");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < param.size(); i++) {
                ps.setObject(i + 1, param.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Penyakit> daftar = new ArrayList<>();
                while (rs.next()) {
                    daftar.add(map(rs));
                }
                return daftar;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar penyakit.", e);
        }
    }

    public Penyakit findById(int id) {
        String sql = "SELECT * FROM penyakit WHERE id_penyakit = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca data penyakit.", e);
        }
    }

    public boolean tambah(Penyakit p) {
        String sql = "INSERT INTO penyakit (kode_penyakit, nama_penyakit, jenis_penyakit, gejala, penyebab, "
                + "tingkat_keparahan, penanganan, obat_utama, keterangan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, p.getKodePenyakit());
            ps.setString(2, p.getNamaPenyakit());
            ps.setString(3, p.getJenisPenyakit());
            ps.setString(4, p.getGejala());
            ps.setString(5, p.getPenyebab());
            ps.setString(6, p.getTingkatKeparahan());
            ps.setString(7, p.getPenanganan());
            ps.setString(8, p.getObatUtama());
            ps.setString(9, p.getKeterangan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menambah penyakit.", e);
        }
    }

    public boolean ubah(Penyakit p) {
        String sql = "UPDATE penyakit SET kode_penyakit = ?, nama_penyakit = ?, jenis_penyakit = ?, gejala = ?, "
                + "penyebab = ?, tingkat_keparahan = ?, penanganan = ?, obat_utama = ?, keterangan = ? "
                + "WHERE id_penyakit = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, p.getKodePenyakit());
            ps.setString(2, p.getNamaPenyakit());
            ps.setString(3, p.getJenisPenyakit());
            ps.setString(4, p.getGejala());
            ps.setString(5, p.getPenyebab());
            ps.setString(6, p.getTingkatKeparahan());
            ps.setString(7, p.getPenanganan());
            ps.setString(8, p.getObatUtama());
            ps.setString(9, p.getKeterangan());
            ps.setInt(10, p.getIdPenyakit());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memperbarui penyakit.", e);
        }
    }

    public boolean hapus(int id) {
        String sql = "DELETE FROM penyakit WHERE id_penyakit = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghapus penyakit.", e);
        }
    }

    /** Mengecek kode penyakit sudah dipakai (kecuali id tertentu). */
    public boolean kodeDipakai(String kode, Integer kecualiId) {
        String sql = "SELECT COUNT(*) FROM penyakit WHERE kode_penyakit = ? AND id_penyakit <> ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, kode);
            ps.setInt(2, kecualiId == null ? -1 : kecualiId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal memeriksa kode penyakit.", e);
        }
    }

    /** Daftar jenis penyakit unik untuk filter. */
    public List<String> daftarJenis() {
        String sql = "SELECT DISTINCT jenis_penyakit FROM penyakit WHERE jenis_penyakit IS NOT NULL ORDER BY jenis_penyakit";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<String> daftar = new ArrayList<>();
            while (rs.next()) {
                daftar.add(rs.getString(1));
            }
            return daftar;
        } catch (SQLException e) {
            throw new RuntimeException("Gagal membaca daftar jenis penyakit.", e);
        }
    }

    public int jumlahTotal() {
        String sql = "SELECT COUNT(*) FROM penyakit WHERE 1=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Gagal menghitung penyakit.", e);
        }
    }
}
