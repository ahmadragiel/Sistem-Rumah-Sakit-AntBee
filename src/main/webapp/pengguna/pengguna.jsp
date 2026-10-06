<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Pengguna" scope="request" />
<c:set var="menuAktif" value="pengguna" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-person-gear"></i>Daftar Pengguna</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarPengguna)}</strong> akun pengguna pada hasil pencarian ini.</p>
        </div>
        <a class="btn btn-primary" href="${ctx}/pengguna?aksi=tambah"><i class="bi bi-person-plus"></i>Tambah Pengguna</a>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/pengguna">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari username, nama lengkap, email, atau role...">
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/pengguna">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarPengguna}">
            <div class="kosong">
                <i class="bi bi-person-x"></i>
                <h6>Belum ada data pengguna</h6>
                <p class="mb-0">Akun pengguna yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Username</th>
                            <th>Nama Lengkap</th>
                            <th>Email</th>
                            <th>No. Telepon</th>
                            <th>Alamat</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Tanggal Dibuat</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPengguna}" var="u" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="fw-semibold">${empty u.username ? '-' : u.username}</td>
                                <td>${empty u.namaLengkap ? '-' : u.namaLengkap}</td>
                                <td>${empty u.email ? '-' : u.email}</td>
                                <td>${empty u.noTelepon ? '-' : u.noTelepon}</td>
                                <td>${empty u.alamat ? '-' : u.alamat}</td>
                                <td><span class="badge badge-dirawat">${empty u.role ? '-' : u.role}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status eq 'AKTIF'}"><span class="badge badge-aktif">AKTIF</span></c:when>
                                        <c:when test="${u.status eq 'NONAKTIF'}"><span class="badge badge-nonaktif">NONAKTIF</span></c:when>
                                        <c:otherwise><span class="badge badge-nonaktif">-</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${empty u.createdAt ? '-' : u.createdAt}</td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/pengguna?aksi=edit&id=${u.idPengguna}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                    <form action="${ctx}/pengguna" method="post" class="d-inline">
                                        <input type="hidden" name="aksi" value="hapus">
                                        <input type="hidden" name="id" value="${u.idPengguna}">
                                        <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                data-konfirmasi="Yakin ingin menghapus pengguna <c:out value='${u.namaLengkap}'/>?"><i class="bi bi-trash"></i></button>
                                    </form>
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
