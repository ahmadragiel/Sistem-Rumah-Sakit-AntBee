<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Jadwal dan Layanan Saya" scope="request" />
<c:set var="menuAktif" value="jadwal" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-calendar-check"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(jadwal)}</div>
                <div class="keterangan">Jadwal Pemeriksaan Mendatang</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-receipt"></i></div>
            <div class="min-w-0">
                <div class="angka">
                    <c:choose>
                        <c:when test="${not empty tagihanBelum}">Rp&nbsp;<fmt:formatNumber value="${tagihanBelum}" type="number" maxFractionDigits="0" /></c:when>
                        <c:otherwise>&mdash;</c:otherwise>
                    </c:choose>
                </div>
                <div class="keterangan">Tagihan Belum Lunas &middot; <a href="${ctx}/saya?aksi=tagihan">Lihat Tagihan</a></div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-person-check"></i></div>
            <div class="min-w-0">
                <div class="angka">${empty pasien.statusPasien ? '-' : pasien.statusPasien}</div>
                <div class="keterangan">Status Anda Saat Ini</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-5">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-person-vcard"></i>Data Diri Anda</h2>
                    <p class="kartu-sub">Identitas yang terdaftar pada rumah sakit.</p>
                </div>
            </div>
            <div class="detail-baris"><span class="label">NIK</span><span class="nilai">${pasien.nik}</span></div>
            <div class="detail-baris"><span class="label">Nama Lengkap</span><span class="nilai">${pasien.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">Jenis Kelamin</span><span class="nilai">${pasien.jenisKelamin}</span></div>
            <div class="detail-baris"><span class="label">Tempat, Tanggal Lahir</span><span class="nilai">${pasien.tempatLahir}, ${pasien.tanggalLahir}</span></div>
            <div class="detail-baris"><span class="label">Golongan Darah</span><span class="nilai">${empty pasien.golonganDarah ? '-' : pasien.golonganDarah}</span></div>
            <div class="detail-baris"><span class="label">No. Telepon</span><span class="nilai">${empty pasien.noTelepon ? '-' : pasien.noTelepon}</span></div>
            <div class="detail-baris"><span class="label">Penyakit</span><span class="nilai">${empty pasien.namaPenyakit ? 'Belum terdiagnosis' : pasien.namaPenyakit}</span></div>
            <div class="detail-baris"><span class="label">Dokter Penanggung Jawab</span><span class="nilai"><c:out value="${empty dokterPenanggung ? 'Belum ditentukan' : dokterPenanggung.namaDokter}" /></span></div>
            <div class="detail-baris"><span class="label">Tanggal Masuk</span><span class="nilai">${pasien.tanggalMasuk}</span></div>
            <div class="detail-baris"><span class="label">Status</span>
                <span class="nilai"><span class="badge ${pasien.statusPasien eq 'DIRAWAT' ? 'badge-dirawat' : (pasien.statusPasien eq 'PULANG' ? 'badge-pulang' : 'badge-rawatjalan')}">${empty pasien.statusPasien ? '-' : pasien.statusPasien}</span></span>
            </div>
        </div>
    </div>
    <div class="col-12 col-xl-7">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-calendar-week"></i>Jadwal Pemeriksaan Mendatang</h2>
                    <p class="kartu-sub">Terdapat <strong>${fn:length(jadwal)}</strong> jadwal pemeriksaan untuk Anda.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=pemeriksaan">Riwayat Pemeriksaan</a>
            </div>
            <c:choose>
                <c:when test="${empty jadwal}">
                    <div class="kosong">
                        <i class="bi bi-calendar-x"></i>
                        <h6>Belum ada jadwal pemeriksaan.</h6>
                        <p class="mb-0">Jadwal pemeriksaan baru dari dokter akan tampil di sini.</p>
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
                                    <th>Diagnosa</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${jadwal}" var="j">
                                    <tr>
                                        <td>${j.tanggalPemeriksaan}</td>
                                        <td class="fw-semibold">${empty j.namaDokter ? '-' : j.namaDokter}</td>
                                        <td>${empty j.keluhan ? '-' : j.keluhan}</td>
                                        <td>${empty j.diagnosa ? '-' : j.diagnosa}</td>
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
    <div class="col-12 col-xl-7">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-bell"></i>Notifikasi Untuk Anda</h2>
                    <p class="kartu-sub">Informasi terbaru mengenai jadwal, rawat inap, dan tagihan Anda.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=notifikasi">Semua Notifikasi</a>
            </div>
            <c:choose>
                <c:when test="${empty daftarNotifikasi}">
                    <div class="kosong">
                        <i class="bi bi-bell-slash"></i>
                        <h6>Belum ada notifikasi.</h6>
                        <p class="mb-0">Informasi terbaru untuk Anda akan tampil di sini. Buka menu notifikasi untuk memeriksa kembali.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <ul class="list-unstyled mb-0">
                        <c:forEach items="${daftarNotifikasi}" var="n">
                            <li class="py-2 border-bottom d-flex gap-2">
                                <i class="bi bi-info-circle-fill text-primary mt-1"></i>
                                <span><c:out value="${n}" /></span>
                            </li>
                        </c:forEach>
                    </ul>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="col-12 col-xl-5">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-grid"></i>Layanan Saya</h2>
                    <p class="kartu-sub">Akses cepat ke seluruh layanan portal pasien.</p>
                </div>
            </div>
            <div class="d-flex flex-column gap-2">
                <a class="btn btn-light text-start" href="${ctx}/saya?aksi=pemeriksaan"><i class="bi bi-clipboard2-pulse"></i>Riwayat Pemeriksaan</a>
                <a class="btn btn-light text-start" href="${ctx}/saya?aksi=rawat-inap"><i class="bi bi-hospital"></i>Riwayat Rawat Inap</a>
                <a class="btn btn-light text-start" href="${ctx}/saya?aksi=pembayaran"><i class="bi bi-credit-card"></i>Riwayat Pembayaran</a>
                <a class="btn btn-light text-start" href="${ctx}/saya?aksi=tagihan"><i class="bi bi-receipt"></i>Tagihan Saya</a>
                <a class="btn btn-light text-start" href="${ctx}/saya?aksi=notifikasi"><i class="bi bi-bell"></i>Notifikasi Saya</a>
            </div>
        </div>
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
