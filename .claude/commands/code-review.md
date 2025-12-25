---
description: Perform a comprehensive code review on a branch and post to GitHub PR
argument-hint: <branch-name>
allowed-tools: Bash, Read, Grep, Glob, Task
---

Perform a comprehensive code review of branch "$ARGUMENTS" compared to main, output to console, and post as GitHub PR review comments.

## Role

You're a senior software engineer conducting a thorough code review. Provide constructive, actionable feedback.

## Steps

1. **Fetch the branch changes and find the PR:**
   ```bash
   git fetch origin "$ARGUMENTS" 2>/dev/null || git fetch origin
   gh pr view "$ARGUMENTS" --json number,url,headRefOid
   ```

2. **Get the diff between the branch and main:**
   ```bash
   git diff origin/main...origin/$ARGUMENTS --stat
   git diff origin/main...origin/$ARGUMENTS
   ```

3. **For each changed file, analyze the code for:**

### Security Issues
- Input validation and sanitization
- Authentication and authorization
- Data exposure risks
- Injection vulnerabilities (SQL, command, XSS)
- Secrets or credentials in code

### Performance & Efficiency
- Algorithm complexity
- Memory usage patterns
- Database query optimization
- Unnecessary computations
- N+1 queries

### Code Quality
- Readability and maintainability
- Proper naming conventions
- Function/class size and responsibility
- Code duplication
- Error handling

### Architecture & Design
- Design pattern usage
- Separation of concerns
- Dependency management
- API design consistency

### Testing & Documentation
- Test coverage for new code
- Test quality and assertions
- Documentation completeness

### Design & Styling (CSS/UI)
- Consistent spacing and layout
- Responsive design considerations
- Proper use of design tokens/variables
- Accessibility (color contrast, focus states, aria labels)
- CSS specificity issues
- Unused or duplicate styles

## Stack-Specific Guidelines

### React
- Proper use of hooks (dependencies arrays, cleanup)
- Avoiding unnecessary re-renders (useMemo, useCallback when needed)
- Component composition over prop drilling
- Proper key usage in lists
- Event handler naming (handleX, onX)
- State management (local vs global state)
- Proper error boundaries

### TypeScript
- Proper typing (avoid `any`, use specific types)
- Interface vs type usage consistency
- Proper null/undefined handling
- Generic type usage where appropriate
- Discriminated unions for state
- Proper type exports

### Go
- Error handling (no ignored errors, proper wrapping)
- Proper context usage and propagation
- Goroutine leaks and proper cleanup
- Defer usage for cleanup
- Interface design (small, focused interfaces)
- Proper logging with structured fields
- Database transaction handling

## Output Format

### Console Output

Provide feedback organized as:

**Critical Issues** - Must fix before merge
**Suggestions** - Improvements to consider
**Good Practices** - What's done well

For each issue include:
- File and line reference (e.g., `src/file.ts:42`)
- Clear explanation of the problem
- Suggested solution with code example when helpful
- Rationale for the change

Be constructive and educational. Focus on meaningful improvements, not style nitpicks.

### GitHub PR Review

After completing the review, post it to the GitHub PR:

1. **Collect all review comments** with their file paths and line numbers

2. **Submit the review with REQUEST_CHANGES** (or APPROVE if no critical issues):
   ```bash
   gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
     --method POST \
     --field body="$(cat <<'EOF'
   ## Code Review Summary

   [Overall summary of the review]

   **Critical Issues:** [count]
   **Suggestions:** [count]

   EOF
   )" \
     --field event="REQUEST_CHANGES" \
     --field comments='[
       {
         "path": "relative/path/to/file.ts",
         "line": 42,
         "body": "**Issue:** Description\n\n**Suggestion:**\n```typescript\n// suggested code\n```"
       }
     ]'
   ```

3. **Important notes for PR comments:**
   - Use `line` for the ending line of the comment
   - Use `start_line` if commenting on a range of lines
   - The `path` must be relative to the repo root
   - Use `side: "RIGHT"` for comments on the new code (default)
   - Each comment body should be concise but actionable
   - Use `event: "REQUEST_CHANGES"` if there are critical issues
   - Use `event: "APPROVE"` if no critical issues (only suggestions)
   - Use `event: "COMMENT"` for informational reviews

4. **After posting, output the PR URL** so the user can view the review.
