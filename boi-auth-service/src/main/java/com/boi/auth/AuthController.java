package com.boi.auth;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final JwtService jwt;

    // Demo user store. In a real system this is the DB + hashed passwords.
    private static final Map<String, String> USERS = Map.of(
            "raju", "password123",
            "admin", "admin123"
    );

    public AuthController(JwtService jwt) { this.jwt = jwt; }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username != null && password != null && password.equals(USERS.get(username))) {
            return ResponseEntity.ok(Map.of("token", jwt.issue(username)));
        }
        return ResponseEntity.status(401).body(Map.of("error", "invalid credentials"));
    }

    @GetMapping("/validate")
    public ResponseEntity<?> validate(@RequestParam String token) {
        try {
            return ResponseEntity.ok(Map.of("valid", true, "user", jwt.validate(token)));
        } catch (Exception e) {
            return ResponseEntity.status(401).body(Map.of("valid", false));
        }
    }
}
