<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Laporan Penyakit" scope="request" />
<c:set var="menuAktif" value="laporan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-file-earmark-text"></i>Laporan Penyakit</h2>
            <p class="kartu-sub">Daftar penyakit, gejala, dan tingkat keparahannya.</p>
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
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari kode atau nama penyakit...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Jenis Penyakit</label>
            <input type="text" class="form-control" id="status" name="status" value="<c:out value='${status}'/>" placeholder="Contoh: Menular">
            <div class="form-text">Kosongkan untuk menampilkan semua jenis penyakit.</div>
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
        <a class="btn btn-light" href="${ctx}/laporan?jenis=penyakit">Atur Ulang</a>
    </form>
</div>

<div class="area-cetak">
    <div class="kop">
        <img class="logo-cetak" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
        <h2>RS AntBee</h2>
        <p>Laporan Penyakit</p>
        <p>Tanggal cetak: ${empty tanggalCetak ? '-' : tanggalCetak}</p>
    </div>

    <div class="row g-3 g-xl-4 mb-1">
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-merah"><i class="bi bi-virus"></i></div>
                <div class="min-w-0">
                    <div class="angka">${fn:length(daftar)}</div>
                    <div class="keterangan">Jumlah Penyakit</div>
                </div>
            </div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kartu">
                <div class="kosong">
                    <i class="bi bi-virus"></i>
                    <h6>Belum ada data penyakit</h6>
                    <p class="mb-0">Data penyakit yang sesuai dengan filter akan tampil di sini.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Kode</th>
                            <th>Nama Penyakit</th>
                            <th>Jenis</th>
                            <th>Tingkat Keparahan</th>
                            <th>Gejala</th>
                            <th>Obat Utama</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="py" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty py.kodePenyakit ? '-' : py.kodePenyakit}</td>
                                <td class="fw-semibold">${empty py.namaPenyakit ? '-' : py.namaPenyakit}</td>
                                <td>${empty py.jenisPenyakit ? '-' : py.jenisPenyakit}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${py.tingkatKeparahan eq 'RINGAN'}"><span class="badge badge-baik">RINGAN</span></c:when>
                                        <c:when test="${py.tingkatKeparahan eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                                        <c:when test="${empty py.tingkatKeparahan}"><span class="badge badge-nonaktif">-</span></c:when>
                                        <c:otherwise><span class="badge badge-kritis">${py.tingkatKeparahan}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${empty py.gejala ? '-' : py.gejala}</td>
                                <td>${empty py.obatUtama ? '-' : py.obatUtama}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
