# modules/cost/outputs.tf

output "budget_name" {
  description = "Budget name for reference"
  value       = aws_budgets_budget.monthly.name
}
