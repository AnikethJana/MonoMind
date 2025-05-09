package com.aniketh.app.lmsmonolithic.controller;

import com.aniketh.app.lmsmonolithic.model.*;
import com.aniketh.app.lmsmonolithic.service.CourseService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.format.annotation.DateTimeFormat;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Date;
import java.util.List;
import java.util.Optional;
// import java.util.stream.Collectors; // Not used currently

@Controller
@RequestMapping("/teacher")
public class TeacherController {

    private final CourseService courseService;

    @Autowired
    public TeacherController(CourseService courseService) {
        this.courseService = courseService;
    }

    private boolean isTeacher(HttpSession session) {
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == Role.TEACHER;
    }

    @GetMapping("/dashboard")
    public String teacherDashboard(HttpSession session, Model model) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        model.addAttribute("user", teacher);
        List<Course> courses = courseService.getCoursesByTeacher(teacher.getId());
        model.addAttribute("courses", courses);
        model.addAttribute("pageTitle", "Teacher Dashboard");
        return "teacher-dashboard"; // Ensure this JSP exists
    }

    @GetMapping("/course/create")
    public String createCoursePage(HttpSession session, Model model) {
        if (!isTeacher(session))
            return "redirect:/login";
        model.addAttribute("user", session.getAttribute("user"));
        model.addAttribute("course", new Course());
        model.addAttribute("pageTitle", "Create New Course");
        return "create-course"; // Ensure this JSP exists
    }

    @PostMapping("/course/create")
    public String handleCreateCourse(@RequestParam String title,
            @RequestParam String description,
            HttpSession session, RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        try {
            courseService.createCourse(title, description, teacher.getId());
            redirectAttributes.addFlashAttribute("success", "Course created successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error creating course: " + e.getMessage());
        }
        return "redirect:/teacher/dashboard";
    }

    @GetMapping("/course/{courseId}/manage")
    public String manageCoursePage(@PathVariable Long courseId, HttpSession session, Model model,
            RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        Optional<Course> courseOpt = courseService.getCourseById(courseId);

        if (courseOpt.isEmpty() || !courseOpt.get().getTeacher().getId().equals(teacher.getId())) {
            redirectAttributes.addFlashAttribute("error", "Course not found or you are not authorized.");
            return "redirect:/teacher/dashboard";
        }
        Course course = courseOpt.get();
        model.addAttribute("user", teacher);
        model.addAttribute("course", course);
        List<Coursework> courseworkList = courseService.getCourseworkForCourse(courseId);
        model.addAttribute("courseworkList", courseworkList);
        model.addAttribute("courseworkTypes", CourseworkType.values());
        model.addAttribute("newCoursework", new Coursework());
        model.addAttribute("pageTitle", "Manage Course - " + course.getTitle());

        for (Coursework cw : courseworkList) {
            if (cw.getType() == CourseworkType.ASSIGNMENT) {
                List<AssignmentSubmission> submissions = courseService.getSubmissionsForAssignment(cw.getId());
                model.addAttribute("submissions_for_cw_" + cw.getId(), submissions);
            }
            // Quiz submissions will be viewed on a separate page via a link
        }
        return "manage-course"; // This is one of the JSPs you requested
    }

    // Helper method to convert QuizQuestion list to the simple text format
    private String convertQuizQuestionsToTextFormat(List<QuizQuestion> questions) {
        if (questions == null || questions.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < questions.size(); i++) {
            QuizQuestion q = questions.get(i);
            sb.append(q.getQuestionText().trim()).append("\n");
            for (int j = 0; j < q.getOptions().size(); j++) {
                // Using A), B), C)... format for options to match the parser logic
                char optionLetter = (char) ('A' + j);
                sb.append(optionLetter).append(") ").append(q.getOptions().get(j).trim());
                if (j == q.getCorrectOptionIndex()) {
                    sb.append(" [*]");
                }
                sb.append("\n");
            }
            if (i < questions.size() - 1) {
                sb.append("---\n"); // Separator
            }
        }
        return sb.toString().trim(); // Trim trailing newline/whitespace
    }

    @GetMapping("/coursework/{courseworkId}/quiz/edit")
    public String editQuizPage(@PathVariable Long courseworkId, HttpSession session, Model model,
            RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        Optional<Coursework> courseworkOpt = courseService.getCourseworkById(courseworkId);

        if (courseworkOpt.isEmpty() || courseworkOpt.get().getType() != CourseworkType.QUIZ) {
            redirectAttributes.addFlashAttribute("error", "Quiz not found.");
            return "redirect:/teacher/dashboard";
        }
        Coursework quiz = courseworkOpt.get();
        if (!quiz.getCourse().getTeacher().getId().equals(teacher.getId())) {
            redirectAttributes.addFlashAttribute("error", "You are not authorized to edit this quiz.");
            return "redirect:/teacher/course/" + quiz.getCourse().getId() + "/manage";
        }

        model.addAttribute("user", teacher);
        model.addAttribute("quizCoursework", quiz);

        // Convert questions JSON to text for pre-filling the textarea
        List<QuizQuestion> questions = courseService.getQuizQuestions(quiz);
        String questionsAsTextForEdit = convertQuizQuestionsToTextFormat(questions);
        model.addAttribute("initialQuestionsTextForEdit", questionsAsTextForEdit);
        model.addAttribute("pageTitle", "Edit Quiz - " + quiz.getTitle());

        return "edit-quiz"; // This is one of the JSPs you requested
    }

    @PostMapping("/coursework/{courseworkId}/quiz/update")
    public String handleUpdateQuiz(@PathVariable Long courseworkId,
            @RequestParam String title,
            @RequestParam(name = "description", required = false) String description, // Quiz description
            @RequestParam(name = "questionsText", required = false) String questionsText, // Raw text for questions
            @RequestParam(name = "dueDate", required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date dueDate,
            HttpSession session, RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");

        try {
            Coursework updatedQuiz = courseService.updateQuizCoursework(courseworkId, teacher.getId(), title,
                    description, questionsText, dueDate);
            redirectAttributes.addFlashAttribute("success", "Quiz updated successfully!");
            return "redirect:/teacher/course/" + updatedQuiz.getCourse().getId() + "/manage";
        } catch (IOException e) {
            redirectAttributes.addFlashAttribute("error", "Error updating quiz (IO): " + e.getMessage());
        } catch (IllegalArgumentException | SecurityException e) {
            redirectAttributes.addFlashAttribute("error", "Error updating quiz: " + e.getMessage());
        }
        // On error, redirect back to manage page
        Optional<Coursework> cwOpt = courseService.getCourseworkById(courseworkId);
        Long courseIdToRedirect = cwOpt.map(cw -> cw.getCourse().getId()).orElse(null);
        if (courseIdToRedirect != null) {
            return "redirect:/teacher/course/" + courseIdToRedirect + "/manage";
        }
        return "redirect:/teacher/dashboard";
    }

    @PostMapping("/course/{courseId}/coursework/add")
    public String addCoursework(@PathVariable Long courseId,
            @RequestParam String title,
            @RequestParam CourseworkType type,
            @RequestParam(required = false) String content,
            @RequestParam(name = "fileNote", required = false) MultipartFile file,
            @RequestParam(name = "quizQuestionsText", required = false) String quizQuestionsText,
            @RequestParam(name = "dueDate", required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date dueDate,
            HttpSession session, RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        Optional<Course> courseOpt = courseService.getCourseById(courseId);

        if (courseOpt.isEmpty() || !courseOpt.get().getTeacher().getId().equals(teacher.getId())) {
            redirectAttributes.addFlashAttribute("error", "Course not found or not authorized.");
            return "redirect:/teacher/dashboard";
        }
        try {
            courseService.addCourseworkToCourse(courseId, title, type, content, file, quizQuestionsText, dueDate);
            redirectAttributes.addFlashAttribute("success", "Coursework added successfully!");
        } catch (IOException e) {
            redirectAttributes.addFlashAttribute("error", "Error processing file: " + e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error adding coursework: " + e.getMessage());
            e.printStackTrace();
        }
        return "redirect:/teacher/course/" + courseId + "/manage";
    }

    @PostMapping("/coursework/{courseworkId}/delete")
    public String deleteCoursework(@PathVariable Long courseworkId,
            @RequestParam Long courseId,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        try {
            courseService.deleteCoursework(courseworkId, teacher.getId());
            redirectAttributes.addFlashAttribute("success", "Coursework deleted successfully.");
        } catch (SecurityException e) {
            redirectAttributes.addFlashAttribute("error", "Authorization failed: " + e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error deleting coursework: " + e.getMessage());
        }
        return "redirect:/teacher/course/" + courseId + "/manage";
    }

    @GetMapping("/assignment/submission/{submissionId}/download")
    public ResponseEntity<Resource> downloadAssignmentSubmission(@PathVariable Long submissionId, HttpSession session) {
        if (!isTeacher(session)) {
            return ResponseEntity.status(403).body(null);
        }
        Optional<AssignmentSubmission> submissionOpt = courseService.getSubmissionById(submissionId);
        if (submissionOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        AssignmentSubmission submission = submissionOpt.get();
        User teacher = (User) session.getAttribute("user");
        if (!submission.getAssignment().getCourse().getTeacher().getId().equals(teacher.getId())) {
            return ResponseEntity.status(403).body(null);
        }
        try {
            Path filePath = Paths.get(submission.getFilePath());
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                String contentType = submission.getFileMimeType();
                if (contentType == null || contentType.isBlank())
                    contentType = "application/octet-stream";
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION,
                                "attachment; filename=\"" + submission.getOriginalFileName() + "\"")
                        .body(resource);
            } else {
                System.err.println("File not found or not readable at path: " + submission.getFilePath());
                return ResponseEntity.status(500).body(null);
            }
        } catch (MalformedURLException e) {
            System.err.println("Malformed URL for path: " + submission.getFilePath() + " - " + e.getMessage());
            return ResponseEntity.status(500).body(null);
        } catch (Exception e) {
            System.err.println("Error downloading file: " + e.getMessage());
            return ResponseEntity.status(500).body(null);
        }
    }

    @GetMapping("/coursework/note/{courseworkId}/viewfile")
    public ResponseEntity<Resource> viewNoteFile(@PathVariable Long courseworkId, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(401).build();
        }
        Optional<Coursework> courseworkOpt = courseService.getCourseworkById(courseworkId);
        if (courseworkOpt.isEmpty() || courseworkOpt.get().getType() != CourseworkType.NOTE
                || courseworkOpt.get().getFilePath() == null) {
            return ResponseEntity.notFound().build();
        }
        Coursework note = courseworkOpt.get();
        Course course = note.getCourse();
        boolean authorized = false;
        if (user.getRole() == Role.TEACHER && course.getTeacher().getId().equals(user.getId())) {
            authorized = true;
        } else if (user.getRole() == Role.STUDENT) {
            authorized = true;
        }
        if (!authorized) {
            return ResponseEntity.status(403).build();
        }
        try {
            Path filePath = Paths.get(note.getFilePath());
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                String contentType = note.getFileMimeType();
                if (contentType == null || contentType.isBlank())
                    contentType = "application/octet-stream";
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION,
                                "inline; filename=\"" + note.getOriginalFileName() + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException e) {
            return ResponseEntity.status(500).build();
        }
    }

    @GetMapping("/quiz/{courseworkId}/submissions")
    public String viewQuizSubmissions(@PathVariable Long courseworkId, HttpSession session, Model model,
            RedirectAttributes redirectAttributes) {
        if (!isTeacher(session))
            return "redirect:/login";
        User teacher = (User) session.getAttribute("user");
        Optional<Coursework> courseworkOpt = courseService.getCourseworkById(courseworkId);

        if (courseworkOpt.isEmpty() || courseworkOpt.get().getType() != CourseworkType.QUIZ) {
            redirectAttributes.addFlashAttribute("error", "Quiz not found.");
            return "redirect:/teacher/dashboard";
        }
        Coursework quizCoursework = courseworkOpt.get();
        if (!quizCoursework.getCourse().getTeacher().getId().equals(teacher.getId())) {
            redirectAttributes.addFlashAttribute("error", "You are not authorized to view submissions for this quiz.");
            return "redirect:/teacher/course/" + quizCoursework.getCourse().getId() + "/manage";
        }

        List<QuizSubmission> submissions = courseService.getSubmissionsForQuiz(courseworkId);
        model.addAttribute("user", teacher);
        model.addAttribute("quiz", quizCoursework);
        model.addAttribute("submissions", submissions);
        model.addAttribute("course", quizCoursework.getCourse());
        model.addAttribute("pageTitle", "Submissions for Quiz: " + quizCoursework.getTitle());

        return "view-quiz-submissions-teacher"; // This is one of the JSPs you requested
    }
}
