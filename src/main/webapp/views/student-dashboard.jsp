<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <html>

        <head>
            <title>Student Dashboard</title>
            <link rel="stylesheet" href="/styles/student-dashboard.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>

        <body>
            <c:set var="role" value="LMS Student" scope="request" />
            <jsp:include page="components/navbar.jsp" />

            <div class="content">
                <div class="header">
                    <div class="title">
                        <i class="fas fa-book"></i>
                        <h2>Available Courses</h2>
                    </div>
                    <div class="search-bar">
                        <i class="fas fa-search"></i>
                        <input type="text" id="courseSearch" placeholder="Search courses..." onkeyup="searchCourses()">
                    </div>
                </div>

                <c:if test="${not empty success}">
                    <div class="success-message">
                        <i class="fas fa-check-circle"></i> ${success}
                    </div>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="error-message">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <c:if test="${not empty info}">
                    <div class="info-message">
                        <i class="fas fa-info-circle"></i> ${info}
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty courses}">
                        <!-- Updated JSP code to match the new CSS structure -->
                        <div class="course-grid" id="courseGrid">
                            <c:forEach var="course" items="${courses}">
                                <c:set var="isEnrolled" value="false" />
                                <c:forEach var="enrolledCourse" items="${enrolledCourses}">
                                    <c:if test="${enrolledCourse.id eq course.id}">
                                        <c:set var="isEnrolled" value="true" />
                                    </c:if>
                                </c:forEach>

                                <div class="course-card">
                                    <div class="card-header">
                                        <div class="course-title">
                                            <h3>${course.title}</h3>
                                            <div class="status-container">
                                                <span class="status-badge status-active">Active</span>
                                                <c:if test="${isEnrolled eq 'true'}">
                                                    <span class="status-badge enrollment-badge">Enrolled</span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="instructor">
                                        <i class="fas fa-chalkboard-teacher"></i> Taught by: ${course.teacher.fullName}
                                    </div>

                                    <p class="description">${course.description}</p>

                                    <c:if test="${isEnrolled eq 'true'}">
                                        <form action="<c:url value='/student/course/${course.id}/unenroll'/>"
                                            method="post">
                                            <button type="submit" class="btn btn-circular btn-unenroll-small"
                                                title="Unenroll">
                                                <i class="fas fa-user-minus"></i>
                                            </button>
                                        </form>
                                    </c:if>

                                    <div class="card-footer">
                                        <div>
                                            <c:choose>
                                                <c:when test="${isEnrolled eq 'true'}">
                                                    <a href="<c:url value='/student/course/${course.id}'/>"
                                                        class="btn btn-view">
                                                        <i class="fas fa-eye"></i> View Course
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="<c:url value='/student/course/${course.id}/enroll'/>"
                                                        method="post">
                                                        <button type="submit" class="btn btn-enroll">
                                                            <i class="fas fa-user-plus"></i> Enroll
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <span class="students-count">
                                            <i class="fas fa-users"></i> ${course.studentCount}
                                        </span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <div id="noSearchResults" class="no-courses" style="display: none;">
                            <div class="icon-container">
                                <i class="fas fa-search"></i>
                            </div>
                            <h3>No Courses Found</h3>
                            <p>Try a different search term.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-courses">
                            <div class="icon-container">
                                <i class="fas fa-book"></i>
                            </div>
                            <h3>No Courses Available</h3>
                            <p>Check back later for new course offerings.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <script>
                function searchCourses() {
                    // Get search input value
                    const searchInput = document.getElementById('courseSearch');
                    const filter = searchInput.value.toUpperCase();
                    const courseGrid = document.getElementById('courseGrid');
                    const courseCards = courseGrid.getElementsByClassName('course-card');
                    const noSearchResults = document.getElementById('noSearchResults');

                    let resultsFound = false;

                    // Loop through all course cards and hide those that don't match the search query
                    for (let i = 0; i < courseCards.length; i++) {
                        const titleElement = courseCards[i].getElementsByClassName('course-title')[0];
                        const descriptionElement = courseCards[i].getElementsByClassName('description')[0];
                        const instructorElement = courseCards[i].getElementsByClassName('instructor')[0];

                        if (titleElement || descriptionElement || instructorElement) {
                            const titleText = titleElement ? titleElement.textContent || titleElement.innerText : '';
                            const descriptionText = descriptionElement ? descriptionElement.textContent || descriptionElement.innerText : '';
                            const instructorText = instructorElement ? instructorElement.textContent || instructorElement.innerText : '';

                            if (titleText.toUpperCase().indexOf(filter) > -1 ||
                                descriptionText.toUpperCase().indexOf(filter) > -1 ||
                                instructorText.toUpperCase().indexOf(filter) > -1) {
                                courseCards[i].style.display = "";
                                resultsFound = true;
                            } else {
                                courseCards[i].style.display = "none";
                            }
                        }
                    }

                    // Show or hide the "No results found" message
                    if (resultsFound) {
                        courseGrid.style.display = "";
                        noSearchResults.style.display = "none";
                    } else {
                        courseGrid.style.display = "none";
                        noSearchResults.style.display = "flex";
                    }
                }
            </script>
        </body>

        </html>