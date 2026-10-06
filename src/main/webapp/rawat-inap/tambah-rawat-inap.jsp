<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Rawat Inap" scope="request" />
<c:set var="menuAktif" value="rawat-inap" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" />
<c:set var="judulForm" value="Tambah Rawat Inap Baru" />
<%@ include file="/rawat-inap/_form-rawat-inap.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
