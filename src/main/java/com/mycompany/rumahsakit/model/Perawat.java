package com.mycompany.rumahsakit.model;

import java.time.LocalDate;

/** Model untuk tabel perawat. */
public class Perawat {

    private Integer idPerawat;
    private Integer idPengguna;
    private String nip;
    private String namaPerawat;
    private String jenisKelamin;
    private String tempatLahir;
    private LocalDate tanggalLahir;
    private String pendidikan;
    private String alamat;
    private String noTelepon;
    private String shift;    // Pagi, Siang, Malam
    private String ruangan;  // nama ruangan tugas (teks bebas)
    private String status;   // AKTIF, NONAKTIF

    // Data tambahan hasil JOIN
    private String username;

    public Perawat() {
    }

    public Integer getIdPerawat() {
        return idPerawat;
    }

    public void setIdPerawat(Integer idPerawat) {
        this.idPerawat = idPerawat;
    }

    public Integer getIdPengguna() {
        return idPengguna;
    }

    public void setIdPengguna(Integer idPengguna) {
        this.idPengguna = idPengguna;
    }

    public String getNip() {
        return nip;
    }

    public void setNip(String nip) {
        this.nip = nip;
    }

    public String getNamaPerawat() {
        return namaPerawat;
    }

    public void setNamaPerawat(String namaPerawat) {
        this.namaPerawat = namaPerawat;
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

    public String getPendidikan() {
        return pendidikan;
    }

    public void setPendidikan(String pendidikan) {
        this.pendidikan = pendidikan;
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

    public String getShift() {
        return shift;
    }

    public void setShift(String shift) {
        this.shift = shift;
    }

    public String getRuangan() {
        return ruangan;
    }

    public void setRuangan(String ruangan) {
        this.ruangan = ruangan;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}
