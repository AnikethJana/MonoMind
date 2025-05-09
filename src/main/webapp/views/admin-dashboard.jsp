<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <html>

        <head>
            <title>Admin Dashboard</title>
            <link rel="stylesheet" href="<c:url value='/styles/admin-dashboard.css'/>">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
        </head>

        <body>
            <header class="navbar">
                <div class="logo-container">
                    <div class="logo-icon"></div>
                    <h1>LMS Admin</h1>
                </div>
                <div class="user-info">
                    <span class="user-name">${user.fullName}</span>
                    <a href="<c:url value='/logout'/>" class="logout-btn">Logout</a>
                </div>
            </header>

            <div class="container">
                <div class="user-management-header">
                    <div class="users-icon"></div>
                    <h2>User Management</h2>
                </div>

                <!-- Search Form -->
                <form method="get" action="<c:url value='/admin/dashboard'/>" class="search-form">
                    <input type="text" name="searchQuery" placeholder="Search by name or email"
                        value="${param.searchQuery}" class="search-input" />
                    <button type="submit" class="search-button">
                        <div class="search-icon"></div>
                    </button>
                </form>

                <c:if test="${not empty error}">
                    <div class="alert error">
                        <span class="alert-icon">!</span> ${error}
                    </div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="alert success">
                        <span class="alert-icon">✓</span> ${success}
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty users}">
                        <table class="users-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Current Role</th>
                                    <th>Change Role</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${users}">
                                    <tr>
                                        <td>${u.id}</td>
                                        <td>${u.fullName}</td>
                                        <td>${u.email}</td>
                                        <td>${u.role}</td>
                                        <form method="post" action="<c:url value='/admin/update-role'/>">
                                            <input type="hidden" name="userId" value="${u.id}">
                                            <td>
                                                <select name="role" class="role-select">
                                                    <option value="STUDENT" ${u.role=='STUDENT' ? 'selected' : '' }>
                                                        Student</option>
                                                    <option value="TEACHER" ${u.role=='TEACHER' ? 'selected' : '' }>
                                                        Teacher</option>
                                                </select>
                                            </td>
                                            <td>
                                                <button type="submit" class="update-btn">
                                                    <div class="check-icon"></div>
                                                    Update
                                                </button>
                                            </td>
                                        </form>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="no-users">
                            <div class="no-users-icon"></div>
                            <p>No users found (excluding admins).</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </body>

        </html>