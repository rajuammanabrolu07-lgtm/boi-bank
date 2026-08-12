package com.boi.account;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/accounts")
public class AccountController {
    private final AccountRepository repo;
    public AccountController(AccountRepository repo) { this.repo = repo; }

    @GetMapping
    public List<Account> all() { return repo.findAll(); }

    @GetMapping("/{id}")
    public ResponseEntity<Account> one(@PathVariable Long id) {
        return repo.findById(id).map(ResponseEntity::ok)
                   .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Account create(@RequestBody Account a) { return repo.save(a); }
}
