<%-- File: view-coursework-student.jsp Description: Page for students to view details of a specific piece of coursework
    (Note, Assignment, or Quiz). This version is self-contained. --%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
                <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>View Coursework -
                            <c:out value="${coursework.title}" />
                        </title>
                        <link rel="stylesheet"
                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                        <link rel="stylesheet" href="<c:url value='/styles/view-coursework-student.css'/>">
                    </head>

                    <body class="lms-dark-theme">

                        <nav class="navbar">
                            <div class="navbar-container">
                                <div class="navbar-brand">
                                    <a href="<c:url value='/home'/>">
                                        <i class="fas fa-graduation-cap"></i> LMS
                                    </a>
                                </div>
                                <div class="navbar-links">
                                    <a href="<c:url value='/home'/>">Home</a>
                                    <c:if test="${not empty sessionScope.user}">
                                        <span class="user-info">
                                            Logged in as:
                                            <c:out value="${sessionScope.user.fullName}" /> (
                                            <c:out value="${sessionScope.user.role}" />) |
                                            <a href="<c:url value='/logout'/>">Logout</a>
                                        </span>
                                    </c:if>
                                    <c:if test="${empty sessionScope.user}">
                                        <a href="<c:url value='/login'/>">Login</a>
                                        <a href="<c:url value='/register'/>">Register</a>
                                    </c:if>
                                </div>
                            </div>
                        </nav>

                        <div class="container">
                            <c:if test="${not empty success}">
                                <div class="alert alert-success">
                                    <i class="fas fa-check-circle"></i>
                                    <c:out value="${success}" />
                                </div>
                            </c:if>
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">
                                    <i class="fas fa-exclamation-circle"></i>
                                    <c:out value="${error}" />
                                </div>
                            </c:if>

                            <div class="breadcrumb">
                                <a href="<c:url value='/home'/>">Home</a>
                                <i class="fas fa-angle-right"></i>
                                <a href="<c:url value='/student/course/${course.id}'/>">${course.title}</a>
                                <i class="fas fa-angle-right"></i>
                                <span>
                                    <c:out value="${coursework.title}" />
                                </span>
                            </div>

                            <div class="assignment-header">
                                <span class="assignment-tag">
                                    <c:out value="${coursework.type}" />
                                </span>
                                <span class="assignment-due">Due:
                                    <fmt:formatDate value="${coursework.dueDate}" pattern="MMM d, yyyy" />
                                </span>
                            </div>

                            <div class="main-content">
                                <div class="content-left">
                                    <div class="content-card">
                                        <h2 class="content-title">Instructions</h2>
                                        <div class="content-body">
                                            <c:choose>
                                                <c:when test="${coursework.type == 'NOTE'}">
                                                    <div style="white-space: pre-wrap;">
                                                        <c:out value="${coursework.content}" />
                                                    </div>
                                                    <c:if test="${not empty coursework.filePath}">
                                                        <p><strong>Attached File:</strong> <a
                                                                href="<c:url value='/student/coursework/note/${coursework.id}/viewfile'/>"
                                                                target="_blank" class="btn btn-link">
                                                                <c:out value="${coursework.originalFileName}" />
                                                            </a></p>
                                                    </c:if>
                                                </c:when>

                                                <c:when test="${coursework.type == 'ASSIGNMENT'}">
                                                    <div style="white-space: pre-wrap;">
                                                        <c:out value="${coursework.content}" />
                                                    </div>
                                                </c:when>

                                                <c:when test="${coursework.type == 'QUIZ'}">
                                                    <div style="white-space: pre-wrap;">
                                                        <c:out value="${coursework.content}" />
                                                    </div>
                                                </c:when>

                                                <c:otherwise>
                                                    <p class="alert alert-secondary">Content for this coursework type is
                                                        not specifically displayed here. General details:
                                                        <c:out value="${coursework.content}" />
                                                    </p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <c:choose>
                                        <c:when test="${coursework.type == 'ASSIGNMENT'}">
                                            <div class="content-card">
                                                <h2 class="content-title">Submit Your Assignment</h2>
                                                <div class="content-body">
                                                    <c:if test="${not empty existingSubmission}">
                                                        <div class="submission-info">
                                                            <i class="fas fa-check-circle"></i>
                                                            <div class="submission-details">
                                                                <p>Previously submitted on
                                                                    <fmt:formatDate
                                                                        value="${existingSubmission.submissionDateAsUtilDate}"
                                                                        pattern="MMM d, yyyy 'at' HH:mm" />
                                                            </div>
                                                        </div>
                                                    </c:if>

                                                    <div class="file-upload-container">
                                                        <div class="file-upload-area">
                                                            <i class="fas fa-cloud-upload-alt"></i>
                                                            <p>Drop your file here or click to upload</p>
                                                            <p class="file-upload-limit">Maximum file size: 10MB</p>
                                                        </div>
                                                        <button type="button" class="btn btn-primary btn-resubmit">
                                                            <c:choose>
                                                                <c:when test="${not empty existingSubmission}">Re-submit
                                                                    Assignment</c:when>
                                                                <c:otherwise>Submit Assignment</c:otherwise>
                                                            </c:choose>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:when>

                                        <c:when test="${coursework.type == 'QUIZ'}">
                                            <div class="content-card">
                                                <h2 class="content-title">Take Quiz</h2>
                                                <div class="content-body">
                                                    <c:if test="${not empty existingQuizSubmission}">
                                                        <div class="submission-info">
                                                            <i class="fas fa-check-circle"></i>
                                                            <div class="submission-details">
                                                                <p>Quiz completed on
                                                                    <fmt:formatDate
                                                                        value="${existingQuizSubmission.submittedAtAsUtilDate}"
                                                                        pattern="MMM d, yyyy 'at' HH:mm" />
                                                                </p>
                                                                <p>Score: ${existingQuizSubmission.totalCorrectAnswers}
                                                                    / ${existingQuizSubmission.totalQuestionsAttempted}
                                                                    (${existingQuizSubmission.percentageScore}%)</p>
                                                            </div>
                                                        </div>
                                                    </c:if>

                                                    <c:if
                                                        test="${empty existingQuizSubmission && not empty quizQuestions}">
                                                        <form id="quizForm" method="POST"
                                                            action="<c:url value='/student/quiz/${coursework.id}/submit'/>">
                                                            <c:forEach items="${quizQuestions}" var="question"
                                                                varStatus="status">
                                                                <div class="quiz-question-card">
                                                                    <p class="quiz-question-text">
                                                                        ${question.questionText}
                                                                    </p>
                                                                    <div class="quiz-options-container">
                                                                        <c:forEach items="${question.options}"
                                                                            var="option" varStatus="optStatus">
                                                                            <div class="quiz-option">
                                                                                <input type="radio"
                                                                                    id="q${status.index}opt${optStatus.index}"
                                                                                    name="answer_q${status.index}"
                                                                                    value="${optStatus.index}" required>
                                                                                <label
                                                                                    for="q${status.index}opt${optStatus.index}">${option}</label>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                            <button type="submit"
                                                                class="btn btn-primary btn-submit-quiz mt-3">Submit
                                                                Quiz</button>
                                                        </form>
                                                    </c:if>

                                                    <c:if
                                                        test="${not empty existingQuizSubmission && not empty quizQuestions && not empty submittedAnswers}">
                                                        <div id="quizReviewSection" style="display: none;" class="mt-3">
                                                            <h3 class="quiz-review-title">Quiz Review</h3>
                                                            <c:forEach items="${quizQuestions}" var="question"
                                                                varStatus="status">
                                                                <div class="quiz-question-card">
                                                                    <p class="quiz-question-text">
                                                                        ${question.questionText}
                                                                    </p>
                                                                    <div class="quiz-options-container">
                                                                        <c:forEach items="${question.options}"
                                                                            var="option" varStatus="optStatus">
                                                                            <div
                                                                                class="quiz-option 
                                                                                ${submittedAnswers[status.index.toString()] == optStatus.index ? 'selected-option' : ''}
                                                                                ${optStatus.index == question.correctOptionIndex ? 'correct-option' : ''}
                                                                                ${submittedAnswers[status.index.toString()] == optStatus.index && submittedAnswers[status.index.toString()] != question.correctOptionIndex ? 'incorrect-option' : ''}">
                                                                                <span class="option-indicator"></span>
                                                                                <span
                                                                                    class="option-text">${option}</span>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                        <button id="reviewQuizBtn"
                                                            class="btn btn-primary btn-review-quiz">Review Quiz</button>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:when>
                                    </c:choose>
                                </div>

                                <div class="content-right">
                                    <div class="content-card">
                                        <h2 class="content-title">Assignment Details</h2>
                                        <div class="content-body">
                                            <div class="details-grid">
                                                <div class="detail-item">
                                                    <span class="detail-label">Status</span>
                                                    <span class="detail-value status-submitted">
                                                        <c:choose>
                                                            <c:when
                                                                test="${coursework.type == 'ASSIGNMENT' && not empty existingSubmission}">
                                                                Submitted</c:when>
                                                            <c:when
                                                                test="${coursework.type == 'QUIZ' && not empty existingQuizSubmission}">
                                                                Completed</c:when>
                                                            <c:when test="${coursework.type == 'NOTE'}">No submission
                                                                required</c:when>
                                                            <c:otherwise>Not Submitted</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <div class="detail-item">
                                                    <span class="detail-label">Due Date</span>
                                                    <span class="detail-value">
                                                        <fmt:formatDate value="${coursework.dueDate}"
                                                            pattern="MMM d, yyyy" />
                                                    </span>
                                                </div>
                                                <div class="detail-item">
                                                    <span class="detail-label">Grade</span>
                                                    <span class="detail-value">${existingSubmission.grade}</span>
                                                </div>
                                                <div class="detail-item">
                                                    <span class="detail-label">Attempts</span>
                                                    <span class="detail-value">
                                                        <c:choose>
                                                            <c:when
                                                                test="${coursework.type == 'ASSIGNMENT' && not empty existingSubmissions}">
                                                                ${fn:length(existingSubmissions)}</c:when>
                                                            <c:when
                                                                test="${coursework.type == 'QUIZ' && not empty existingQuizSubmission}">
                                                                1</c:when>
                                                            <c:when test="${coursework.type == 'NOTE'}">N/A</c:when>
                                                            <c:otherwise>0</c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${coursework.type != 'NOTE'}">/3</c:if>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <footer class="footer">
                            <p>&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> LMS
                                    Application. All rights reserved.</p>
                        </footer>

                        <script>
                            // JavaScript for handling file uploads
                            document.addEventListener('DOMContentLoaded', function () {
                                const fileUploadArea = document.querySelector('.file-upload-area');
                                const resubmitButton = document.querySelector('.btn-resubmit');
                                const reviewQuizBtn = document.getElementById('reviewQuizBtn');
                                const quizReviewSection = document.getElementById('quizReviewSection');

                                if (fileUploadArea) {
                                    fileUploadArea.addEventListener('click', function () {
                                        // Create a file input element
                                        const fileInput = document.createElement('input');
                                        fileInput.type = 'file';
                                        fileInput.style.display = 'none';

                                        // Trigger click on the file input
                                        document.body.appendChild(fileInput);
                                        fileInput.click();

                                        // Handle file selection
                                        fileInput.addEventListener('change', function () {
                                            if (fileInput.files.length > 0) {
                                                const fileName = fileInput.files[0].name;
                                                // You can display the selected file name
                                                // and prepare for submission
                                                alert('Selected file: ' + fileName);
                                            }
                                            document.body.removeChild(fileInput);
                                        });
                                    });
                                }

                                if (resubmitButton) {
                                    resubmitButton.addEventListener('click', function () {
                                        // Handle submission logic here
                                        alert('Assignment submission button clicked');
                                    });
                                }

                                // Handle quiz review button
                                if (reviewQuizBtn && quizReviewSection) {
                                    reviewQuizBtn.addEventListener('click', function () {
                                        // Toggle the review section
                                        if (quizReviewSection.style.display === 'none') {
                                            quizReviewSection.style.display = 'block';
                                            reviewQuizBtn.textContent = 'Hide Review';
                                        } else {
                                            quizReviewSection.style.display = 'none';
                                            reviewQuizBtn.textContent = 'Review Quiz';
                                        }
                                    });
                                }
                            });
                        </script>

                    </body>

                    </html>