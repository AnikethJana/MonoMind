<%--
  File: view-coursework-student.jsp
  Description: Page for students to view details of a specific piece of coursework (Note, Assignment, or Quiz).
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
    <title>View Coursework - <c:out value="${coursework.title}"/></title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; color: #333; line-height: 1.6; }
        .navbar { background-color: #333; color: #fff; padding: 1rem; text-align: center; }
        .navbar a { color: #fff; margin: 0 15px; text-decoration: none; }
        .navbar a:hover { text-decoration: underline; }
        .container { width: 85%; margin: 20px auto; padding: 20px; background-color: #fff; border-radius: 8px; box-shadow: 0 0 15px rgba(0,0,0,0.1); }
        h1, h2, h3, h4, h5 { color: #333; margin-top: 0; }
        hr { border: 0; height: 1px; background: #ddd; margin: 20px 0; }
        .form-styled .form-group { margin-bottom: 1.5rem; }
        .form-styled label { display: block; margin-bottom: .5rem; font-weight: bold; }
        .form-styled .form-control, .form-styled .form-control-file, .form-styled select {
            width: calc(100% - 24px); padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;
        }
        .form-styled .form-check-input { width: auto; margin-right: 5px; }
        .form-styled .form-check-label { font-weight: normal; }
        .btn { display: inline-block; padding: 10px 18px; font-size: 1rem; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; color: #fff; transition: background-color 0.3s ease; margin-right: 5px; margin-bottom: 5px;}
        .btn-primary { background-color: #007bff; } .btn-primary:hover { background-color: #0056b3; }
        .btn-secondary { background-color: #6c757d; } .btn-secondary:hover { background-color: #545b62; }
        .btn-link { background-color: transparent; color: #007bff; text-decoration: underline; padding: 0; }
        .alert { padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: 4px; }
        .alert-success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
        .alert-danger { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
        .alert-info { color: #0c5460; background-color: #d1ecf1; border-color: #bee5eb; }
        .alert-warning { color: #856404; background-color: #fff3cd; border-color: #ffeeba; }
        .user-info { float: right; font-size: 0.9em; }
        .card { border: 1px solid #ddd; border-radius: 5px; margin-bottom: 1rem; }
        .card-body { padding: 1.25rem; }
        .bg-light { background-color: #f8f9fa !important; }
        .quiz-question { border: 1px solid #eee; padding: 15px; margin-bottom: 15px; border-radius: 5px; background-color: #f9f9f9;}
        .quiz-question h5 { margin-top: 0; }
        .bg-success-light { background-color: #e6ffed !important; border-left: 5px solid #28a745; padding: 10px; margin-bottom:10px; }
        .bg-danger-light { background-color: #ffe6e6 !important; border-left: 5px solid #dc3545; padding: 10px; margin-bottom:10px; }
        .text-success { color: #28a745 !important; }
        .text-danger { color: #dc3545 !important; }
        .text-warning { color: #ffc107 !important; }
        .font-weight-bold { font-weight: bold !important; }
        .list-unstyled { padding-left: 0; list-style: none; }
        .badge { display: inline-block; padding: .35em .65em; font-size: .75em; font-weight: 700; line-height: 1; color: #fff; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: .25rem; }
        .badge-info { background-color: #17a2b8; }
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

    <h2>Course: <a href="<c:url value='/student/course/${course.id}'/>"><c:out value="${course.title}"/></a></h2>
    <hr>
    <h3>Coursework: <c:out value="${coursework.title}"/></h3>
    <p><strong>Type:</strong> <span class="badge badge-info"><c:out value="${fn:toLowerCase(fn:replace(coursework.type, '_', ' '))}"/></span></p>

    <c:choose>
        <c:when test="${coursework.type == 'NOTE'}">
            <h4>Details:</h4>
            <div class="card card-body bg-light mb-3" style="white-space: pre-wrap;">
                <c:out value="${coursework.content}"/>
            </div>
            <c:if test="${not empty coursework.filePath}">
                <p><strong>Attached File:</strong> <a href="<c:url value='/student/coursework/note/${coursework.id}/viewfile'/>" target="_blank" class="btn btn-link"><c:out value="${coursework.originalFileName}"/></a></p>
            </c:if>
        </c:when>

        <c:when test="${coursework.type == 'ASSIGNMENT'}">
            <h4>Instructions:</h4>
            <div class="card card-body bg-light mb-3" style="white-space: pre-wrap;">
                <c:out value="${coursework.content}"/>
            </div>
            <hr>
            <h4>Submit Your Assignment</h4>
            <c:if test="${not empty existingSubmission}">
                <div class="alert alert-success">
                    You have already submitted this assignment on
                    <fmt:formatDate value="${existingSubmission.submissionDateAsUtilDate}" pattern="yyyy-MM-dd HH:mm"/>.
                    File: <c:out value="${existingSubmission.originalFileName}"/>
                </div>
            </c:if>
            <form method="POST" action="<c:url value='/student/assignment/${coursework.id}/submit'/>" enctype="multipart/form-data" class="form-styled">
                <div class="form-group">
                    <label for="assignmentFile">Upload your assignment file:</label>
                    <input type="file" name="assignmentFile" id="assignmentFile" class="form-control-file" required>
                </div>
                <button type="submit" class="btn btn-primary">
                    <c:choose>
                        <c:when test="${not empty existingSubmission}">Re-submit Assignment</c:when>
                        <c:otherwise>Submit Assignment</c:otherwise>
                    </c:choose>
                </button>
            </form>
        </c:when>

        <c:when test="${coursework.type == 'QUIZ'}">
            <h4>Description:</h4>
            <div class="card card-body bg-light mb-3" style="white-space: pre-wrap;">
                <c:out value="${coursework.content}"/>
            </div>
            <hr>
            <c:if test="${not empty existingQuizSubmission}">
                <h4>Your Quiz Result:</h4>
                <div class="alert alert-info">
                    <p><strong>Score:</strong> <c:out value="${existingQuizSubmission.totalCorrectAnswers}"/> / <c:out value="${existingQuizSubmission.totalQuestionsAttempted}"/></p>
                    <p><strong>Percentage:</strong> <c:out value="${existingQuizSubmission.percentageScore}"/>%</p>
                    <p>Submitted on: <fmt:formatDate value="${existingQuizSubmission.submittedAtAsUtilDate}" pattern="yyyy-MM-dd HH:mm"/></p>
                </div>

                <c:if test="${not empty quizQuestions && not empty submittedAnswers}">
                    <h4>Review Your Answers:</h4>
                    <c:forEach items="${quizQuestions}" var="question" varStatus="qLoop">
                        <div class="quiz-question ${submittedAnswers[qLoop.index] == question.correctOptionIndex ? 'bg-success-light' : (submittedAnswers[qLoop.index] != null ? 'bg-danger-light' : 'bg-light')}">
                            <p><strong>Q${qLoop.index + 1}:</strong> <c:out value="${question.questionText}"/></p>
                            <ul class="list-unstyled">
                                <c:forEach items="${question.options}" var="optionText" varStatus="optLoop">
                                    <li>
                                        <c:if test="${optLoop.index == submittedAnswers[qLoop.index]}">
                                            <strong class="${optLoop.index == question.correctOptionIndex ? 'text-success' : 'text-danger'}">
                                                <c:out value="${optionText}"/> (Your Answer)
                                            </strong>
                                        </c:if>
                                        <c:if test="${optLoop.index != submittedAnswers[qLoop.index]}">
                                            <c:out value="${optionText}"/>
                                        </c:if>
                                        <c:if test="${optLoop.index == question.correctOptionIndex}">
                                            <span class="text-success font-weight-bold"> (Correct Answer)</span>
                                        </c:if>
                                    </li>
                                </c:forEach>
                            </ul>
                            <c:if test="${submittedAnswers[qLoop.index] == null && question.correctOptionIndex != -1}">
                                <p class="text-warning">You did not answer this question. Correct answer was: <c:out value="${question.options[question.correctOptionIndex]}"/></p>
                            </c:if>
                        </div>
                    </c:forEach>
                </c:if>
            </c:if>

            <c:if test="${empty existingQuizSubmission and not empty quizQuestions}">
                <h4>Attempt Quiz:</h4>
                <form method="POST" action="<c:url value='/student/quiz/${coursework.id}/submit'/>" class="form-styled">
                    <c:forEach items="${quizQuestions}" var="question" varStatus="loop">
                        <div class="quiz-question card card-body mb-3">
                            <h5>Question ${loop.index + 1}: <c:out value="${question.questionText}"/></h5>
                            <c:forEach items="${question.options}" var="option" varStatus="optLoop">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="answer_q${loop.index}" id="q${loop.index}_opt${optLoop.index}" value="${optLoop.index}" required>
                                    <label class="form-check-label" for="q${loop.index}_opt${optLoop.index}"><c:out value="${option}"/></label>
                                </div>
                            </c:forEach>
                        </div>
                    </c:forEach>
                    <button type="submit" class="btn btn-primary">Submit Quiz</button>
                </form>
            </c:if>
            <c:if test="${empty existingQuizSubmission and empty quizQuestions}">
                <p class="alert alert-warning">This quiz currently has no questions or is not available for submission.</p>
            </c:if>
        </c:when>

        <c:otherwise>
            <p class="alert alert-secondary">Content for this coursework type is not specifically displayed here. General details: <c:out value="${coursework.content}"/></p>
        </c:otherwise>
    </c:choose>

    <br><br>
    <a href="<c:url value='/student/course/${course.id}'/>" class="btn btn-secondary">Back to Course</a>
</div>

<footer class="footer">
    <p>&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> LMS Application. All rights reserved.</p>
</footer>

</body>
</html>
