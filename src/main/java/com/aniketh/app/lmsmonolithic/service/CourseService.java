package com.aniketh.app.lmsmonolithic.service;

import com.aniketh.app.lmsmonolithic.model.*;
import com.aniketh.app.lmsmonolithic.repository.AssignmentSubmissionRepository;
import com.aniketh.app.lmsmonolithic.repository.CourseRepository;
import com.aniketh.app.lmsmonolithic.repository.CourseworkRepository;
import com.aniketh.app.lmsmonolithic.repository.UserRepository;
import com.aniketh.app.lmsmonolithic.repository.QuizSubmissionRepository; // New import
import com.fasterxml.jackson.core.JsonProcessingException; // New import
import com.fasterxml.jackson.core.type.TypeReference; // New import
import com.fasterxml.jackson.databind.ObjectMapper; // New import
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.ArrayList; // New import
import java.util.Date;
import java.util.List;
import java.util.Map; // New import
import java.util.Optional;
import java.util.UUID;

@Service
public class CourseService {

    private final CourseRepository courseRepository;
    private final CourseworkRepository courseworkRepository;
    private final UserRepository userRepository;
    private final AssignmentSubmissionRepository assignmentSubmissionRepository;
    private final QuizSubmissionRepository quizSubmissionRepository; // New field
    private final ObjectMapper objectMapper; // For JSON processing

    private final String NOTE_UPLOAD_DIR = "./uploads/course_notes/";
    private final String ASSIGNMENT_SUBMISSION_DIR = "./uploads/assignment_submissions/";

    @Autowired
    public CourseService(CourseRepository courseRepository,
            CourseworkRepository courseworkRepository,
            UserRepository userRepository,
            AssignmentSubmissionRepository assignmentSubmissionRepository,
            QuizSubmissionRepository quizSubmissionRepository) { // Added quizSubmissionRepository
        this.courseRepository = courseRepository;
        this.courseworkRepository = courseworkRepository;
        this.userRepository = userRepository;
        this.assignmentSubmissionRepository = assignmentSubmissionRepository;
        this.quizSubmissionRepository = quizSubmissionRepository; // Initialize
        this.objectMapper = new ObjectMapper(); // Initialize ObjectMapper

        try {
            Files.createDirectories(Paths.get(NOTE_UPLOAD_DIR));
            Files.createDirectories(Paths.get(ASSIGNMENT_SUBMISSION_DIR));
        } catch (IOException e) {
            System.err.println("Could not create upload directories: " + e.getMessage());
        }
    }

    @Transactional
    public Course createCourse(String title, String description, Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new IllegalArgumentException("Teacher not found with ID: " + teacherId));
        Course course = new Course(title, description, teacher);
        return courseRepository.save(course);
    }

    public List<Course> getCoursesByTeacher(Long teacherId) {
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new IllegalArgumentException("Teacher not found with ID: " + teacherId));
        return courseRepository.findByTeacher(teacher);
    }

    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }

    public Optional<Course> getCourseById(Long courseId) {
        return courseRepository.findById(courseId);
    }

    @Transactional
    public boolean enrollStudent(Long courseId, Long studentId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new IllegalArgumentException("Course not found with ID: " + courseId));
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with ID: " + studentId));

        // Check if student is already enrolled
        if (course.getEnrolledStudents().contains(student)) {
            return false; // Student already enrolled
        }

        // Add student to the course
        course.getEnrolledStudents().add(student);
        courseRepository.save(course);
        return true;
    }

    @Transactional
    public boolean unenrollStudent(Long courseId, Long studentId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new IllegalArgumentException("Course not found with ID: " + courseId));
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with ID: " + studentId));

        boolean removed = course.getEnrolledStudents().removeIf(s -> s.getId().equals(studentId));
        if (removed) {
            courseRepository.save(course);
        }
        return removed;
    }

    public List<Course> getEnrolledCourses(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Student not found with ID: " + studentId));

        // Get all courses where student is enrolled
        List<Course> allCourses = courseRepository.findAll();
        List<Course> enrolledCourses = new ArrayList<>();

        for (Course course : allCourses) {
            if (course.getEnrolledStudents().contains(student)) {
                enrolledCourses.add(course);
            }
        }

        return enrolledCourses;
    }

    public boolean isStudentEnrolled(Long courseId, Long studentId) {
        Course course = courseRepository.findById(courseId).orElse(null);
        User student = userRepository.findById(studentId).orElse(null);

        if (course == null || student == null) {
            return false;
        }

        return course.getEnrolledStudents().contains(student);
    }

    @Transactional
    public Coursework addCourseworkToCourse(Long courseId, String title, CourseworkType type, String textContent,
            MultipartFile file, String quizQuestionsRawText, Date dueDate) throws IOException {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new IllegalArgumentException("Course not found with ID: " + courseId));

        Coursework coursework = new Coursework(title, type, textContent, course); // textContent is description for quiz
        coursework.setDueDate(dueDate);

        if (type == CourseworkType.NOTE && file != null && !file.isEmpty()) {
            String originalFileName = org.springframework.util.StringUtils.cleanPath(file.getOriginalFilename());
            String uniqueFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            Path courseNoteDir = Paths.get(NOTE_UPLOAD_DIR, String.valueOf(courseId));
            Files.createDirectories(courseNoteDir);

            Path targetLocation = courseNoteDir.resolve(uniqueFileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            coursework.setFilePath(targetLocation.toString());
            coursework.setOriginalFileName(originalFileName);
            coursework.setFileMimeType(file.getContentType());
            // coursework.setContent("File attached: " + originalFileName); // This was
            // original behavior
            coursework.setContent(textContent); // Keep description if provided
        } else if (type == CourseworkType.NOTE || type == CourseworkType.ASSIGNMENT) {
            coursework.setContent(textContent);
        } else if (type == CourseworkType.QUIZ) {
            coursework.setContent(textContent); // Use textContent for quiz description
            if (quizQuestionsRawText != null && !quizQuestionsRawText.isBlank()) {
                List<QuizQuestion> questions = parseQuizQuestionsFromText(quizQuestionsRawText);
                try {
                    coursework.setQuestionsJson(objectMapper.writeValueAsString(questions));
                } catch (JsonProcessingException e) {
                    throw new IllegalArgumentException("Error processing quiz questions JSON: " + e.getMessage());
                }
            } else {
                coursework.setQuestionsJson("[]"); // Empty quiz
            }
        } else {
            coursework.setContent(textContent);
        }

        return courseworkRepository.save(coursework);
    }

    public List<Coursework> getCourseworkForCourse(Long courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new IllegalArgumentException("Course not found with ID: " + courseId));
        return courseworkRepository.findByCourse(course);
    }

    public Optional<Coursework> getCourseworkById(Long courseworkId) {
        return courseworkRepository.findById(courseworkId);
    }

    // Helper to parse questions from text area (KISS approach)
    // Example format per question:
    // Question text line 1
    // Question text line 2 (if any)
    // A) Option 1
    // B) Option 2 [*]
    // C) Option 3
    // --- (separator)
    private List<QuizQuestion> parseQuizQuestionsFromText(String rawText) {
        List<QuizQuestion> questions = new ArrayList<>();
        if (rawText == null || rawText.isBlank())
            return questions;

        String[] questionBlocks = rawText.split("---"); // Split by "---" separator

        for (String block : questionBlocks) {
            block = block.trim();
            if (block.isEmpty())
                continue;

            String[] lines = block.split("\\r?\\n"); // Split each block by lines
            if (lines.length < 2)
                continue; // Need at least question and one option

            StringBuilder qTextBuilder = new StringBuilder();
            List<String> options = new ArrayList<>();
            int correctOptionIdx = -1;
            int lineIndex = 0;

            // Assume first lines until an option marker (A), B), etc.) are question text
            while (lineIndex < lines.length && !lines[lineIndex].trim().matches("^[A-Za-z][).].*")) {
                qTextBuilder.append(lines[lineIndex].trim()).append(" ");
                lineIndex++;
            }
            String questionText = qTextBuilder.toString().trim();
            if (questionText.isEmpty())
                continue;

            for (int i = lineIndex; i < lines.length; i++) {
                String line = lines[i].trim();
                if (line.matches("^[A-Za-z][).].*")) { // Simple check for option lines like "A) ..." or "a. ..."
                    String optionText = line.substring(line.indexOf(')') + 1).trim(); // or line.indexOf('.')
                    if (optionText.endsWith("[*]")) {
                        optionText = optionText.substring(0, optionText.length() - 3).trim();
                        correctOptionIdx = options.size();
                    }
                    options.add(optionText);
                }
            }

            if (!questionText.isEmpty() && !options.isEmpty() && correctOptionIdx != -1) {
                questions.add(new QuizQuestion(questionText, options, correctOptionIdx));
            }
        }
        return questions;
    }

    public List<QuizQuestion> getQuizQuestions(Coursework quizCoursework) {
        if (quizCoursework.getType() != CourseworkType.QUIZ || quizCoursework.getQuestionsJson() == null) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(quizCoursework.getQuestionsJson(), new TypeReference<List<QuizQuestion>>() {
            });
        } catch (JsonProcessingException e) {
            System.err.println("Error parsing quiz questions JSON: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    @Transactional
    public void deleteCoursework(Long courseworkId, Long teacherId) throws IOException {
        Coursework coursework = courseworkRepository.findById(courseworkId)
                .orElseThrow(() -> new IllegalArgumentException("Coursework not found with ID: " + courseworkId));

        if (!coursework.getCourse().getTeacher().getId().equals(teacherId)) {
            throw new SecurityException("Teacher not authorized to delete this coursework.");
        }

        if (coursework.getType() == CourseworkType.NOTE && coursework.getFilePath() != null
                && !coursework.getFilePath().isBlank()) {
            try {
                Files.deleteIfExists(Paths.get(coursework.getFilePath()));
            } catch (IOException e) {
                System.err.println("Error deleting note file: " + coursework.getFilePath() + " - " + e.getMessage());
            }
        }

        if (coursework.getType() == CourseworkType.ASSIGNMENT) {
            List<AssignmentSubmission> submissions = assignmentSubmissionRepository.findByAssignment(coursework);
            if (submissions != null && !submissions.isEmpty()) {
                for (AssignmentSubmission submission : submissions) {
                    if (submission.getFilePath() != null && !submission.getFilePath().isBlank()) {
                        try {
                            Files.deleteIfExists(Paths.get(submission.getFilePath()));
                        } catch (IOException e) {
                            System.err.println("Error deleting submission file: " + submission.getFilePath() + " - "
                                    + e.getMessage());
                        }
                    }
                }
                assignmentSubmissionRepository.deleteAll(submissions);
            }
        } else if (coursework.getType() == CourseworkType.QUIZ) {
            // Delete all quiz submissions associated with this quiz coursework
            List<QuizSubmission> quizSubmissions = quizSubmissionRepository.findByQuizCoursework(coursework);
            if (quizSubmissions != null && !quizSubmissions.isEmpty()) {
                quizSubmissionRepository.deleteAll(quizSubmissions);
            }
        }
        courseworkRepository.delete(coursework);
    }

    // --- Assignment Submission Methods (Existing) ---
    @Transactional
    public AssignmentSubmission submitAssignment(Long courseworkId, Long studentId, MultipartFile assignmentFile)
            throws IOException {
        Coursework assignment = courseworkRepository.findById(courseworkId)
                .filter(cw -> cw.getType() == CourseworkType.ASSIGNMENT)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Assignment (Coursework) not found or not of type ASSIGNMENT: " + courseworkId));
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Student not found: " + studentId));
        if (assignmentFile.isEmpty())
            throw new IllegalArgumentException("Assignment file cannot be empty.");

        String originalFileName = org.springframework.util.StringUtils.cleanPath(assignmentFile.getOriginalFilename());
        String uniqueFileName = UUID.randomUUID().toString() + "_" + originalFileName;
        Path studentSubmissionDir = Paths.get(ASSIGNMENT_SUBMISSION_DIR, String.valueOf(courseworkId),
                String.valueOf(studentId));
        Files.createDirectories(studentSubmissionDir);
        Path targetLocation = studentSubmissionDir.resolve(uniqueFileName);
        Files.copy(assignmentFile.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

        Optional<AssignmentSubmission> existingSubmissionOpt = assignmentSubmissionRepository
                .findByAssignmentAndStudent(assignment, student);
        AssignmentSubmission submission;
        if (existingSubmissionOpt.isPresent()) {
            submission = existingSubmissionOpt.get();
            if (submission.getFilePath() != null && !submission.getFilePath().isBlank()) {
                try {
                    Files.deleteIfExists(Paths.get(submission.getFilePath()));
                } catch (IOException e) {
                    System.err.println("Could not delete old submission file: " + submission.getFilePath());
                }
            }
            submission.setFilePath(targetLocation.toString());
            submission.setOriginalFileName(originalFileName);
            submission.setFileMimeType(assignmentFile.getContentType());
            submission.setSubmissionDate(LocalDateTime.now());
        } else {
            submission = new AssignmentSubmission(assignment, student, targetLocation.toString(), originalFileName,
                    assignmentFile.getContentType());
        }
        return assignmentSubmissionRepository.save(submission);
    }

    public List<AssignmentSubmission> getSubmissionsForAssignment(Long courseworkId) {
        Coursework assignment = courseworkRepository.findById(courseworkId)
                .orElseThrow(() -> new IllegalArgumentException("Assignment (Coursework) not found: " + courseworkId));
        if (assignment.getType() != CourseworkType.ASSIGNMENT) {
            throw new IllegalArgumentException("Coursework is not an assignment.");
        }
        return assignmentSubmissionRepository.findByAssignment(assignment);
    }

    public Optional<AssignmentSubmission> getSubmissionById(Long submissionId) {
        return assignmentSubmissionRepository.findById(submissionId);
    }

    // --- Quiz Submission Methods (New) ---

    @Transactional
    public QuizSubmission submitQuiz(Long courseworkId, Long studentId, Map<Integer, Integer> answersMap) {
        Coursework quizCoursework = courseworkRepository.findById(courseworkId)
                .filter(cw -> cw.getType() == CourseworkType.QUIZ)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Quiz (Coursework) not found or not of type QUIZ: " + courseworkId));
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Student not found: " + studentId));

        List<QuizQuestion> questions = getQuizQuestions(quizCoursework);
        if (questions.isEmpty()) {
            throw new IllegalArgumentException("This quiz has no questions.");
        }

        int score = 0;
        int correctAnswersCount = 0;
        for (int i = 0; i < questions.size(); i++) {
            QuizQuestion question = questions.get(i);
            Integer selectedOptionIndex = answersMap.get(i); // answersMap uses question index as key
            if (selectedOptionIndex != null && selectedOptionIndex == question.getCorrectOptionIndex()) {
                score++; // Or apply points per question if varied
                correctAnswersCount++;
            }
        }

        String answersJson;
        try {
            answersJson = objectMapper.writeValueAsString(answersMap);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error serializing quiz answers: " + e.getMessage(), e);
        }

        // Check for existing submission and update if resubmission is allowed (KISS:
        // allow one submission for now)
        Optional<QuizSubmission> existingSubmissionOpt = quizSubmissionRepository
                .findByQuizCourseworkAndStudent(quizCoursework, student);
        if (existingSubmissionOpt.isPresent()) {
            // For KISS, we can prevent re-submission or update the existing one.
            // Let's prevent for now. For update, add logic here.
            throw new IllegalStateException("You have already submitted this quiz.");
        }

        QuizSubmission submission = new QuizSubmission(quizCoursework, student, answersJson, score, questions.size(),
                correctAnswersCount);
        return quizSubmissionRepository.save(submission);
    }

    public Optional<QuizSubmission> getStudentQuizSubmission(Long courseworkId, Long studentId) {
        Coursework quizCoursework = courseworkRepository.findById(courseworkId)
                .filter(cw -> cw.getType() == CourseworkType.QUIZ)
                .orElse(null);
        if (quizCoursework == null)
            return Optional.empty();
        User student = userRepository.findById(studentId).orElse(null);
        if (student == null)
            return Optional.empty();
        return quizSubmissionRepository.findByQuizCourseworkAndStudent(quizCoursework, student);
    }

    public List<QuizSubmission> getSubmissionsForQuiz(Long courseworkId) {
        Coursework quizCoursework = courseworkRepository.findById(courseworkId)
                .filter(cw -> cw.getType() == CourseworkType.QUIZ)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Quiz (Coursework) not found or not of type QUIZ: " + courseworkId));
        return quizSubmissionRepository.findByQuizCoursework(quizCoursework);
    }

    @Transactional
    public Coursework updateQuizCoursework(Long courseworkId, Long teacherId, String title, String description,
            String quizQuestionsRawText, Date dueDate) throws IOException {
        Coursework coursework = courseworkRepository.findById(courseworkId)
                .orElseThrow(() -> new IllegalArgumentException("Coursework not found with ID: " + courseworkId));

        if (coursework.getType() != CourseworkType.QUIZ) {
            throw new IllegalArgumentException("This coursework is not a quiz and cannot be updated as such.");
        }
        if (!coursework.getCourse().getTeacher().getId().equals(teacherId)) {
            throw new SecurityException("Teacher not authorized to update this quiz.");
        }

        coursework.setTitle(title);
        coursework.setContent(description); // Quiz description
        coursework.setDueDate(dueDate);

        if (quizQuestionsRawText != null && !quizQuestionsRawText.isBlank()) {
            List<QuizQuestion> questions = parseQuizQuestionsFromText(quizQuestionsRawText);
            try {
                coursework.setQuestionsJson(objectMapper.writeValueAsString(questions));
            } catch (JsonProcessingException e) {
                throw new IllegalArgumentException(
                        "Error processing quiz questions JSON for update: " + e.getMessage());
            }
        } else {
            // If raw text is empty, it could mean clearing questions or no change.
            // For KISS, if empty, we assume no change to questions unless explicitly
            // handled.
            // Or, to clear questions: coursework.setQuestionsJson("[]");
        }
        return courseworkRepository.save(coursework);
    }

}