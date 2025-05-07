package com.aniketh.app.lmsmonolithic.model;

import java.util.List;
import java.util.Objects;

public class QuizQuestion {
    private String questionText;
    private List<String> options;
    private int correctOptionIndex; // 0-based index for the options list

    // Constructors
    public QuizQuestion() {
    }

    public QuizQuestion(String questionText, List<String> options, int correctOptionIndex) {
        this.questionText = questionText;
        this.options = options;
        this.correctOptionIndex = correctOptionIndex;
    }

    // Getters and Setters
    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public List<String> getOptions() {
        return options;
    }

    public void setOptions(List<String> options) {
        this.options = options;
    }

    public int getCorrectOptionIndex() {
        return correctOptionIndex;
    }

    public void setCorrectOptionIndex(int correctOptionIndex) {
        this.correctOptionIndex = correctOptionIndex;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        QuizQuestion that = (QuizQuestion) o;
        return correctOptionIndex == that.correctOptionIndex &&
                Objects.equals(questionText, that.questionText) &&
                Objects.equals(options, that.options);
    }

    @Override
    public int hashCode() {
        return Objects.hash(questionText, options, correctOptionIndex);
    }

    @Override
    public String toString() {
        return "QuizQuestion{" +
                "questionText='" + questionText + '\'' +
                ", options=" + options +
                ", correctOptionIndex=" + correctOptionIndex +
                '}';
    }
}