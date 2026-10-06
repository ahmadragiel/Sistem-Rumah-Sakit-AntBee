package com.mycompany.rumahsakit.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/** Model untuk tabel pembayaran. */
public class Pembayaran {

    private Integer idPembayaran;
    private Integer idPasien;
    private Integer idRawatInap;
    private BigDecimal biayaKamar;
    private BigDecimal biayaDokter;
    private BigDecimal biayaObat;
    private BigDecimal biayaTindakan;
    private BigDecimal biayaLain;
    private BigDecimal totalBiaya;
    private String metodePembayaran;
    private LocalDate tanggalPembayaran;
    private String statusPembayaran; // BELUM DIBAYAR, MENUNGGU, LUNAS

    // Data tambahan hasil JOIN
    private String namaPasien;
    private String nomorKamar;

    public Pembayaran() {
    }

    public Integer getIdPembayaran() {
        return idPembayaran;
    }

    public void setIdPembayaran(Integer idPembayaran) {
        this.idPembayaran = idPembayaran;
    }

    public Integer getIdPasien() {
        return idPasien;
    }

    public void setIdPasien(Integer idPasien) {
        this.idPasien = idPasien;
    }

    public Integer getIdRawatInap() {
        return idRawatInap;
    }

    public void setIdRawatInap(Integer idRawatInap) {
        this.idRawatInap = idRawatInap;
    }

    public BigDecimal getBiayaKamar() {
        return biayaKamar;
    }

    public void setBiayaKamar(BigDecimal biayaKamar) {
        this.biayaKamar = biayaKamar;
    }

    public BigDecimal getBiayaDokter() {
        return biayaDokter;
    }

    public void setBiayaDokter(BigDecimal biayaDokter) {
        this.biayaDokter = biayaDokter;
    }

    public BigDecimal getBiayaObat() {
        return biayaObat;
    }

    public void setBiayaObat(BigDecimal biayaObat) {
        this.biayaObat = biayaObat;
    }

    public BigDecimal getBiayaTindakan() {
        return biayaTindakan;
    }

    public void setBiayaTindakan(BigDecimal biayaTindakan) {
        this.biayaTindakan = biayaTindakan;
    }

    public BigDecimal getBiayaLain() {
        return biayaLain;
    }

    public void setBiayaLain(BigDecimal biayaLain) {
        this.biayaLain = biayaLain;
    }

    public BigDecimal getTotalBiaya() {
        return totalBiaya;
    }

    public void setTotalBiaya(BigDecimal totalBiaya) {
        this.totalBiaya = totalBiaya;
    }

    public String getMetodePembayaran() {
        return metodePembayaran;
    }

    public void setMetodePembayaran(String metodePembayaran) {
        this.metodePembayaran = metodePembayaran;
    }

    public LocalDate getTanggalPembayaran() {
        return tanggalPembayaran;
    }

    public void setTanggalPembayaran(LocalDate tanggalPembayaran) {
        this.tanggalPembayaran = tanggalPembayaran;
    }

    public String getStatusPembayaran() {
        return statusPembayaran;
    }

    public void setStatusPembayaran(String statusPembayaran) {
        this.statusPembayaran = statusPembayaran;
    }

    public String getNamaPasien() {
        return namaPasien;
    }

    public void setNamaPasien(String namaPasien) {
        this.namaPasien = namaPasien;
    }

    public String getNomorKamar() {
        return nomorKamar;
    }

    public void setNomorKamar(String nomorKamar) {
        this.nomorKamar = nomorKamar;
    }

    /** Menghitung total biaya dari seluruh komponen (dihitung sistem, bukan input user). */
    public BigDecimal hitungTotal() {
        BigDecimal total = BigDecimal.ZERO;
        total = total.add(nol(biayaKamar));
        total = total.add(nol(biayaDokter));
        total = total.add(nol(biayaObat));
        total = total.add(nol(biayaTindakan));
        total = total.add(nol(biayaLain));
        return total;
    }

    private static BigDecimal nol(BigDecimal nilai) {
        return nilai == null ? BigDecimal.ZERO : nilai;
    }
}
