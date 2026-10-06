<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Pengguna" scope="request" />
<c:set var="menuAktif" value="pengguna" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" />
<c:set var="judulForm" value="Tambah Pengguna Baru" />
<%@ include file="/pengguna/_form-pengguna.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
