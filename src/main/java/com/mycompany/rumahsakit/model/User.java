package com.mycompany.rumahsakit.model;

import java.time.LocalDateTime;

/** Model untuk tabel pengguna (akun login multi-role). */
public class User {

    private Integer idPengguna;
    private String username;
    private String password;
    private String namaLengkap;
    private String email;
    private String noTelepon;
    private String alamat;
    private String role;     // ADMIN, DOKTER, PERAWAT, PETUGAS, PASIEN
    private String status;   // AKTIF, NONAKTIF
    private LocalDateTime createdAt;

    public User() {
    }

    public Integer getIdPengguna() {
        return idPengguna;
    }

    public void setIdPengguna(Integer idPengguna) {
        this.idPengguna = idPengguna;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNamaLengkap() {
        return namaLengkap;
    }

    public void setNamaLengkap(String namaLengkap) {
        this.namaLengkap = namaLengkap;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNoTelepon() {
        return noTelepon;
    }

    public void setNoTelepon(String noTelepon) {
        this.noTelepon = noTelepon;
    }

    public String getAlamat() {
        return alamat;
    }

    public void setAlamat(String alamat) {
        this.alamat = alamat;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    /** Tanggal pembuatan akun dalam format dd-MM-yyyy HH:mm. */
    public String getCreatedAtTampil() {
        if (createdAt == null) {
            return "-";
        }
        return String.format("%02d-%02d-%d %02d:%02d",
                createdAt.getDayOfMonth(), createdAt.getMonthValue(), createdAt.getYear(),
                createdAt.getHour(), createdAt.getMinute());
    }
}
