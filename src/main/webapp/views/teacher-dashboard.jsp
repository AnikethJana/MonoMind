<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <html>

        <head>
            <title>Teacher Dashboard</title>
            <link rel="stylesheet" href="<c:url value='/styles/teacher-dashboard.css'/>">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
        </head>

        <body>
            <c:set var="role" value="LMS Teacher" scope="request" />
            <jsp:include page="components/navbar.jsp" />

            <main class="dashboard-content">
                <div class="header-section">
                    <div class="title-section">
                        <h2>My Courses</h2>
                        <p>Manage your teaching materials and student progress</p>
                    </div>
                    <a href="<c:url value='/teacher/course/create'/>" class="create-course-btn">
                        <span class="plus-icon">+</span> Create New Course
                    </a>
                </div>

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

                <div class="courses-grid">
                    <c:choose>
                        <c:when test="${not empty courses}">
                            <c:forEach var="course" items="${courses}">
                                <div class="course-card">
                                    <div class="course-card-header">
                                        <div class="course-document-icon"></div>
                                        <div class="course-students">
                                            <div class="students-icon"></div>
                                            <span>${course.studentCount}</span>
                                        </div>
                                    </div>
                                    <div class="course-content">
                                        <h3 class="course-title">${course.title}</h3>
                                        <p class="course-description">${course.description}</p>
                                        <a href="<c:url value='/teacher/course/${course.id}/manage'/>"
                                            class="manage-course-btn">
                                            Manage Course <span class="arrow-icon">→</span>
                                        </a>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="no-courses">
                                <div class="no-courses-icon"></div>
                                <h3>No Courses Yet</h3>
                                <p>You haven't created any courses. Start by creating your first course.</p>
                                <a href="<c:url value='/teacher/course/create'/>" class="create-course-btn">
                                    <span class="plus-icon">+</span> Create New Course
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </main>
        </body>

        </html>