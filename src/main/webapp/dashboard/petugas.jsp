<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Dashboard Petugas" scope="request" />
<c:set var="menuAktif" value="dashboard" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-person-plus-fill"></i></div>
            <div class="min-w-0">
                <div class="angka">${registrasiHariIni}</div>
                <div class="keterangan">Registrasi Hari Ini</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-hospital"></i></div>
            <div class="min-w-0">
                <div class="angka">${pasienHariIni}</div>
                <div class="keterangan">Rawat Inap Hari Ini</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-credit-card"></i></div>
            <div class="min-w-0">
                <div class="angka">${pembayaranPending}</div>
                <div class="keterangan">Pembayaran Pending</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-people-fill"></i></div>
            <div class="min-w-0">
                <div class="angka">${totalPasien}</div>
                <div class="keterangan">Total Pasien</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-md-4">
        <div class="kartu h-100">
            <div class="kartu-sub text-uppercase fw-semibold">Rawat Inap Aktif</div>
            <div class="fs-3 fw-bold mt-1">${rawatInapAktif}</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="kartu h-100">
            <div class="kartu-sub text-uppercase fw-semibold">Pasien Pulang</div>
            <div class="fs-3 fw-bold mt-1">${pasienPulang}</div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="kartu h-100">
            <div class="kartu-sub text-uppercase fw-semibold">Total Pembayaran Tercatat</div>
            <div class="fs-3 fw-bold mt-1">${totalPembayaran}</div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-6">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-credit-card"></i>Pembayaran Terbaru</h2>
                    <p class="kartu-sub">Lima transaksi pembayaran terakhir.</p>
                </div>
                <a class="btn btn-primary btn-sm" href="${ctx}/pembayaran">Buka Pembayaran</a>
            </div>
            <c:choose>
                <c:when test="${empty pembayaranTerbaru}">
                    <div class="kosong">
                        <i class="bi bi-credit-card-2-front"></i>
                        <h6>Belum ada pembayaran</h6>
                        <p class="mb-0">Transaksi pembayaran yang baru dicatat akan tampil di sini.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Pasien</th>
                                    <th>Total Biaya</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${pembayaranTerbaru}" var="by">
                                    <tr>
                                        <td class="fw-semibold">${by.namaPasien}</td>
                                        <td>Rp&nbsp;<fmt:formatNumber value="${by.totalBiaya}" type="number" maxFractionDigits="0" /></td>
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
    <div class="col-12 col-xl-6">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-hospital-add"></i>Rawat Inap Terbaru</h2>
                    <p class="kartu-sub">Lima pendaftaran rawat inap terakhir.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/rawat-inap">Buka Rawat Inap</a>
            </div>
            <c:choose>
                <c:when test="${empty rawatInapTerbaru}">
                    <div class="kosong">
                        <i class="bi bi-inbox"></i>
                        <h6>Belum ada data rawat inap</h6>
                        <p class="mb-0">Data rawat inap yang baru didaftarkan akan tampil di sini.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Pasien</th>
                                    <th>Ruangan</th>
                                    <th>Masuk</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${rawatInapTerbaru}" var="r">
                                    <tr>
                                        <td class="fw-semibold">${r.namaPasien}</td>
                                        <td>${r.namaRuangan} (${r.nomorKamar})</td>
                                        <td>${r.tanggalMasuk}</td>
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
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
