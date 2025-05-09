<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>

<head>
    <title>LMS Registration</title>
    <link rel="stylesheet" href="/styles/login.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* Additional styles specific to the registration page */
        .btn {
            background-color: #3b82f6;
        }
        .btn:hover {
            background-color: #2563eb;
        }
        .btn i {
            margin-right: 10px;
        }
    </style>
</head>

<body>
<div class="logo">
    <i class="fas fa-graduation-cap"></i>
    <div class="system-name">Learning Management System</div>
</div>

<div class="container">
    <h2>Create Your Account</h2>

    <c:if test="${not empty error}">
        <div class="status-message status-error">${error}</div>
    </c:if>

    <form method="post" action="<c:url value='/register'/>">
        <div class="form-group">
            <label for="fullName">Full Name</label>
            <input type="text" id="fullName" name="fullName" placeholder="Enter your full name" required>
        </div>
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" placeholder="name@company.com" required>
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn">
            <i class="fas fa-user-plus"></i> Create Account
        </button>
    </form>
    <div class="account-text">
        Already have an account? <a href="<c:url value='/login'/>">Sign in</a>
    </div>
</div>

<div class="copyright">
    © 2025 Learning Management System. All rights reserved.
</div>
</body>

</html>