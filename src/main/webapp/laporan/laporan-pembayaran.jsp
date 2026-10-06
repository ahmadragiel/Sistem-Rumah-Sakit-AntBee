<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Laporan Pembayaran" scope="request" />
<c:set var="menuAktif" value="laporan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-file-earmark-text"></i>Laporan Pembayaran</h2>
            <p class="kartu-sub">Rincian tagihan pasien berdasarkan rentang tanggal pembayaran.</p>
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
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien, metode, atau nomor kamar...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Pembayaran</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="BELUM DIBAYAR" <c:if test="${status eq 'BELUM DIBAYAR'}">selected</c:if>>Belum Dibayar</option>
                <option value="MENUNGGU" <c:if test="${status eq 'MENUNGGU'}">selected</c:if>>Menunggu</option>
                <option value="LUNAS" <c:if test="${status eq 'LUNAS'}">selected</c:if>>Lunas</option>
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
        <a class="btn btn-light" href="${ctx}/laporan?jenis=pembayaran">Atur Ulang</a>
    </form>
</div>

<div class="area-cetak">
    <div class="kop">
        <img class="logo-cetak" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
        <h2>RS AntBee</h2>
        <p>Laporan Pembayaran</p>
        <p>Tanggal cetak: ${empty tanggalCetak ? '-' : tanggalCetak}</p>
    </div>

    <div class="row g-3 g-xl-4 mb-1">
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-biru"><i class="bi bi-receipt"></i></div>
                <div class="min-w-0">
                    <div class="angka">${fn:length(daftar)}</div>
                    <div class="keterangan">Jumlah Tagihan</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-xl-3">
            <div class="kartu kartu-stat h-100">
                <div class="ikon-kotak ikon-hijau"><i class="bi bi-cash-stack"></i></div>
                <div class="min-w-0">
                    <div class="angka">Rp&nbsp;<fmt:formatNumber value="${empty totalBiaya ? 0 : totalBiaya}" type="number" maxFractionDigits="0" /></div>
                    <div class="keterangan">Total Seluruh Biaya</div>
                </div>
            </div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kartu">
                <div class="kosong">
                    <i class="bi bi-credit-card-2-front"></i>
                    <h6>Belum ada data pembayaran</h6>
                    <p class="mb-0">Data pembayaran yang sesuai dengan filter akan tampil di sini.</p>
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
                            <th>Nomor Kamar</th>
                            <th>Biaya Kamar</th>
                            <th>Biaya Dokter</th>
                            <th>Biaya Obat</th>
                            <th>Biaya Tindakan</th>
                            <th>Biaya Lain</th>
                            <th>Total Biaya</th>
                            <th>Metode</th>
                            <th>Tanggal</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="by" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="fw-semibold">${empty by.namaPasien ? '-' : by.namaPasien}</td>
                                <td>${empty by.nomorKamar ? '-' : by.nomorKamar}</td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaKamar ? 0 : by.biayaKamar}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaDokter ? 0 : by.biayaDokter}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaObat ? 0 : by.biayaObat}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaTindakan ? 0 : by.biayaTindakan}" type="number" maxFractionDigits="0" /></td>
                                <td>Rp&nbsp;<fmt:formatNumber value="${empty by.biayaLain ? 0 : by.biayaLain}" type="number" maxFractionDigits="0" /></td>
                                <td class="fw-semibold">Rp&nbsp;<fmt:formatNumber value="${empty by.totalBiaya ? 0 : by.totalBiaya}" type="number" maxFractionDigits="0" /></td>
                                <td>${empty by.metodePembayaran ? '-' : by.metodePembayaran}</td>
                                <td>${empty by.tanggalPembayaran ? '-' : by.tanggalPembayaran}</td>
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
