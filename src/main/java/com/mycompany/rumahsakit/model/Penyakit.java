package com.mycompany.rumahsakit.model;

/** Model untuk tabel penyakit (kamus penyakit). */
public class Penyakit {

    private Integer idPenyakit;
    private String kodePenyakit;
    private String namaPenyakit;
    private String jenisPenyakit;
    private String gejala;
    private String penyebab;
    private String tingkatKeparahan;
    private String penanganan;
    private String obatUtama;
    private String keterangan;

    public Penyakit() {
    }

    public Integer getIdPenyakit() {
        return idPenyakit;
    }

    public void setIdPenyakit(Integer idPenyakit) {
        this.idPenyakit = idPenyakit;
    }

    public String getKodePenyakit() {
        return kodePenyakit;
    }

    public void setKodePenyakit(String kodePenyakit) {
        this.kodePenyakit = kodePenyakit;
    }

    public String getNamaPenyakit() {
        return namaPenyakit;
    }

    public void setNamaPenyakit(String namaPenyakit) {
        this.namaPenyakit = namaPenyakit;
    }

    public String getJenisPenyakit() {
        return jenisPenyakit;
    }

    public void setJenisPenyakit(String jenisPenyakit) {
        this.jenisPenyakit = jenisPenyakit;
    }

    public String getGejala() {
        return gejala;
    }

    public void setGejala(String gejala) {
        this.gejala = gejala;
    }

    public String getPenyebab() {
        return penyebab;
    }

    public void setPenyebab(String penyebab) {
        this.penyebab = penyebab;
    }

    public String getTingkatKeparahan() {
        return tingkatKeparahan;
    }

    public void setTingkatKeparahan(String tingkatKeparahan) {
        this.tingkatKeparahan = tingkatKeparahan;
    }

    public String getPenanganan() {
        return penanganan;
    }

    public void setPenanganan(String penanganan) {
        this.penanganan = penanganan;
    }

    public String getObatUtama() {
        return obatUtama;
    }

    public void setObatUtama(String obatUtama) {
        this.obatUtama = obatUtama;
    }

    public String getKeterangan() {
        return keterangan;
    }

    public void setKeterangan(String keterangan) {
        this.keterangan = keterangan;
    }
}
