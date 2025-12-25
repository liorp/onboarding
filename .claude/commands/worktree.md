---
description: Create a new worktree for a ticket with full setup
argument-hint: <ticket-name>
allowed-tools: Bash, Read, Grep, Glob, WebFetch, mcp__linear-server__get_issue, mcp__linear-server__list_comments
---

Create a new git worktree for ticket "$ARGUMENTS" and set it up completely.

Steps to execute:
1. **Fetch the ticket from Linear first** to get the proper branch name:
   - Use `get_issue` with the ticket ID "$ARGUMENTS" to get the ticket details
   - Extract the `branchName` field from the response - this is the Linear-formatted branch name (e.g., `plt-2849-homepage`)
   - Use this branch name for all subsequent steps

2. Create a new worktree using the Linear branch name:
   ```bash
   git worktree add ~/projects/wonderful/wonderful-<linear-branch-name> -b <linear-branch-name>
   ```
   Where `<linear-branch-name>` is the `branchName` from step 1 (e.g., `plt-2849-homepage`)

3. Change to the new worktree directory and install frontend dependencies:
   ```bash
   cd ~/projects/wonderful/wonderful-<linear-branch-name>/wonderful-ui && yarn install
   ```

4. Run AWS SSO login to get credentials (required for make env):
   ```bash
   aws sso login
   ```

5. Run make env with localhost:
   ```bash
   cd ~/projects/wonderful/wonderful-<linear-branch-name> && make env HOST=localhost
   ```

6. **Research the ticket thoroughly before opening the IDE:**
   - Use the Linear MCP tools to fetch additional ticket details:
     - `list_comments` to get any discussion or clarifications on the ticket
   - Check for any linked resources in the ticket:
     - Figma links: If present, use `WebFetch` to extract design specifications
     - GitHub PR links: Review any related PRs or discussions
     - Documentation links: Fetch and summarize relevant docs
   - Analyze the ticket requirements and create a summary including:
     - What needs to be done (acceptance criteria)
     - Which files/components are likely affected
     - Any design specifications from Figma
     - Dependencies or blockers mentioned
   - Search the codebase in the new worktree to identify:
     - Relevant existing code that will need modification
     - Similar implementations to reference
     - Test files that may need updates

7. Open a new Cursor window at the worktree folder:
   ```bash
   cursor ~/projects/wonderful/wonderful-$ARGUMENTS
   ```

8. **Implement the ticket:**
   - Based on the research from step 6, implement the required changes
   - Follow the acceptance criteria from the ticket
   - Write clean, tested code following project conventions
   - Commit changes with a meaningful commit message referencing the ticket

Execute all these steps in order and report the results.
