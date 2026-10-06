package com.mycompany.rumahsakit.model;

import java.time.LocalDate;

/** Model untuk tabel catatan_perawatan. */
public class CatatanPerawatan {

    private Integer idCatatan;
    private Integer idPasien;
    private Integer idPerawat;
    private LocalDate tanggal;
    private String kondisiPasien;
    private String catatan;
    private String tindakan;
    private String status; // BAIK, SEDANG, KRITIS

    // Data tambahan hasil JOIN
    private String namaPasien;
    private String namaPerawat;
    private String statusPasien;

    public CatatanPerawatan() {
    }

    public Integer getIdCatatan() {
        return idCatatan;
    }

    public void setIdCatatan(Integer idCatatan) {
        this.idCatatan = idCatatan;
    }

    public Integer getIdPasien() {
        return idPasien;
    }

    public void setIdPasien(Integer idPasien) {
        this.idPasien = idPasien;
    }

    public Integer getIdPerawat() {
        return idPerawat;
    }

    public void setIdPerawat(Integer idPerawat) {
        this.idPerawat = idPerawat;
    }

    public LocalDate getTanggal() {
        return tanggal;
    }

    public void setTanggal(LocalDate tanggal) {
        this.tanggal = tanggal;
    }

    public String getKondisiPasien() {
        return kondisiPasien;
    }

    public void setKondisiPasien(String kondisiPasien) {
        this.kondisiPasien = kondisiPasien;
    }

    public String getCatatan() {
        return catatan;
    }

    public void setCatatan(String catatan) {
        this.catatan = catatan;
    }

    public String getTindakan() {
        return tindakan;
    }

    public void setTindakan(String tindakan) {
        this.tindakan = tindakan;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNamaPasien() {
        return namaPasien;
    }

    public void setNamaPasien(String namaPasien) {
        this.namaPasien = namaPasien;
    }

    public String getNamaPerawat() {
        return namaPerawat;
    }

    public void setNamaPerawat(String namaPerawat) {
        this.namaPerawat = namaPerawat;
    }

    public String getStatusPasien() {
        return statusPasien;
    }

    public void setStatusPasien(String statusPasien) {
        this.statusPasien = statusPasien;
    }
}
