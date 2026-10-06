<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Profil Saya" scope="request" />
<c:set var="menuAktif" value="profil" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-lg-5">
        <div class="kartu h-100">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-person-circle"></i>Profil Saya</h2>
                    <p class="kartu-sub">Informasi akun yang sedang digunakan.</p>
                </div>
                <a class="btn btn-light" href="${ctx}/dashboard"><i class="bi bi-arrow-left"></i>Kembali</a>
            </div>

            <div class="d-flex align-items-center gap-3 mb-3">
                <div class="user-avatar" style="width:52px;height:52px;flex:0 0 52px;font-size:1.3rem;">
                    <c:out value="${fn:substring(user.namaLengkap,0,1)}" />
                </div>
                <div>
                    <div class="fw-bold">${empty user.namaLengkap ? '-' : user.namaLengkap}</div>
                    <div class="kartu-sub">${empty user.username ? '-' : user.username}</div>
                </div>
            </div>

            <div class="detail-baris"><span class="label">Username</span><span class="nilai">${empty user.username ? '-' : user.username}</span></div>
            <div class="detail-baris"><span class="label">Nama Lengkap</span><span class="nilai">${empty user.namaLengkap ? '-' : user.namaLengkap}</span></div>
            <div class="detail-baris"><span class="label">Email</span><span class="nilai">${empty user.email ? '-' : user.email}</span></div>
            <div class="detail-baris"><span class="label">No. Telepon</span><span class="nilai">${empty user.noTelepon ? '-' : user.noTelepon}</span></div>
            <div class="detail-baris"><span class="label">Alamat</span><span class="nilai">${empty user.alamat ? '-' : user.alamat}</span></div>
            <div class="detail-baris"><span class="label">Role</span><span class="nilai"><span class="badge badge-dirawat">${empty user.role ? '-' : user.role}</span></span></div>
            <div class="detail-baris"><span class="label">Status Akun</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${user.status eq 'AKTIF'}"><span class="badge badge-aktif">AKTIF</span></c:when>
                        <c:when test="${user.status eq 'NONAKTIF'}"><span class="badge badge-nonaktif">NONAKTIF</span></c:when>
                        <c:otherwise><span class="badge badge-nonaktif">-</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="detail-baris"><span class="label">Tanggal Dibuat</span><span class="nilai">${empty user.createdAt ? '-' : user.createdAt}</span></div>
            <c:if test="${not empty jabatan}">
                <div class="detail-baris"><span class="label">Data Terkait</span><span class="nilai">${empty labelJabatan ? '-' : labelJabatan}</span></div>
            </c:if>
        </div>
    </div>

    <div class="col-lg-7">
        <div class="kartu">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-pencil-square"></i>Ubah Data Profil</h2>
                    <p class="kartu-sub">Perbarui nama, email, nomor telepon, dan alamat Anda.</p>
                </div>
            </div>

            <c:if test="${not empty errors and tabUbahData}">
                <div class="panel-error">
                    <strong>Perbaiki data berikut:</strong>
                    <ul class="mt-1">
                        <c:forEach items="${errors}" var="e">
                            <li><c:out value="${e.value}" /></li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>

            <form method="post" action="${ctx}/profil" class="row g-3">
                <input type="hidden" name="aksi" value="ubahData">

                <div class="col-12">
                    <label class="form-label" for="namaLengkap">Nama Lengkap <span class="wajib">*</span></label>
                    <input type="text" class="form-control ${not empty errors.namaLengkap ? 'is-invalid' : ''}" id="namaLengkap" name="namaLengkap"
                           value="<c:out value='${data.namaLengkap}'/>" placeholder="Nama lengkap sesuai identitas" required>
                    <div class="invalid-feedback"><c:out value="${errors.namaLengkap}" /></div>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="email">Email</label>
                    <input type="email" class="form-control ${not empty errors.email ? 'is-invalid' : ''}" id="email" name="email"
                           value="<c:out value='${data.email}'/>" placeholder="Contoh: nama@sehatsentosa.id">
                    <div class="invalid-feedback"><c:out value="${errors.email}" /></div>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="noTelepon">No. Telepon</label>
                    <input type="text" class="form-control ${not empty errors.noTelepon ? 'is-invalid' : ''}" id="noTelepon" name="noTelepon"
                           value="<c:out value='${data.noTelepon}'/>" placeholder="Contoh: 081234567890">
                    <div class="invalid-feedback"><c:out value="${errors.noTelepon}" /></div>
                </div>
                <div class="col-12">
                    <label class="form-label" for="alamat">Alamat</label>
                    <textarea class="form-control" id="alamat" name="alamat" rows="2"
                              placeholder="Alamat lengkap domisili"><c:out value='${data.alamat}'/></textarea>
                </div>
                <div class="col-12">
                    <div class="form-text">Username, role, dan status akun hanya dapat diubah oleh administrator.</div>
                </div>
                <div class="col-12">
                    <button class="btn btn-primary" type="submit"><i class="bi bi-check2-circle"></i>Perbarui Data</button>
                </div>
            </form>
        </div>

        <div class="kartu">
            <div class="kartu-kepala">
                <div>
                    <h2 class="kartu-judul"><i class="bi bi-shield-lock"></i>Ganti Password</h2>
                    <p class="kartu-sub">Gunakan password baru minimal 6 karakter dan mudah diingat.</p>
                </div>
            </div>

            <c:if test="${not empty errors and tabGantiPassword}">
                <div class="panel-error">
                    <strong>Perbaiki data berikut:</strong>
                    <ul class="mt-1">
                        <c:forEach items="${errors}" var="e">
                            <li><c:out value="${e.value}" /></li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>

            <form method="post" action="${ctx}/profil" class="row g-3">
                <input type="hidden" name="aksi" value="gantiPassword">

                <div class="col-12">
                    <label class="form-label" for="passwordLama">Password Lama <span class="wajib">*</span></label>
                    <input type="password" class="form-control ${not empty errors.passwordLama ? 'is-invalid' : ''}" id="passwordLama" name="passwordLama"
                           placeholder="Password yang sedang digunakan" autocomplete="current-password" required>
                    <div class="invalid-feedback"><c:out value="${errors.passwordLama}" /></div>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="passwordBaru">Password Baru <span class="wajib">*</span></label>
                    <input type="password" class="form-control ${not empty errors.passwordBaru ? 'is-invalid' : ''}" id="passwordBaru" name="passwordBaru"
                           placeholder="Minimal 6 karakter" autocomplete="new-password" required>
                    <div class="invalid-feedback"><c:out value="${errors.passwordBaru}" /></div>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="ulangiPassword">Ulangi Password Baru <span class="wajib">*</span></label>
                    <input type="password" class="form-control ${not empty errors.ulangiPassword ? 'is-invalid' : ''}" id="ulangiPassword" name="ulangiPassword"
                           placeholder="Ketik ulang password baru" autocomplete="new-password" required>
                    <div class="invalid-feedback"><c:out value="${errors.ulangiPassword}" /></div>
                </div>
                <div class="col-12">
                    <button class="btn btn-primary" type="submit"><i class="bi bi-key"></i>Ganti Password</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
