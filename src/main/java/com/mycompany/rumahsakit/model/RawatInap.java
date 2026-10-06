package com.mycompany.rumahsakit.model;

import java.time.LocalDate;

/** Model untuk tabel rawat_inap. */
public class RawatInap {

    private Integer idRawatInap;
    private Integer idPasien;
    private Integer idDokter;
    private Integer idRuangan;
    private String nomorKamar;
    private String diagnosa;
    private String keluhan;
    private LocalDate tanggalMasuk;
    private LocalDate tanggalKeluar;
    private Integer lamaRawat;
    private String statusRawat; // MENUNGGU, DIRAWAT, SELESAI, DIPULANGKAN

    // Data tambahan hasil JOIN
    private String namaPasien;
    private String namaDokter;
    private String namaRuangan;
    private String jenisRuangan;

    public RawatInap() {
    }

    public Integer getIdRawatInap() {
        return idRawatInap;
    }

    public void setIdRawatInap(Integer idRawatInap) {
        this.idRawatInap = idRawatInap;
    }

    public Integer getIdPasien() {
        return idPasien;
    }

    public void setIdPasien(Integer idPasien) {
        this.idPasien = idPasien;
    }

    public Integer getIdDokter() {
        return idDokter;
    }

    public void setIdDokter(Integer idDokter) {
        this.idDokter = idDokter;
    }

    public Integer getIdRuangan() {
        return idRuangan;
    }

    public void setIdRuangan(Integer idRuangan) {
        this.idRuangan = idRuangan;
    }

    public String getNomorKamar() {
        return nomorKamar;
    }

    public void setNomorKamar(String nomorKamar) {
        this.nomorKamar = nomorKamar;
    }

    public String getDiagnosa() {
        return diagnosa;
    }

    public void setDiagnosa(String diagnosa) {
        this.diagnosa = diagnosa;
    }

    public String getKeluhan() {
        return keluhan;
    }

    public void setKeluhan(String keluhan) {
        this.keluhan = keluhan;
    }

    public LocalDate getTanggalMasuk() {
        return tanggalMasuk;
    }

    public void setTanggalMasuk(LocalDate tanggalMasuk) {
        this.tanggalMasuk = tanggalMasuk;
    }

    public LocalDate getTanggalKeluar() {
        return tanggalKeluar;
    }

    public void setTanggalKeluar(LocalDate tanggalKeluar) {
        this.tanggalKeluar = tanggalKeluar;
    }

    public Integer getLamaRawat() {
        return lamaRawat;
    }

    public void setLamaRawat(Integer lamaRawat) {
        this.lamaRawat = lamaRawat;
    }

    public String getStatusRawat() {
        return statusRawat;
    }

    public void setStatusRawat(String statusRawat) {
        this.statusRawat = statusRawat;
    }

    public String getNamaPasien() {
        return namaPasien;
    }

    public void setNamaPasien(String namaPasien) {
        this.namaPasien = namaPasien;
    }

    public String getNamaDokter() {
        return namaDokter;
    }

    public void setNamaDokter(String namaDokter) {
        this.namaDokter = namaDokter;
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
}
