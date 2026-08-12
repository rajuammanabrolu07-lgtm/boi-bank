package com.boi.account;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "accounts")
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String accountNumber;
    private String holderName;
    private BigDecimal balance = BigDecimal.ZERO;
    private Instant createdAt = Instant.now();

    public Long getId() { return id; }
    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String a) { this.accountNumber = a; }
    public String getHolderName() { return holderName; }
    public void setHolderName(String h) { this.holderName = h; }
    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal b) { this.balance = b; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant c) { this.createdAt = c; }
}
