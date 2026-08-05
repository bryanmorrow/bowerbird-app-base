# AI agents (Grok / xAI)

Customer apps that need generative AI use **named agents** on top of a shared
**GrokClient**, not one-off HTTP calls or fake “template” generators.

## Required pieces

| Path | Role |
|------|------|
| `app/services/grok_client.rb` | xAI API (`chat`, `chat_json`) |
| `app/models/concerns/ai_agent.rb` | `include AiAgent` → `ai_scope` + `build_tracked_client` |
| `app/services/ai_tracking.rb` | Thread-local cost attribution |
| `app/models/ai_usage_event.rb` | Optional usage rows |
| `app/agents/*_agent.rb` | Product agents (one class per job) |

## Secret

```
REQUEST_SECRET: XAI_API_KEY — xAI Grok API key for AI agents
```

Bowerbird collects this in chat and syncs it to Railway as `XAI_API_KEY`.
**Do not invent other provider keys** unless the customer asked for a specific API.
Default AI for Bowerbird-managed apps is **Grok (xAI)**.

## Agent pattern

```ruby
# app/agents/landing_page_agent.rb
class LandingPageAgent
  include AiAgent

  def generate!(business:, answers:, assets: [])
    ai_scope(step: "landing_page.generate") do
      build_tracked_client.chat_json(
        system: "You write conversion landing pages as JSON…",
        prompt: { business: business, answers: answers, assets: assets }.to_json
      )
    end
  end
end
```

## Rules for Grok Build (Bowerbird)

1. When the customer asks for AI / agents / “use Grok”, implement **real agents** under `app/agents/`.
2. Call **GrokClient** via `include AiAgent` — never a deterministic string template pretending to be AI.
3. Request **`XAI_API_KEY`** with `REQUEST_SECRET` if missing.
4. Handle missing key gracefully (empty state / flash: “Add your Grok API key in Secrets”).
5. Do not call OpenAI/Anthropic unless explicitly requested.

## Env

| Variable | Purpose |
|----------|---------|
| `XAI_API_KEY` | Bearer token for api.x.ai |
| `XAI_MODEL` | Optional model id (default `grok-3-mini`) |
| `XAI_TIMEOUT_SEC` | HTTP read timeout (default 120) |
