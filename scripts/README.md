# Scripts

This directory contains utility scripts for maintaining the GitOps repository.

## Available Scripts

### find-similar-files.sh

Identifies files with similar content that might be candidates for refactoring into shared templates.

**Usage**:
```bash
# Find all similar YAML files
./scripts/find-similar-files.sh "*.yaml"

# Find similar files with specific pattern
./scripts/find-similar-files.sh "vs.yaml"

# Find similar patches
./scripts/find-similar-files.sh "*service*.yaml"
```

**Output**:
- Groups of files with the same name
- List of patch files that might be consolidated
- Recommendations for reducing duplication

**Use cases**:
- Periodic audits for code duplication
- Before major refactoring efforts
- When adding new applications to check for existing patterns

## Contributing

When adding new scripts:

1. Include a header comment explaining what the script does
2. Add usage examples
3. Make scripts executable: `chmod +x scripts/your-script.sh`
4. Document the script in this README
5. Follow bash best practices (set -e, proper quoting, etc.)

## Best Practices

- Keep scripts simple and focused on one task
- Use meaningful variable names
- Include error handling
- Document expected inputs and outputs
- Test scripts before committing
