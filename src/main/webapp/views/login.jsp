<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>

<head>
    <title>LMS Login</title>
    <link rel="stylesheet" href="/styles/login.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>

<body>
<div class="logo">
    <i class="fas fa-graduation-cap"></i>
    <div class="system-name">Learning Management System</div>
</div>

<div class="container">
    <h2>Sign In to Your Account</h2>

    <c:if test="${not empty error}">
        <div class="status-message status-error">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="status-message status-success">${success}</div>
    </c:if>
    <c:if test="${param.logout != null}">
        <div class="status-message status-success">You have been logged out successfully.</div>
    </c:if>

    <form method="post" action="<c:url value='/login'/>">
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" placeholder="name@company.com" required>
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn">
            <i class="fas fa-sign-in-alt"></i> Sign In
        </button>
    </form>
    <div class="account-text">
        Don't have an account? <a href="<c:url value='/register'/>">Create account</a>
    </div>
</div>

<div class="copyright">
    © 2025 Learning Management System. All rights reserved.
</div>
</body>

</html>