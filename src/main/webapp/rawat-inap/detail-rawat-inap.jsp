<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Rawat Inap" scope="request" />
<c:set var="menuAktif" value="rawat-inap" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-hospital"></i>Rawat Inap - <c:out value="${empty data.namaPasien ? '-' : data.namaPasien}" /></h2>
            <p class="kartu-sub">Rincian pendaftaran rawat inap pasien.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/rawat-inap"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
                <a class="btn btn-warning" href="${ctx}/rawat-inap?aksi=edit&id=${data.idRawatInap}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Pasien dan Kamar</h6>
            <div class="detail-baris"><span class="label">Nomor Rawat Inap</span><span class="nilai">${empty data.idRawatInap ? '-' : data.idRawatInap}</span></div>
            <div class="detail-baris"><span class="label">Nama Pasien</span><span class="nilai">${empty data.namaPasien ? '-' : data.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">Dokter Penanggung Jawab</span><span class="nilai">${empty data.namaDokter ? 'Belum ditentukan' : data.namaDokter}</span></div>
            <div class="detail-baris"><span class="label">Ruangan</span><span class="nilai">${empty data.namaRuangan ? '-' : data.namaRuangan}</span></div>
            <div class="detail-baris"><span class="label">Jenis Ruangan</span><span class="nilai">${empty data.jenisRuangan ? '-' : data.jenisRuangan}</span></div>
            <div class="detail-baris"><span class="label">Nomor Kamar</span><span class="nilai">${empty data.nomorKamar ? '-' : data.nomorKamar}</span></div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Rincian Perawatan</h6>
            <div class="detail-baris"><span class="label">Keluhan</span><span class="nilai">${empty data.keluhan ? 'Tidak ada keluhan' : data.keluhan}</span></div>
            <div class="detail-baris"><span class="label">Diagnosa</span><span class="nilai">${empty data.diagnosa ? '-' : data.diagnosa}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Masuk</span><span class="nilai">${empty data.tanggalMasuk ? '-' : data.tanggalMasuk}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Keluar</span><span class="nilai">${empty data.tanggalKeluar ? 'Masih dirawat' : data.tanggalKeluar}</span></div>
            <div class="detail-baris"><span class="label">Lama Rawat</span><span class="nilai"><c:choose><c:when test="${empty data.lamaRawat}">Belum dihitung</c:when><c:otherwise>${data.lamaRawat} hari</c:otherwise></c:choose></span></div>
            <div class="detail-baris"><span class="label">Status Rawat Inap</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.statusRawat eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                        <c:when test="${data.statusRawat eq 'SELESAI'}"><span class="badge badge-selesai">SELESAI</span></c:when>
                        <c:when test="${data.statusRawat eq 'DIPULANGKAN'}"><span class="badge badge-pulang">DIPULANGKAN</span></c:when>
                        <c:otherwise><span class="badge badge-menunggu">MENUNGGU</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Pemeriksaan Terakhir</h2>
            <p class="kartu-sub">Maksimal 5 pemeriksaan pasien ini yang paling baru.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN' or user.role eq 'DOKTER'}">
            <c:url var="tautanPemeriksaan" value="/pemeriksaan">
                <c:param name="q" value="${data.namaPasien}" />
            </c:url>
            <a class="btn btn-outline-primary btn-sm" href="${tautanPemeriksaan}"><i class="bi bi-eye"></i>Lihat Detail</a>
        </c:if>
    </div>
    <c:choose>
        <c:when test="${empty daftarPemeriksaan}">
            <div class="kosong">
                <i class="bi bi-clipboard-x"></i>
                <h6>Belum ada data pemeriksaan</h6>
                <p class="mb-0">Pasien ini belum memiliki riwayat pemeriksaan.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>Tanggal</th>
                            <th>Dokter</th>
                            <th>Keluhan</th>
                            <th>Tekanan Darah</th>
                            <th>Suhu</th>
                            <th>Berat Badan</th>
                            <th>Diagnosa</th>
                            <th>Tindakan</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPemeriksaan}" var="pm" varStatus="loop">
                            <tr>
                                <td>${empty pm.tanggalPemeriksaan ? '-' : pm.tanggalPemeriksaan}</td>
                                <td class="fw-semibold">${empty pm.namaDokter ? '-' : pm.namaDokter}</td>
                                <td>${empty pm.keluhan ? '-' : pm.keluhan}</td>
                                <td>${empty pm.tekananDarah ? '-' : pm.tekananDarah}</td>
                                <td><c:choose><c:when test="${empty pm.suhu}">-</c:when><c:otherwise>${pm.suhu} °C</c:otherwise></c:choose></td>
                                <td><c:choose><c:when test="${empty pm.beratBadan}">-</c:when><c:otherwise>${pm.beratBadan} kg</c:otherwise></c:choose></td>
                                <td>${empty pm.diagnosa ? '-' : pm.diagnosa}</td>
                                <td>${empty pm.tindakan ? '-' : pm.tindakan}</td>
                                <td class="text-end text-nowrap">
                                    <c:if test="${user.role eq 'ADMIN' or user.role eq 'DOKTER'}">
                                        <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/pemeriksaan?aksi=detail&id=${pm.idPemeriksaan}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    </c:if>
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
            <h2 class="kartu-judul"><i class="bi bi-credit-card"></i>Pembayaran Rawat Inap</h2>
            <p class="kartu-sub">Tagihan yang terkait dengan rawat inap ini.</p>
        </div>
    </div>
    <c:choose>
        <c:when test="${empty daftarPembayaran}">
            <div class="kosong">
                <i class="bi bi-credit-card-2-front"></i>
                <h6>Belum ada pembayaran</h6>
                <p class="mb-0">Belum ada tagihan yang terhubung dengan rawat inap ini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Tanggal</th>
                            <th>Biaya Kamar</th>
                            <th>Biaya Dokter</th>
                            <th>Biaya Obat</th>
                            <th>Biaya Tindakan</th>
                            <th class="text-end">Total Biaya</th>
                            <th>Metode</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPembayaran}" var="by" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty by.tanggalPembayaran ? '-' : by.tanggalPembayaran}</td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaKamar ? 0 : by.biayaKamar}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaDokter ? 0 : by.biayaDokter}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaObat ? 0 : by.biayaObat}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaTindakan ? 0 : by.biayaTindakan}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end fw-semibold">Rp&nbsp;<fmt:formatNumber value="${empty by.totalBiaya ? 0 : by.totalBiaya}" type="number" maxFractionDigits="0" /></td>
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

<%@ include file="/fragments/footer.jspf" %>
