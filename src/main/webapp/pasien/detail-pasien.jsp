<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Pasien" scope="request" />
<c:set var="menuAktif" value="pasien" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-person-vcard"></i><c:out value="${data.namaPasien}" /></h2>
            <p class="kartu-sub">Profil lengkap dan riwayat layanan pasien.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/pasien"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
                <a class="btn btn-warning" href="${ctx}/pasien?aksi=edit&id=${data.idPasien}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Identitas Pasien</h6>
            <div class="detail-baris"><span class="label">NIK</span><span class="nilai">${data.nik}</span></div>
            <div class="detail-baris"><span class="label">Nama Lengkap</span><span class="nilai">${data.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">Jenis Kelamin</span><span class="nilai">${data.jenisKelamin}</span></div>
            <div class="detail-baris"><span class="label">Tempat, Tanggal Lahir</span><span class="nilai">${data.tempatLahir}, ${data.tanggalLahir}</span></div>
            <div class="detail-baris"><span class="label">Golongan Darah</span><span class="nilai">${empty data.golonganDarah ? '-' : data.golonganDarah}</span></div>
            <div class="detail-baris"><span class="label">No. Telepon</span><span class="nilai">${data.noTelepon}</span></div>
            <div class="detail-baris"><span class="label">Alamat</span><span class="nilai">${data.alamat}</span></div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Layanan</h6>
            <div class="detail-baris"><span class="label">Penyakit</span><span class="nilai">${empty data.namaPenyakit ? 'Belum terdiagnosis' : data.namaPenyakit}</span></div>
            <div class="detail-baris"><span class="label">Dokter Penanggung Jawab</span><span class="nilai">${empty data.namaDokter ? 'Belum ditentukan' : data.namaDokter}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Masuk</span><span class="nilai">${data.tanggalMasuk}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Keluar</span><span class="nilai">${empty data.tanggalKeluar ? 'Masih berada di rumah sakit' : data.tanggalKeluar}</span></div>
            <div class="detail-baris"><span class="label">Akun Login</span><span class="nilai">${empty data.username ? 'Tidak memiliki akun' : data.username}</span></div>
            <div class="detail-baris"><span class="label">Status Pasien</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.statusPasien eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                        <c:when test="${data.statusPasien eq 'PULANG'}"><span class="badge badge-pulang">PULANG</span></c:when>
                        <c:otherwise><span class="badge badge-rawatjalan">RAWAT JALAN</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-hospital"></i>Riwayat Rawat Inap</h2>
            <p class="kartu-sub">Total ${fn:length(riwayatRawatInap)} data rawat inap.</p>
        </div>
    </div>
    <c:choose>
        <c:when test="${empty riwayatRawatInap}">
            <div class="kosong"><i class="bi bi-bed"></i><h6>Belum ada riwayat rawat inap</h6><p class="mb-0">Pasien ini belum pernah menjalani rawat inap.</p></div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Ruangan</th>
                            <th>Nomor Kamar</th>
                            <th>Dokter</th>
                            <th>Diagnosa</th>
                            <th>Masuk</th>
                            <th>Keluar</th>
                            <th>Lama</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${riwayatRawatInap}" var="r">
                            <tr>
                                <td class="fw-semibold">${r.namaRuangan}</td>
                                <td>${r.nomorKamar}</td>
                                <td>${r.namaDokter}</td>
                                <td>${r.diagnosa}</td>
                                <td>${r.tanggalMasuk}</td>
                                <td>${empty r.tanggalKeluar ? '-' : r.tanggalKeluar}</td>
                                <td>${empty r.lamaRawat ? '-' : r.lamaRawat} hari</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.statusRawat eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${r.statusRawat eq 'SELESAI'}"><span class="badge badge-selesai">SELESAI</span></c:when>
                                        <c:when test="${r.statusRawat eq 'DIPULANGKAN'}"><span class="badge badge-pulang">DIPULANGKAN</span></c:when>
                                        <c:otherwise><span class="badge badge-menunggu">MENUNGGU</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Riwayat Pemeriksaan</h2>
            <p class="kartu-sub">Total ${fn:length(riwayatPemeriksaan)} data pemeriksaan.</p>
        </div>
    </div>
    <c:choose>
        <c:when test="${empty riwayatPemeriksaan}">
            <div class="kosong"><i class="bi bi-clipboard-x"></i><h6>Belum ada riwayat pemeriksaan</h6><p class="mb-0">Pasien ini belum pernah diperiksa.</p></div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Tanggal</th>
                            <th>Dokter</th>
                            <th>Keluhan</th>
                            <th>Tekanan</th>
                            <th>Suhu</th>
                            <th>Berat Badan</th>
                            <th>Diagnosa</th>
                            <th>Tindakan</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${riwayatPemeriksaan}" var="pm">
                            <tr>
                                <td>${pm.tanggalPemeriksaan}</td>
                                <td class="fw-semibold">${pm.namaDokter}</td>
                                <td>${pm.keluhan}</td>
                                <td>${pm.tekananDarah}</td>
                                <td>${pm.suhu} °C</td>
                                <td>${pm.beratBadan} kg</td>
                                <td>${pm.diagnosa}</td>
                                <td>${pm.tindakan}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="row g-3 g-xl-4">
    <div class="col-xl-6">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-journal-medical"></i>Catatan Perawatan</h2>
                    <p class="kartu-sub">Total ${fn:length(riwayatCatatan)} catatan.</p>
                </div>
            </div>
            <c:choose>
                <c:when test="${empty riwayatCatatan}">
                    <div class="kosong"><i class="bi bi-journal-x"></i><h6>Belum ada catatan</h6><p class="mb-0">Belum ada perawat yang mencatat kondisi pasien ini.</p></div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Tanggal</th>
                                    <th>Perawat</th>
                                    <th>Kondisi</th>
                                    <th>Tindakan</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${riwayatCatatan}" var="ct">
                                    <tr>
                                        <td>${ct.tanggal}</td>
                                        <td class="fw-semibold">${ct.namaPerawat}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ct.status eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                                                <c:when test="${ct.status eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                                                <c:otherwise><span class="badge badge-baik">BAIK</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${ct.tindakan}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="col-xl-6">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-credit-card"></i>Riwayat Pembayaran</h2>
                    <p class="kartu-sub">Total ${fn:length(riwayatPembayaran)} tagihan.</p>
                </div>
            </div>
            <c:choose>
                <c:when test="${empty riwayatPembayaran}">
                    <div class="kosong"><i class="bi bi-credit-card-2-front"></i><h6>Belum ada pembayaran</h6><p class="mb-0">Pasien ini belum memiliki tagihan.</p></div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Tanggal</th>
                                    <th>Total Biaya</th>
                                    <th>Metode</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${riwayatPembayaran}" var="by">
                                    <tr>
                                        <td>${empty by.tanggalPembayaran ? '-' : by.tanggalPembayaran}</td>
                                        <td class="fw-semibold">Rp&nbsp;<fmt:formatNumber value="${by.totalBiaya}" type="number" maxFractionDigits="0" /></td>
                                        <td>${empty by.metodePembayaran ? '-' : by.metodePembayaran}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${by.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                                                <c:when test="${by.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                                                <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
