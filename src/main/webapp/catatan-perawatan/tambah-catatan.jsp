<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tambah Catatan Perawatan" scope="request" />
<c:set var="menuAktif" value="catatan-perawatan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="aksiForm" value="simpan" scope="request" />
<c:set var="judulForm" value="Tambah Catatan Perawatan Baru" scope="request" />
<%@ include file="/catatan-perawatan/_form-catatan.jspf" %>

<%@ include file="/fragments/footer.jspf" %>
