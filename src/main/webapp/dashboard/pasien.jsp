<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Beranda Saya" scope="request" />
<c:set var="menuAktif" value="jadwal" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-person-lines-fill"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(pemeriksaanTerbaru)}</div>
                <div class="keterangan">Riwayat Pemeriksaan</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-calendar-check"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(jadwal)}</div>
                <div class="keterangan">Jadwal Mendatang</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-hospital"></i></div>
            <div class="min-w-0">
                <div class="angka">${rawatInapAktif != null ? 'Dirawat' : 'Tidak Dirawat'}</div>
                <div class="keterangan">Status Rawat Inap</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-3">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-receipt"></i></div>
            <div class="min-w-0">
                <div class="angka">Rp&nbsp;<fmt:formatNumber value="${tagihanBelum}" type="number" maxFractionDigits="0" /></div>
                <div class="keterangan">Tagihan Belum Lunas</div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3 g-xl-4 mt-1">
    <div class="col-12 col-xl-5">
        <div class="kartu h-100">
            <h2 class="kartu-judul mb-3"><i class="bi bi-person-vcard"></i>Data Diri Saya</h2>
            <div class="detail-baris"><span class="label">NIK</span><span class="nilai">${pasien.nik}</span></div>
            <div class="detail-baris"><span class="label">Nama Lengkap</span><span class="nilai">${pasien.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">Jenis Kelamin</span><span class="nilai">${pasien.jenisKelamin}</span></div>
            <div class="detail-baris"><span class="label">Golongan Darah</span><span class="nilai">${pasien.golonganDarah}</span></div>
            <div class="detail-baris"><span class="label">No. Telepon</span><span class="nilai">${pasien.noTelepon}</span></div>
            <div class="detail-baris"><span class="label">Penyakit</span><span class="nilai">${pasien.namaPenyakit}</span></div>
            <div class="detail-baris"><span class="label">Dokter Penanggung Jawab</span><span class="nilai"><c:out value="${empty dokterPenanggung ? 'Belum ditentukan' : dokterPenanggung.namaDokter}" /></span></div>
            <div class="detail-baris"><span class="label">Tanggal Masuk</span><span class="nilai">${pasien.tanggalMasuk}</span></div>
            <div class="detail-baris"><span class="label">Status</span>
                <span class="nilai"><span class="badge ${pasien.statusPasien eq 'DIRAWAT' ? 'badge-dirawat' : (pasien.statusPasien eq 'PULANG' ? 'badge-pulang' : 'badge-rawatjalan')}">${pasien.statusPasien}</span></span>
            </div>
        </div>
    </div>
    <div class="col-12 col-xl-7">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-calendar-week"></i>Jadwal Pemeriksaan Mendatang</h2>
                    <p class="kartu-sub">Jadwal pemeriksaan Anda bersama dokter.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya">Lihat Jadwal</a>
            </div>
            <c:choose>
                <c:when test="${empty jadwal}">
                    <div class="kosong">
                        <i class="bi bi-calendar-x"></i>
                        <h6>Tidak ada jadwal mendatang</h6>
                        <p class="mb-0">Jadwal pemeriksaan baru dari dokter akan tampil di sini.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
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
                                        <td class="fw-semibold">${j.namaDokter}</td>
                                        <td>${j.keluhan}</td>
                                        <td>${j.diagnosa}</td>
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
                    <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Pemeriksaan Terbaru</h2>
                    <p class="kartu-sub">Riwayat pemeriksaan terakhir Anda.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=pemeriksaan">Riwayat Lengkap</a>
            </div>
            <c:choose>
                <c:when test="${empty pemeriksaanTerbaru}">
                    <div class="kosong">
                        <i class="bi bi-clipboard-x"></i>
                        <h6>Belum ada pemeriksaan</h6>
                        <p class="mb-0">Riwayat pemeriksaan Anda akan tampil di sini.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bungkus-tabel">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Tanggal</th>
                                    <th>Dokter</th>
                                    <th>Tekanan</th>
                                    <th>Suhu</th>
                                    <th>Diagnosa</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${pemeriksaanTerbaru}" var="pm">
                                    <tr>
                                        <td>${pm.tanggalPemeriksaan}</td>
                                        <td class="fw-semibold">${pm.namaDokter}</td>
                                        <td>${pm.tekananDarah}</td>
                                        <td>${pm.suhu} °C</td>
                                        <td>${pm.diagnosa}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="col-12 col-xl-5">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-bell"></i>Notifikasi Saya</h2>
                    <p class="kartu-sub">Informasi terbaru untuk Anda.</p>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=notifikasi">Semua Notifikasi</a>
            </div>
            <c:choose>
                <c:when test="${empty notifikasi}">
                    <div class="kosong">
                        <i class="bi bi-bell-slash"></i>
                        <h6>Belum ada notifikasi</h6>
                        <p class="mb-0">Informasi terbaru akan muncul di sini.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <ul class="list-unstyled mb-0">
                        <c:forEach items="${notifikasi}" var="n">
                            <li class="py-2 border-bottom d-flex gap-2">
                                <i class="bi bi-info-circle-fill text-primary mt-1"></i>
                                <span>${n}</span>
                            </li>
                        </c:forEach>
                    </ul>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<c:if test="${not empty pembayaranTerakhir}">
    <div class="kartu">
        <div class="kartu-kepala">
            <div>
                <h2 class="kartu-judul"><i class="bi bi-receipt"></i>Pembayaran Terakhir</h2>
                <p class="kartu-sub">Rincian tagihan terakhir Anda.</p>
            </div>
            <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=pembayaran">Riwayat Pembayaran</a>
        </div>
        <div class="row g-3">
            <div class="col-md-6">
                <div class="detail-baris"><span class="label">Total Biaya</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${pembayaranTerakhir.totalBiaya}" type="number" maxFractionDigits="0" /></span></div>
                <div class="detail-baris"><span class="label">Metode Pembayaran</span><span class="nilai">${pembayaranTerakhir.metodePembayaran}</span></div>
            </div>
            <div class="col-md-6">
                <div class="detail-baris"><span class="label">Tanggal Pembayaran</span><span class="nilai">${pembayaranTerakhir.tanggalPembayaran}</span></div>
                <div class="detail-baris"><span class="label">Status</span><span class="nilai"><span class="badge ${pembayaranTerakhir.statusPembayaran eq 'LUNAS' ? 'badge-lunas' : (pembayaranTerakhir.statusPembayaran eq 'MENUNGGU' ? 'badge-menunggu' : 'badge-belum')}">${pembayaranTerakhir.statusPembayaran}</span></span></div>
            </div>
        </div>
    </div>
</c:if>

<%@ include file="/fragments/footer.jspf" %>
