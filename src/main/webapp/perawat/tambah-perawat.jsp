<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Perawat" scope="request" />
<c:set var="menuAktif" value="perawat" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" scope="request" />
<c:set var="judulForm" value="Tambah Perawat Baru" scope="request" />
<%@ include file="/perawat/_form-perawat.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
