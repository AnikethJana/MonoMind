package com.aniketh.app.lmsmonolithic.config;

import com.aniketh.app.lmsmonolithic.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserService userService;

    @Value("${lms.admin.email}")
    private String adminEmail;

    // You'll need to set a default admin password, perhaps in properties or hardcode for initial setup
    // For security, this should be a strong, unique password, and ideally set via environment variables in production
    @Value("${lms.admin.password:DefaultAdminPassword123!}") // Provide a default if not in properties
    private String adminPassword;

    @Value("${lms.admin.name:LMS Admin}")
    private String adminFullName;


    @Autowired
    public DataInitializer(UserService userService) {
        this.userService = userService;
    }

    @Override
    public void run(String... args) throws Exception {
        userService.createDefaultAdminUserIfNotFound(adminEmail, adminPassword, adminFullName);
    }
}
