package com.aniketh.app.lmsmonolithic.controller;

import com.aniketh.app.lmsmonolithic.model.User;
import com.aniketh.app.lmsmonolithic.model.Role;
import com.aniketh.app.lmsmonolithic.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

@Controller
public class AuthController {

    private final UserService userService;

    @Autowired
    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        if (session.getAttribute("user") != null) {
            return "redirect:/home"; // Already logged in
        }
        return "login";
    }

    @PostMapping("/login")
    public String handleLogin(@RequestParam String email,
                              @RequestParam String password,
                              HttpSession session,
                              RedirectAttributes redirectAttributes) {
        Optional<User> userOptional = userService.loginUser(email, password);
        if (userOptional.isPresent()) {
            session.setAttribute("user", userOptional.get());
            // Redirect based on role
            User user = userOptional.get();
            if (user.getRole() == Role.ADMIN) {
                return "redirect:/admin/dashboard";
            } else if (user.getRole() == Role.TEACHER) {
                return "redirect:/teacher/dashboard";
            } else {
                return "redirect:/student/dashboard"; // Default for STUDENT
            }
        } else {
            redirectAttributes.addFlashAttribute("error", "Invalid email or password");
            return "redirect:/login";
        }
    }

    @GetMapping("/register")
    public String registerPage(HttpSession session) {
        if (session.getAttribute("user") != null) {
            return "redirect:/home"; // Already logged in
        }
        return "register";
    }

    @PostMapping("/register")
    public String handleRegistration(@RequestParam String fullName,
                                     @RequestParam String email,
                                     @RequestParam String password,
                                     RedirectAttributes redirectAttributes) {
        try {
            userService.registerUser(fullName, email, password);
            redirectAttributes.addFlashAttribute("success", "Registration successful! Please login.");
            return "redirect:/login";
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/register";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate(); // Invalidate session
        return "redirect:/login?logout";
    }
}
