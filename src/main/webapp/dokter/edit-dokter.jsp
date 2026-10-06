<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Ubah Dokter" scope="request" />
<c:set var="menuAktif" value="dokter" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="update" scope="request" />
<c:set var="judulForm" value="Ubah Data Dokter" scope="request" />
<%@ include file="/dokter/_form-dokter.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
