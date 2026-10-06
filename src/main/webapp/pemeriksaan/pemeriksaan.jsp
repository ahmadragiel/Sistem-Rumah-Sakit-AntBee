<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Pemeriksaan" scope="request" />
<c:set var="menuAktif" value="pemeriksaan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Daftar Pemeriksaan</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarPemeriksaan)}</strong> data pemeriksaan pada hasil pencarian ini.</p>
        </div>
        <a class="btn btn-primary" href="${ctx}/pemeriksaan?aksi=tambah"><i class="bi bi-plus-circle"></i>Tambah Pemeriksaan</a>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/pemeriksaan">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien, NIK, dokter, atau diagnosa...">
        </div>
        <c:if test="${user.role ne 'DOKTER'}">
            <div class="grup">
                <label class="form-label" for="idDokter">Dokter</label>
                <select class="form-select" id="idDokter" name="idDokter">
                    <option value="">Semua dokter</option>
                    <c:forEach items="${daftarDokter}" var="d">
                        <option value="${d.idDokter}" <c:if test="${idDokter eq d.idDokter}">selected</c:if>>dr. ${d.namaDokter} - ${d.spesialisasi}</option>
                    </c:forEach>
                </select>
            </div>
        </c:if>
        <div class="grup">
            <label class="form-label" for="dari">Dari Tanggal</label>
            <input type="date" class="form-control" id="dari" name="dari" value="<c:out value='${dari}'/>">
        </div>
        <div class="grup">
            <label class="form-label" for="sampai">Sampai Tanggal</label>
            <input type="date" class="form-control" id="sampai" name="sampai" value="<c:out value='${sampai}'/>">
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/pemeriksaan">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarPemeriksaan}">
            <div class="kosong">
                <i class="bi bi-clipboard-x"></i>
                <h6>Belum ada data pemeriksaan</h6>
                <p class="mb-0">Data pemeriksaan yang sesuai dengan pencarian akan tampil di sini.</p>
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
                            <th>NIK</th>
                            <th>Dokter</th>
                            <th>Keluhan</th>
                            <th>Tekanan Darah</th>
                            <th>Suhu</th>
                            <th>Berat Badan</th>
                            <th>Diagnosa</th>
                            <th>Tindakan</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPemeriksaan}" var="pm" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty pm.tanggalPemeriksaan ? '-' : pm.tanggalPemeriksaan}</td>
                                <td class="fw-semibold">${empty pm.namaPasien ? '-' : pm.namaPasien}</td>
                                <td>${empty pm.nik ? '-' : pm.nik}</td>
                                <td>${empty pm.namaDokter ? '-' : pm.namaDokter}</td>
                                <td>${empty pm.keluhan ? '-' : pm.keluhan}</td>
                                <td>${empty pm.tekananDarah ? '-' : pm.tekananDarah}</td>
                                <td><c:choose><c:when test="${empty pm.suhu}">-</c:when><c:otherwise>${pm.suhu} °C</c:otherwise></c:choose></td>
                                <td><c:choose><c:when test="${empty pm.beratBadan}">-</c:when><c:otherwise>${pm.beratBadan} kg</c:otherwise></c:choose></td>
                                <td>${empty pm.diagnosa ? '-' : pm.diagnosa}</td>
                                <td>${empty pm.tindakan ? '-' : pm.tindakan}</td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/pemeriksaan?aksi=detail&id=${pm.idPemeriksaan}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN' or (user.role eq 'DOKTER' and pm.idDokter eq sessionScope.idDokter)}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/pemeriksaan?aksi=edit&id=${pm.idPemeriksaan}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                    </c:if>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <form action="${ctx}/pemeriksaan" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${pm.idPemeriksaan}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data pemeriksaan <c:out value='${pm.namaPasien}'/> tanggal <c:out value='${pm.tanggalPemeriksaan}'/>?"><i class="bi bi-trash"></i></button>
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
