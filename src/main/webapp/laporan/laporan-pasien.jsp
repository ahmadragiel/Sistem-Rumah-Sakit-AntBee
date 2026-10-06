<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Laporan Pasien" scope="request" />
<c:set var="menuAktif" value="laporan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-file-earmark-text"></i>Laporan Pasien</h2>
            <p class="kartu-sub">Rekapitulasi data pasien berdasarkan pencarian dan filter yang dipilih.</p>
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
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien, NIK, atau nama dokter...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Pasien</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="RAWAT JALAN" <c:if test="${status eq 'RAWAT JALAN'}">selected</c:if>>Rawat Jalan</option>
                <option value="DIRAWAT" <c:if test="${status eq 'DIRAWAT'}">selected</c:if>>Dirawat</option>
                <option value="PULANG" <c:if test="${status eq 'PULANG'}">selected</c:if>>Pulang</option>
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
        <a class="btn btn-light" href="${ctx}/laporan?jenis=pasien">Atur Ulang</a>
    </form>
</div>

<div class="area-cetak">
    <div class="kop">
        <img class="logo-cetak" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
        <h2>RS AntBee</h2>
        <p>Laporan Pasien</p>
        <p>Tanggal cetak: ${empty tanggalCetak ? '-' : tanggalCetak}</p>
    </div>

    <div class="row g-3 g-xl-4 mb-1">
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-biru"><i class="bi bi-people-fill"></i></div>
                <div class="min-w-0">
                    <div class="angka">${fn:length(daftar)}</div>
                    <div class="keterangan">Jumlah Pasien</div>
                </div>
            </div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kartu">
                <div class="kosong">
                    <i class="bi bi-people"></i>
                    <h6>Belum ada data pasien</h6>
                    <p class="mb-0">Data pasien yang sesuai dengan filter akan tampil di sini.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>NIK</th>
                            <th>Nama Pasien</th>
                            <th>Jenis Kelamin</th>
                            <th>Gol. Darah</th>
                            <th>No. Telepon</th>
                            <th>Dokter</th>
                            <th>Penyakit</th>
                            <th>Tanggal Masuk</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="p" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty p.nik ? '-' : p.nik}</td>
                                <td class="fw-semibold">${empty p.namaPasien ? '-' : p.namaPasien}</td>
                                <td>${empty p.jenisKelamin ? '-' : p.jenisKelamin}</td>
                                <td>${empty p.golonganDarah ? '-' : p.golonganDarah}</td>
                                <td>${empty p.noTelepon ? '-' : p.noTelepon}</td>
                                <td>${empty p.namaDokter ? '-' : p.namaDokter}</td>
                                <td>${empty p.namaPenyakit ? '-' : p.namaPenyakit}</td>
                                <td>${empty p.tanggalMasuk ? '-' : p.tanggalMasuk}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.statusPasien eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${p.statusPasien eq 'PULANG'}"><span class="badge badge-pulang">PULANG</span></c:when>
                                        <c:otherwise><span class="badge badge-rawatjalan">RAWAT JALAN</span></c:otherwise>
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
