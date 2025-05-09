<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <html>

        <head>
            <title>Create New Course</title>
            <style>
                body {
                    font-family: sans-serif;
                    margin: 0;
                    padding: 0;
                    background-color: #f8f9fa;
                    color: #333;
                }

                .container {
                    padding: 20px;
                    max-width: 700px;
                    margin: 20px auto;
                    background-color: #fff;
                    border-radius: 8px;
                    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                }

                h2 {
                    color: #1e7e34;
                    border-bottom: 2px solid #1e7e34;
                    padding-bottom: 10px;
                }

                .form-group {
                    margin-bottom: 15px;
                }

                label {
                    display: block;
                    margin-bottom: 5px;
                    font-weight: bold;
                }

                input[type="text"],
                textarea {
                    width: calc(100% - 22px);
                    padding: 10px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                }

                textarea {
                    min-height: 100px;
                    resize: vertical;
                }

                .btn-submit {
                    background-color: #007bff;
                    color: white;
                    padding: 10px 15px;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                    font-size: 16px;
                }

                .btn-submit:hover {
                    background-color: #0056b3;
                }

                .link-back {
                    display: inline-block;
                    margin-top: 15px;
                    color: #007bff;
                    text-decoration: none;
                }

                .link-back:hover {
                    text-decoration: underline;
                }
            </style>
        </head>

        <body>
            <c:set var="role" value="LMS Teacher" scope="request" />
            <jsp:include page="components/navbar.jsp" />

            <div class="container">
                <h2>Create New Course</h2>
                <form method="post" action="<c:url value='/teacher/course/create'/>">
                    <div class="form-group">
                        <label for="title">Course Title:</label>
                        <input type="text" id="title" name="title" required>
                    </div>
                    <div class="form-group">
                        <label for="description">Course Description:</label>
                        <textarea id="description" name="description" rows="4" required></textarea>
                    </div>
                    <div>
                        <button type="submit" class="btn-submit">Create Course</button>
                    </div>
                </form>
                <a href="<c:url value='/teacher/dashboard'/>" class="link-back">&laquo; Back to Dashboard</a>
            </div>
        </body>

        </html>