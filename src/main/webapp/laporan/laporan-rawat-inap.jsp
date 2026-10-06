<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Laporan Rawat Inap" scope="request" />
<c:set var="menuAktif" value="laporan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-file-earmark-text"></i>Laporan Rawat Inap</h2>
            <p class="kartu-sub">Riwayat rawat inap pasien berdasarkan rentang tanggal masuk.</p>
        </div>
        <button class="btn btn-primary tombol-print" onclick="window.print()"><i class="bi bi-printer"></i>Cetak Laporan</button>
    </div>

    <form class="baris-filter" method="get" action="${ctx}/laporan">
        <div class="grup">
            <label class="form-label" for="jenis">Jenis Laporan</label>
            <select class="form-select" id="jenis" name="jenis">
                <option value="pasien" <c:if test="${jenis eq 'pasien'}">selected</c:if>>Laporan Pasien</option>
                <option value="dokter" <c:if test="${jenis eq 'dokter'}">selected</c:if>>Laporan Dokter</option>
                <option value="rawat-inap" <c:if test="${jenis eq 'rawat-inap'}">selected</c:if>>Laporan Rawat Inap</option>
                <option value="penyakit" <c:if test="${jenis eq 'penyakit'}">selected</c:if>>Laporan Penyakit</option>
                <option value="pembayaran" <c:if test="${jenis eq 'pembayaran'}">selected</c:if>>Laporan Pembayaran</option>
                <option value="ruangan" <c:if test="${jenis eq 'ruangan'}">selected</c:if>>Laporan Ruangan</option>
            </select>
        </div>
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien atau nomor kamar...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Rawat</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="MENUNGGU" <c:if test="${status eq 'MENUNGGU'}">selected</c:if>>Menunggu</option>
                <option value="DIRAWAT" <c:if test="${status eq 'DIRAWAT'}">selected</c:if>>Dirawat</option>
                <option value="SELESAI" <c:if test="${status eq 'SELESAI'}">selected</c:if>>Selesai</option>
                <option value="DIPULANGKAN" <c:if test="${status eq 'DIPULANGKAN'}">selected</c:if>>Dipulangkan</option>
            </select>
        </div>
        <div class="grup">
            <label class="form-label" for="dari">Tanggal Dari</label>
            <input type="date" class="form-control" id="dari" name="dari" value="<c:out value='${dari}'/>">
        </div>
        <div class="grup">
            <label class="form-label" for="sampai">Tanggal Sampai</label>
            <input type="date" class="form-control" id="sampai" name="sampai" value="<c:out value='${sampai}'/>">
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/laporan?jenis=rawat-inap">Atur Ulang</a>
    </form>
</div>

<div class="area-cetak">
    <div class="kop">
        <img class="logo-cetak" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
        <h2>RS AntBee</h2>
        <p>Laporan Rawat Inap</p>
        <p>Tanggal cetak: ${empty tanggalCetak ? '-' : tanggalCetak}</p>
    </div>

    <div class="row g-3 g-xl-4 mb-1">
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-kuning"><i class="bi bi-hospital"></i></div>
                <div class="min-w-0">
                    <div class="angka">${fn:length(daftar)}</div>
                    <div class="keterangan">Jumlah Rawat Inap</div>
                </div>
            </div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kartu">
                <div class="kosong">
                    <i class="bi bi-bed"></i>
                    <h6>Belum ada data rawat inap</h6>
                    <p class="mb-0">Data rawat inap yang sesuai dengan filter akan tampil di sini.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Pasien</th>
                            <th>Ruangan</th>
                            <th>Jenis Ruangan</th>
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
                        <c:forEach items="${daftar}" var="r" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="fw-semibold">${empty r.namaPasien ? '-' : r.namaPasien}</td>
                                <td>${empty r.namaRuangan ? '-' : r.namaRuangan}</td>
                                <td>${empty r.jenisRuangan ? '-' : r.jenisRuangan}</td>
                                <td>${empty r.nomorKamar ? '-' : r.nomorKamar}</td>
                                <td>${empty r.namaDokter ? '-' : r.namaDokter}</td>
                                <td>${empty r.diagnosa ? '-' : r.diagnosa}</td>
                                <td>${empty r.tanggalMasuk ? '-' : r.tanggalMasuk}</td>
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

<%@ include file="/fragments/footer.jspf" %>
