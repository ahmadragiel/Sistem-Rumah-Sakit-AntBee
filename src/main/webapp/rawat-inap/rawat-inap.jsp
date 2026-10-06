<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Rawat Inap" scope="request" />
<c:set var="menuAktif" value="rawat-inap" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-hospital"></i>Daftar Rawat Inap</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarRawatInap)}</strong> data rawat inap pada hasil pencarian ini.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
            <a class="btn btn-primary" href="${ctx}/rawat-inap?aksi=tambah"><i class="bi bi-plus-circle"></i>Tambah Rawat Inap</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/rawat-inap">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien, nomor kamar, diagnosa, atau dokter...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Rawat</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="MENUNGGU" <c:if test="${status eq 'MENUNGGU'}">selected</c:if>>Menunggu</option>
                <option value="DIRAWAT" <c:if test="${status eq 'DIRAWAT'}">selected</c:if>>Dirawat</option>
                <option value="SELESAI" <c:if test="${status eq 'SELESAI'}">selected</c:if>>Selesai</option>
                <option value="DIPULANGKAN" <c:if test="${status eq 'DIPULANGKAN'}">selected</c:if>>Dipulangkan</option>
            </select>
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/rawat-inap">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarRawatInap}">
            <div class="kosong">
                <i class="bi bi-hospital"></i>
                <h6>Belum ada data rawat inap</h6>
                <p class="mb-0">Data rawat inap yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Pasien</th>
                            <th>Ruangan</th>
                            <th>Nomor Kamar</th>
                            <th>Jenis Ruangan</th>
                            <th>Dokter</th>
                            <th>Diagnosa</th>
                            <th>Tanggal Masuk</th>
                            <th>Tanggal Keluar</th>
                            <th>Lama</th>
                            <th>Status</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarRawatInap}" var="r" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="fw-semibold">${empty r.namaPasien ? '-' : r.namaPasien}</td>
                                <td>${empty r.namaRuangan ? '-' : r.namaRuangan}</td>
                                <td>${empty r.nomorKamar ? '-' : r.nomorKamar}</td>
                                <td>${empty r.jenisRuangan ? '-' : r.jenisRuangan}</td>
                                <td>${empty r.namaDokter ? '-' : r.namaDokter}</td>
                                <td>${empty r.diagnosa ? '-' : r.diagnosa}</td>
                                <td>${empty r.tanggalMasuk ? '-' : r.tanggalMasuk}</td>
                                <td>${empty r.tanggalKeluar ? '-' : r.tanggalKeluar}</td>
                                <td><c:choose><c:when test="${empty r.lamaRawat}">-</c:when><c:otherwise>${r.lamaRawat} hari</c:otherwise></c:choose></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.statusRawat eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${r.statusRawat eq 'SELESAI'}"><span class="badge badge-selesai">SELESAI</span></c:when>
                                        <c:when test="${r.statusRawat eq 'DIPULANGKAN'}"><span class="badge badge-pulang">DIPULANGKAN</span></c:when>
                                        <c:otherwise><span class="badge badge-menunggu">MENUNGGU</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/rawat-inap?aksi=detail&id=${r.idRawatInap}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/rawat-inap?aksi=edit&id=${r.idRawatInap}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                    </c:if>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <form action="${ctx}/rawat-inap" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${r.idRawatInap}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data rawat inap pasien <c:out value='${r.namaPasien}'/> pada kamar <c:out value='${r.nomorKamar}'/>?"><i class="bi bi-trash"></i></button>
                                        </form>
                                    </c:if>
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
