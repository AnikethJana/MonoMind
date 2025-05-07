package com.aniketh.app.lmsmonolithic.repository;

import com.aniketh.app.lmsmonolithic.model.Course;
import com.aniketh.app.lmsmonolithic.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {
    List<Course> findByTeacher(User teacher);
    // Add findByStudent if implementing enrollment directly on Course
    // For now, students access all courses or based on a separate enrollment entity (not implemented yet)
    List<Course> findAll(); // For students to see all available courses initially
}
