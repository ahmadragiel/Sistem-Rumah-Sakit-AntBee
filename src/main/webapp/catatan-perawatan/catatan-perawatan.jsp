<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Catatan Perawatan" scope="request" />
<c:set var="menuAktif" value="catatan-perawatan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-journal-medical"></i>Daftar Catatan Perawatan</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarCatatan)}</strong> catatan perawatan pada hasil pencarian ini.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN' or user.role eq 'PERAWAT'}">
            <a class="btn btn-primary" href="${ctx}/catatan-perawatan?aksi=tambah"><i class="bi bi-plus-circle"></i>Tambah Catatan</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/catatan-perawatan">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien, perawat, kondisi, atau tindakan...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Kondisi</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="BAIK" <c:if test="${status eq 'BAIK'}">selected</c:if>>Baik</option>
                <option value="SEDANG" <c:if test="${status eq 'SEDANG'}">selected</c:if>>Sedang</option>
                <option value="KRITIS" <c:if test="${status eq 'KRITIS'}">selected</c:if>>Kritis</option>
            </select>
        </div>
        <c:if test="${user.role eq 'ADMIN'}">
            <div class="grup">
                <label class="form-label" for="idPerawat">Perawat</label>
                <select class="form-select" id="idPerawat" name="idPerawat">
                    <option value="">Semua perawat</option>
                    <c:forEach items="${daftarPerawat}" var="w">
                        <option value="${w.idPerawat}" <c:if test="${idPerawat eq w.idPerawat}">selected</c:if>>${w.namaPerawat}</option>
                    </c:forEach>
                </select>
            </div>
        </c:if>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/catatan-perawatan">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarCatatan}">
            <div class="kosong">
                <i class="bi bi-journal-x"></i>
                <h6>Belum ada catatan perawatan.</h6>
                <p class="mb-0">Catatan perawatan yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
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
                            <th>Perawat</th>
                            <th>Kondisi Pasien</th>
                            <th>Catatan</th>
                            <th>Tindakan</th>
                            <th>Status Kondisi</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarCatatan}" var="ct" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty ct.tanggal ? '-' : ct.tanggal}</td>
                                <td class="fw-semibold">${empty ct.namaPasien ? '-' : ct.namaPasien}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ct.statusPasien eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${ct.statusPasien eq 'PULANG'}"><span class="badge badge-pulang">PULANG</span></c:when>
                                        <c:otherwise><span class="badge badge-rawatjalan">RAWAT JALAN</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${empty ct.namaPerawat ? '-' : ct.namaPerawat}</td>
                                <td>${empty ct.kondisiPasien ? '-' : ct.kondisiPasien}</td>
                                <td>${empty ct.catatan ? '-' : ct.catatan}</td>
                                <td>${empty ct.tindakan ? '-' : ct.tindakan}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ct.status eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                                        <c:when test="${ct.status eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                                        <c:otherwise><span class="badge badge-baik">BAIK</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/catatan-perawatan?aksi=detail&id=${ct.idCatatan}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN' or user.role eq 'PERAWAT'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/catatan-perawatan?aksi=edit&id=${ct.idCatatan}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                    </c:if>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <form action="${ctx}/catatan-perawatan" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${ct.idCatatan}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus catatan perawatan pasien <c:out value='${ct.namaPasien}'/> tanggal <c:out value='${ct.tanggal}'/>?"><i class="bi bi-trash"></i></button>
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
