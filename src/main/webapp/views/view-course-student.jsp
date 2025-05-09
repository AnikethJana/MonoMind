<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>Course: ${course.title}</title>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
                <link rel="stylesheet" href="<c:url value='/styles/view-course-student.css'/>">
            </head>

            <body>
                <!-- Original navbar - hidden via CSS but kept for functionality -->
                <div class="navbar">
                    <h1>LMS Student</h1>
                    <div>Welcome, ${user.fullName} | <a href="<c:url value='/logout'/>">Logout</a></div>
                </div>

                <div class="container">
                    <!-- Back link matching the design -->
                    <a href="<c:url value='/student/dashboard'/>" class="back-link">Back to Courses</a>

                    <!-- Course info card -->
                    <div class="course-card">
                        <h2 class="course-title">${course.title}</h2>

                        <div class="course-instructor">
                            <div class="course-instructor-icon">
                                <i class="fas fa-chalkboard-teacher"></i>
                            </div>
                            <span class="taught-by">Taught by:</span>&nbsp;${course.teacher.fullName}
                        </div>

                        <div class="course-description">
                            <div class="course-description-icon">
                                <i class="fas fa-info-circle"></i>
                            </div>
                            <div> <span class="taught-by">Description:</span>&nbsp;${course.description}</div>
                        </div>
                    </div>

                    <!-- Course materials card -->
                    <div class="course-materials-card">
                        <h3 class="materials-header">
                            <div class="materials-icon">
                                <i class="fas fa-info-circle"></i>
                            </div>
                            Course Materials
                        </h3>

                        <c:choose>
                            <c:when test="${not empty courseworkList}">
                                <c:forEach var="cw" items="${courseworkList}">
                                    <a href="<c:url value='/student/coursework/${cw.id}'/>"
                                        style="text-decoration: none;">
                                        <div class="material-item">
                                            <div class="material-icon">
                                                <i class="fas fa-file-alt"></i>
                                            </div>
                                            <div>
                                                <span class="material-title">${cw.title}</span>
                                                <span class="material-type">(${cw.type})</span>
                                                <c:if test="${not empty cw.dueDate}">
                                                    <span class="material-due-date">Due:
                                                        <fmt:formatDate value="${cw.dueDate}" pattern="MMM d, yyyy" />
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </a>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-materials">
                                    <div class="empty-icon">
                                        <i class="fas fa-folder-open"></i>
                                    </div>
                                    <p>No materials added to this course yet.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Keep the original elements hidden but present for functionality -->
                    <div style="display: none;">
                        <a href="<c:url value='/student/dashboard'/>" class="link-back">&laquo; Back to Courses</a>
                        <hr>
                    </div>
                </div>
            </body>

            </html>