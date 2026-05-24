#!/usr/bin/env python3
"""Renderiza uma captura estilo terminal a partir de um arquivo texto."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ANSI_RE = re.compile(r"\x1b\[([0-9;]*)m")

COLOR_MAP = {
    30: "#2e3436",
    31: "#cc0000",
    32: "#4e9a06",
    33: "#c4a000",
    34: "#3465a4",
    35: "#75507b",
    36: "#06989a",
    37: "#eeeeec",
    90: "#555753",
    91: "#ef2929",
    92: "#8ae234",
    93: "#fce94f",
    94: "#729fcf",
    95: "#ad7fa8",
    96: "#34e2e2",
    97: "#ffffff",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--font", required=True)
    parser.add_argument("--font-size", type=int, default=24)
    parser.add_argument("--line-height", type=int, default=34)
    parser.add_argument("--padding-x", type=int, default=28)
    parser.add_argument("--padding-y", type=int, default=26)
    parser.add_argument("--background", default="#300a24")
    parser.add_argument("--default-color", default="#ffffff")
    parser.add_argument("--max-width", type=int, default=1900)
    return parser.parse_args()


def split_segments(line: str, default_color: str) -> list[tuple[str, str]]:
    segments: list[tuple[str, str]] = []
    current_color = default_color
    position = 0

    for match in ANSI_RE.finditer(line):
        if match.start() > position:
            segments.append((line[position:match.start()], current_color))

        codes = [code for code in match.group(1).split(";") if code]
        if not codes or "0" in codes:
            current_color = default_color
        else:
            for raw_code in codes:
                code = int(raw_code)
                if code == 1:
                    continue
                if code in COLOR_MAP:
                    current_color = COLOR_MAP[code]
        position = match.end()

    if position < len(line):
        segments.append((line[position:], current_color))

    return segments


def text_width(font: ImageFont.FreeTypeFont, text: str) -> int:
    if not text:
        return 0
    left, _, right, _ = font.getbbox(text)
    return right - left


def main() -> None:
    args = parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    lines = input_path.read_text(encoding="utf-8").splitlines()
    if not lines:
        lines = [""]

    font = ImageFont.truetype(args.font, args.font_size)
    segmented_lines = [split_segments(line, args.default_color) for line in lines]

    content_width = 0
    for segments in segmented_lines:
        line_width = sum(text_width(font, text) for text, _ in segments)
        if line_width > content_width:
            content_width = line_width

    width = min(max(content_width + (args.padding_x * 2), 1200), args.max_width)
    height = (len(lines) * args.line_height) + (args.padding_y * 2)

    image = Image.new("RGB", (width, height), args.background)
    draw = ImageDraw.Draw(image)

    y = args.padding_y
    for segments in segmented_lines:
        x = args.padding_x
        for text, color in segments:
            if not text:
                continue
            draw.text((x, y), text, fill=color, font=font)
            x += text_width(font, text)
        y += args.line_height

    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(output_path)


if __name__ == "__main__":
    main()
