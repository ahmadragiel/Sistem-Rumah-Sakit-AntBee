<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Dashboard Dokter" scope="request" />
<c:set var="menuAktif" value="dashboard" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-people-fill"></i></div>
            <div class="min-w-0">
                <div class="angka">${jumlahPasien}</div>
                <div class="keterangan">Pasien Saya</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-person-heart"></i></div>
            <div class="min-w-0">
                <div class="angka">${pasienDirawat}</div>
                <div class="keterangan">Sedang Dirawat</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-clipboard2-pulse"></i></div>
            <div class="min-w-0">
                <div class="angka">${pemeriksaanHariIni}</div>
                <div class="keterangan">Pemeriksaan Hari Ini</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-journal-medical"></i></div>
            <div class="min-w-0">
                <div class="angka">${totalPemeriksaan}</div>
                <div class="keterangan">Total Pemeriksaan</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-4">
        <div class="kartu h-100">
            <h2 class="kartu-judul mb-3"><i class="bi bi-person-badge"></i>Profil Praktik</h2>
            <div class="detail-baris"><span class="label">Nama Dokter</span><span class="nilai">${dokter.namaDokter}</span></div>
            <div class="detail-baris"><span class="label">NIP</span><span class="nilai">${dokter.nip}</span></div>
            <div class="detail-baris"><span class="label">Spesialisasi</span><span class="nilai">${dokter.spesialisasi}</span></div>
            <div class="detail-baris"><span class="label">Jadwal Praktik</span><span class="nilai">${jadwalPraktik}</span></div>
            <div class="detail-baris"><span class="label">Status</span>
                <span class="nilai"><span class="badge ${dokter.status eq 'AKTIF' ? 'badge-aktif' : 'badge-nonaktif'}">${dokter.status}</span></span>
            </div>
        </div>
    </div>
    <div class="col-12 col-xl-8">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Pemeriksaan Terbaru</h2>
                    <p class="kartu-sub">Lima pemeriksaan terakhir yang Anda tangani.</p>
                </div>
                <a class="btn btn-primary btn-sm" href="${ctx}/pemeriksaan">Buka Pemeriksaan <i class="bi bi-arrow-right"></i></a>
            </div>
            <c:choose>
                <c:when test="${empty pemeriksaanTerbaru}">
                    <div class="kosong">
                        <i class="bi bi-clipboard-x"></i>
                        <h6>Belum ada pemeriksaan</h6>
                        <p class="mb-0">Pemeriksaan yang Anda catat akan tampil di sini.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Tanggal</th>
                                    <th>Pasien</th>
                                    <th>Keluhan</th>
                                    <th>Diagnosa</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${pemeriksaanTerbaru}" var="p">
                                    <tr>
                                        <td>${p.tanggalPemeriksaan}</td>
                                        <td class="fw-semibold">${p.namaPasien}</td>
                                        <td>${p.keluhan}</td>
                                        <td>${p.diagnosa}</td>
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

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-6">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-people"></i>Pasien Ditangani</h2>
                    <p class="kartu-sub">Daftar pasien yang terdaftar atas nama Anda.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/pasien">Lihat Semua</a>
            </div>
            <c:choose>
                <c:when test="${empty daftarPasien}">
                    <div class="kosong">
                        <i class="bi bi-person-x"></i>
                        <h6>Belum ada pasien</h6>
                        <p class="mb-0">Belum ada pasien yang ditangani oleh Anda.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>NIK</th>
                                    <th>Nama Pasien</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${daftarPasien}" var="p">
                                    <tr>
                                        <td>${p.nik}</td>
                                        <td class="fw-semibold">${p.namaPasien}</td>
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
    </div>
    <div class="col-12 col-xl-6">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-hospital"></i>Rawat Inap Pasien Saya</h2>
                    <p class="kartu-sub">Riwayat rawat inap pasien yang ditangani.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/rawat-inap">Lihat Semua</a>
            </div>
            <c:choose>
                <c:when test="${empty rawatInapTerbaru}">
                    <div class="kosong">
                        <i class="bi bi-bed"></i>
                        <h6>Belum ada rawat inap</h6>
                        <p class="mb-0">Belum ada pasien Anda yang menjalani rawat inap.</p>
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
