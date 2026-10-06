<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Data Pembayaran" scope="request" />
<c:set var="menuAktif" value="pembayaran" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-credit-card"></i>Daftar Pembayaran</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarPembayaran)}</strong> data pembayaran pada hasil pencarian ini, dengan total pembayaran lunas <strong>Rp&nbsp;<fmt:formatNumber value="${empty totalLunas ? 0 : totalLunas}" type="number" maxFractionDigits="0" /></strong>.</p>
        </div>
        <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
            <a class="btn btn-primary" href="${ctx}/pembayaran?aksi=tambah"><i class="bi bi-plus-circle"></i>Tambah Pembayaran</a>
        </c:if>
    </div>

    <form class="baris-filter mb-3" method="get" action="${ctx}/pembayaran">
        <div class="grup grup-lebar">
            <label class="form-label" for="q">Pencarian</label>
            <input type="text" class="form-control" id="q" name="q" value="<c:out value='${q}'/>" placeholder="Cari nama pasien, nomor kamar, atau metode pembayaran...">
        </div>
        <div class="grup">
            <label class="form-label" for="status">Status Pembayaran</label>
            <select class="form-select" id="status" name="status">
                <option value="">Semua status</option>
                <option value="BELUM DIBAYAR" <c:if test="${status eq 'BELUM DIBAYAR'}">selected</c:if>>Belum Dibayar</option>
                <option value="MENUNGGU" <c:if test="${status eq 'MENUNGGU'}">selected</c:if>>Menunggu</option>
                <option value="LUNAS" <c:if test="${status eq 'LUNAS'}">selected</c:if>>Lunas</option>
            </select>
        </div>
        <div class="grup">
            <label class="form-label" for="dari">Tanggal Dari</label>
            <input type="date" class="form-control" id="dari" name="dari" value="<c:out value='${dari}'/>">
        </div>
        <div class="grup">
            <label class="form-label" for="sampai">Tanggal Sampai</label>
            <input type="date" class="form-control" id="sampai" name="sampai" value="<c:out value='${sampai}'/>">
        </div>
        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i>Terapkan</button>
        <a class="btn btn-light" href="${ctx}/pembayaran">Atur Ulang</a>
    </form>

    <c:choose>
        <c:when test="${empty daftarPembayaran}">
            <div class="kosong">
                <i class="bi bi-credit-card-2-front"></i>
                <h6>Belum ada data pembayaran.</h6>
                <p class="mb-0">Data pembayaran yang sesuai dengan pencarian akan tampil di sini.</p>
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
                            <th>Nomor Kamar</th>
                            <th class="text-end">Biaya Kamar</th>
                            <th class="text-end">Biaya Dokter</th>
                            <th class="text-end">Biaya Obat</th>
                            <th class="text-end">Biaya Tindakan</th>
                            <th class="text-end">Biaya Lain</th>
                            <th class="text-end">Total Biaya</th>
                            <th>Metode</th>
                            <th>Status</th>
                            <th class="text-end">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftarPembayaran}" var="by" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>${empty by.tanggalPembayaran ? '-' : by.tanggalPembayaran}</td>
                                <td class="fw-semibold">${empty by.namaPasien ? '-' : by.namaPasien}</td>
                                <td>${empty by.nomorKamar ? '-' : by.nomorKamar}</td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaKamar ? 0 : by.biayaKamar}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaDokter ? 0 : by.biayaDokter}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaObat ? 0 : by.biayaObat}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaTindakan ? 0 : by.biayaTindakan}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaLain ? 0 : by.biayaLain}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end fw-semibold">Rp&nbsp;<fmt:formatNumber value="${empty by.totalBiaya ? 0 : by.totalBiaya}" type="number" maxFractionDigits="0" /></td>
                                <td>${empty by.metodePembayaran ? '-' : by.metodePembayaran}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${by.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                                        <c:when test="${by.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                                        <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end text-nowrap">
                                    <a class="btn btn-outline-primary btn-sm btn-aksi" href="${ctx}/pembayaran?aksi=detail&id=${by.idPembayaran}" title="Lihat detail"><i class="bi bi-eye"></i></a>
                                    <a class="btn btn-success btn-sm btn-aksi" href="${ctx}/pembayaran?aksi=cetak&id=${by.idPembayaran}" title="Cetak bukti pembayaran"><i class="bi bi-printer"></i></a>
                                    <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
                                        <a class="btn btn-warning btn-sm btn-aksi" href="${ctx}/pembayaran?aksi=edit&id=${by.idPembayaran}" title="Ubah data"><i class="bi bi-pencil"></i></a>
                                    </c:if>
                                    <c:if test="${user.role eq 'ADMIN'}">
                                        <form action="${ctx}/pembayaran" method="post" class="d-inline">
                                            <input type="hidden" name="aksi" value="hapus">
                                            <input type="hidden" name="id" value="${by.idPembayaran}">
                                            <button class="btn btn-danger btn-sm btn-aksi" type="submit" title="Hapus data"
                                                    data-konfirmasi="Yakin ingin menghapus data pembayaran pasien <c:out value='${by.namaPasien}'/> tanggal <c:out value='${by.tanggalPembayaran}'/>?"><i class="bi bi-trash"></i></button>
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
