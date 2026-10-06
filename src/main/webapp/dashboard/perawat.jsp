<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Dashboard Perawat" scope="request" />
<c:set var="menuAktif" value="dashboard" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="persenOkupansi" value="${kapasitasTotal > 0 ? (kapasitasTerisi * 100.0) / kapasitasTotal : 0}" />

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-person-bed"></i></div>
            <div class="min-w-0">
                <div class="angka">${pasienRawatInap}</div>
                <div class="keterangan">Pasien Rawat Inap</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-door-open"></i></div>
            <div class="min-w-0">
                <div class="angka">${kamarTersedia}</div>
                <div class="keterangan">Kamar Tersedia</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-person-plus"></i></div>
            <div class="min-w-0">
                <div class="angka">${pasienBaru}</div>
                <div class="keterangan">Pasien Masuk Hari Ini</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-journal-medical"></i></div>
            <div class="min-w-0">
                <div class="angka">${catatanSaya}</div>
                <div class="keterangan">Catatan Saya</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-5">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-hospital"></i>Okupansi Kamar</h2>
                    <p class="kartu-sub">Jumlah bed terisi dari seluruh kapasitas rumah sakit.</p>
                </div>
                <a class="btn btn-primary btn-sm" href="${ctx}/ruangan">Ruangan</a>
            </div>
            <div class="row text-center g-3">
                <div class="col-4">
                    <div class="fs-3 fw-bold text-primary">${kamarTerisi}</div>
                    <div class="kartu-sub">Ruangan Terisi</div>
                </div>
                <div class="col-4">
                    <div class="fs-3 fw-bold text-success">${kapasitasTerisi}</div>
                    <div class="kartu-sub">Bed Terisi</div>
                </div>
                <div class="col-4">
                    <div class="fs-3 fw-bold text-warning">${kapasitasTotal}</div>
                    <div class="kartu-sub">Total Bed</div>
                </div>
            </div>
            <div class="progres mt-3">
                <div class="progres-bar" style="width: <fmt:formatNumber value="${persenOkupansi}" type="number" maxFractionDigits="1" />%;"></div>
            </div>
            <p class="kartu-sub mt-2">Kapasitas terpakai <fmt:formatNumber value="${persenOkupansi}" type="number" maxFractionDigits="1" />%.</p>
        </div>
    </div>
    <div class="col-12 col-xl-7">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-journal-medical"></i>Catatan Perawatan Terbaru</h2>
                    <p class="kartu-sub">Lima catatan perawatan terakhir di ruangan.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/catatan-perawatan">Buka Catatan</a>
            </div>
            <c:choose>
                <c:when test="${empty catatanTerbaru}">
                    <div class="kosong">
                        <i class="bi bi-journal-x"></i>
                        <h6>Belum ada catatan perawatan</h6>
                        <p class="mb-0">Catat kondisi pasien terlebih dahulu.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Tanggal</th>
                                    <th>Pasien</th>
                                    <th>Perawat</th>
                                    <th>Kondisi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${catatanTerbaru}" var="ct">
                                    <tr>
                                        <td>${ct.tanggal}</td>
                                        <td class="fw-semibold">${ct.namaPasien}</td>
                                        <td>${ct.namaPerawat}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${ct.status eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                                                <c:when test="${ct.status eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                                                <c:otherwise><span class="badge badge-baik">BAIK</span></c:otherwise>
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

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-hospital-add"></i>Rawat Inap Terbaru</h2>
            <p class="kartu-sub">Pendaftaran rawat inap terbaru di rumah sakit.</p>
        </div>
        <a class="btn btn-outline-primary btn-sm" href="${ctx}/rawat-inap">Lihat Semua</a>
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
                            <th>Dokter</th>
                            <th>Masuk</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${rawatInapTerbaru}" var="r">
                            <tr>
                                <td class="fw-semibold">${r.namaPasien}</td>
                                <td>${r.namaRuangan} (${r.nomorKamar})</td>
                                <td>${r.namaDokter}</td>
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

<%@ include file="/fragments/footer.jspf" %>
