package com.mycompany.rumahsakit.model;

import java.time.LocalDate;

/** Model untuk tabel pasien. */
public class Pasien {

    private Integer idPasien;
    private Integer idPengguna;
    private String nik;
    private String namaPasien;
    private String jenisKelamin;
    private String tempatLahir;
    private LocalDate tanggalLahir;
    private String alamat;
    private String noTelepon;
    private String golonganDarah;
    private Integer idPenyakit;
    private Integer idDokter;
    private LocalDate tanggalMasuk;
    private LocalDate tanggalKeluar;
    private String statusPasien; // RAWAT JALAN, DIRAWAT, PULANG

    // Data tambahan hasil JOIN (tidak disimpan di tabel pasien)
    private String namaDokter;
    private String namaPenyakit;
    private String username;

    public Pasien() {
    }

    public Integer getIdPasien() {
        return idPasien;
    }

    public void setIdPasien(Integer idPasien) {
        this.idPasien = idPasien;
    }

    public Integer getIdPengguna() {
        return idPengguna;
    }

    public void setIdPengguna(Integer idPengguna) {
        this.idPengguna = idPengguna;
    }

    public String getNik() {
        return nik;
    }

    public void setNik(String nik) {
        this.nik = nik;
    }

    public String getNamaPasien() {
        return namaPasien;
    }

    public void setNamaPasien(String namaPasien) {
        this.namaPasien = namaPasien;
    }

    public String getJenisKelamin() {
        return jenisKelamin;
    }

    public void setJenisKelamin(String jenisKelamin) {
        this.jenisKelamin = jenisKelamin;
    }

    public String getTempatLahir() {
        return tempatLahir;
    }

    public void setTempatLahir(String tempatLahir) {
        this.tempatLahir = tempatLahir;
    }

    public LocalDate getTanggalLahir() {
        return tanggalLahir;
    }

    public void setTanggalLahir(LocalDate tanggalLahir) {
        this.tanggalLahir = tanggalLahir;
    }

    public String getAlamat() {
        return alamat;
    }

    public void setAlamat(String alamat) {
        this.alamat = alamat;
    }

    public String getNoTelepon() {
        return noTelepon;
    }

    public void setNoTelepon(String noTelepon) {
        this.noTelepon = noTelepon;
    }

    public String getGolonganDarah() {
        return golonganDarah;
    }

    public void setGolonganDarah(String golonganDarah) {
        this.golonganDarah = golonganDarah;
    }

    public Integer getIdPenyakit() {
        return idPenyakit;
    }

    public void setIdPenyakit(Integer idPenyakit) {
        this.idPenyakit = idPenyakit;
    }

    public Integer getIdDokter() {
        return idDokter;
    }

    public void setIdDokter(Integer idDokter) {
        this.idDokter = idDokter;
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

    public String getStatusPasien() {
        return statusPasien;
    }

    public void setStatusPasien(String statusPasien) {
        this.statusPasien = statusPasien;
    }

    public String getNamaDokter() {
        return namaDokter;
    }

    public void setNamaDokter(String namaDokter) {
        this.namaDokter = namaDokter;
    }

    public String getNamaPenyakit() {
        return namaPenyakit;
    }

    public void setNamaPenyakit(String namaPenyakit) {
        this.namaPenyakit = namaPenyakit;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}
