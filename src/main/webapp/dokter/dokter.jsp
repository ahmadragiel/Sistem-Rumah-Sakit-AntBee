<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Dokter" scope="request" />
<c:set var="menuAktif" value="dokter" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-person-badge"></i>Daftar Dokter</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarDokter)}</strong> dokter pada hasil pencarian ini.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN'}">
            <a class="btn btn-primary" href="${ctx}/dokter?aksi=tambah"><i class="bi bi-person-plus"></i>Tambah Dokter</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/dokter">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama, NIP, spesialisasi, atau telepon...">
        </div>
        <div class="grup">
            <label class="form-label" for="spesialisasi">Spesialisasi</label>
            <select class="form-select" id="spesialisasi" name="spesialisasi">
                <option value="">Semua spesialisasi</option>
                <c:forEach items="${daftarSpesialisasi}" var="sp">
                    <option value="<c:out value='${sp}'/>" <c:if test="${spesialisasi eq sp}">selected</c:if>><c:out value="${sp}"/></option>
                </c:forEach>
            </select>
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="AKTIF" <c:if test="${status eq 'AKTIF'}">selected</c:if>>Aktif</option>
                <option value="NONAKTIF" <c:if test="${status eq 'NONAKTIF'}">selected</c:if>>Nonaktif</option>
            </select>
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/dokter">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarDokter}">
            <div class="kosong">
                <i class="bi bi-person-badge"></i>
                <h6>Belum ada data dokter</h6>
                <p class="mb-0">Data dokter yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>NIP</th>
                            <th>Nama Dokter</th>
                            <th>Jenis Kelamin</th>
                            <th>Tempat Lahir</th>
                            <th>Tanggal Lahir</th>
                            <th>Spesialisasi</th>
                            <th>No. Telepon</th>
                            <th>Email</th>
                            <th>Jadwal Praktik</th>
                            <th>Akun Login</th>
                            <th>Status</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarDokter}" var="d" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${d.nip}</td>
                                <td class="fw-semibold">${d.namaDokter}</td>
                                <td>${empty d.jenisKelamin ? '-' : d.jenisKelamin}</td>
                                <td>${empty d.tempatLahir ? '-' : d.tempatLahir}</td>
                                <td>${empty d.tanggalLahir ? '-' : d.tanggalLahir}</td>
                                <td>${empty d.spesialisasi ? '-' : d.spesialisasi}</td>
                                <td>${empty d.noTelepon ? '-' : d.noTelepon}</td>
                                <td>${empty d.email ? '-' : d.email}</td>
                                <td>${empty d.jadwalPraktik ? '-' : d.jadwalPraktik}</td>
                                <td>${empty d.username ? 'Belum memiliki akun' : d.username}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.status eq 'AKTIF'}"><span class="badge badge-aktif">AKTIF</span></c:when>
                                        <c:otherwise><span class="badge badge-nonaktif">NONAKTIF</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/dokter?aksi=detail&id=${d.idDokter}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/dokter?aksi=edit&id=${d.idDokter}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                        <form action="${ctx}/dokter" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${d.idDokter}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data dokter <c:out value='${d.namaDokter}'/>?"><i class="bi bi-trash"></i></button>
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
