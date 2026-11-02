"""Removes the brand marks listed in tool/excluded_icons.txt from the CDS icon font.

Their codepoints are unmapped and their outlines emptied, so the logos are not
redistributed. Layout tables are dropped: icons are addressed by codepoint and
the source font's ligature table is malformed.

Usage (needs fontTools):
  python tool/subset_icon_font.py <cds>/packages/icons/src
Writes assets/fonts/CdsIcons.ttf.
"""
import re
import sys

from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

src = sys.argv[1]
excluded = {l.strip() for l in open('tool/excluded_icons.txt') if l.strip() and not l.startswith('#')}
glyph_map = open(f'{src}/glyphMap.ts', encoding='utf-8').read()
drop = {
    ord(char)
    for name, char in re.findall(r"'([A-Za-z0-9]+)-(?:12|16|24)-(?:active|inactive)':\s*'(.+?)'", glyph_map)
    if name in excluded
}

# Keep the original bounding box so glyph metrics (and baselines) do not shift.
font = TTFont(f'{src}/fonts/native/CoinbaseIcons.ttf', recalcBBoxes=False, recalcTimestamp=False)
for tag in ('GSUB', 'GPOS', 'GDEF'):
    if tag in font:
        del font[tag]

glyph_names = set()
for table in font['cmap'].tables:
    for cp in list(table.cmap):
        if cp in drop:
            glyph_names.add(table.cmap.pop(cp))

empty = TTGlyphPen(None).glyph()
glyf = font['glyf']
for name in glyph_names:
    glyf[name] = empty
    font['hmtx'][name] = (font['hmtx'][name][0], 0)

font.save('assets/fonts/CdsIcons.ttf')
print(f'removed {len(drop)} codepoints ({len(glyph_names)} glyphs)')
