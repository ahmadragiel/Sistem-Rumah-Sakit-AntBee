<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Pasien" scope="request" />
<c:set var="menuAktif" value="pasien" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-people"></i>Daftar Pasien</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarPasien)}</strong> pasien pada hasil pencarian ini.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
            <a class="btn btn-primary" href="${ctx}/pasien?aksi=tambah"><i class="bi bi-person-plus"></i>Tambah Pasien</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/pasien">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari NIK, nama, telepon, atau alamat...">
        </div>
        <c:if test="${user.role ne 'DOKTER'}">
            <div class="grup">
                <label class="form-label" for="idDokter">Dokter</label>
                <select class="form-select" id="idDokter" name="idDokter">
                    <option value="">Semua dokter</option>
                    <c:forEach items="${daftarDokter}" var="d">
                        <option value="${d.idDokter}" <c:if test="${idDokter eq d.idDokter}">selected</c:if>>${d.namaDokter}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="grup">
                <label class="form-label" for="status">Status</label>
                <select class="form-select" id="status" name="status">
                    <option value="">Semua status</option>
                    <option value="RAWAT JALAN" <c:if test="${status eq 'RAWAT JALAN'}">selected</c:if>>Rawat Jalan</option>
                    <option value="DIRAWAT" <c:if test="${status eq 'DIRAWAT'}">selected</c:if>>Dirawat</option>
                    <option value="PULANG" <c:if test="${status eq 'PULANG'}">selected</c:if>>Pulang</option>
                </select>
            </div>
        </c:if>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/pasien">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarPasien}">
            <div class="kosong">
                <i class="bi bi-people"></i>
                <h6>Belum ada data pasien</h6>
                <p class="mb-0">Data pasien yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>NIK</th>
                            <th>Nama Pasien</th>
                            <th>Jenis Kelamin</th>
                            <th>Gol. Darah</th>
                            <th>No. Telepon</th>
                            <th>Penyakit</th>
                            <th>Dokter</th>
                            <th>Tanggal Masuk</th>
                            <th>Status</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPasien}" var="p" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${p.nik}</td>
                                <td class="fw-semibold">${p.namaPasien}</td>
                                <td>${p.jenisKelamin}</td>
                                <td><span class="badge badge-rawatjalan">${empty p.golonganDarah ? '-' : p.golonganDarah}</span></td>
                                <td>${p.noTelepon}</td>
                                <td>${empty p.namaPenyakit ? '-' : p.namaPenyakit}</td>
                                <td>${empty p.namaDokter ? '-' : p.namaDokter}</td>
                                <td>${p.tanggalMasuk}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.statusPasien eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${p.statusPasien eq 'PULANG'}"><span class="badge badge-pulang">PULANG</span></c:when>
                                        <c:otherwise><span class="badge badge-rawatjalan">RAWAT JALAN</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/pasien?aksi=detail&id=${p.idPasien}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/pasien?aksi=edit&id=${p.idPasien}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                    </c:if>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <form action="${ctx}/pasien" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${p.idPasien}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data pasien <c:out value='${p.namaPasien}'/>?"><i class="bi bi-trash"></i></button>
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
