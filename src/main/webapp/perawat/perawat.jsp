<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Perawat" scope="request" />
<c:set var="menuAktif" value="perawat" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-person-workspace"></i>Daftar Perawat</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarPerawat)}</strong> perawat pada hasil pencarian ini.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN'}">
            <a class="btn btn-primary" href="${ctx}/perawat?aksi=tambah"><i class="bi bi-person-plus"></i>Tambah Perawat</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/perawat">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama, NIP, ruangan, atau telepon...">
        </div>
        <div class="grup">
            <label class="form-label" for="shift">Shift</label>
            <select class="form-select" id="shift" name="shift">
                <option value="">Semua shift</option>
                <option value="Pagi" <c:if test="${shift eq 'Pagi'}">selected</c:if>>Pagi</option>
                <option value="Siang" <c:if test="${shift eq 'Siang'}">selected</c:if>>Siang</option>
                <option value="Malam" <c:if test="${shift eq 'Malam'}">selected</c:if>>Malam</option>
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
        <a class="btn btn-light" href="${ctx}/perawat">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarPerawat}">
            <div class="kosong">
                <i class="bi bi-person-workspace"></i>
                <h6>Belum ada data perawat</h6>
                <p class="mb-0">Data perawat yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>NIP</th>
                            <th>Nama Perawat</th>
                            <th>Jenis Kelamin</th>
                            <th>Tempat Lahir</th>
                            <th>Tanggal Lahir</th>
                            <th>Pendidikan</th>
                            <th>No. Telepon</th>
                            <th>Shift</th>
                            <th>Ruangan Tugas</th>
                            <th>Akun Login</th>
                            <th>Status</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPerawat}" var="w" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${w.nip}</td>
                                <td class="fw-semibold">${w.namaPerawat}</td>
                                <td>${empty w.jenisKelamin ? '-' : w.jenisKelamin}</td>
                                <td>${empty w.tempatLahir ? '-' : w.tempatLahir}</td>
                                <td>${empty w.tanggalLahir ? '-' : w.tanggalLahir}</td>
                                <td>${empty w.pendidikan ? '-' : w.pendidikan}</td>
                                <td>${empty w.noTelepon ? '-' : w.noTelepon}</td>
                                <td>${empty w.shift ? '-' : w.shift}</td>
                                <td>${empty w.ruangan ? '-' : w.ruangan}</td>
                                <td>${empty w.username ? 'Belum memiliki akun' : w.username}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${w.status eq 'AKTIF'}"><span class="badge badge-aktif">AKTIF</span></c:when>
                                        <c:otherwise><span class="badge badge-nonaktif">NONAKTIF</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/perawat?aksi=detail&id=${w.idPerawat}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/perawat?aksi=edit&id=${w.idPerawat}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                        <form action="${ctx}/perawat" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${w.idPerawat}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data perawat <c:out value='${w.namaPerawat}'/>?"><i class="bi bi-trash"></i></button>
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
