<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Teacher Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 0; padding: 0; background-color: #f8f9fa; color: #333; }
        .navbar { background-color: #28a745; padding: 15px 30px; color: white; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { margin: 0; font-size: 24px; }
        .navbar a { color: #fff; text-decoration: none; font-weight: bold; }
        .navbar a:hover { text-decoration: underline; }
        .container { padding: 20px; max-width: 1000px; margin: 20px auto; background-color: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h2 { color: #1e7e34; border-bottom: 2px solid #1e7e34; padding-bottom: 10px; }
        .course-card { border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 15px; background-color: #fff; }
        .course-card h3 { margin-top: 0; color: #007bff; }
        .btn-primary { background-color: #007bff; color: white; padding: 10px 15px; border: none; border-radius: 4px; text-decoration: none; display: inline-block; margin-top:10px;}
        .btn-primary:hover { background-color: #0056b3; }
        .btn-manage { background-color: #ffc107; color: #212529; padding: 8px 12px; text-decoration: none; border-radius: 4px; }
        .btn-manage:hover { background-color: #e0a800; }
        .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: center; }
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>
<div class="navbar">
    <h1>LMS Teacher</h1>
    <div>Welcome, ${user.fullName} | <a href="<c:url value='/logout'/>">Logout</a></div>
</div>

<div class="container">
    <h2>My Courses</h2>
    <a href="<c:url value='/teacher/course/create'/>" class="btn-primary">Create New Course</a>
    <hr style="margin: 20px 0;">

    <c:if test="${not empty error}">
        <p class="message error">${error}</p>
    </c:if>
    <c:if test="${not empty success}">
        <p class="message success">${success}</p>
    </c:if>

    <c:choose>
        <c:when test="${not empty courses}">
            <c:forEach var="course" items="${courses}">
                <div class="course-card">
                    <h3>${course.title}</h3>
                    <p>${course.description}</p>
                    <a href="<c:url value='/teacher/course/${course.id}/manage'/>" class="btn-manage">Manage Course</a>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <p>You have not created any courses yet.</p>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
