#!/usr/bin/env python3

import sys
import socket
import selectors
import traceback

import lib

sel = selectors.DefaultSelector()


def create_request(command, argument):
    return dict(
        type="text/json",
        encoding="utf-8",
        content=dict(action=command, value=argument),
    )


def start_connection(host, port, request):
    addr = (host, port)
    print("starting connection to", addr)
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setblocking(False)
    sock.connect_ex(addr)
    events = selectors.EVENT_READ | selectors.EVENT_WRITE
    message = lib.clientMessage(sel, sock, addr, request)
    sel.register(sock, events, data=message)


if len(sys.argv) != 5:
    print("usage:", sys.argv[0], "<host> <port> <command> <argument>")
    sys.exit(1)

host, port = sys.argv[1], int(sys.argv[2])
command, argument = sys.argv[3], sys.argv[4]
request = create_request(command, argument)
start_connection(host, port, request)

try:
    while True:
        events = sel.select(timeout=1)
        for key, mask in events:
            message = key.data
            try:
                message.process_events(mask)
            except Exception:
                print(
                    "main: error: exception for",
                    f"{message.addr}:\n{traceback.format_exc()}",
                )
                message.close()
        # Check for a socket being monitored to continue.
        if not sel.get_map():
            break
except KeyboardInterrupt:
    print("caught keyboard interrupt, exiting")
finally:
    sel.close()