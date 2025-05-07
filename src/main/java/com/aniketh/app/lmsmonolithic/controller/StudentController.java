package com.aniketh.app.lmsmonolithic.controller;

import com.aniketh.app.lmsmonolithic.model.*;
import com.aniketh.app.lmsmonolithic.service.CourseService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest; // For quiz submission
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

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap; // For quiz answers
import java.util.List;
import java.util.Map; // For quiz answers
import java.util.Optional;

@Controller
@RequestMapping("/student")
public class StudentController {

    private final CourseService courseService;
    private final ObjectMapper objectMapper; // For JSON processing

    @Autowired
    public StudentController(CourseService courseService, ObjectMapper objectMapper) {
        this.courseService = courseService;
        this.objectMapper = objectMapper;
    }

    private boolean isStudent(HttpSession session) {
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == Role.STUDENT;
    }

    @GetMapping("/dashboard")
    public String studentDashboard(HttpSession session, Model model) {
        if (!isStudent(session)) return "redirect:/login";
        User student = (User) session.getAttribute("user");
        model.addAttribute("user", student);
        List<Course> courses = courseService.getAllCourses();
        model.addAttribute("courses", courses);
        return "student-dashboard";
    }

    @GetMapping("/course/{courseId}")
    public String viewCoursePage(@PathVariable Long courseId, HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        if (!isStudent(session)) return "redirect:/login";
        User student = (User) session.getAttribute("user");
        Optional<Course> courseOpt = courseService.getCourseById(courseId);

        if (courseOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Course not found.");
            return "redirect:/student/dashboard";
        }
        model.addAttribute("user", student);
        model.addAttribute("course", courseOpt.get());
        model.addAttribute("courseworkList", courseService.getCourseworkForCourse(courseId));
        return "view-course-student";
    }

    @GetMapping("/coursework/{courseworkId}")
    public String viewCourseworkPage(@PathVariable Long courseworkId, HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        if (!isStudent(session)) return "redirect:/login";
        User student = (User) session.getAttribute("user");
        Optional<Coursework> courseworkOpt = courseService.getCourseworkById(courseworkId);

        if (courseworkOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Coursework not found.");
            return "redirect:/student/dashboard";
        }

        Coursework coursework = courseworkOpt.get();
        model.addAttribute("user", student);
        model.addAttribute("coursework", coursework);
        model.addAttribute("course", coursework.getCourse());

        if (coursework.getType() == CourseworkType.ASSIGNMENT) {
            Optional<AssignmentSubmission> submissionOpt = courseService.getSubmissionsForAssignment(courseworkId)
                    .stream()
                    .filter(s -> s.getStudent().getId().equals(student.getId()))
                    .findFirst();
            submissionOpt.ifPresent(submission -> model.addAttribute("existingSubmission", submission));
        } else if (coursework.getType() == CourseworkType.QUIZ) {
            List<QuizQuestion> questions = courseService.getQuizQuestions(coursework);
            model.addAttribute("quizQuestions", questions);
            Optional<QuizSubmission> quizSubmissionOpt = courseService.getStudentQuizSubmission(courseworkId, student.getId());
            quizSubmissionOpt.ifPresent(qs -> model.addAttribute("existingQuizSubmission", qs));

            if (quizSubmissionOpt.isPresent() && quizSubmissionOpt.get().getAnswersJson() != null) {
                try {
                    Map<String, Integer> answersMap = objectMapper.readValue(quizSubmissionOpt.get().getAnswersJson(), new TypeReference<Map<String, Integer>>() {});
                    model.addAttribute("submittedAnswers", answersMap);
                } catch (IOException e) {
                    System.err.println("Error parsing submitted quiz answers: " + e.getMessage());
                }
            }
        }
        return "view-coursework-student"; // This JSP will need to handle QUIZ type
    }

    @PostMapping("/assignment/{courseworkId}/submit")
    public String handleAssignmentSubmission(@PathVariable Long courseworkId,
                                             @RequestParam("assignmentFile") MultipartFile assignmentFile,
                                             HttpSession session,
                                             RedirectAttributes redirectAttributes) {
        // ... (existing code - unchanged)
        if (!isStudent(session)) return "redirect:/login";
        User student = (User) session.getAttribute("user");
        if (assignmentFile.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Please select a file for the assignment.");
            return "redirect:/student/coursework/" + courseworkId;
        }
        try {
            courseService.submitAssignment(courseworkId, student.getId(), assignmentFile);
            redirectAttributes.addFlashAttribute("success", "Assignment submitted successfully!");
        } catch (IOException e) {
            redirectAttributes.addFlashAttribute("error", "Could not save file: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/student/coursework/" + courseworkId;
    }

    @GetMapping("/coursework/note/{courseworkId}/viewfile")
    public ResponseEntity<Resource> viewStudentNoteFile(@PathVariable Long courseworkId, HttpSession session) {
        // ... (existing code - unchanged)
        User student = (User) session.getAttribute("user");
        if (!isStudent(session)) return ResponseEntity.status(401).build();
        Optional<Coursework> courseworkOpt = courseService.getCourseworkById(courseworkId);
        if (courseworkOpt.isEmpty() || courseworkOpt.get().getType() != CourseworkType.NOTE || courseworkOpt.get().getFilePath() == null) {
            return ResponseEntity.notFound().build();
        }
        Coursework note = courseworkOpt.get();
        try {
            Path filePath = Paths.get(note.getFilePath());
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                String contentType = note.getFileMimeType();
                if (contentType == null || contentType.isBlank()) contentType = "application/octet-stream";
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + note.getOriginalFileName() + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException e) {
            return ResponseEntity.status(500).build();
        }
    }

    // New endpoint for submitting a quiz
    @PostMapping("/quiz/{courseworkId}/submit")
    public String handleQuizSubmission(@PathVariable Long courseworkId,
                                       HttpServletRequest request, // To get all parameters
                                       HttpSession session,
                                       RedirectAttributes redirectAttributes) {
        if (!isStudent(session)) return "redirect:/login";
        User student = (User) session.getAttribute("user");

        Map<Integer, Integer> answersMap = new HashMap<>();
        // Parameters from form will be like "answer_q0", "answer_q1", etc.
        // The value will be the selected option index.
        int questionIndex = 0;
        while (true) {
            String paramName = "answer_q" + questionIndex;
            String paramValue = request.getParameter(paramName);
            if (paramValue == null) {
                break; // No more questions found in parameters
            }
            try {
                answersMap.put(questionIndex, Integer.parseInt(paramValue));
            } catch (NumberFormatException e) {
                // Handle cases where an answer might not be an integer, or not selected
                // For KISS, we assume valid integer input or it might be skipped.
                // For non-selection, paramValue might be null or empty, handled by the break.
                // If a question was shown but not answered, it won't be in the map.
                // Service layer should handle this (e.g., consider unanswered as wrong).
            }
            questionIndex++;
        }

        if (answersMap.isEmpty() && questionIndex > 0) {
            // This means questions were likely present but nothing was selected or submitted correctly.
            redirectAttributes.addFlashAttribute("error", "You did not answer any questions.");
            return "redirect:/student/coursework/" + courseworkId;
        }


        try {
            courseService.submitQuiz(courseworkId, student.getId(), answersMap);
            redirectAttributes.addFlashAttribute("success", "Quiz submitted successfully!");
        } catch (IllegalStateException e) { // For re-submission attempts if not allowed
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", "Error submitting quiz: " + e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "An unexpected error occurred: " + e.getMessage());
            e.printStackTrace(); // For debugging
        }
        return "redirect:/student/coursework/" + courseworkId;
    }
}