# ADR-002: Auto Scaling Strategy



**Status:** Accepted | **Date:** 2026-01-22



## Context



We need elastic compute capacity that:

- Scales automatically based on demand

- Maintains high availability

- Controls costs

- Demonstrates scaling policies for portfolio



## Decision



Use Target Tracking scaling with CPU metric:

- **Min:** 2 (maintain HA across AZs)

- **Max:** 6 (cost cap)

- **Desired:** 2

- **Target CPU:** 70%

- **Cooldown:** 300 seconds (default)



## Consequences



**Positive:**

- Automatic scaling without manual intervention

- CloudWatch handles metric collection

- Predictable, well-documented behavior



**Trade-offs:**

- CPU may not suit all workload types (e.g., memory-intensive)

- 5-minute cooldown can delay scale-in during traffic drops

- Single metric may miss complex load patterns



## Alternatives Considered



1. **Step Scaling** - Rejected: More complex configuration for similar results

2. **Scheduled Scaling** - Rejected: Load patterns unknown for demo

3. **No Scaling** - Rejected: Doesn't demonstrate production patterns



#
