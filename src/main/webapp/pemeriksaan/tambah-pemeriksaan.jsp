<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Pemeriksaan" scope="request" />
<c:set var="menuAktif" value="pemeriksaan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" />
<c:set var="judulForm" value="Tambah Pemeriksaan Baru" />
<%@ include file="/pemeriksaan/_form-pemeriksaan.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
