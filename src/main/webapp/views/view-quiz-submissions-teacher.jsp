<%--
  File: view-quiz-submissions-teacher.jsp
  Description: Page for teachers to view student submissions for a specific quiz.
               This version is self-contained and does not rely on external header/footer includes.
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
    <title>Quiz Submissions - <c:out value="${quiz.title}"/></title>
    <style>
        /* Basic Styling - Adapt to your project's needs */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
            line-height: 1.6;
        }
        .navbar {
            background-color: #333;
            color: #fff;
            padding: 1rem;
            text-align: center;
        }
        .navbar a {
            color: #fff;
            margin: 0 15px;
            text-decoration: none;
        }
        .navbar a:hover {
            text-decoration: underline;
        }
        .container {
            width: 85%;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
        h1, h2, h3, h4, h5, h6 {
            color: #333;
            margin-top: 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 2px 3px rgba(0,0,0,0.1);
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #f0f0f0;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .btn {
            display: inline-block;
            padding: 10px 18px;
            font-size: 1rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            color: #fff;
            transition: background-color 0.3s ease;
        }
        .btn-primary { background-color: #007bff; }
        .btn-primary:hover { background-color: #0056b3; }
        .btn-secondary { background-color: #6c757d; }
        .btn-secondary:hover { background-color: #545b62; }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        .alert-info {
            color: #0c5460;
            background-color: #d1ecf1;
            border-color: #bee5eb;
        }
        .user-info {
            float: right;
            font-size: 0.9em;
        }
        .footer {
            text-align: center;
            padding: 20px 0;
            margin-top: 30px;
            background-color: #333;
            color: #fff;
            font-size: 0.9em;
        }
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
    <%-- Display success/error messages if any (from RedirectAttributes) --%>
    <c:if test="${not empty success}">
        <p class="alert alert-success"><c:out value="${success}"/></p>
    </c:if>
    <c:if test="${not empty error}">
        <p class="alert alert-danger"><c:out value="${error}"/></p>
    </c:if>

    <h2>Submissions for Quiz: <c:out value="${quiz.title}"/></h2>
    <p><strong>Course:</strong> <a href="<c:url value='/teacher/course/${course.id}/manage'/>"><c:out value="${course.title}"/></a></p>
    <p><strong>Quiz Description:</strong> <c:out value="${quiz.content}"/></p>

    <c:if test="${not empty submissions}">
        <table class="table table-hover">
            <thead>
            <tr>
                <th>Student Name</th>
                <th>Student Email</th>
                <th>Correct Answers</th>
                <th>Total Questions</th>
                <th>Percentage</th>
                <th>Submitted At</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${submissions}" var="submission">
                <tr>
                    <td><c:out value="${submission.student.fullName}"/></td>
                    <td><c:out value="${submission.student.email}"/></td>
                    <td><c:out value="${submission.totalCorrectAnswers}"/></td>
                    <td><c:out value="${submission.totalQuestionsAttempted}"/></td>
                    <td><c:out value="${submission.percentageScore}"/>%</td>
                    <td><fmt:formatDate value="${submission.submittedAtAsUtilDate}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>
    <c:if test="${empty submissions}">
        <p class="alert alert-info">No submissions yet for this quiz.</p>
    </c:if>

    <br>
    <a href="<c:url value='/teacher/course/${quiz.course.id}/manage'/>" class="btn btn-secondary">Back to Course Management</a>
</div>

<footer class="footer">
    <p>&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> LMS Application. All rights reserved.</p>
</footer>

</body>
</html>
