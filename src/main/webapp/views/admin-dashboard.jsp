<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Admin Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 0; padding: 0; background-color: #f8f9fa; color: #333; }
        .navbar { background-color: #343a40; padding: 15px 30px; color: white; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { margin: 0; font-size: 24px; }
        .navbar a { color: #ffc107; text-decoration: none; font-weight: bold; }
        .navbar a:hover { text-decoration: underline; }
        .container { padding: 20px; max-width: 1000px; margin: 20px auto; background-color: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h2 { color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #dee2e6; padding: 12px; text-align: left; }
        th { background-color: #e9ecef; }
        select, button { padding: 8px 12px; border-radius: 4px; border: 1px solid #ced4da; margin-right: 5px; }
        button { background-color: #007bff; color: white; cursor: pointer; }
        button:hover { background-color: #0056b3; }
        .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: center; }
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        /* Style for the search form */
        .search-group { margin-bottom: 20px; }
        .search-group input[type="text"] {
            width: 80%;
            padding: 8px 12px;
            border: 1px solid #ced4da;
            border-radius: 4px;
        }
        .search-group button {
            padding: 8px 12px;
            border: 1px solid #007bff;
            border-radius: 4px;
            background-color: #007bff;
            color: white;
            cursor: pointer;
        }
        .search-group button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<div class="navbar">
    <h1>LMS Admin</h1>
    <div>Welcome, ${user.fullName} | <a href="<c:url value='/logout'/>">Logout</a></div>
</div>

<div class="container">
    <h2>User Management</h2>

    <!-- Search Form -->
    <form method="get" action="<c:url value='/admin/dashboard'/>" class="search-group">
        <input type="text" name="searchQuery" placeholder="Search by name or email" value="${param.searchQuery}" />
        <button type="submit">Search</button>
    </form>

    <c:if test="${not empty error}">
        <p class="message error">${error}</p>
    </c:if>
    <c:if test="${not empty success}">
        <p class="message success">${success}</p>
    </c:if>

    <c:choose>
        <c:when test="${not empty users}">
            <table>
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
                                <select name="role">
                                    <option value="STUDENT" ${u.role == 'STUDENT' ? 'selected' : ''}>Student</option>
                                    <option value="TEACHER" ${u.role == 'TEACHER' ? 'selected' : ''}>Teacher</option>
                                </select>
                            </td>
                            <td><button type="submit">Update</button></td>
                        </form>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <p>No users found (excluding admins).</p>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
