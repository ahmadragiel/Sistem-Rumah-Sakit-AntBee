<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Dokter" scope="request" />
<c:set var="menuAktif" value="dokter" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" scope="request" />
<c:set var="judulForm" value="Tambah Dokter Baru" scope="request" />
<%@ include file="/dokter/_form-dokter.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
