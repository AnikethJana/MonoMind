package com.aniketh.app.lmsmonolithic.repository;

import com.aniketh.app.lmsmonolithic.model.Course;
import com.aniketh.app.lmsmonolithic.model.Coursework;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CourseworkRepository extends JpaRepository<Coursework, Long> {
    List<Coursework> findByCourse(Course course);
}
