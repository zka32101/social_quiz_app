#!/usr/bin/env python3
"""
社会コレ！アセット生成スクリプト
SVG をベースに、高品質な PNG プレースホルダーを生成
"""

from PIL import Image, ImageDraw, ImageFont
import os
from pathlib import Path

# カラー定義
COLORS = {
    'primary': '#2ECC71',
    'secondary': '#27AE60',
    'background': '#F8F9FA',
    'accent_red': '#FF6B6B',
    'accent_gold': '#FFE66D',
    'accent_teal': '#4ECDC4',
}

# RGB 値に変換
def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

class AssetGenerator:
    def __init__(self, output_dir='analytics'):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

    def generate_icon(self, name, color, icon_symbol):
        """Performance metric icon (256x256)"""
        size = 256
        img = Image.new('RGBA', (size, size), (248, 249, 250, 255))
        draw = ImageDraw.Draw(img)

        # Background circle with border
        margin = 10
        color_rgb = hex_to_rgb(color)
        border_color = tuple(list(color_rgb) + [80])
        draw.ellipse(
            [(margin, margin), (size-margin, size-margin)],
            fill=(*color_rgb, 30),
            outline=(*color_rgb, 180),
            width=3
        )

        # Icon text/symbol
        try:
            # Try to use a larger font if available
            font_size = 120
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
        except:
            font = ImageFont.load_default()

        # Draw symbol in center
        bbox = draw.textbbox((0, 0), icon_symbol, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = (size - text_width) // 2
        y = (size - text_height) // 2
        draw.text((x, y), icon_symbol, fill=(*color_rgb, 255), font=font)

        # Save
        icon_path = self.output_dir / 'icons' / f'{name}.png'
        icon_path.parent.mkdir(exist_ok=True)
        img.save(icon_path, 'PNG')
        print(f"✅ Generated: {icon_path}")
        return icon_path

    def generate_header(self, name, width=1200, height=400):
        """Analytics header background"""
        img = Image.new('RGBA', (width, height), hex_to_rgb(COLORS['background']) + (255,))
        draw = ImageDraw.Draw(img)

        # Gradient simulation with rectangles
        primary_rgb = hex_to_rgb(COLORS['primary'])
        for i in range(width):
            # Subtle gradient
            alpha = int(8 * (i / width))
            draw.line(
                [(i, 0), (i, height)],
                fill=(*primary_rgb, alpha)
            )

        # Draw decorative bars (chart motif)
        bar_width = 50
        bar_spacing = 20
        bar_colors = [
            hex_to_rgb(COLORS['primary']),
            hex_to_rgb(COLORS['secondary']),
            hex_to_rgb(COLORS['accent_teal']),
        ]

        base_y = height - 80
        x_start = 100
        heights = [80, 120, 160, 140, 200, 180]

        for idx, bar_height in enumerate(heights):
            x = x_start + idx * (bar_width + bar_spacing)
            color = bar_colors[idx % len(bar_colors)]
            draw.rectangle(
                [(x, base_y - bar_height), (x + bar_width, base_y)],
                fill=(*color, 100),
                outline=(*color, 180)
            )

        # Decorative text
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 36)
        except:
            font = ImageFont.load_default()

        draw.text((width - 300, 30), "📊", font=font, fill=hex_to_rgb(COLORS['primary']) + (100,))

        # Save
        header_path = self.output_dir / 'headers' / f'{name}.png'
        header_path.parent.mkdir(exist_ok=True)
        img.save(header_path, 'PNG')
        print(f"✅ Generated: {header_path}")
        return header_path

    def generate_guidance_illustration(self, name, width=400, height=300):
        """Learning guidance illustration"""
        img = Image.new('RGBA', (width, height), hex_to_rgb(COLORS['background']) + (255,))
        draw = ImageDraw.Draw(img)

        # Gradient background
        primary_rgb = hex_to_rgb(COLORS['primary'])
        for i in range(height):
            alpha = int(6 * (i / height))
            draw.line(
                [(0, i), (width, i)],
                fill=(*primary_rgb, alpha)
            )

        # Decorative circles
        circle_color = hex_to_rgb(COLORS['primary'])
        draw.ellipse([(30, 30), (130, 130)], fill=(*circle_color, 50), outline=(*circle_color, 100))
        draw.ellipse([(270, 150), (370, 250)], fill=(*circle_color, 40), outline=(*circle_color, 80))

        # Center text
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 48)
            small_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
        except:
            font = small_font = ImageFont.load_default()

        # Emoji/symbol in center
        emoji = {"repeat": "🔄", "daily": "📅", "accuracy": "🎯"}
        symbol = emoji.get(name.split('_')[-1], "✨")

        draw.text((width//2 - 40, height//2 - 40), symbol, font=font, fill=hex_to_rgb(COLORS['primary']) + (200,))

        # Save
        guide_path = self.output_dir / 'decorations' / f'{name}.png'
        guide_path.parent.mkdir(exist_ok=True)
        img.save(guide_path, 'PNG')
        print(f"✅ Generated: {guide_path}")
        return guide_path

def main():
    gen = AssetGenerator()

    print("🎨 社会コレ！ アセット生成開始...\n")

    # Generate icons
    print("📌 アイコンを生成中...")
    gen.generate_icon('icon_accuracy_rate', COLORS['primary'], '✓%')
    gen.generate_icon('icon_consecutive_streak', COLORS['accent_red'], '🔥5')
    gen.generate_icon('icon_best_score', COLORS['accent_gold'], '🏆')
    gen.generate_icon('icon_total_attempts', COLORS['accent_teal'], '42')

    # Generate headers
    print("\n📊 ヘッダーイメージを生成中...")
    gen.generate_header('analytics_header_main')

    # Generate guidance illustrations
    print("\n💡 ガイダンスイラストを生成中...")
    gen.generate_guidance_illustration('guidance_repeat_learning')
    gen.generate_guidance_illustration('guidance_daily_consistency')
    gen.generate_guidance_illustration('guidance_accuracy_goal')

    print("\n✨ 生成完了！\n")
    print("📁 出力先: analytics/")
    print("   ├── icons/          (4個)")
    print("   ├── headers/        (1個)")
    print("   ├── decorations/    (3個)")
    print("   └── backgrounds/    (SVG)")

if __name__ == '__main__':
    main()
