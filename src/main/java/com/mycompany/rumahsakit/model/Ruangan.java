package com.mycompany.rumahsakit.model;

import java.math.BigDecimal;

/** Model untuk tabel ruangan. */
public class Ruangan {

    private Integer idRuangan;
    private String namaRuangan;
    private String jenisRuangan; // Kelas I, Kelas II, Kelas III, ICU, Anak, Isolasi
    private String nomorKamar;
    private Integer lantai;
    private Integer kapasitas;
    private Integer jumlahTerisi;
    private BigDecimal tarifPerHari;
    private String fasilitas;
    private String statusRuangan; // TERSEDIA, TERISI, PERAWATAN

    public Ruangan() {
    }

    public Integer getIdRuangan() {
        return idRuangan;
    }

    public void setIdRuangan(Integer idRuangan) {
        this.idRuangan = idRuangan;
    }

    public String getNamaRuangan() {
        return namaRuangan;
    }

    public void setNamaRuangan(String namaRuangan) {
        this.namaRuangan = namaRuangan;
    }

    public String getJenisRuangan() {
        return jenisRuangan;
    }

    public void setJenisRuangan(String jenisRuangan) {
        this.jenisRuangan = jenisRuangan;
    }

    public String getNomorKamar() {
        return nomorKamar;
    }

    public void setNomorKamar(String nomorKamar) {
        this.nomorKamar = nomorKamar;
    }

    public Integer getLantai() {
        return lantai;
    }

    public void setLantai(Integer lantai) {
        this.lantai = lantai;
    }

    public Integer getKapasitas() {
        return kapasitas;
    }

    public void setKapasitas(Integer kapasitas) {
        this.kapasitas = kapasitas;
    }

    public Integer getJumlahTerisi() {
        return jumlahTerisi;
    }

    public void setJumlahTerisi(Integer jumlahTerisi) {
        this.jumlahTerisi = jumlahTerisi;
    }

    public BigDecimal getTarifPerHari() {
        return tarifPerHari;
    }

    public void setTarifPerHari(BigDecimal tarifPerHari) {
        this.tarifPerHari = tarifPerHari;
    }

    public String getFasilitas() {
        return fasilitas;
    }

    public void setFasilitas(String fasilitas) {
        this.fasilitas = fasilitas;
    }

    public String getStatusRuangan() {
        return statusRuangan;
    }

    public void setStatusRuangan(String statusRuangan) {
        this.statusRuangan = statusRuangan;
    }

    /** Sisa daya tampung kamar (kapasitas - yang sudah terisi). */
    public int getSisaKapasitas() {
        int k = kapasitas == null ? 0 : kapasitas;
        int t = jumlahTerisi == null ? 0 : jumlahTerisi;
        return Math.max(0, k - t);
    }

    /** Persentase kamar terisi (0 - 100). */
    public int getPersentaseTerisi() {
        if (kapasitas == null || kapasitas == 0) {
            return 0;
        }
        int t = jumlahTerisi == null ? 0 : jumlahTerisi;
        return Math.min(100, (int) Math.round(t * 100.0 / kapasitas));
    }
}
