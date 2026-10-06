<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Perawat" scope="request" />
<c:set var="menuAktif" value="perawat" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-person-workspace"></i><c:out value="${empty data.namaPerawat ? 'Perawat' : data.namaPerawat}" /></h2>
            <p class="kartu-sub">Profil lengkap dan riwayat catatan perawatan yang dibuat perawat ini.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/perawat"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN'}">
                <a class="btn btn-warning" href="${ctx}/perawat?aksi=edit&id=${data.idPerawat}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Identitas Perawat</h6>
            <div class="detail-baris"><span class="label">ID Perawat</span><span class="nilai">${empty data.idPerawat ? '-' : data.idPerawat}</span></div>
            <div class="detail-baris"><span class="label">NIP</span><span class="nilai">${empty data.nip ? '-' : data.nip}</span></div>
            <div class="detail-baris"><span class="label">Nama Lengkap</span><span class="nilai">${empty data.namaPerawat ? '-' : data.namaPerawat}</span></div>
            <div class="detail-baris"><span class="label">Jenis Kelamin</span><span class="nilai">${empty data.jenisKelamin ? '-' : data.jenisKelamin}</span></div>
            <div class="detail-baris"><span class="label">Tempat Lahir</span><span class="nilai">${empty data.tempatLahir ? '-' : data.tempatLahir}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Lahir</span><span class="nilai">${empty data.tanggalLahir ? '-' : data.tanggalLahir}</span></div>
            <div class="detail-baris"><span class="label">Pendidikan</span><span class="nilai">${empty data.pendidikan ? '-' : data.pendidikan}</span></div>
            <div class="detail-baris"><span class="label">Alamat</span><span class="nilai">${empty data.alamat ? 'Belum diisi' : data.alamat}</span></div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Tugas</h6>
            <div class="detail-baris"><span class="label">No. Telepon</span><span class="nilai">${empty data.noTelepon ? 'Belum diisi' : data.noTelepon}</span></div>
            <div class="detail-baris"><span class="label">Shift</span><span class="nilai">${empty data.shift ? 'Belum ditentukan' : data.shift}</span></div>
            <div class="detail-baris"><span class="label">Ruangan Tugas</span><span class="nilai">${empty data.ruangan ? 'Belum ditentukan' : data.ruangan}</span></div>
            <div class="detail-baris"><span class="label">Akun Login</span><span class="nilai">${empty data.username ? 'Tidak memiliki akun' : data.username}</span></div>
            <div class="detail-baris"><span class="label">ID Akun Pengguna</span><span class="nilai">${empty data.idPengguna ? 'Belum terhubung' : data.idPengguna}</span></div>
            <div class="detail-baris"><span class="label">Status Perawat</span>
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
            <h2 class="kartu-judul"><i class="bi bi-journal-medical"></i>Riwayat Catatan Perawatan</h2>
            <p class="kartu-sub">Total ${fn:length(daftarCatatan)} catatan yang dibuat perawat ini.</p>
        </div>
    </div>
    <c:choose>
        <c:when test="${empty daftarCatatan}">
            <div class="kosong"><i class="bi bi-journal-x"></i><h6>Belum ada catatan perawatan</h6><p class="mb-0">Perawat ini belum pernah mencatat kondisi pasien.</p></div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Tanggal</th>
                            <th>Pasien</th>
                            <th>Status Pasien</th>
                            <th>Kondisi Pasien</th>
                            <th>Status Kondisi</th>
                            <th>Tindakan</th>
                            <th>Catatan</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarCatatan}" var="ct" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${ct.tanggal}</td>
                                <td class="fw-semibold">${empty ct.namaPasien ? '-' : ct.namaPasien}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ct.statusPasien eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${ct.statusPasien eq 'PULANG'}"><span class="badge badge-pulang">PULANG</span></c:when>
                                        <c:otherwise><span class="badge badge-rawatjalan">RAWAT JALAN</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${empty ct.kondisiPasien ? '-' : ct.kondisiPasien}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ct.status eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                                        <c:when test="${ct.status eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                                        <c:otherwise><span class="badge badge-baik">BAIK</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${empty ct.tindakan ? '-' : ct.tindakan}</td>
                                <td>${empty ct.catatan ? '-' : ct.catatan}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
