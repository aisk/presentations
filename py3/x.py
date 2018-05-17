import typing


Num = typing.Union[int, float]


def add(x: Num, y: Num) -> Num:
    return x + y


add('foo', 1)
