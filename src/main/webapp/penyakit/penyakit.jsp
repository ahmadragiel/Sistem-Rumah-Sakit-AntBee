<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Penyakit" scope="request" />
<c:set var="menuAktif" value="penyakit" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-virus"></i>Kamus Penyakit</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarPenyakit)}</strong> penyakit pada hasil pencarian ini.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN'}">
            <a class="btn btn-primary" href="${ctx}/penyakit?aksi=tambah"><i class="bi bi-plus-lg"></i>Tambah Penyakit</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/penyakit">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari kode, nama, atau gejala penyakit...">
        </div>
        <div class="grup">
            <label class="form-label" for="jenis">Jenis Penyakit</label>
            <select class="form-select" id="jenis" name="jenis">
                <option value="">Semua jenis penyakit</option>
                <c:forEach items="${daftarJenis}" var="jt">
                    <option value="<c:out value='${jt}'/>" <c:if test="${jenis eq jt}">selected</c:if>><c:out value="${jt}" /></option>
                </c:forEach>
            </select>
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/penyakit">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarPenyakit}">
            <div class="kosong">
                <i class="bi bi-virus"></i>
                <h6>Belum ada data penyakit.</h6>
                <p class="mb-0">Data penyakit yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>ID</th>
                            <th>Kode</th>
                            <th>Nama Penyakit</th>
                            <th>Jenis</th>
                            <th>Tingkat Keparahan</th>
                            <th>Gejala</th>
                            <th>Penyebab</th>
                            <th>Penanganan</th>
                            <th>Obat Utama</th>
                            <th>Keterangan</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPenyakit}" var="p" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty p.idPenyakit ? '-' : p.idPenyakit}</td>
                                <td class="fw-semibold">${empty p.kodePenyakit ? '-' : p.kodePenyakit}</td>
                                <td class="fw-semibold">${empty p.namaPenyakit ? '-' : p.namaPenyakit}</td>
                                <td>${empty p.jenisPenyakit ? '-' : p.jenisPenyakit}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.tingkatKeparahan eq 'RINGAN'}"><span class="badge badge-baik">RINGAN</span></c:when>
                                        <c:when test="${p.tingkatKeparahan eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                                        <c:when test="${p.tingkatKeparahan eq 'BERAT'}"><span class="badge badge-belum">BERAT</span></c:when>
                                        <c:when test="${p.tingkatKeparahan eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                                        <c:otherwise><span class="badge badge-nonaktif">${empty p.tingkatKeparahan ? '-' : p.tingkatKeparahan}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td title="<c:out value='${p.gejala}'/>"><c:out value="${empty p.gejala ? '-' : (fn:length(p.gejala) > 60 ? fn:substring(p.gejala, 0, 60) : p.gejala)}"/><c:if test="${fn:length(p.gejala) > 60}"> ...</c:if></td>
                                <td title="<c:out value='${p.penyebab}'/>"><c:out value="${empty p.penyebab ? '-' : (fn:length(p.penyebab) > 60 ? fn:substring(p.penyebab, 0, 60) : p.penyebab)}"/><c:if test="${fn:length(p.penyebab) > 60}"> ...</c:if></td>
                                <td title="<c:out value='${p.penanganan}'/>"><c:out value="${empty p.penanganan ? '-' : (fn:length(p.penanganan) > 60 ? fn:substring(p.penanganan, 0, 60) : p.penanganan)}"/><c:if test="${fn:length(p.penanganan) > 60}"> ...</c:if></td>
                                <td>${empty p.obatUtama ? '-' : p.obatUtama}</td>
                                <td title="<c:out value='${p.keterangan}'/>"><c:out value="${empty p.keterangan ? '-' : (fn:length(p.keterangan) > 60 ? fn:substring(p.keterangan, 0, 60) : p.keterangan)}"/><c:if test="${fn:length(p.keterangan) > 60}"> ...</c:if></td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/penyakit?aksi=detail&id=${p.idPenyakit}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/penyakit?aksi=edit&id=${p.idPenyakit}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                        <form action="${ctx}/penyakit" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${p.idPenyakit}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data penyakit <c:out value='${p.namaPenyakit}'/>?"><i class="bi bi-trash"></i></button>
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
