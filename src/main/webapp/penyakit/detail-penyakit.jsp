<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Penyakit" scope="request" />
<c:set var="menuAktif" value="penyakit" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-virus"></i><c:out value="${empty data.namaPenyakit ? 'Detail Penyakit' : data.namaPenyakit}" /></h2>
            <p class="kartu-sub">Kode penyakit <strong><c:out value="${empty data.kodePenyakit ? '-' : data.kodePenyakit}" /></strong> dan penjelasan medis lengkapnya.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/penyakit"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN'}">
                <a class="btn btn-warning" href="${ctx}/penyakit?aksi=edit&id=${data.idPenyakit}"><i class="bi bi-pencil"></i>Perbarui Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-5">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Identitas Penyakit</h6>
            <div class="detail-baris"><span class="label">ID Penyakit</span><span class="nilai">${empty data.idPenyakit ? '-' : data.idPenyakit}</span></div>
            <div class="detail-baris"><span class="label">Kode Penyakit</span><span class="nilai">${empty data.kodePenyakit ? '-' : data.kodePenyakit}</span></div>
            <div class="detail-baris"><span class="label">Nama Penyakit</span><span class="nilai">${empty data.namaPenyakit ? '-' : data.namaPenyakit}</span></div>
            <div class="detail-baris"><span class="label">Jenis Penyakit</span><span class="nilai">${empty data.jenisPenyakit ? '-' : data.jenisPenyakit}</span></div>
            <div class="detail-baris"><span class="label">Tingkat Keparahan</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.tingkatKeparahan eq 'RINGAN'}"><span class="badge badge-baik">RINGAN</span></c:when>
                        <c:when test="${data.tingkatKeparahan eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                        <c:when test="${data.tingkatKeparahan eq 'BERAT'}"><span class="badge badge-belum">BERAT</span></c:when>
                        <c:when test="${data.tingkatKeparahan eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                        <c:otherwise><span class="badge badge-nonaktif">${empty data.tingkatKeparahan ? '-' : data.tingkatKeparahan}</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
        <div class="col-lg-7">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Penjelasan Medis</h6>
            <div class="detail-baris"><span class="label">Gejala</span><span class="nilai">${empty data.gejala ? '-' : data.gejala}</span></div>
            <div class="detail-baris"><span class="label">Penyebab</span><span class="nilai">${empty data.penyebab ? '-' : data.penyebab}</span></div>
            <div class="detail-baris"><span class="label">Penanganan</span><span class="nilai">${empty data.penanganan ? '-' : data.penanganan}</span></div>
            <div class="detail-baris"><span class="label">Obat Utama</span><span class="nilai">${empty data.obatUtama ? 'Belum ada obat utama' : data.obatUtama}</span></div>
            <div class="detail-baris"><span class="label">Keterangan</span><span class="nilai">${empty data.keterangan ? '-' : data.keterangan}</span></div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-people"></i>Keterkaitan Data Pasien</h2>
            <p class="kartu-sub">Jumlah pasien yang terdiagnosis penyakit ini.</p>
        </div>
    </div>
    <div class="baris-kartu baris-3">
        <div class="kartu-stat">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-people"></i></div>
            <div class="min-w-0">
                <div class="angka">${empty jumlahPasien ? 0 : jumlahPasien}</div>
                <div class="keterangan">Pasien Terdiagnosis</div>
            </div>
        </div>
        <div class="kartu-stat">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-shield-check"></i></div>
            <div class="min-w-0">
                <div class="angka"><c:out value="${empty data.kodePenyakit ? '-' : data.kodePenyakit}" /></div>
                <div class="keterangan">Kode Rujukan Penyakit</div>
            </div>
        </div>
        <div class="kartu-stat">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-exclamation-triangle"></i></div>
            <div class="min-w-0">
                <div class="angka"><c:out value="${empty data.tingkatKeparahan ? '-' : data.tingkatKeparahan}" /></div>
                <div class="keterangan">Tingkat Keparahan</div>
            </div>
        </div>
    </div>
    <p class="kartu-sub mt-3 mb-0">Jumlah ini dihitung langsung dari data pasien yang terhubung dengan penyakit ini.</p>
</div>

<%@ include file="/fragments/footer.jspf" %>
