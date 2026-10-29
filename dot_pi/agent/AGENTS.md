<!-- BEGIN COMPOUND PI TOOL MAP -->
## Compound Engineering (Pi compatibility)

This block is managed by compound-plugin.

Pi extensions used by this plugin:
- Required: `pi-subagents` (by nicobailon) provides the `subagent` tool used by skills that dispatch parallel agents
- Recommended: `pi-ask-user` (by edlsh) provides the `ask_user` tool; skills fall back to numbered options in chat when it is missing

Install with:
  pi install npm:pi-subagents
  pi install npm:pi-ask-user
<!-- END COMPOUND PI TOOL MAP -->

## PR branding preference

- Do not add Compound Engineering branding, watermarks, badges, promotional links, or `ce-engineering` tags/labels to pull requests.
- Keep PR branding off across all workflows, including `ce-work` and `ce-commit-push-pr`. This user preference overrides skill-generated `branding:on` defaults: replace them with `branding:off` rather than passing both tokens.
- When rewriting an existing PR, remove Compound Engineering promotional branding while preserving substantive content and human contributor credit.
- Only add this branding if the user explicitly requests it for that PR. Preserve any repository-required disclosure.
