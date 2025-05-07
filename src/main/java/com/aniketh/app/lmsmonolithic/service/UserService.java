package com.aniketh.app.lmsmonolithic.service;

import com.aniketh.app.lmsmonolithic.model.Role;
import com.aniketh.app.lmsmonolithic.model.User;
import com.aniketh.app.lmsmonolithic.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder; // For password hashing
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder; // For hashing passwords

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    @Transactional
    public User registerUser(String fullName, String email, String password) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("User with email " + email + " already exists.");
        }
        String hashedPassword = passwordEncoder.encode(password);
        User newUser = new User(email, fullName, hashedPassword, Role.STUDENT); // Default role is STUDENT
        return userRepository.save(newUser);
    }

    public Optional<User> loginUser(String email, String password) {
        Optional<User> userOptional = userRepository.findByEmail(email);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            if (passwordEncoder.matches(password, user.getPassword())) {
                return Optional.of(user);
            }
        }
        return Optional.empty();
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public List<User> getAllUsersExcludingAdmin() {
        return userRepository.findAllByRoleNot(Role.ADMIN);
    }

    @Transactional
    public boolean updateUserRole(Long userId, Role newRole) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            // Prevent changing an admin's role or changing to admin via this method
            if (user.getRole() == Role.ADMIN || newRole == Role.ADMIN) {
                return false;
            }
            user.setRole(newRole);
            userRepository.save(user);
            return true;
        }
        return false;
    }

    // Method to create a default admin user if one doesn't exist
    @Transactional
    public void createDefaultAdminUserIfNotFound(String adminEmail, String adminPassword, String adminFullName) {
        if (userRepository.findByEmail(adminEmail).isEmpty()) {
            String hashedPassword = passwordEncoder.encode(adminPassword);
            User adminUser = new User(adminEmail, adminFullName, hashedPassword, Role.ADMIN);
            userRepository.save(adminUser);
            System.out.println("Default admin user created: " + adminEmail);
        }
    }
}
