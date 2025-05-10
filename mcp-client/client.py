import asyncio
from typing import Callable, Awaitable, Mapping
from contextlib import AsyncExitStack

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

from anthropic import Anthropic
from dotenv import load_dotenv

from bluetooth import *
import dbus
import time

class BluetoothKeyboard:
    def __init__(self):
        self.bus = dbus.SystemBus()
        self.bluez = self.bus.get_object('org.bluez', "/")
        self.manager = dbus.Interface(self.bluez, 'org.bluez.ProfileManager1')


# Type aliases and monadic types
type Fn[*T, U] = Callable[[*T], U]
type Function[*T, U, V] = Fn[Fn[*T, U], V]
type Just[*T, U] = Function[*T, U, U]
type Result[*T, U] = Function[*T, U, Maybe[U]]
type AsyncFn[*T, U] = Fn[*T, Awaitable[U]]
type Maybe[T] = T | None
type ToolName = str

def just[T, U](x: T) -> Just[T, U]:
    def bind(f: Fn[T, U]) -> U:
        return f(x)
    return bind

def maybe[T, U](x: Maybe[T]) -> Result[T, U]:
    def bind(f: Fn[T, U]) -> Maybe[U]:
        return f(x) if x is not None else None
    return bind

async def init_mcp(address: str, port: int) -> tuple[StdioServerParameters, Mapping[str, AsyncFn]]:
    stack = AsyncExitStack()
    session = await stack.enter_async_context(ClientSession())
    client = await stdio_client(session, address, port)

    async def handle_message(message: str) -> None:
        await client.send_message(message)

    async def close() -> None:
        await stack.aclose()

    handlers = {
        'message': handle_message,
        'close': close
    }

    return client.parameters, handlers

load_dotenv()
