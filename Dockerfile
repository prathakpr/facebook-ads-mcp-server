# Dockerfile for Facebook Ads MCP Server (HTTP mode)
FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . ./

# Expose port for HTTP (SSE) mode
EXPOSE 8000

# Set environment variable for the Facebook token (to be overridden at runtime)
ENV FB_ACCESS_TOKEN=""

# Command to run the MCP server in HTTP mode
# The Facebook token should be provided via FB_ACCESS_TOKEN environment variable
CMD ["python", "server.py", "--transport", "sse", "--host", "0.0.0.0", "--port", "8000"]
