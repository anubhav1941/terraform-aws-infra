output "state_bucket" {
  description = "Put this in envs/*/backend.hcl as bucket"
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "Put this in envs/*/backend.hcl as dynamodb_table"
  value       = aws_dynamodb_table.locks.name
}
