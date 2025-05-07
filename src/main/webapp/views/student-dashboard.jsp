<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Student Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 0; padding: 0; background-color: #f8f9fa; color: #333; }
        .navbar { background-color: #007bff; padding: 15px 30px; color: white; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { margin: 0; font-size: 24px; }
        .navbar a { color: #fff; text-decoration: none; font-weight: bold; }
        .navbar a:hover { text-decoration: underline; }
        .container { padding: 20px; max-width: 1000px; margin: 20px auto; background-color: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h2 { color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 10px; }
        .course-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; margin-top: 20px;}
        .course-card { border: 1px solid #ddd; border-radius: 8px; padding: 20px; background-color: #fff; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .course-card h3 { margin-top: 0; color: #0056b3; font-size: 1.2em; }
        .course-card p { font-size: 0.9em; color: #555; margin-bottom: 15px; min-height: 40px; }
        .course-card .teacher-name { font-size: 0.8em; color: #777; margin-bottom: 15px; }
        .btn-view { background-color: #17a2b8; color: white; padding: 8px 12px; text-decoration: none; border-radius: 4px; display: inline-block; font-size: 0.9em;}
        .btn-view:hover { background-color: #117a8b; }
        .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: center; }
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
<div class="navbar">
    <h1>LMS Student</h1>
    <div>Welcome, ${user.fullName} | <a href="<c:url value='/logout'/>">Logout</a></div>
</div>

<div class="container">
    <h2>Available Courses</h2>
    <c:if test="${not empty error}">
        <p class="message error">${error}</p>
    </c:if>

    <c:choose>
        <c:when test="${not empty courses}">
            <div class="course-grid">
                <c:forEach var="course" items="${courses}">
                    <div class="course-card">
                        <h3>${course.title}</h3>
                        <p class="teacher-name">Taught by: ${course.teacher.fullName}</p>
                        <p>${course.description}</p>
                        <a href="<c:url value='/student/course/${course.id}'/>" class="btn-view">View Course</a>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <p>No courses available at the moment.</p>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
