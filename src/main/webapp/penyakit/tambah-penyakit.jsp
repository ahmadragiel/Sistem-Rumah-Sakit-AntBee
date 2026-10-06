<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Penyakit" scope="request" />
<c:set var="menuAktif" value="penyakit" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" />
<c:set var="judulForm" value="Tambah Penyakit Baru" />
<%@ include file="/penyakit/_form-penyakit.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
