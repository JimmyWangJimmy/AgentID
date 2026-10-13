#!/usr/bin/env python3
"""Synthesize AgentID Judge Mode demo MP4 (1280x720)."""
from __future__ import annotations
import math, shutil, subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

W, H, FPS = 1280, 720, 30
DURATION = 65.0
OUT_DIR = Path("/workspace/AgentID/docs/frames")
MP4 = Path("/workspace/AgentID/docs/AgentID-demo-1min.mp4")
BG = (3, 4, 10)
TEXT = (245, 247, 255)
MUTED = (139, 147, 168)
VIOLET = (167, 139, 250)
CYAN = (92, 225, 255)
GREEN = (52, 211, 153)
AMBER = (251, 191, 36)
RED = (255, 92, 122)
PINK = (244, 114, 182)

FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
MONO = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"

def font(size, mono=False):
    try:
        return ImageFont.truetype(MONO if mono else FONT, size)
    except Exception:
        return ImageFont.load_default()

def lerp(a, b, t):
    return a + (b - a) * t

def ease(t):
    return 1 - (1 - t) ** 3

# Scenes: (start, end, id)
SCENES = [
    (0, 9, "problem"),
    (9, 20, "erc8004"),
    (20, 31, "raw"),
    (31, 48, "weighted"),
    (48, 65, "verdict"),
]

CAPTIONS = [
    (0, "01 / 05  Agents can fake trust with sockpuppets."),
    (9, "02 / 05  ERC-8004 feedback is on-chain. AgentID is the aggregator lens."),
    (20, "03 / 05  Raw average: SybilBot 4.00 fools the mean."),
    (31, "04 / 05  Weighted: puppets collapse. Sybil 4.00 → 1.22 EXPOSED."),
    (48, "05 / 05  Verdicts: GRANT · CAUTION · DENY."),
]

def caption_at(t):
    c = CAPTIONS[0][1]
    for start, text in CAPTIONS:
        if t >= start:
            c = text
    return c

def scene_at(t):
    for a, b, name in SCENES:
        if a <= t < b:
            return name, (t - a) / (b - a)
    return "verdict", 1.0

def draw_bg(draw, name):
    # vignette-ish rects
    draw.rectangle([0, 0, W, H], fill=BG)
    if name == "verdict":
        draw.ellipse([W*0.2, -H*0.3, W*0.8, H*0.4], fill=(20, 40, 35))
    elif name in ("raw", "weighted"):
        draw.ellipse([W*0.15, -H*0.35, W*0.85, H*0.45], fill=(40, 18, 28))
    else:
        draw.ellipse([W*0.15, -H*0.35, W*0.85, H*0.45], fill=(28, 22, 48))

def draw_chrome(draw, t):
    draw.text((40, 28), "AgentID", fill=TEXT, font=font(22))
    draw.text((140, 34), "Judge Mode · Monad", fill=MUTED, font=font(14))
    # progress pills
    step = 0
    for i, (a, _, _) in enumerate(SCENES):
        if t >= a:
            step = i
    x = W - 220
    for i in range(5):
        col = VIOLET if i == step else ((80, 70, 110) if i < step else (40, 44, 56))
        draw.rounded_rectangle([x + i*36, 36, x + i*36 + 28, 42], radius=2, fill=col)

def draw_caption_bar(draw, t):
    draw.rectangle([0, H - 70, W, H], fill=(8, 10, 18))
    draw.text((40, H - 48), caption_at(t), fill=TEXT, font=font(18))

def scene_problem(draw, p):
    draw.text((W//2, 200), "THE PROBLEM", fill=VIOLET, font=font(16), anchor="mm")
    draw.text((W//2, 280), "Agents can fake trust", fill=TEXT, font=font(54), anchor="mm")
    draw.text((W//2, 350), "with sockpuppets.", fill=TEXT, font=font(54), anchor="mm")
    draw.text((W//2, 430), "Open feedback alone is not a gate.", fill=MUTED, font=font(22), anchor="mm")

def scene_erc(draw, p):
    draw.text((W//2, 160), "ERC-8004 ON MONAD", fill=CYAN, font=font(16), anchor="mm")
    draw.text((W//2, 230), "Official feedback is live.", fill=TEXT, font=font(48), anchor="mm")
    boxes = [
        (220, "GoodBot #2204", "summary ≈ 4★", GREEN),
        (640, "FakeBot #2205", "summary ≈ 1★", AMBER),
        (1060, "SybilBot #2206", "summary ≈ 4★", PINK),
    ]
    for cx, title, sub, col in boxes:
        draw.rounded_rectangle([cx-150, 340, cx+150, 440], radius=16, outline=col, width=2)
        draw.text((cx, 375), title, fill=TEXT, font=font(18), anchor="mm")
        draw.text((cx, 410), sub, fill=MUTED, font=font(14), anchor="mm")

def scene_raw(draw, p):
    draw.text((W//2, 150), "RAW AVERAGE", fill=RED, font=font(16), anchor="mm")
    draw.text((W//2, 210), "SybilBot looks fine.", fill=TEXT, font=font(48), anchor="mm")
    cards = [
        (250, "GOODBOT", "4.66", GREEN, False),
        (640, "FAKEBOT", "1.50", AMBER, False),
        (1030, "SYBILBOT", "4.00", PINK, True),
    ]
    for cx, name, num, col, glow in cards:
        draw.rounded_rectangle([cx-140, 300, cx+140, 480], radius=18, outline=col if glow else (40,44,56), width=2)
        draw.text((cx, 340), name, fill=MUTED, font=font(14), anchor="mm")
        draw.text((cx, 400), num, fill=col, font=font(56, mono=True), anchor="mm")
        if glow:
            draw.text((cx, 455), "FOOLS RAW AVG", fill=PINK, font=font(12), anchor="mm")

def scene_weighted(draw, img, p):
    draw.text((W//2, 120), "AGENTID WEIGHTED", fill=VIOLET, font=font(16), anchor="mm")
    draw.text((W//2, 175), "Trust-weight the attesters.", fill=TEXT, font=font(36), anchor="mm")
    # ring
    cx, cy, R = W//2, 400, 110
    collapsed = p > 0.35
    nodes = [
        ("S", cx, cy, 26, PINK),
        ("P1", cx-160, cy-80, 14, PINK),
        ("P2", cx+160, cy-80, 14, PINK),
        ("P3", cx, cy+130, 14, PINK),
        ("A1", cx+170, cy+100, 16, CYAN),
    ]
    edges = [(1,0,PINK),(2,0,PINK),(3,0,PINK),(4,0,CYAN)]
    for a,b,col in edges:
        thin = collapsed and col == PINK
        draw.line([nodes[a][1], nodes[a][2], nodes[b][1], nodes[b][2]],
                  fill=(col[0], col[1], col[2], 255), width=2 if thin else (5 if col==CYAN else 3))
    for lab,x,y,r,col in nodes:
        draw.ellipse([x-r,y-r,x+r,y+r], fill=col)
        draw.text((x,y), lab, fill=BG, font=font(11, mono=True), anchor="mm")
    # score drop
    tdrop = ease(min(1, max(0, (p - 0.25) / 0.45)))
    val = lerp(4.00, 1.22, tdrop)
    draw.text((W//2 - 120, 560), "4.00", fill=PINK, font=font(40, mono=True), anchor="mm")
    draw.text((W//2, 560), "→", fill=MUTED, font=font(36), anchor="mm")
    draw.text((W//2 + 120, 560), f"{val:.2f}", fill=RED, font=font(40, mono=True), anchor="mm")
    if tdrop > 0.7:
        draw.rounded_rectangle([W//2+200, 540, W//2+320, 580], radius=12, fill=(60, 20, 30))
        draw.text((W//2+260, 560), "EXPOSED", fill=RED, font=font(14), anchor="mm")

def scene_verdict(draw, p):
    draw.text((W//2, 130), "VERDICTS", fill=GREEN, font=font(16), anchor="mm")
    draw.text((W//2, 185), "Access cleared — or denied.", fill=TEXT, font=font(40), anchor="mm")
    cards = [
        (250, "GOODBOT", "GRANT", GREEN, "weighted 4.69"),
        (640, "FAKEBOT", "CAUTION", AMBER, "weighted 1.44"),
        (1030, "SYBILBOT", "DENY", RED, "weighted 1.22"),
    ]
    appear = [0.05, 0.2, 0.35]
    for i,(cx,name,stamp,col,sub) in enumerate(cards):
        if p < appear[i]:
            continue
        draw.rounded_rectangle([cx-150, 280, cx+150, 520], radius=20, outline=col, width=3)
        draw.text((cx, 320), name, fill=MUTED, font=font(14), anchor="mm")
        draw.text((cx, 390), stamp, fill=col, font=font(40), anchor="mm")
        draw.text((cx, 460), sub, fill=MUTED, font=font(14, mono=True), anchor="mm")

def render(t):
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img, "RGBA") if False else ImageDraw.Draw(img)
    name, p = scene_at(t)
    draw_bg(draw, name)
    draw_chrome(draw, t)
    if name == "problem":
        scene_problem(draw, p)
    elif name == "erc8004":
        scene_erc(draw, p)
    elif name == "raw":
        scene_raw(draw, p)
    elif name == "weighted":
        scene_weighted(draw, img, p)
    else:
        scene_verdict(draw, p)
    draw_caption_bar(draw, t)
    return img

def main():
    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)
    OUT_DIR.mkdir(parents=True)
    n = int(DURATION * FPS)
    for i in range(n):
        t = i / FPS
        render(t).save(OUT_DIR / f"frame_{i:05d}.png")
        if i % 60 == 0:
            print(f"frame {i}/{n}")
    subprocess.check_call([
        "ffmpeg", "-y", "-framerate", str(FPS),
        "-i", str(OUT_DIR / "frame_%05d.png"),
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20",
        "-movflags", "+faststart", str(MP4)
    ])
    print("wrote", MP4, MP4.stat().st_size)
    shutil.rmtree(OUT_DIR, ignore_errors=True)

if __name__ == "__main__":
    main()
