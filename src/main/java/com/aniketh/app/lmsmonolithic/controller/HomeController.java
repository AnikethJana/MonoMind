package com.aniketh.app.lmsmonolithic.controller;

import com.aniketh.app.lmsmonolithic.model.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping({"/", "/home"})
    public String homePage(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login"; // Not logged in
        }
        model.addAttribute("user", user);
        // Could redirect to role-specific dashboards here as well,
        // but AuthController already handles that on login.
        // This home page can be a generic landing or point to role dashboards.
        switch (user.getRole()) {
            case ADMIN:
                return "redirect:/admin/dashboard";
            case TEACHER:
                return "redirect:/teacher/dashboard";
            case STUDENT:
                return "redirect:/student/dashboard";
            default:
                return "login"; // Should not happen if user is in session
        }
    }
}
