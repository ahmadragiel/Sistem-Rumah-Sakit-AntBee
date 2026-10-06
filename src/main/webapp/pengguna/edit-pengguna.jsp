<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Ubah Pengguna" scope="request" />
<c:set var="menuAktif" value="pengguna" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="update" />
<c:set var="judulForm" value="Ubah Data Pengguna" />
<%@ include file="/pengguna/_form-pengguna.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
