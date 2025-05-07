package com.aniketh.app.lmsmonolithic.controller;

import com.aniketh.app.lmsmonolithic.model.Role;
import com.aniketh.app.lmsmonolithic.model.User;
import com.aniketh.app.lmsmonolithic.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final UserService userService;

    @Autowired
    public AdminController(UserService userService) {
        this.userService = userService;
    }

    // Filter to check if user is admin and logged in
    private boolean isAdmin(HttpSession session) {
        User user = (User) session.getAttribute("user");
        return user != null && user.getRole() == Role.ADMIN;
    }

    @GetMapping("/dashboard")
    public String adminDashboard(HttpSession session, Model model) {
        if (!isAdmin(session)) {
            return "redirect:/login";
        }
        User adminUser = (User) session.getAttribute("user");
        model.addAttribute("user", adminUser);
        List<User> users = userService.getAllUsersExcludingAdmin(); // Fetch non-admin users
        model.addAttribute("users", users);
        return "admin-dashboard";
    }

    @PostMapping("/update-role")
    public String updateUserRole(@RequestParam Long userId,
                                 @RequestParam String role,
                                 HttpSession session,
                                 RedirectAttributes redirectAttributes) {
        if (!isAdmin(session)) {
            return "redirect:/login";
        }
        try {
            Role newRole = Role.valueOf(role.toUpperCase());
            if (newRole == Role.ADMIN) { // Prevent setting anyone to ADMIN via this form
                redirectAttributes.addFlashAttribute("error", "Cannot assign ADMIN role via this interface.");
                return "redirect:/admin/dashboard";
            }
            boolean success = userService.updateUserRole(userId, newRole);
            if (success) {
                redirectAttributes.addFlashAttribute("success", "User role updated successfully.");
            } else {
                redirectAttributes.addFlashAttribute("error", "Failed to update user role. User not found or invalid operation.");
            }
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", "Invalid role specified.");
        }
        return "redirect:/admin/dashboard";
    }
}
