# LLM-router

## Overview

Access models from OpenAI, Groq, local Ollama, and other providers by setting LLM-router as the base URL in Cursor. 

LLM-router is a reverse proxy that routes `chat/completions` API requests to various OpenAI-compatible backends based on the model's prefix.

## Background

[Cursor](https://cursor.sh) lacks support for local models and the flexibility to switch between multiple LLM providers efficiently. There's clear demand in the community, evidenced by months of unanswered requests for such features on Cursor's GitHub and Discord channels.

The specific challenges with Cursor include:
1. The `Override OpenAI Base URL` setting requires a URL that is publicly accessible and secured with `https`, complicating the use of local models.
2. The platform allows configuration for only one LLM provider at a time, which makes it cumbersome to switch between service providers.

LLM-router overcomes these limitations, allowing seamless switching between locally served models like Ollama and external services such as OpenAI and Groq.

https://github.com/kcolemangt/llm-router/assets/20099734/7220a3ac-11c5-4c89-984a-29d1ea850d10

## Getting Started

1. Edit your configuration file:
   - config.json file defines which LLM backends are available and how to route to them

2. Launch LLM-router to manage API requests across multiple backends:
```sh
./llm-router-darwin-arm64
```
   - If you haven't set a `LLMROUTER_API_KEY` environment variable, the program will generate a random strong API key
   - **Copy this API key** as you'll need it for Cursor's configuration

3. Launch [ngrok](https://ngrok.com) to create a public HTTPS endpoint for your LLM-router:
```sh
ngrok http 11411
```
   - Take note of the HTTPS URL provided by ngrok (e.g., `https://xxxx.ngrok-free.app`)

4. Configure Cursor to use your LLM-router:
   - Open Cursor's settings and go to the "Models" section
   - Paste the LLM-router API key (from step 2) into the "OpenAI API Key" field
   - Click the dropdown beneath the API key field labeled "Override OpenAI Base URL (when using key)"
   - Enter your ngrok URL (from step 3) in this field
   - Click the "Save" button next to this field
   - Click the "Verify" button next to the API key field to confirm the connection

5. Define your preferred models in Cursor using the appropriate prefixes:
```
ollama/gemma3:1b
```

⚠️ **Important Warning**: When clicking "Verify", Cursor randomly selects one of your enabled models to test the connection. Make sure to **uncheck any models** in Cursor's model list that aren't provided by the backends configured in your `config.json`. Otherwise, verification may fail if Cursor tries to test a model that's not available through your LLM-router.

## Configuration

Here is an example of how to configure Groq, Ollama, and OpenAI backends in `config.json`:
```json
{
	"listening_port": 11411,
	"llmrouter_api_key_env": "LLMROUTER_API_KEY",
	"aliases": {
		"gemma3": "ollama/gemma3:1b"
	},
	"backends": [
		{
			"name": "ollama",
			"base_url": "http://localhost:11434/v1",
			"prefix": "ollama/",
			"role_rewrites": {
				"developer": "system"
			}
		}
	]
}
```

### Optimizing for Reasoning Models and Prompt Techniques

Clients such as Cursor send specialized prompts to specific models recognized for enhanced reasoning performance. Usually, these optimized prompts target proprietary models. The **Model Aliases** and **Role Rewrites** features in LLM-router allow you to extend these optimizations to reasoning-oriented models hosted locally (such as via Ollama) or by alternative providers (like Groq).

By combining aliases and role rewrites, you can route optimized reasoning prompts effectively across different backend models.

#### Model Aliases

Aliases allow mapping specific client-recognized reasoning model identifiers to backend models of your choice. This causes Cursor and similar clients to use specialized reasoning prompts designed for those models.

Simple example:

```json
"aliases": {
    "o1": "groq/deepseek-r1-distill-llama-70b-specdec"
}
```

#### Role Rewrites

Role rewrites ensure that message roles from clients are correctly translated to match backend provider expectations. Clients using specialized reasoning prompts often use custom roles (e.g., `developer`) that may not be recognized universally.

Simple example:

```json
"role_rewrites": {
    "developer": "system"
}
```

- Messages with the role `developer` from Cursor will be rewritten to the standard role `system`, ensuring compatibility with backends.

#### Unsupported Parameters

Each model provider may support different parameters in their API requests. The `unsupported_params` option allows you to specify parameters that should be automatically removed from requests before forwarding them to specific backends, preventing errors due to incompatible parameters.

Simple example:

```json
"unsupported_params": [
    "reasoning_effort"
]
```

In this example:
- The parameter `reasoning_effort` will be automatically removed from requests before forwarding to this backend.
- This is particularly useful when aliases direct Cursor-optimized prompts (which may include provider-specific parameters) to different backends that don't support those parameters.

In this configuration:
- Requests to `gemma3` go to the local Ollama model `llama/gemma3:1b`.
- Both backends use role rewriting to map Cursor's custom `developer` role to the standard `system` role.

#### Additional Uses

These features are not limited to reasoning models. They can be applied broadly to facilitate compatibility and optimal prompting strategies across various model types and backend configurations.

### API Keys

Provide the necessary API keys via environment variables:
```sh
OPENAI_API_KEY=<YOUR_OPENAI_KEY> ./llm-router-darwin-arm64
```

If you wish to specify your own LLM-router API key instead of using a generated one:
```sh
LLMROUTER_API_KEY=your_custom_key ./llm-router-darwin-arm64
```

Alternatively, you can use the command-line flag:
```sh
./llm-router-darwin-arm64 --llmrouter-api-key=your_custom_key
```

#### Using .env Files

You can also store your API keys and other configuration in a `.env` file in the same directory as LLM-router. This is recommended to avoid exposing sensitive keys in your shell history or environment.

1. Create a `.env` file by copying the provided example:
```sh
cp .env.example .env
```

2. Edit the `.env` file with your API keys:
```sh
# LLM-Router configuration
LLMROUTER_API_KEY=your_llmrouter_api_key_here

```

LLM-router will automatically load variables from this file at startup. Environment variables that are already set will take precedence over those in the `.env` file, following standard precedence rules.

## Details

Routes `chat/completions` API requests to any OpenAI-compatible LLM backend based on the model's prefix. Streaming is supported.

LLM-router can be set up to use individual API keys for each backend, or no key for services like local Ollama.

Requests to LLM-router are secured with your `LLMROUTER_API_KEY` which you set in Cursor's OpenAI API Key field. This key is used to authenticate requests to your LLM-router, while the backend-specific API keys (like GROQ_API_KEY) are used by LLM-router to authenticate with the respective API providers.

### Build from Source
If none of the above methods work, consider building the application from source:

1. Download the source code.
2. Ensure you have a current version of [Go](https://go.dev) installed.
3. Build the application:
   ```sh
   make
   ./build/llm-router-local
   ```
