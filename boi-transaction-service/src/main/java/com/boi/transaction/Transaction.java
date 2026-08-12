package com.boi.transaction;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "transactions")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long fromAccountId;
    private Long toAccountId;
    private BigDecimal amount;
    private String status = "COMPLETED";
    private Instant createdAt = Instant.now();

    public Long getId() { return id; }
    public Long getFromAccountId() { return fromAccountId; }
    public void setFromAccountId(Long f) { this.fromAccountId = f; }
    public Long getToAccountId() { return toAccountId; }
    public void setToAccountId(Long t) { this.toAccountId = t; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal a) { this.amount = a; }
    public String getStatus() { return status; }
    public void setStatus(String s) { this.status = s; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant c) { this.createdAt = c; }
}
