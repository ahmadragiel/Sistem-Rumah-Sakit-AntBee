<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Dashboard Admin" scope="request" />
<c:set var="menuAktif" value="dashboard" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="persenOkupansi" value="${kapasitasTotal > 0 ? (kapasitasTerisi * 100.0) / kapasitasTotal : 0}" />

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-people-fill"></i></div>
            <div class="min-w-0">
                <div class="angka">${totalPasien}</div>
                <div class="keterangan">Total Pasien Terdaftar</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-person-badge-fill"></i></div>
            <div class="min-w-0">
                <div class="angka">${totalDokter}</div>
                <div class="keterangan">Dokter Aktif</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-hospital"></i></div>
            <div class="min-w-0">
                <div class="angka">${kamarTersedia}</div>
                <div class="keterangan">Kamar Tersedia</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-cash-stack"></i></div>
            <div class="min-w-0">
                <div class="angka">Rp&nbsp;<fmt:formatNumber value="${totalPendapatan}" type="number" maxFractionDigits="0" /></div>
                <div class="keterangan">Pendapatan Lunas</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-6 col-xl-3">
        <div class="kartu">
            <div class="kartu-sub text-uppercase fw-semibold">Pasien Dirawat</div>
            <div class="fs-3 fw-bold mt-1">${pasienDirawat}</div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu">
            <div class="kartu-sub text-uppercase fw-semibold">Rawat Inap Aktif</div>
            <div class="fs-3 fw-bold mt-1">${rawatInapAktif}</div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu">
            <div class="kartu-sub text-uppercase fw-semibold">Pemeriksaan</div>
            <div class="fs-3 fw-bold mt-1">${totalPemeriksaan}</div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu">
            <div class="kartu-sub text-uppercase fw-semibold">Tagihan Belum Dibayar</div>
            <div class="fs-3 fw-bold mt-1">${pembayaranBelum}</div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-8">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-door-open"></i>Okupansi Kamar</h2>
                    <p class="kartu-sub">Kapasitas kamar yang sudah terisi dibanding total kapasitas.</p>
                </div>
                <a class="btn btn-primary btn-sm" href="${ctx}/ruangan">Kelola Ruangan <i class="bi bi-arrow-right"></i></a>
            </div>
            <div class="row text-center g-3">
                <div class="col-4">
                    <div class="fs-3 fw-bold text-primary">${totalRuangan}</div>
                    <div class="kartu-sub">Total Ruangan</div>
                </div>
                <div class="col-4">
                    <div class="fs-3 fw-bold text-success">${kapasitasTerisi}</div>
                    <div class="kartu-sub">Bed Terisi dari ${kapasitasTotal} Bed</div>
                </div>
                <div class="col-4">
                    <div class="fs-3 fw-bold text-warning">${kamarTerisi}</div>
                    <div class="kartu-sub">Ruangan Terisi</div>
                </div>
            </div>
            <div class="progres mt-3">
                <div class="progres-bar" style="width: <fmt:formatNumber value="${persenOkupansi}" type="number" maxFractionDigits="1" />%;"></div>
            </div>
            <p class="kartu-sub mt-2">Kapasitas rumah sakit terpakai <fmt:formatNumber value="${persenOkupansi}" type="number" maxFractionDigits="1" />%.</p>
        </div>
    </div>
    <div class="col-12 col-xl-4">
        <div class="kartu h-100">
            <h2 class="kartu-judul mb-3"><i class="bi bi-graph-up-arrow"></i>Ringkasan Layanan</h2>
            <div class="detail-baris"><span class="label">Pasien Terdaftar</span><span class="nilai">${totalPasien}</span></div>
            <div class="detail-baris"><span class="label">Rawat Inap</span><span class="nilai">${totalRawatInap}</span></div>
            <div class="detail-baris"><span class="label">Catatan Perawatan</span><span class="nilai">${totalCatatan}</span></div>
            <div class="detail-baris"><span class="label">Pembayaran</span><span class="nilai">${totalPembayaran}</span></div>
            <div class="detail-baris"><span class="label">Akun Pengguna</span><span class="nilai">${totalPengguna}</span></div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-hospital-add"></i>Rawat Inap Terbaru</h2>
            <p class="kartu-sub">Lima pendaftaran rawat inap terakhir.</p>
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
                            <th>Tanggal Masuk</th>
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
