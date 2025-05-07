package com.aniketh.app.lmsmonolithic.repository;

import com.aniketh.app.lmsmonolithic.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findAllByRoleNot(com.aniketh.app.lmsmonolithic.model.Role role); // To fetch non-admin users
}
