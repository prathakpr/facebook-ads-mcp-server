# Configuration Examples

This document provides configuration examples for different deployment scenarios.

## Local Setup (stdio mode)

### Claude Desktop Config

**Location:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

**Configuration:**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "command": "python",
      "args": [
        "/path/to/facebook-ads-mcp-server/server.py",
        "--fb-token",
        "YOUR_FACEBOOK_ACCESS_TOKEN"
      ]
    }
  }
}
```

**With virtual environment:**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "command": "/path/to/facebook-ads-mcp-server/venv/bin/python",
      "args": [
        "/path/to/facebook-ads-mcp-server/server.py",
        "--fb-token",
        "YOUR_FACEBOOK_ACCESS_TOKEN"
      ]
    }
  }
}
```

## HTTP Deployment (sse mode)

### Claude Desktop Config for HTTP

**Local Docker deployment:**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "http://localhost:8000/sse"
    }
  }
}
```

**Remote deployment (Heroku example):**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "https://your-fb-ads-mcp.herokuapp.com/sse"
    }
  }
}
```

**Remote deployment (custom domain with HTTPS):**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "https://fb-ads-mcp.yourdomain.com/sse"
    }
  }
}
```

### Cursor Config for HTTP

Same format as Claude Desktop:

```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "http://localhost:8000/sse"
    }
  }
}
```

## Key Differences: Local vs HTTP

| Aspect | Local (stdio) | HTTP (sse) |
|--------|--------------|------------|
| **Token Location** | In client config | On server (environment variable) |
| **Configuration** | `command` + `args` | `url` |
| **Network** | Not required | Server must be accessible |
| **Sharing** | One instance per user | Multiple users can share |
| **Security** | Token in config file | Token on server only |

## Environment Variables for Server

When running the server in HTTP mode, set these environment variables:

```bash
# Required
export FB_ACCESS_TOKEN="your_facebook_access_token"
```

## Docker Environment Variables

### Using docker run
```bash
docker run -d \
  -p 8000:8000 \
  -e FB_ACCESS_TOKEN="your_token" \
  fb-ads-mcp-server
```

### Using .env file with docker-compose

Create a `.env` file:
```bash
FB_ACCESS_TOKEN=your_facebook_access_token_here
```

Then run:
```bash
docker-compose up -d
```

## Multiple Server Instances

You can configure multiple MCP servers in the same config file:

```json
{
  "mcpServers": {
    "fb-ads-local": {
      "command": "python",
      "args": [
        "/path/to/server.py",
        "--fb-token",
        "TOKEN_1"
      ]
    },
    "fb-ads-remote": {
      "url": "https://fb-ads-mcp.yourdomain.com/sse"
    },
    "other-mcp-server": {
      "url": "https://other-server.com/sse"
    }
  }
}
```

## Testing Your Configuration

After updating your config:

1. **Restart your AI client** (Claude Desktop/Cursor)
2. **Test the connection** by asking: "List my Facebook ad accounts"
3. **Check for errors** in the client's logs if it doesn't work

### Finding Client Logs

**Claude Desktop:**
- macOS: `~/Library/Logs/Claude/`
- Windows: `%APPDATA%\Claude\logs\`

**Cursor:**
- Check the developer console in Cursor settings

## Troubleshooting

### "Server not responding" error
- For local setup: Check that the Python path is correct
- For HTTP setup: Verify the URL is accessible (try in browser or with curl)

### "Authentication failed" error
- Verify your Facebook access token is valid
- Check token hasn't expired
- Ensure token has the right permissions (ads_read, ads_management)

### "Connection refused" error
- For HTTP setup: Ensure the server is running
- Check firewall settings
- Verify the port is correct

## Advanced: Custom Port or Host

If you need to run the server on a different port:

### Server side:
```bash
python server.py --transport sse --host 0.0.0.0 --port 3000
```

### Client config:
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "http://localhost:3000/sse"
    }
  }
}
```

