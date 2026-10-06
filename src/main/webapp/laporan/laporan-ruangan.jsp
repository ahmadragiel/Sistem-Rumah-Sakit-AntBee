<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Laporan Ruangan" scope="request" />
<c:set var="menuAktif" value="laporan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-file-earmark-text"></i>Laporan Ruangan</h2>
            <p class="kartu-sub">Data ruangan, kapasitas kamar, dan status pemanfaatannya.</p>
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
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama ruangan, nomor kamar, atau fasilitas...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Ruangan</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="TERSEDIA" <c:if test="${status eq 'TERSEDIA'}">selected</c:if>>Tersedia</option>
                <option value="TERISI" <c:if test="${status eq 'TERISI'}">selected</c:if>>Terisi</option>
                <option value="PERAWATAN" <c:if test="${status eq 'PERAWATAN'}">selected</c:if>>Perawatan</option>
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
        <a class="btn btn-light" href="${ctx}/laporan?jenis=ruangan">Atur Ulang</a>
    </form>
</div>

<div class="area-cetak">
    <div class="kop">
        <img class="logo-cetak" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
        <h2>RS AntBee</h2>
        <p>Laporan Ruangan</p>
        <p>Tanggal cetak: ${empty tanggalCetak ? '-' : tanggalCetak}</p>
    </div>

    <div class="row g-3 g-xl-4 mb-1">
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-biru"><i class="bi bi-door-open"></i></div>
                <div class="min-w-0">
                    <div class="angka">${fn:length(daftar)}</div>
                    <div class="keterangan">Jumlah Ruangan</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-hijau"><i class="bi bi-check2-circle"></i></div>
                <div class="min-w-0">
                    <div class="angka">${empty totalKamarTersedia ? 0 : totalKamarTersedia}</div>
                    <div class="keterangan">Kamar Tersedia</div>
                </div>
            </div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kartu">
                <div class="kosong">
                    <i class="bi bi-door-closed"></i>
                    <h6>Belum ada data ruangan</h6>
                    <p class="mb-0">Data ruangan yang sesuai dengan filter akan tampil di sini.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Nama Ruangan</th>
                            <th>Jenis</th>
                            <th>Nomor Kamar</th>
                            <th>Lantai</th>
                            <th>Kapasitas</th>
                            <th>Terisi</th>
                            <th>Tarif per Hari</th>
                            <th>Fasilitas</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="r" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="fw-semibold">${empty r.namaRuangan ? '-' : r.namaRuangan}</td>
                                <td>${empty r.jenisRuangan ? '-' : r.jenisRuangan}</td>
                                <td>${empty r.nomorKamar ? '-' : r.nomorKamar}</td>
                                <td>${empty r.lantai ? '-' : r.lantai}</td>
                                <td>${empty r.kapasitas ? '-' : r.kapasitas}</td>
                                <td>${empty r.jumlahTerisi ? '-' : r.jumlahTerisi}</td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty r.tarifPerHari ? 0 : r.tarifPerHari}" type="number" maxFractionDigits="0" /></td>
                                <td>${empty r.fasilitas ? '-' : r.fasilitas}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.statusRuangan eq 'TERSEDIA'}"><span class="badge badge-aktif">TERSEDIA</span></c:when>
                                        <c:when test="${r.statusRuangan eq 'TERISI'}"><span class="badge badge-dirawat">TERISI</span></c:when>
                                        <c:when test="${r.statusRuangan eq 'PERAWATAN'}"><span class="badge badge-menunggu">PERAWATAN</span></c:when>
                                        <c:otherwise><span class="badge badge-nonaktif">-</span></c:otherwise>
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
