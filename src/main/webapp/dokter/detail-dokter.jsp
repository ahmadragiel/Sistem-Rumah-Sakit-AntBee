<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Dokter" scope="request" />
<c:set var="menuAktif" value="dokter" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-person-badge"></i><c:out value="${empty data.namaDokter ? 'Dokter' : data.namaDokter}" /></h2>
            <p class="kartu-sub">Profil lengkap dan riwayat pemeriksaan yang ditangani dokter ini.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/dokter"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN'}">
                <a class="btn btn-warning" href="${ctx}/dokter?aksi=edit&id=${data.idDokter}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Identitas Dokter</h6>
            <div class="detail-baris"><span class="label">ID Dokter</span><span class="nilai">${empty data.idDokter ? '-' : data.idDokter}</span></div>
            <div class="detail-baris"><span class="label">NIP</span><span class="nilai">${empty data.nip ? '-' : data.nip}</span></div>
            <div class="detail-baris"><span class="label">Nama Lengkap</span><span class="nilai">${empty data.namaDokter ? '-' : data.namaDokter}</span></div>
            <div class="detail-baris"><span class="label">Jenis Kelamin</span><span class="nilai">${empty data.jenisKelamin ? '-' : data.jenisKelamin}</span></div>
            <div class="detail-baris"><span class="label">Tempat Lahir</span><span class="nilai">${empty data.tempatLahir ? 'Belum diisi' : data.tempatLahir}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Lahir</span><span class="nilai">${empty data.tanggalLahir ? 'Belum diisi' : data.tanggalLahir}</span></div>
            <div class="detail-baris"><span class="label">Alamat</span><span class="nilai">${empty data.alamat ? 'Belum diisi' : data.alamat}</span></div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Praktik</h6>
            <div class="detail-baris"><span class="label">Spesialisasi</span><span class="nilai">${empty data.spesialisasi ? 'Belum ditentukan' : data.spesialisasi}</span></div>
            <div class="detail-baris"><span class="label">No. Telepon</span><span class="nilai">${empty data.noTelepon ? 'Belum diisi' : data.noTelepon}</span></div>
            <div class="detail-baris"><span class="label">Email</span><span class="nilai">${empty data.email ? 'Belum diisi' : data.email}</span></div>
            <div class="detail-baris"><span class="label">Jadwal Praktik</span><span class="nilai">${empty data.jadwalPraktik ? 'Belum diisi' : data.jadwalPraktik}</span></div>
            <div class="detail-baris"><span class="label">Akun Login</span><span class="nilai">${empty data.username ? 'Tidak memiliki akun' : data.username}</span></div>
            <div class="detail-baris"><span class="label">ID Akun Pengguna</span><span class="nilai">${empty data.idPengguna ? 'Belum terhubung' : data.idPengguna}</span></div>
            <div class="detail-baris"><span class="label">Status Dokter</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.status eq 'AKTIF'}"><span class="badge badge-aktif">AKTIF</span></c:when>
                        <c:when test="${data.status eq 'NONAKTIF'}"><span class="badge badge-nonaktif">NONAKTIF</span></c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Riwayat Pemeriksaan</h2>
            <p class="kartu-sub">Total ${fn:length(daftarPemeriksaan)} pemeriksaan yang ditangani dokter ini.</p>
        </div>
    </div>
    <c:choose>
        <c:when test="${empty daftarPemeriksaan}">
            <div class="kosong"><i class="bi bi-clipboard-x"></i><h6>Belum ada riwayat pemeriksaan</h6><p class="mb-0">Dokter ini belum pernah mencatat pemeriksaan pasien.</p></div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Tanggal</th>
                            <th>Pasien</th>
                            <th>NIK</th>
                            <th>Keluhan</th>
                            <th>Tekanan Darah</th>
                            <th>Suhu</th>
                            <th>Berat Badan</th>
                            <th>Diagnosa</th>
                            <th>Tindakan</th>
                            <th>Catatan</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPemeriksaan}" var="pm" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${pm.tanggalPemeriksaan}</td>
                                <td class="fw-semibold">${empty pm.namaPasien ? '-' : pm.namaPasien}</td>
                                <td>${empty pm.nik ? '-' : pm.nik}</td>
                                <td>${empty pm.keluhan ? '-' : pm.keluhan}</td>
                                <td>${empty pm.tekananDarah ? '-' : pm.tekananDarah}</td>
                                <td>${empty pm.suhu ? '-' : pm.suhu}<c:if test="${not empty pm.suhu}"> °C</c:if></td>
                                <td>${empty pm.beratBadan ? '-' : pm.beratBadan}<c:if test="${not empty pm.beratBadan}"> kg</c:if></td>
                                <td>${empty pm.diagnosa ? '-' : pm.diagnosa}</td>
                                <td>${empty pm.tindakan ? '-' : pm.tindakan}</td>
                                <td>${empty pm.catatan ? '-' : pm.catatan}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
