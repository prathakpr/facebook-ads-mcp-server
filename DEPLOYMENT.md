# HTTP Deployment Guide for Facebook Ads MCP Server

This guide explains how to deploy the Facebook Ads MCP Server as an HTTP service that can be accessed remotely by AI assistants like Claude Desktop, Cursor, or other MCP-compatible clients.

## Overview

The MCP server now supports two modes:
- **stdio mode** (default): For local use, communicates via standard input/output
- **sse mode**: For HTTP deployment, uses Server-Sent Events for communication

## Deployment Options

### Option 1: Using Docker (Recommended)

#### Quick Start with Docker

1. **Build the Docker image:**
   ```bash
   docker build -t fb-ads-mcp-server .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     --name fb-ads-mcp-server \
     -p 8000:8000 \
     -e FB_ACCESS_TOKEN="your_facebook_access_token" \
     fb-ads-mcp-server
   ```

   The server will be available at `http://localhost:8000`

#### Using Docker Compose

1. **Create a `.env` file** (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and add your Facebook token:**
   ```bash
   FB_ACCESS_TOKEN=your_facebook_access_token_here
   ```

3. **Start the service:**
   ```bash
   docker-compose up -d
   ```

4. **View logs:**
   ```bash
   docker-compose logs -f
   ```

5. **Stop the service:**
   ```bash
   docker-compose down
   ```

### Option 2: Direct Python Execution

#### Prerequisites
- Python 3.10+
- Virtual environment (recommended)

#### Steps

1. **Clone and navigate to the repository:**
   ```bash
   git clone <your-repo-url>
   cd facebook-ads-mcp-server
   ```

2. **Create and activate virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set the Facebook token as environment variable:**
   ```bash
   export FB_ACCESS_TOKEN="your_facebook_access_token"
   ```

5. **Run the server in HTTP mode:**
   ```bash
   python server.py --transport sse --host 0.0.0.0 --port 8000
   ```

   The server will be available at `http://localhost:8000`

### Option 3: Cloud Deployment

#### Deploy to Heroku

1. **Create a `Procfile`:**
   ```
   web: python server.py --transport sse --host 0.0.0.0 --port $PORT
   ```

2. **Deploy:**
   ```bash
   heroku create your-fb-ads-mcp-server
   heroku config:set FB_ACCESS_TOKEN="your_facebook_access_token"
   git push heroku main
   ```

#### Deploy to Railway/Render/Fly.io

Most cloud platforms will automatically detect the Dockerfile. You just need to:
1. Connect your repository
2. Set the `FB_ACCESS_TOKEN` environment variable in the platform's dashboard
3. Deploy

#### Deploy to AWS/GCP/Azure

Use container services like:
- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances

Set the `FB_ACCESS_TOKEN` environment variable in the container configuration.

## Configuring AI Clients to Use HTTP Server

### For Claude Desktop

Edit your Claude Desktop config file:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

Add the following configuration:

```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "http://your-server-url:8000/sse"
    }
  }
}
```

**Example with deployed server:**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "https://your-app.herokuapp.com/sse"
    }
  }
}
```

**Example with local Docker:**
```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "http://localhost:8000/sse"
    }
  }
}
```

### For Cursor

Edit your Cursor config file and add:

```json
{
  "mcpServers": {
    "fb-ads-mcp-server": {
      "url": "http://your-server-url:8000/sse"
    }
  }
}
```

### For Other MCP Clients

Refer to your specific client's documentation for configuring remote MCP servers. Generally, you'll need:
- The SSE endpoint URL: `http://your-server-url:8000/sse`
- The server should be accessible from where your client runs

## Security Considerations

### Important Security Notes

1. **Token Security**: The Facebook access token is stored on the server, not shared with clients. This is more secure than passing tokens through client configs.

2. **HTTPS**: For production deployments, always use HTTPS to encrypt communication:
   - Use a reverse proxy (nginx, Caddy)
   - Use cloud platform's SSL/TLS features
   - Consider using Let's Encrypt for free SSL certificates

3. **Authentication**: Consider adding authentication to your MCP server:
   - API keys
   - OAuth
   - IP whitelisting

4. **Network Security**:
   - Don't expose the server directly to the internet without authentication
   - Use firewall rules to restrict access
   - Consider using a VPN or private network

### Adding Basic Authentication (Optional)

For added security, you can put the server behind a reverse proxy with authentication:

**Example nginx config:**
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Basic auth
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

## Testing the Deployment

### Test with curl

```bash
# Test if the server is running
curl http://localhost:8000/sse

# You should see Server-Sent Events stream connection
```

### Test with MCP Client

1. Update your AI client's config with the server URL
2. Restart the client
3. Try using one of the MCP tools (e.g., "list my Facebook ad accounts")

## Monitoring and Logs

### Docker Logs
```bash
# View logs
docker logs fb-ads-mcp-server

# Follow logs
docker logs -f fb-ads-mcp-server
```

### Direct Python Logs
The server outputs logs to stdout/stderr. Redirect to files if needed:
```bash
python server.py --transport sse > server.log 2>&1
```

## Troubleshooting

### Server won't start
- Check if the port is already in use: `lsof -i :8000` (macOS/Linux)
- Verify Facebook token is set correctly
- Check logs for error messages

### Client can't connect
- Verify the server is accessible from the client's network
- Check firewall rules
- Ensure the URL includes `/sse` endpoint
- Test with curl from the client's machine

### Token expired
- Facebook tokens expire periodically
- Update the `FB_ACCESS_TOKEN` environment variable
- Restart the server/container

## Updating the Server

### Docker
```bash
docker-compose down
git pull
docker-compose build
docker-compose up -d
```

### Direct Python
```bash
git pull
# Restart the Python process
```

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `FB_ACCESS_TOKEN` | Yes | Facebook/Meta access token with ads permissions |

## Command Line Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `--transport` | `stdio` | Transport mode: `stdio` or `sse` |
| `--host` | `0.0.0.0` | Host to bind to (SSE mode only) |
| `--port` | `8000` | Port to listen on (SSE mode only) |
| `--fb-token` | None | Facebook token (alternative to env var) |

## Support

For issues, questions, or contributions:
- GitHub Issues: [Your repo URL]
- Slack Community: [AI in Ads](https://join.slack.com/t/ai-in-ads/shared_invite/zt-36hntbyf8-FSFixmwLb9mtEzVZhsToJQ)

