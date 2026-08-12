package com.boi.auth;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = "jwt.secret=test-secret-that-is-long-enough-32bytes!")
class BoiAuthServiceApplicationTests {
    @Test
    void contextLoads() {
    }
}
