package com.aniketh.app.lmsmonolithic.repository;

import com.aniketh.app.lmsmonolithic.model.AssignmentSubmission;
import com.aniketh.app.lmsmonolithic.model.Coursework;
import com.aniketh.app.lmsmonolithic.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssignmentSubmissionRepository extends JpaRepository<AssignmentSubmission, Long> {
    // Find all submissions for a specific assignment (coursework)
    List<AssignmentSubmission> findByAssignment(Coursework assignment);

    // Find a specific submission by a student for a particular assignment
    Optional<AssignmentSubmission> findByAssignmentAndStudent(Coursework assignment, User student);

    // Find all submissions by a particular student
    List<AssignmentSubmission> findByStudent(User student);
}
