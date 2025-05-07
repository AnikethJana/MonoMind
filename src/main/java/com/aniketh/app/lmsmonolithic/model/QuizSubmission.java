package com.aniketh.app.lmsmonolithic.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Objects;

@Entity
@Table(name = "quiz_submissions")
public class QuizSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coursework_id", nullable = false)
    private Coursework quizCoursework; // The Coursework of type QUIZ this submission is for

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Lob
    @Column(columnDefinition="TEXT")
    private String answersJson; // JSON string of student's answers (e.g., Map<Integer_questionIndex, Integer_selectedOptionIndex>)

    @Column(nullable = false)
    private int score;

    @Column(nullable = false)
    private int totalQuestionsAttempted; // Could be total questions in quiz

    @Column(nullable = false)
    private int totalCorrectAnswers;

    @Column(nullable = false)
    private LocalDateTime submittedAt;

    // Constructors
    public QuizSubmission() {
        this.submittedAt = LocalDateTime.now();
    }

    public QuizSubmission(Coursework quizCoursework, User student, String answersJson, int score, int totalQuestionsAttempted, int totalCorrectAnswers) {
        this(); // Sets submittedAt
        this.quizCoursework = quizCoursework;
        this.student = student;
        this.answersJson = answersJson;
        this.score = score; // Typically calculated as number of correct answers
        this.totalQuestionsAttempted = totalQuestionsAttempted;
        this.totalCorrectAnswers = totalCorrectAnswers;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Coursework getQuizCoursework() { return quizCoursework; }
    public void setQuizCoursework(Coursework quizCoursework) { this.quizCoursework = quizCoursework; }
    public User getStudent() { return student; }
    public void setStudent(User student) { this.student = student; }
    public String getAnswersJson() { return answersJson; }
    public void setAnswersJson(String answersJson) { this.answersJson = answersJson; }
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
    public int getTotalQuestionsAttempted() { return totalQuestionsAttempted; }
    public void setTotalQuestionsAttempted(int totalQuestionsAttempted) { this.totalQuestionsAttempted = totalQuestionsAttempted; }
    public int getTotalCorrectAnswers() { return totalCorrectAnswers; }
    public void setTotalCorrectAnswers(int totalCorrectAnswers) { this.totalCorrectAnswers = totalCorrectAnswers; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }

    @Transient
    public java.util.Date getSubmittedAtAsUtilDate() {
        if (this.submittedAt == null) {
            return null;
        }
        return java.util.Date.from(this.submittedAt.atZone(ZoneId.systemDefault()).toInstant());
    }

    @Transient
    public int getPercentageScore() {
        if (totalQuestionsAttempted == 0) return 0;
        return (int) Math.round(((double) totalCorrectAnswers / totalQuestionsAttempted) * 100);
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        QuizSubmission that = (QuizSubmission) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}