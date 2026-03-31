# Environment Context
You are running inside an Alpine Linux container.
## Environment Details
- OS: Alpine Linux (Docker container)
- Working directory: /workspace
- Temporary (you can install tools to be able to do things)

## Git Workflow
- Always push code to `main`
- Before pushing, ensure you are on the correct branch:
```
  git checkout main 2>/dev/null || git checkout -b main
```
- To push changes:
```
  git add .
  git commit -m "your commit message"
  git push origin main
```