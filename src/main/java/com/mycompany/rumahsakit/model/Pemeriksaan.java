package com.mycompany.rumahsakit.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/** Model untuk tabel pemeriksaan. */
public class Pemeriksaan {

    private Integer idPemeriksaan;
    private Integer idPasien;
    private Integer idDokter;
    private LocalDate tanggalPemeriksaan;
    private String keluhan;
    private String tekananDarah;
    private BigDecimal suhu;
    private BigDecimal beratBadan;
    private String diagnosa;
    private String tindakan;
    private String catatan;

    // Data tambahan hasil JOIN
    private String namaPasien;
    private String namaDokter;
    private String nik;

    public Pemeriksaan() {
    }

    public Integer getIdPemeriksaan() {
        return idPemeriksaan;
    }

    public void setIdPemeriksaan(Integer idPemeriksaan) {
        this.idPemeriksaan = idPemeriksaan;
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

    public LocalDate getTanggalPemeriksaan() {
        return tanggalPemeriksaan;
    }

    public void setTanggalPemeriksaan(LocalDate tanggalPemeriksaan) {
        this.tanggalPemeriksaan = tanggalPemeriksaan;
    }

    public String getKeluhan() {
        return keluhan;
    }

    public void setKeluhan(String keluhan) {
        this.keluhan = keluhan;
    }

    public String getTekananDarah() {
        return tekananDarah;
    }

    public void setTekananDarah(String tekananDarah) {
        this.tekananDarah = tekananDarah;
    }

    public BigDecimal getSuhu() {
        return suhu;
    }

    public void setSuhu(BigDecimal suhu) {
        this.suhu = suhu;
    }

    public BigDecimal getBeratBadan() {
        return beratBadan;
    }

    public void setBeratBadan(BigDecimal beratBadan) {
        this.beratBadan = beratBadan;
    }

    public String getDiagnosa() {
        return diagnosa;
    }

    public void setDiagnosa(String diagnosa) {
        this.diagnosa = diagnosa;
    }

    public String getTindakan() {
        return tindakan;
    }

    public void setTindakan(String tindakan) {
        this.tindakan = tindakan;
    }

    public String getCatatan() {
        return catatan;
    }

    public void setCatatan(String catatan) {
        this.catatan = catatan;
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

    public String getNik() {
        return nik;
    }

    public void setNik(String nik) {
        this.nik = nik;
    }
}
