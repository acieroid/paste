#!/usr/bin/env python
# Inspired from delroth's pygments benchmark
# (http://delroth.alwaysdata.net/sdz/geshi/bench-suite.tar.gz)

from SimpleXMLRPCServer import SimpleXMLRPCServer
from pygments import highlight
from pygments.lexers import get_lexer_by_name, get_all_lexers
from pygments.formatters import HtmlFormatter

def highlight_code(code, lang):
  return highlight(code, get_lexer_by_name(lang), HtmlFormatter())

def list_languages():
  return sorted(map(lambda x: (x[0], x[1][0]), get_all_lexers()),
                key=lambda x: x[0])

server = SimpleXMLRPCServer(("localhost", 8001))
server.register_function(highlight_code)
server.register_function(list_languages)
server.serve_forever()

