from collections.abc import Generator, Iterable
from typing import Callable, Any, Type, Coroutine, Unpack
from dataclasses import dataclass, field
from functools import wraps
from typing_extensions import Concatenate, Mapping
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


type Func[**P, U] = Callable[P, U] | None

class Pass[**P, Z]():
    def __init__(self, *args: P.args, **kwargs: P.kwargs):
        self.args = args
        self.kwargs = kwargs

    def __repr__(self):
        return f"\033[1;32m({self.__class__})\033[0m\n  \033[1;34margs:\033[0m\n    {self.args}\n  \033[1;34mkwargs:\033[0m\n    {self.kwargs}"

    def __call__[T, U](self, *args: T, **kwargs: U) -> Generator[Iterable[Z], object, None]:
        for maybe_f in self.args:
            if callable(maybe_f):
                yield maybe_f(*args, **self.kwargs, **kwargs)

    @classmethod
    def unit[**V](cls, *args: P.args, **kwargs: P.kwargs) -> "Pass[P, Z]":
        return cls(*args, **kwargs)

    def to[U](self, f: Callable[P, U]) -> U:
        return f(*self.args, **self.kwargs)

    def maybe_to[U](self, f: Func[P, U]) -> U | None:
        return self.to(f) if all(self.args) and callable(f) else None


## unfinished
class Next[**P, U: Iterable](Pass):
    def __init__(self, next_pass: type[Pass], *effects: Func[..., U], **kwargs: ...):
        super().__init__(next_pass(*effects))


#------------------------------------------------------------------
def set_state(prompt: str | None = None) -> str:
    if prompt:
        print(f"({prompt})", end='', flush=True)
    return input()



if __name__ == "__main__":
    for val in (Next
        (Pass, lambda *x: x*2, lambda x, y, z: x + y + z)
        (2, 3, 4)):
        for z in val:
            print(z)
