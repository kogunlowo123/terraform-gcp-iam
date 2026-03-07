# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Service account creation and management with configurable properties
- Service account key generation with algorithm selection
- Project-level custom IAM role definitions
- Organization-level custom IAM role definitions
- Project-level IAM member bindings with conditional access support
- Folder-level IAM member bindings with conditional access support
- Organization-level IAM member bindings with conditional access support
- Workload Identity Federation pool and provider management
- OIDC provider support for GitHub Actions and other identity providers
- AWS provider support for cross-cloud federation
- Service account impersonation bindings via Token Creator role
- Organization policy enforcement with boolean and list constraints
- Comprehensive input validation for project IDs, service account IDs, and role stages
- Basic, advanced, and complete usage examples
- Full output coverage for all created resources
