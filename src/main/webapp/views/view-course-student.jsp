<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Course: ${course.title}</title>
    <style>
        body { font-family: sans-serif; margin: 0; padding: 0; background-color: #f8f9fa; color: #333; }
        .navbar { background-color: #007bff; padding: 15px 30px; color: white; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { margin: 0; font-size: 24px; }
        .navbar a { color: #fff; text-decoration: none; font-weight: bold; }
        .container { padding: 20px; max-width: 900px; margin: 20px auto; background-color: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h2 { color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 10px; }
        .course-details p { margin: 5px 0; }
        .coursework-item { border: 1px solid #eee; padding: 15px; margin-bottom: 10px; border-radius: 5px; background-color: #f9f9f9; }
        .coursework-item h4 { margin-top: 0; color: #0056b3; }
        .coursework-item h4 a {text-decoration: none; color: #0056b3;}
        .coursework-item h4 a:hover {text-decoration: underline;}
        .link-back { display: inline-block; margin-top: 15px; margin-bottom: 15px; color: #007bff; text-decoration: none; }
        .link-back:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="navbar">
    <h1>LMS Student</h1>
    <div>Welcome, ${user.fullName} | <a href="<c:url value='/logout'/>">Logout</a></div>
</div>

<div class="container">
    <a href="<c:url value='/student/dashboard'/>" class="link-back">&laquo; Back to Courses</a>
    <h2>${course.title}</h2>
    <div class="course-details">
        <p><strong>Taught by:</strong> ${course.teacher.fullName}</p>
        <p><strong>Description:</strong> ${course.description}</p>
    </div>
    <hr>

    <h3>Course Materials</h3>
    <c:choose>
        <c:when test="${not empty courseworkList}">
            <c:forEach var="cw" items="${courseworkList}">
                <div class="coursework-item">
                    <h4><a href="<c:url value='/student/coursework/${cw.id}'/>">${cw.title} (${cw.type})</a></h4>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <p>No materials added to this course yet.</p>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
