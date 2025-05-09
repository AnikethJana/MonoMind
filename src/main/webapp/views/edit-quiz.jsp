<%-- File: edit-quiz.jsp Description: Page for teachers to edit an existing quiz (title, description, questions) with an
    improved interactive interface. --%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
                <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Edit Quiz -
                            <c:out value="${quizCoursework.title}" />
                        </title>
                        <!-- Using Bootstrap for styling -->
                        <link rel="stylesheet"
                            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
                        <style>
                            body {
                                font-family: Arial, sans-serif;
                                background-color: #f4f4f4;
                                color: #333;
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
                                box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
                            }

                            .drag-handle {
                                cursor: grab;
                                margin-right: 10px;
                            }

                            .question-card {
                                border: 1px solid #ccc;
                                padding: 15px;
                                margin-bottom: 10px;
                                border-radius: 5px;
                                background-color: #fafafa;
                            }

                            .question-header {
                                display: flex;
                                justify-content: space-between;
                                align-items: center;
                            }

                            .btn-remove-question {
                                color: red;
                                background: none;
                                border: none;
                                font-size: 1.25rem;
                            }

                            .option-group {
                                display: flex;
                                align-items: center;
                                margin-bottom: 5px;
                            }

                            .option-group input[type="radio"] {
                                margin-right: 10px;
                            }

                            .option-group input[type="text"] {
                                flex: 1;
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
                        <c:set var="role" value="LMS Teacher" scope="request" />
                        <jsp:include page="components/navbar.jsp" />

                        <div class="container">
                            <c:if test="${not empty success}">
                                <p class="alert alert-success">
                                    <c:out value="${success}" />
                                </p>
                            </c:if>
                            <c:if test="${not empty error}">
                                <p class="alert alert-danger">
                                    <c:out value="${error}" />
                                </p>
                            </c:if>

                            <h2>Edit Quiz:
                                <c:out value="${quizCoursework.title}" />
                            </h2>
                            <p><strong>Course:</strong>
                                <c:out value="${quizCoursework.course.title}" />
                            </p>

                            <form method="POST"
                                action="<c:url value='/teacher/coursework/${quizCoursework.id}/quiz/update'/>"
                                class="form-styled" id="quizForm">
                                <%-- Include CSRF token if you're using Spring Security --%>
                                    <div class="mb-3">
                                        <label for="title" class="form-label">Quiz Title:</label>
                                        <input type="text" name="title" id="title" class="form-control"
                                            value="<c:out value='${quizCoursework.title}'/>" required>
                                    </div>

                                    <div class="mb-3">
                                        <label for="description" class="form-label">Description:</label>
                                        <textarea name="description" id="description" class="form-control"
                                            rows="3"><c:out value="${quizCoursework.content}"/></textarea>
                                    </div>

                                    <div class="mb-3">
                                        <label for="dueDate" class="form-label">Due Date:</label>
                                        <input type="date" name="dueDate" id="dueDate" class="form-control"
                                            value="<fmt:formatDate value='${quizCoursework.dueDate}' pattern='yyyy-MM-dd'/>">
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Quiz Questions:</label>
                                        <!-- Interactive question builder container -->
                                        <div id="questionBuilder"></div>
                                        <button type="button" class="btn btn-success mt-2" id="addQuestionBtn">+ Add
                                            Question</button>
                                        <small class="form-text text-muted">
                                            Use the interactive builder to update the quiz questions. Each question
                                            requires:
                                            <br>- A main question text
                                            <br>- An optional additional text
                                            <br>- Three options (A, B, C) with one correct answer selected.
                                        </small>
                                    </div>

                                    <!-- Hidden textarea to hold the serialized questions (formatted text) -->
                                    <textarea name="questionsText" id="questionsText" style="display:none;"></textarea>

                                    <button type="submit" class="btn btn-primary">Update Quiz</button>
                                    <a href="<c:url value='/teacher/course/${quizCoursework.course.id}/manage'/>"
                                        class="btn btn-secondary">Cancel</a>
                            </form>
                        </div>

                        <footer class="footer">
                            <p>&copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> LMS
                                    Application. All rights reserved.</p>
                        </footer>

                        <!-- Load Bootstrap JS and SortableJS for drag-and-drop functionality -->
                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                        <script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>
                        <script>
                            document.addEventListener("DOMContentLoaded", function () {
                                const questionBuilder = document.getElementById("questionBuilder");
                                const addQuestionBtn = document.getElementById("addQuestionBtn");
                                const quizForm = document.getElementById("quizForm");
                                const hiddenQuestionsText = document.getElementById("questionsText");

                                // Function to create a new question card.
                                // Notice the use of string concatenation to insert dynamic values,
                                // avoiding JS template literal syntax that JSP might parse as EL expressions.
                                function createQuestionCard(questionData) {
                                    questionData = questionData || { question: "", additional: "", options: ["", "", ""], correctOption: null };
                                    const card = document.createElement("div");
                                    card.classList.add("question-card");

                                    // Create a unique radio group name using the current timestamp.
                                    const radioGroupName = "correct_" + Date.now();

                                    var innerHTML =
                                        '<div class="question-header mb-2">' +
                                        '<span class="drag-handle">☰</span>' +
                                        '<button type="button" class="btn-remove-question" title="Remove Question">&times;</button>' +
                                        '</div>' +
                                        '<div class="mb-2">' +
                                        '<input type="text" class="form-control question-text" placeholder="Enter Question Text" value="' + questionData.question + '">' +
                                        '</div>' +
                                        '<div class="mb-2">' +
                                        '<input type="text" class="form-control additional-text" placeholder="Optional Additional Text" value="' + questionData.additional + '">' +
                                        '</div>' +
                                        '<div class="option-group mb-1">' +
                                        '<input type="radio" name="' + radioGroupName + '" class="correct-option" ' + (questionData.correctOption == 0 ? "checked" : "") + '>' +
                                        '<input type="text" class="form-control option-text" placeholder="Option A" value="' + questionData.options[0] + '">' +
                                        '</div>' +
                                        '<div class="option-group mb-1">' +
                                        '<input type="radio" name="' + radioGroupName + '" class="correct-option" ' + (questionData.correctOption == 1 ? "checked" : "") + '>' +
                                        '<input type="text" class="form-control option-text" placeholder="Option B" value="' + questionData.options[1] + '">' +
                                        '</div>' +
                                        '<div class="option-group mb-1">' +
                                        '<input type="radio" name="' + radioGroupName + '" class="correct-option" ' + (questionData.correctOption == 2 ? "checked" : "") + '>' +
                                        '<input type="text" class="form-control option-text" placeholder="Option C" value="' + questionData.options[2] + '">' +
                                        '</div>';

                                    card.innerHTML = innerHTML;

                                    // Remove question event
                                    card.querySelector(".btn-remove-question").addEventListener("click", function () {
                                        card.remove();
                                    });

                                    return card;
                                }

                                // Function to update the hidden textarea with formatted questions.
                                // It serializes the interactive inputs into the designated text format.
                                function updateFormattedQuestions() {
                                    let formatted = "";
                                    const cards = document.querySelectorAll(".question-card");
                                    cards.forEach(function (card, idx) {
                                        const qText = card.querySelector(".question-text").value.trim();
                                        if (!qText) return; // Skip if the question text is empty
                                        const additional = card.querySelector(".additional-text").value.trim();
                                        const optionElements = card.querySelectorAll(".option-group");
                                        let optionsText = "";
                                        optionElements.forEach(function (opt, index) {
                                            let optText = opt.querySelector(".option-text").value.trim();
                                            const isCorrect = opt.querySelector(".correct-option").checked;
                                            const letter = String.fromCharCode(65 + index); // A, B, C...
                                            if (isCorrect) {
                                                optText += " [*]";
                                            }
                                            optionsText += letter + ') ' + optText + "\n";
                                        });
                                        formatted += qText + "\n";
                                        if (additional) {
                                            formatted += additional + "\n";
                                        }
                                        formatted += optionsText;
                                        if (idx < cards.length - 1) {
                                            formatted += "---\n"; // Separator for the next question
                                        }
                                    });
                                    hiddenQuestionsText.value = formatted;
                                }

                                // Initialize SortableJS for drag & drop reordering of question cards.
                                Sortable.create(questionBuilder, {
                                    handle: '.drag-handle',
                                    animation: 150
                                });

                                // Add a new question card when the "Add Question" button is clicked.
                                addQuestionBtn.addEventListener("click", function () {
                                    const newCard = createQuestionCard();
                                    questionBuilder.appendChild(newCard);
                                });

                                // Parse initial questions from the server if available.
                                // The hidden textarea (questionsText) is populated from the server via the JSP variable "initialQuestionsTextForEdit".
                                function parseInitialQuestions() {
                                    const initialText = document.getElementById("questionsText").textContent || "";
                                    if (!initialText.trim()) return;
                                    const questionBlocks = initialText.split(/---\s*\n/);
                                    questionBlocks.forEach(function (block) {
                                        const lines = block.split("\n").filter(l => l.trim() !== "");
                                        if (lines.length >= 4) { // Ensure there are enough lines (question text and options)
                                            let question = lines[0];
                                            let additional = "";
                                            let index = 1;
                                            // If the second line does not start with "A)", treat it as additional text.
                                            if (lines[1].trim().substring(0, 2) !== "A)") {
                                                additional = lines[1];
                                                index = 2;
                                            }
                                            const options = [];
                                            let correctOption = null;
                                            for (let i = index; i < lines.length; i++) {
                                                const line = lines[i].trim();
                                                const match = line.match(/^([A-C])\)\s*(.*)$/);
                                                if (match) {
                                                    let content = match[2];
                                                    if (content.includes("[*]")) {
                                                        content = content.replace("[*]", "").trim();
                                                        correctOption = i - index; // 0 for A, 1 for B, 2 for C
                                                    }
                                                    options.push(content);
                                                }
                                            }
                                            // Ensure there are exactly 3 options.
                                            while (options.length < 3) { options.push(""); }
                                            const card = createQuestionCard({
                                                question: question,
                                                additional: additional,
                                                options: options,
                                                correctOption: correctOption
                                            });
                                            questionBuilder.appendChild(card);
                                        }
                                    });
                                }

                                // Load the server's initial questions into the builder.
                                (function loadInitialQuestions() {
                                    // Inject the server value into the hidden textarea. Use JSTL to output safely.
                                    const initial = `<c:out value="${initialQuestionsTextForEdit}"/>`;
                                    document.getElementById("questionsText").textContent = initial;
                                    parseInitialQuestions();
                                })();

                                // Auto-save quiz data to localStorage every 5 seconds,
                                // minimizing risk of data loss during editing.
                                function autoSave() {
                                    const quizData = {
                                        title: document.getElementById("title").value,
                                        description: document.getElementById("description").value,
                                        questions: questionBuilder.innerHTML // Optional: could serialize further if needed.
                                    };
                                    localStorage.setItem("quizDraft", JSON.stringify(quizData));
                                }
                                // Attempt to restore saved draft data on load.
                                (function restoreAutoSave() {
                                    const saved = localStorage.getItem("quizDraft");
                                    if (saved) {
                                        const data = JSON.parse(saved);
                                        document.getElementById("title").value = data.title || "";
                                        document.getElementById("description").value = data.description || "";
                                        // Restoring questions can be enhanced with a parse function if needed.
                                    }
                                })();

                                setInterval(autoSave, 5000);

                                // Before form submission, update the hidden textarea with the formatted questions.
                                quizForm.addEventListener("submit", function (e) {
                                    updateFormattedQuestions();
                                });
                            });
                        </script>

                    </body>

                    </html>