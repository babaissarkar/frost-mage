#! /usr/bin/env python3

import os
import re
import shlex
import sys

def expand_inline_or_self_closing(line):
    """
    Expand single-line self-closing or inline tags with =, space, or {payload}.
    """
    pattern = re.compile(r'^(\s*)\[(\w+)(.*?)\s*(/?)\]\s*$')
    match = pattern.match(line)
    if not match:
        return line
    indent, tag, content, slash = match.groups()
    # Expand if self-closing, inline with = or space, or if it contains {macro}
    expand = slash == "/" or "=" in content or " " in content or (content.startswith("{") and content.endswith("}"))
    content = content.strip()
    if not expand:
        return line
    if content:
        direct: list[str] = []
        nested: dict[str, list[str]] = {}  # subtag -> [key=value, ...]
        for arg in shlex.split(content):
            dot_match = re.match(r'^(\w+)\.(\w+=\S+)$', arg)
            if dot_match:
                subtag, kv = dot_match.groups()
                nested.setdefault(subtag, []).append(kv)
            elif tag == "specials":
                direct.append(f"{{WEAPON_SPECIAL_{arg.upper()}}}")
            elif tag == "abilities":
                direct.append(f"{{ABILITY_{arg.upper()}}}")
            else:
                direct.append(arg)

        lines_out: list[str] = []
        for a in direct:
            if "=" in a:
                k, v = a.split("=", 1)
                a = f'{k}="{v}"' if " " in v else a
            lines_out.append(f"{indent}\t{a}")
        for subtag, kvs in nested.items():
            lines_out.append(f"{indent}\t[{subtag}]")
            for kv in kvs:
                lines_out.append(f"{indent}\t\t{kv}")
            lines_out.append(f"{indent}\t[/{subtag}]")
        content_body = "\n".join(lines_out)
        always_close = {"specials", "abilities"}
        if slash or tag in always_close:
            return f"{indent}[{tag}]\n{content_body}\n{indent}[/{tag}]"
        else:
            return f"{indent}[{tag}]\n{content_body}"
    else:
        return f"{indent}[{tag}]\n{indent}[/{tag}]"

def process_file(input_file, output_file=None):
    if output_file is None:
        output_file = input_file
    with open(input_file, 'r', encoding='utf-8') as f:
        raw = f.read()
    had_trailing_newline = raw.endswith('\n')
    lines = raw.splitlines()
    # Pass 1: expand self-closing / inline tags
    lines = [expand_inline_or_self_closing(l) for l in lines]
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))
        if had_trailing_newline:
            f.write("\n")

if __name__ == "__main__":
    if len(sys.argv) < 1:
        print("Usage: python wml_expand.py [input dir]")
        sys.exit(1)

    # Directory to start walking from (current dir by default)
    start_dir = sys.argv[1] if len(sys.argv) > 1 else "."

    for root, dirs, files in os.walk(start_dir):
        for file in files:
            if file.endswith(".cwml"):
                input_path = os.path.join(root, file)
                # Output path: same name but with .cfg extension
                output_path = os.path.splitext(input_path)[0] + ".cfg"
                print(f"Processing {input_path} -> {output_path}")
                process_file(input_path, output_path)
                print(f"Processed {input_path} -> {output_path}")

