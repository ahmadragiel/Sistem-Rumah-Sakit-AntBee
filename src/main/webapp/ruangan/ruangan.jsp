<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Ruangan" scope="request" />
<c:set var="menuAktif" value="ruangan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-door-open"></i>Daftar Ruangan</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarRuangan)}</strong> ruangan pada hasil pencarian ini, dengan <strong>${empty totalKamarTersedia ? 0 : totalKamarTersedia}</strong> kamar tersedia.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN'}">
            <a class="btn btn-primary" href="${ctx}/ruangan?aksi=tambah"><i class="bi bi-plus-lg"></i>Tambah Ruangan</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/ruangan">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama ruangan, nomor kamar, atau fasilitas...">
        </div>
        <div class="grup">
            <label class="form-label" for="jenis">Jenis Ruangan</label>
            <select class="form-select" id="jenis" name="jenis">
                <option value="">Semua jenis ruangan</option>
                <c:forEach items="${['Kelas I','Kelas II','Kelas III','ICU','Anak','Isolasi']}" var="j">
                    <option value="${j}" <c:if test="${jenis eq j}">selected</c:if>>${j}</option>
                </c:forEach>
            </select>
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="TERSEDIA" <c:if test="${status eq 'TERSEDIA'}">selected</c:if>>Tersedia</option>
                <option value="TERISI" <c:if test="${status eq 'TERISI'}">selected</c:if>>Terisi</option>
                <option value="PERAWATAN" <c:if test="${status eq 'PERAWATAN'}">selected</c:if>>Perawatan</option>
            </select>
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/ruangan">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarRuangan}">
            <div class="kosong">
                <i class="bi bi-door-open"></i>
                <h6>Belum ada data ruangan.</h6>
                <p class="mb-0">Data ruangan yang sesuai dengan pencarian akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>ID</th>
                            <th>Nama Ruangan</th>
                            <th>Nomor Kamar</th>
                            <th>Jenis</th>
                            <th>Lantai</th>
                            <th>Kapasitas</th>
                            <th>Terisi</th>
                            <th>Sisa</th>
                            <th>Tarif / Hari</th>
                            <th>Fasilitas</th>
                            <th>Status</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarRuangan}" var="r" varStatus="loop">
                            <c:set var="persen" value="${r.kapasitas > 0 ? (r.jumlahTerisi * 100.0) / r.kapasitas : 0}"/>
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty r.idRuangan ? '-' : r.idRuangan}</td>
                                <td class="fw-semibold">${empty r.namaRuangan ? '-' : r.namaRuangan}</td>
                                <td>${empty r.nomorKamar ? '-' : r.nomorKamar}</td>
                                <td>${empty r.jenisRuangan ? '-' : r.jenisRuangan}</td>
                                <td>${empty r.lantai ? '-' : r.lantai}</td>
                                <td>${empty r.kapasitas ? 0 : r.kapasitas} tempat tidur</td>
                                <td>
                                    <div class="d-flex justify-content-between align-items-center gap-2 mb-1">
                                        <span class="fw-semibold">${empty r.jumlahTerisi ? 0 : r.jumlahTerisi} / ${empty r.kapasitas ? 0 : r.kapasitas}</span>
                                        <span class="kartu-sub"><fmt:formatNumber value="${persen}" type="number" maxFractionDigits="0"/>%</span>
                                    </div>
                                    <div class="progres">
                                        <div class="progres-bar${persen >= 80 ? '' : (persen >= 50 ? ' kuning' : ' hijau')}" style="width: <fmt:formatNumber value="${persen}" type="number" maxFractionDigits="0"/>%;"></div>
                                    </div>
                                </td>
                                <td>${empty r.sisaKapasitas ? 0 : r.sisaKapasitas} tempat</td>
                                <td class="text-nowrap">Rp&nbsp;<fmt:formatNumber value="${empty r.tarifPerHari ? 0 : r.tarifPerHari}" type="number" maxFractionDigits="0"/> / hari</td>
                                <td title="<c:out value='${r.fasilitas}'/>"><c:out value="${empty r.fasilitas ? '-' : (fn:length(r.fasilitas) > 50 ? fn:substring(r.fasilitas, 0, 50) : r.fasilitas)}"/><c:if test="${fn:length(r.fasilitas) > 50}"> ...</c:if></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.statusRuangan eq 'TERSEDIA'}"><span class="badge badge-baik">TERSEDIA</span></c:when>
                                        <c:when test="${r.statusRuangan eq 'TERISI'}"><span class="badge badge-dirawat">TERISI</span></c:when>
                                        <c:when test="${r.statusRuangan eq 'PERAWATAN'}"><span class="badge badge-menunggu">PERAWATAN</span></c:when>
                                        <c:otherwise><span class="badge badge-nonaktif">${empty r.statusRuangan ? '-' : r.statusRuangan}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/ruangan?aksi=detail&id=${r.idRuangan}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/ruangan?aksi=edit&id=${r.idRuangan}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                        <form action="${ctx}/ruangan" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${r.idRuangan}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data ruangan <c:out value='${r.namaRuangan}'/>?"><i class="bi bi-trash"></i></button>
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
