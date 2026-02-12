#!/usr/bin/env python3
import sys


def main(argv=None) -> int:
    prog = (argv or sys.argv)[0]
    print(f"{prog}: not implemented yet (kernel present: tools/hd validate, tools/hd init)", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())

