<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <link rel="stylesheet" href="<c:url value='/styles/navbar.css'/>">

        <div class="navbar">
            <div class="logo">
                <i class="fas fa-graduation-cap"></i>
                <h1>${role} Dashboard</h1>
            </div>
            <div class="user-menu">
                <span><i class="fas fa-user"></i> ${user.fullName}</span>
                <a href="<c:url value='/logout'/>"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>