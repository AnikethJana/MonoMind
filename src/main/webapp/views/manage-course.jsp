<%--
  File: manage-course.jsp
  Description: Page for teachers to manage a specific course, including adding/viewing coursework.
               This version is self-contained.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Course - <c:out value="${course.title}"/></title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; color: #333; line-height: 1.6; }
        .navbar { background-color: #333; color: #fff; padding: 1rem; text-align: center; }
        .navbar a { color: #fff; margin: 0 15px; text-decoration: none; }
        .navbar a:hover { text-decoration: underline; }
        .container { width: 85%; margin: 20px auto; padding: 20px; background-color: #fff; border-radius: 8px; box-shadow: 0 0 15px rgba(0,0,0,0.1); }
        h1, h2, h3 { color: #333; margin-top: 0; }
        hr { border: 0; height: 1px; background: #ddd; margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; box-shadow: 0 2px 3px rgba(0,0,0,0.1); }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; vertical-align: top;}
        th { background-color: #f0f0f0; font-weight: bold; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f1f1f1; }
        .form-styled .form-group { margin-bottom: 1.5rem; }
        .form-styled label { display: block; margin-bottom: .5rem; font-weight: bold; }
        .form-styled .form-control, .form-styled .form-control-file, .form-styled select {
            width: calc(100% - 24px); /* Account for padding and border */
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box; /* Important for width calculation */
        }
        .form-styled textarea.form-control { resize: vertical; min-height: 80px; }
        .form-styled .form-text { font-size: 0.875em; color: #6c757d; display: block; margin-top: .25rem; }
        .btn { display: inline-block; padding: 10px 18px; font-size: 1rem; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; color: #fff; transition: background-color 0.3s ease; margin-right: 5px; margin-bottom: 5px;}
        .btn-primary { background-color: #007bff; } .btn-primary:hover { background-color: #0056b3; }
        .btn-secondary { background-color: #6c757d; } .btn-secondary:hover { background-color: #545b62; }
        .btn-info { background-color: #17a2b8; } .btn-info:hover { background-color: #0f6674; }
        .btn-danger { background-color: #dc3545; } .btn-danger:hover { background-color: #b02a37; }
        .btn-sm { padding: 8px 12px; font-size: 0.875rem; }
        .alert { padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: 4px; }
        .alert-success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
        .alert-danger { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
        .user-info { float: right; font-size: 0.9em; }
        .list-group { padding-left: 0; list-style: none; margin-top: 10px; }
        .list-group-item { border: 1px solid #ddd; padding: 10px 15px; margin-bottom: -1px; background-color: #fff; }
        .list-group-item:first-child { border-top-left-radius: .25rem; border-top-right-radius: .25rem;}
        .list-group-item:last-child { border-bottom-left-radius: .25rem; border-bottom-right-radius: .25rem; margin-bottom: 0;}
        .assignment-submissions-details td { background-color: #f9f9f9 !important; padding: 15px; } /* !important to override tr:hover */
        .footer { text-align: center; padding: 20px 0; margin-top: 30px; background-color: #333; color: #fff; font-size: 0.9em; }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="<c:url value='/home'/>">Home</a>
    <c:if test="${not empty sessionScope.user}">
            <span class="user-info">
                Logged in as: <c:out value="${sessionScope.user.fullName}"/> (<c:out value="${sessionScope.user.role}"/>) |
                <a href="<c:url value='/logout'/>">Logout</a>
            </span>
    </c:if>
    <c:if test="${empty sessionScope.user}">
        <a href="<c:url value='/login'/>">Login</a>
        <a href="<c:url value='/register'/>">Register</a>
    </c:if>
</nav>

<div class="container">
    <c:if test="${not empty success}">
        <p class="alert alert-success"><c:out value="${success}"/></p>
    </c:if>
    <c:if test="${not empty error}">
        <p class="alert alert-danger"><c:out value="${error}"/></p>
    </c:if>

    <h2>Manage Course: <c:out value="${course.title}"/></h2>
    <p><strong>Description:</strong> <c:out value="${course.description}"/></p>
    <p><strong>Teacher:</strong> <c:out value="${course.teacher.fullName}"/></p>

    <hr>

    <h3>Add New Coursework</h3>
    <form method="POST" action="<c:url value='/teacher/course/${course.id}/coursework/add'/>" enctype="multipart/form-data" class="form-styled">
        <div class="form-group">
            <label for="courseworkTitle">Title:</label>
            <input type="text" name="title" id="courseworkTitle" class="form-control" required>
        </div>
        <div class="form-group">
            <label for="courseworkType">Type:</label>
            <select name="type" id="courseworkType" class="form-control" onchange="toggleCourseworkFields()" required>
                <option value="">-- Select Type --</option>
                <c:forEach items="${courseworkTypes}" var="cwType">
                    <option value="${cwType}">${fn:toLowerCase(fn:replace(cwType, '_', ' '))}</option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <label for="courseworkContent" id="courseworkContentLabel">Description / Content:</label>
            <textarea name="content" id="courseworkContent" class="form-control" rows="4"></textarea>
        </div>

        <div id="noteFields" class="form-group" style="display:none;">
            <label for="fileNote">Upload File (for Note):</label>
            <input type="file" name="fileNote" id="fileNote" class="form-control-file">
        </div>

        <div id="quizFields" class="form-group" style="display:none;">
            <label for="quizQuestionsText">Quiz Questions:</label>
            <textarea name="quizQuestionsText" id="quizQuestionsText" class="form-control" rows="10" placeholder="Enter questions one by one, separated by '---'. Mark correct option with [*] e.g., B) Option B [*]"></textarea>
            <small class="form-text">
                Example Question Format:<br>
                What is the color of the sky on a clear day?<br>
                A) Green<br>
                B) Blue [*]<br>
                C) Red<br>
                --- (separator for next question) ---<br>
                What is 2 + 2?<br>
                1) 3<br>
                2) 4 [*]<br>
                3) 5
            </small>
        </div>
        <button type="submit" class="btn btn-primary">Add Coursework</button>
    </form>

    <hr>

    <h3>Existing Coursework</h3>
    <c:if test="${empty courseworkList}">
        <p>No coursework added yet for this course.</p>
    </c:if>
    <c:if test="${not empty courseworkList}">
        <table class="table table-striped">
            <thead>
            <tr>
                <th>Title</th>
                <th>Type</th>
                <th>Content/Description</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${courseworkList}" var="cw">
                <tr>
                    <td><c:out value="${cw.title}"/></td>
                    <td><c:out value="${fn:toLowerCase(fn:replace(cw.type, '_', ' '))}"/></td>
                    <td>
                        <c:choose>
                            <c:when test="${cw.type == 'NOTE' && not empty cw.filePath}">
                                <c:out value="${fn:substring(cw.content, 0, 100)}"/><c:if test="${fn:length(cw.content) > 100}">...</c:if><br>
                                File: <a href="<c:url value='/teacher/coursework/note/${cw.id}/viewfile'/>" target="_blank"><c:out value="${cw.originalFileName}"/></a>
                            </c:when>
                            <c:otherwise>
                                <c:out value="${fn:substring(cw.content, 0, 150)}"/><c:if test="${fn:length(cw.content) > 150}">...</c:if>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:if test="${cw.type == 'ASSIGNMENT'}">
                            <button onclick="toggleSubmissions('submissions_cw_${cw.id}'); return false;" class="btn btn-info btn-sm">View Submissions</button>
                        </c:if>
                        <c:if test="${cw.type == 'QUIZ'}">
                            <a href="<c:url value='/teacher/quiz/${cw.id}/submissions'/>" class="btn btn-info btn-sm">View Submissions</a>
                            <a href="<c:url value='/teacher/coursework/${cw.id}/quiz/edit'/>" class="btn btn-secondary btn-sm">Edit Quiz</a>
                        </c:if>
                        <form method="POST" action="<c:url value='/teacher/coursework/${cw.id}/delete'/>" style="display:inline-block;" onsubmit="return confirm('Are you sure you want to delete this coursework? This action cannot be undone and will delete associated submissions/files.');">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                        </form>
                    </td>
                </tr>
                <c:if test="${cw.type == 'ASSIGNMENT'}">
                    <tr id="submissions_cw_${cw.id}" class="assignment-submissions-details" style="display:none;">
                        <td colspan="4">
                            <h4>Submissions for: <c:out value="${cw.title}"/></h4>
                                <%-- Construct the key for accessing submissions from requestScope --%>
                            <c:set var="assignmentSubmissionsKey" value="submissions_for_cw_${cw.id}" />
                            <c:set var="assignmentSubmissions" value="${requestScope[assignmentSubmissionsKey]}" />

                            <c:if test="${empty assignmentSubmissions}">
                                <p>No submissions yet.</p>
                            </c:if>
                            <c:if test="${not empty assignmentSubmissions}">
                                <ul class="list-group">
                                    <c:forEach items="${assignmentSubmissions}" var="sub">
                                        <li class="list-group-item">
                                            <c:out value="${sub.student.fullName}"/> (<c:out value="${sub.student.email}"/>) -
                                            <a href="<c:url value='/teacher/assignment/submission/${sub.id}/download'/>">Download Submission</a>
                                            (Submitted: <fmt:formatDate value="${sub.submissionDateAsUtilDate}" pattern="yyyy-MM-dd HH:mm"/>)
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:if>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
            </tbody>
        </table>
    </c:if>

    <script>
        function toggleCourseworkFields() {
            var type = document.getElementById('courseworkType').value;
            var noteFieldsDiv = document.getElementById('noteFields');
            var quizFieldsDiv = document.getElementById('quizFields');
            var courseworkContentLabel = document.getElementById('courseworkContentLabel'); // Get label by ID

            // Hide all special fields first
            noteFieldsDiv.style.display = 'none';
            quizFieldsDiv.style.display = 'none';

            // Show fields based on type and update label
            if (type === 'NOTE') {
                noteFieldsDiv.style.display = 'block';
                courseworkContentLabel.textContent = 'Note Text / Description:';
            } else if (type === 'QUIZ') {
                quizFieldsDiv.style.display = 'block';
                courseworkContentLabel.textContent = 'Quiz Description:';
            } else if (type === 'ASSIGNMENT') {
                courseworkContentLabel.textContent = 'Assignment Details/Instructions:';
            } else {
                courseworkContentLabel.textContent = 'Description / Content:'; // Default label
            }

            // Clear file input if not NOTE to avoid submitting it accidentally
            if (type !== 'NOTE') {
                document.getElementById('fileNote').value = '';
            }
            // Clear quiz questions if not QUIZ
            if (type !== 'QUIZ') {
                document.getElementById('quizQuestionsText').value = '';
            }
        }

        function toggleSubmissions(rowId) {
            const targetRow = document.getElementById(rowId);
            if (targetRow) {
                targetRow.style.display = targetRow.style.display === 'none' ? 'table-row' : 'none';
            }
        }

        // Call on page load to set initial state of dynamic fields
        window.addEventListener('DOMContentLoaded', (event) => {
            toggleCourseworkFields();
        });
    </script>
    <br>
    <a href="<c:url value='/teacher/dashboard'/>" class="btn btn-secondary">Back to Dashboard</a>
</div>

<footer class="footer">
    <p>&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> LMS Application. All rights reserved.</p>
</footer>

</body>
</html>
