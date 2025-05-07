package com.aniketh.app.lmsmonolithic.repository;

import com.aniketh.app.lmsmonolithic.model.Coursework;
import com.aniketh.app.lmsmonolithic.model.QuizSubmission;
import com.aniketh.app.lmsmonolithic.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuizSubmissionRepository extends JpaRepository<QuizSubmission, Long> {

    List<QuizSubmission> findByQuizCoursework(Coursework quizCoursework);

    Optional<QuizSubmission> findByQuizCourseworkAndStudent(Coursework quizCoursework, User student);

    List<QuizSubmission> findByStudent(User student);
}