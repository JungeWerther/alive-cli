from typing import Any, Mapping
import httpx
from mcp.server.fastmcp import FastMCP
from helpers.lib import async_catch, just, Maybe
from functools import partial
from dataclasses import dataclass, field


type Headers = Mapping[str, str]

# Initialize FastMCP server
mcp = FastMCP("weather")

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
DEFAULT_HEADERS = {
            "User-Agent": USER_AGENT,
            "Accept": "text/html",
            "Content-Type": "application/json"
        }

# @async_catch(Exception, lambda e: f"{e}")
async def request(client: httpx.AsyncClient, url: str, headers: dict) -> dict:
    response = await client.get(url, headers=headers, timeout=30.0)
    response.raise_for_status()
    return response.json()


@dataclass
class RequestManager:
    headers: Maybe[Headers] = just(DEFAULT_HEADERS)

    async def async_request(self, async_client: httpx.AsyncClient, *args):
        async with async_client() as client:
            return await client(*args, headers=self.headers)

    async def request(self, url: str, headers: Headers) -> dict[str, Any] | None:
        """Make a request to the NWS API with proper error handling."""
        with httpx.AsyncClient as client:
            await self.async_request(client, url)

def format_alert(feature: dict) -> str:
    """Format an alert feature into a readable string."""
    props = feature["properties"]
    return f"""
Event: {props.get('event', 'Unknown')}
Area: {props.get('areaDesc', 'Unknown')}
Severity: {props.get('severity', 'Unknown')}
Description: {props.get('description', 'No description available')}
Instructions: {props.get('instruction', 'No specific instructions provided')}
"""

@mcp.tool()
async def get_alerts(state: str) -> str:
    """Get weather alerts for a US state.

    Args:
        state: Two-letter US state code (e.g. CA, NY)
    """

    url = "https://pearstop.com"

    data = await RequestManager().async_request(url)

    if not data or "features" not in data:
        return "Unable to fetch alerts or no alerts found."

    if not data["features"]:
        return "No active alerts for this state."

    alerts = [format_alert(feature) for feature in data["features"]]
    return "\n---\n".join(alerts)

if __name__ == "__main__":
    mcp.run(transport='stdio')
