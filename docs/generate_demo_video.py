#!/usr/bin/env python3
"""Generate AgentID demo MP4 frames (1280x720) then encode with ffmpeg."""
from __future__ import annotations

import math
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

W, H = 1280, 720
FPS = 30
DURATION = 58.0  # seconds
OUT_DIR = Path("/workspace/AgentID/docs/frames")
MP4_PATH = Path("/workspace/AgentID/docs/AgentID-demo-1min.mp4")

BG = (11, 15, 20)
PANEL = (17, 24, 33)
BORDER = (30, 42, 56)
TEXT = (230, 237, 243)
MUTED = (139, 155, 176)
GREEN = (61, 214, 140)
CYAN = (92, 200, 255)
AMBER = (255, 193, 74)
PINK = (255, 122, 178)
DIM = (74, 90, 106)

FONT_REG = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"
FONT_SANS = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

# Timed lines matching npm run demo / demo.html
LINES = [
    (0.6, "banner", "=" * 64),
    (0.8, "header", "  AgentID — Sybil-lite reputation"),
    (1.0, "banner", "=" * 64),
    (1.4, "meta", "  Track: Trust / Identity · Monad Metropolis"),
    (1.8, "hl", "  LIVE: 0xDCcBbFFC…f859 · chain 10143"),
    (2.3, "meta", "  Rules: No self-attest · One vote · Average (not spam-sum)"),
    (2.8, "meta", "  Author: Jimmy Wang"),
    (3.4, "blank", ""),
    (4.0, "banner", "=" * 64),
    (4.2, "header", "  Problem: two agents claim to be helpful"),
    (4.4, "banner", "=" * 64),
    (5.2, "key", "  Without portable reputation you cannot tell who to trust."),
    (7.0, "blank", ""),
    (7.5, "banner", "=" * 64),
    (7.7, "header", "  1) Register GoodBot + FakeBot"),
    (7.9, "banner", "=" * 64),
    (8.8, "ok", "  GoodBot agentId: 1  uri: ipfs://agentid/good-bot"),
    (10.0, "pink", "  FakeBot agentId: 2  uri: ipfs://agentid/fake-bot"),
    (11.5, "blank", ""),
    (12.2, "banner", "=" * 64),
    (12.4, "header", "  2) Attest GoodBot — 5 / 5 / 4"),
    (12.6, "banner", "=" * 64),
    (13.5, "ok", "  tags: reliable, helpful, on-time"),
    (15.5, "blank", ""),
    (16.2, "banner", "=" * 64),
    (16.4, "header", "  3) Attest FakeBot — 1 / 2"),
    (16.6, "banner", "=" * 64),
    (17.5, "pink", "  tags: spam, impersonation"),
    (19.5, "blank", ""),
    (20.5, "banner", "=" * 64),
    (20.7, "header", "  4) getReputation — average ×100"),
    (20.9, "banner", "=" * 64),
    (22.5, "ok", "  GoodBot  avg=4.66  count=3  unique=3"),
    (25.0, "pink", "  FakeBot  avg=1.50  count=2  unique=2"),
    (28.0, "hl", "  → GoodBot clearly beats FakeBot (466 > 150)"),
    (31.0, "blank", ""),
    (32.0, "banner", "=" * 64),
    (32.2, "header", "  5) Sybil-lite: re-attest does not spam-sum"),
    (32.4, "banner", "=" * 64),
    (34.0, "ok", "  same attester overwrite → still count=3"),
    (36.5, "blank", ""),
    (38.0, "banner", "=" * 64),
    (38.3, "header", "  Done — portable trust that resists self-boost"),
    (38.6, "banner", "=" * 64),
    (41.0, "ok", "  No self-attest · One vote / attester · Average reputation"),
    (44.0, "hl", "  ★ Live on Monad testnet · GoodBot vs FakeBot seeded"),
    (47.0, "meta", "  github.com/JimmyWangJimmy/AgentID"),
    (50.0, "meta", "  jimmywangjimmy.github.io/AgentID/"),
]


def color_for(cls: str):
    return {
        "banner": DIM,
        "header": CYAN,
        "meta": MUTED,
        "key": TEXT,
        "ok": GREEN,
        "hl": AMBER,
        "pink": PINK,
        "blank": BG,
    }.get(cls, TEXT)


def load_fonts():
    return {
        "title": ImageFont.truetype(FONT_SANS, 48),
        "sub": ImageFont.truetype(FONT_REG, 22),
        "badge": ImageFont.truetype(FONT_BOLD, 16),
        "mono": ImageFont.truetype(FONT_REG, 18),
        "mono_b": ImageFont.truetype(FONT_BOLD, 18),
        "chrome": ImageFont.truetype(FONT_REG, 14),
        "footer": ImageFont.truetype(FONT_REG, 14),
    }


def rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def draw_title_card(img, fonts, t):
    """First ~3.5s: title card overlay fading into terminal."""
    draw = ImageDraw.Draw(img)
    # dark overlay
    overlay = Image.new("RGBA", (W, H), (11, 15, 20, 230))
    base = img.convert("RGBA")
    # fade out after 2.5s
    if t > 2.5:
        alpha = max(0, int(230 * (1 - (t - 2.5) / 1.0)))
        overlay = Image.new("RGBA", (W, H), (11, 15, 20, alpha))
    composed = Image.alpha_composite(base, overlay)
    d = ImageDraw.Draw(composed)
    if t <= 3.4:
        title = "AgentID"
        sub1 = "On-chain Agent Identity & Reputation Registry"
        sub2 = "Monad Metropolis  ·  Trust / Identity & AI Infrastructure"
        author = "Jimmy Wang"
        badge = "MOCK REGISTRY — NO CHAIN DEPLOY"
        # center text
        def center(text, font, y, fill):
            bbox = d.textbbox((0, 0), text, font=font)
            tw = bbox[2] - bbox[0]
            d.text(((W - tw) // 2, y), text, font=font, fill=fill)

        fade = 255 if t < 2.5 else max(0, int(255 * (1 - (t - 2.5) / 1.0)))
        def with_a(rgb):
            return (*rgb, fade) if len(rgb) == 3 else rgb

        # PIL text doesn't use alpha in RGB mode well on RGBA - use fill with alpha
        center(title, fonts["title"], 240, (*CYAN, fade))
        center(sub1, fonts["sub"], 310, (*TEXT, fade))
        center(sub2, fonts["sub"], 345, (*MUTED, fade))
        center(author, fonts["sub"], 390, (*GREEN, fade))
        # badge
        bb = d.textbbox((0, 0), badge, font=fonts["badge"])
        bw = bb[2] - bb[0] + 28
        bh = bb[3] - bb[1] + 14
        bx = (W - bw) // 2
        by = 440
        d.rounded_rectangle([bx, by, bx + bw, by + bh], radius=20,
                            outline=(*AMBER, fade), width=2)
        center(badge, fonts["badge"], by + 6, (*AMBER, fade))
    return composed.convert("RGB")


def visible_lines(t: float):
    return [(cls, text) for (ts, cls, text) in LINES if ts <= t]


def draw_frame(t: float, fonts) -> Image.Image:
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    # subtle vignette circles (simple)
    # top header outside terminal
    header_y = 28
    draw.text((40, header_y), "AgentID", font=fonts["title"], fill=CYAN)
    draw.text((230, header_y + 18), "· Monad Metropolis · Trust/Identity · Jimmy Wang",
              font=fonts["chrome"], fill=MUTED)
    # badge top-right
    badge = "MOCK"
    bb = draw.textbbox((0, 0), badge, font=fonts["badge"])
    bw = bb[2] - bb[0] + 24
    bh = bb[3] - bb[1] + 10
    bx, by = W - 40 - bw, header_y + 12
    draw.rounded_rectangle([bx, by, bx + bw, by + bh], radius=12, outline=AMBER, width=2)
    draw.text((bx + 12, by + 4), badge, font=fonts["badge"], fill=AMBER)

    # terminal panel
    tx0, ty0, tx1, ty1 = 40, 90, W - 40, H - 50
    rounded_rect(draw, [tx0, ty0, tx1, ty1], 14, PANEL, outline=BORDER, width=2)

    # chrome bar
    draw.rectangle([tx0, ty0, tx1, ty0 + 36], fill=(13, 19, 26))
    for i, c in enumerate([(255, 95, 87), (254, 188, 46), (40, 200, 64)]):
        cx = tx0 + 18 + i * 18
        cy = ty0 + 18
        draw.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=c)
    draw.text((tx0 + 80, ty0 + 10), "~/AgentID  ·  npm run demo", font=fonts["chrome"], fill=DIM)

    # progress bar at bottom of panel
    prog_y = ty1 - 18
    draw.rectangle([tx0 + 20, prog_y, tx1 - 20, prog_y + 6], fill=BORDER)
    pct = min(1.0, t / DURATION)
    pw = int((tx1 - tx0 - 40) * pct)
    if pw > 0:
        draw.rectangle([tx0 + 20, prog_y, tx0 + 20 + pw, prog_y + 6], fill=GREEN)

    # terminal content
    lines = visible_lines(t)
    # show prompt until first line
    x = tx0 + 28
    y = ty0 + 52
    line_h = 24
    max_lines = 22

    if t < 0.8:
        draw.text((x, y), "$ npm run demo", font=fonts["mono"], fill=MUTED)
        # blinking cursor
        if int(t * 2) % 2 == 0:
            draw.rectangle([x + 170, y + 2, x + 180, y + 20], fill=GREEN)
    else:
        # only show last max_lines
        shown = lines[-max_lines:]
        for cls, text in shown:
            if cls == "blank":
                y += line_h // 2
                continue
            font = fonts["mono_b"] if cls in ("header", "ok") else fonts["mono"]
            # truncate long lines for safety
            display = text if len(text) <= 88 else text[:85] + "..."
            draw.text((x, y), display, font=font, fill=color_for(cls))
            y += line_h
            if y > prog_y - 30:
                break

    # footer
    draw.text((40, H - 36), "register → attest → getReputation", font=fonts["footer"], fill=DIM)
    draw.text((W - 360, H - 36), "github.com/JimmyWangJimmy/AgentID", font=fonts["footer"], fill=DIM)

    if t < 3.5:
        img = draw_title_card(img, fonts, t)
    return img


def main():
    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)
    OUT_DIR.mkdir(parents=True)

    fonts = load_fonts()
    n_frames = int(DURATION * FPS)
    print(f"Generating {n_frames} frames @ {FPS}fps ({DURATION}s)…")

    # Generate every frame — but to save time/disk, we can generate at lower
    # density and let ffmpeg interpolate... Better: generate all at 15fps then set -r 15
    # For quality use 15fps for generation (still smooth for terminal text)
    gen_fps = 15
    n = int(DURATION * gen_fps)
    for i in range(n):
        t = i / gen_fps
        frame = draw_frame(t, fonts)
        frame.save(OUT_DIR / f"frame_{i:05d}.png", optimize=True)
        if i % 30 == 0:
            print(f"  frame {i}/{n} t={t:.1f}s")

    print("Encoding MP4…")
    # hold last frame feel already in duration
    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(gen_fps),
        "-i", str(OUT_DIR / "frame_%05d.png"),
        "-c:v", "libx264",
        "-pix_fmt", "yuv420p",
        "-crf", "20",
        "-movflags", "+faststart",
        "-vf", "scale=1280:720",
        str(MP4_PATH),
    ]
    subprocess.check_call(cmd)
    print(f"Wrote {MP4_PATH} ({MP4_PATH.stat().st_size} bytes)")

    # cleanup frames to keep repo lean (keep mp4 + html only)
    shutil.rmtree(OUT_DIR)
    print("Cleaned frames/")


if __name__ == "__main__":
    main()
