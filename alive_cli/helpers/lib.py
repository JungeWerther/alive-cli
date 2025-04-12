from typing import Callable, Any, Type, Coroutine, Unpack
from dataclasses import dataclass, field
from functools import wraps
from typing_extensions import Mapping
import numpy as np


type Just[T] = T
def just[T](x: T) -> Just[T]:
    return field(default_factory=lambda: x)

def get_type[T](x: T) -> Type[T]:
    return field(default_factory=lambda: type(x))

@dataclass
class Err[T]:
    type: Type = get_type(T)

type Maybe[T] = Just[T] | None
type Result[T, U] = Just[T] | Err[U]
type Aargs[*T, U, V] = tuple[*T, Mapping[U, V]]
type Vargs[W, Z] = Aargs[W, str, Z]
type FString[W, Z, V] = Fn[Unpack[Vargs[W, Z]], V]
type FnString[V] = FString[np.float32]

type Fn[*T, U] = Callable[[*T], U]
type MkMaybe[T, U] = Fn[Fn[T, U], Maybe[U]]
type MkResult[T, U] = Fn[Fn[T, U], Result[T, U]]

def async_catch[U, V](e: type[Exception], to_message: Fn[Exception, Err[V]]) -> MkResult[U, V]:
    @wraps
    def decorator[W, Z](f: FString[W, Z, V]) -> Callable:
        async def wrapper(*args: W, **kwargs: dict[str, Z]) -> Result[U, V]:
            try:
                return f(*args, **kwargs)
            except e as exc:
                return to_message(exc)
        return wrapper
    return decorator

import subprocess

def wrap(f: Callable) -> Callable:
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return subprocess.run(["zsh", "-c", "history -1"], capture_output=True, text=True).stdout
    return wrapper



def maybe[T, U](x: Maybe[T]) -> MkMaybe[T, U]:
    def bind(f: Fn[T, U]) -> Maybe[U]:
        return just(f(x)) if x else None
    return bind
