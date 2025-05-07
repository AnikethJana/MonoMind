package com.aniketh.app.lmsmonolithic.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.time.ZoneId; // Required for conversion
import java.util.Objects;
// No need to import java.util.Date explicitly for the getter if using fully qualified name

@Entity
@Table(name = "assignment_submissions")
public class AssignmentSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coursework_id", nullable = false)
    private Coursework assignment; // The assignment (Coursework of type ASSIGNMENT) this submission is for

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Column(nullable = false)
    private String filePath; // Path to the uploaded handwritten assignment file on the server

    @Column(nullable = false)
    private String originalFileName; // Original name of the student's uploaded file

    private String fileMimeType; // MIME type of the uploaded file

    @Column(nullable = false)
    private LocalDateTime submissionDate;

    // Constructors
    public AssignmentSubmission() {
        this.submissionDate = LocalDateTime.now();
    }

    public AssignmentSubmission(Coursework assignment, User student, String filePath, String originalFileName, String fileMimeType) {
        this(); // Sets submissionDate
        this.assignment = assignment;
        this.student = student;
        this.filePath = filePath;
        this.originalFileName = originalFileName;
        this.fileMimeType = fileMimeType;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Coursework getAssignment() { return assignment; }
    public void setAssignment(Coursework assignment) { this.assignment = assignment; }
    public User getStudent() { return student; }
    public void setStudent(User student) { this.student = student; }
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    public String getOriginalFileName() { return originalFileName; }
    public void setOriginalFileName(String originalFileName) { this.originalFileName = originalFileName; }
    public String getFileMimeType() { return fileMimeType; }
    public void setFileMimeType(String fileMimeType) { this.fileMimeType = fileMimeType; }
    public LocalDateTime getSubmissionDate() { return submissionDate; }
    public void setSubmissionDate(LocalDateTime submissionDate) { this.submissionDate = submissionDate; }

    /**
     * Provides the submissionDate as a java.util.Date for compatibility with JSTL fmt:formatDate.
     * @return The submission date as a java.util.Date, or null if submissionDate is null.
     */
    @Transient // Ensures JPA doesn't try to map this to a database column
    public java.util.Date getSubmissionDateAsUtilDate() {
        if (this.submissionDate == null) {
            return null;
        }
        // Convert LocalDateTime to java.util.Date
        return java.util.Date.from(this.submissionDate.atZone(ZoneId.systemDefault()).toInstant());
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        AssignmentSubmission that = (AssignmentSubmission) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
