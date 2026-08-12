package com.boi.transaction;

import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/transactions")
public class TransactionController {
    private final TransactionRepository repo;
    public TransactionController(TransactionRepository repo) { this.repo = repo; }

    @GetMapping
    public List<Transaction> all() { return repo.findAll(); }

    @PostMapping("/transfer")
    public Transaction transfer(@RequestBody Transaction t) {
        // Ledger-only demo: records the movement. Real system would call account-service
        // to debit/credit atomically. Kept simple so the pipeline is the focus.
        t.setStatus("COMPLETED");
        return repo.save(t);
    }
}
