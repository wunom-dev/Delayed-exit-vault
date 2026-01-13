Delayed-Exit-Vault

Overview

**Delayed-Exit-Vault** is a secure Clarity smart contract on the Stacks blockchain that enforces **time-delayed withdrawals** for deposited STX.  
It is designed to improve fund safety by introducing a mandatory waiting period between a withdrawal request and execution.

This contract is suitable for:
- Personal security vaults
- DAO and treasury fund protection
- Protocol-controlled liquidity
- Anti-rug and exit-throttling mechanisms

---

Key Features

- **Time-Locked Withdrawals**  
  Withdrawals can only be executed after a predefined delay period.

- **Two-Step Exit Process**  
  Users must first request an exit, then complete it after the delay expires.

- **Transparent State Tracking**  
  Read-only functions expose vault balances and exit status.

- **Protection Against Early Withdrawals**  
  Attempts to withdraw before the delay period are rejected.

- **Simple & Auditable Logic**  
  Written entirely in Clarity with deterministic state transitions.

---

## How It Works

1. **Deposit STX**  
   Users deposit STX into the vault.

2. **Request Withdrawal**  
   A withdrawal request is created, starting the delay timer.

3. **Wait for Delay Period**  
   The user must wait until the delay period has elapsed.

4. **Execute Withdrawal**  
   After the delay, the user can successfully withdraw their funds.

---

Contract Design Goals

- Enhance security through delayed exits
- Reduce risk of impulsive or malicious withdrawals
- Support treasury and DAO safety patterns
- Remain lightweight and easy to audit
- Pass Clarinet checks without external dependencies

---

Read-Only Functions

The contract exposes read-only functions to:
- Check vault balances
- Verify withdrawal request status
- Confirm eligibility for withdrawal execution

These functions allow frontends and indexers to track vault state without modifying it.

---

Security Considerations

- Withdrawals cannot bypass the delay period
- Only the rightful depositor can execute their withdrawal
- No privileged admin access or backdoors
- All state transitions are deterministic and transparent

---

Use Cases

- DAO treasury protection
- Protocol-controlled fund storage
- Personal cold-exit vaults
- Vesting or cooldown-based withdrawal systems
- Risk-managed liquidity pools

---

Development & Testing

- Language: **Clarity**
- Blockchain: **Stacks**
- Compatible with **Clarinet**
- No external contract dependencies

---

Disclaimer

This smart contract is provided as-is.  
It has not been formally audited and should be reviewed before use in production environments.

---

License

MIT License
