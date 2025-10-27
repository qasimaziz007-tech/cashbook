#!/bin/bash
# Create a professional icon for Esthetics Auto Cashbook

# Create a 512x512 PNG icon with a car and dollar sign
cat > icon.svg << 'SVGEOF'
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <!-- Gradient Background -->
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2c3e50;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#34495e;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="grad2" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#3498db;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2980b9;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background Circle -->
  <circle cx="256" cy="256" r="240" fill="url(#grad1)"/>
  
  <!-- Car Shape -->
  <g transform="translate(100, 200)">
    <!-- Car Body -->
    <rect x="50" y="60" width="220" height="70" rx="10" fill="url(#grad2)"/>
    <!-- Car Roof -->
    <path d="M 80 60 L 120 20 L 200 20 L 240 60 Z" fill="url(#grad2)"/>
    <!-- Windows -->
    <rect x="90" y="30" width="50" height="30" rx="5" fill="#85c1e9" opacity="0.7"/>
    <rect x="170" y="30" width="50" height="30" rx="5" fill="#85c1e9" opacity="0.7"/>
    <!-- Wheels -->
    <circle cx="100" cy="130" r="25" fill="#34495e"/>
    <circle cx="100" cy="130" r="15" fill="#7f8c8d"/>
    <circle cx="220" cy="130" r="25" fill="#34495e"/>
    <circle cx="220" cy="130" r="15" fill="#7f8c8d"/>
  </g>
  
  <!-- Dollar Sign -->
  <g transform="translate(340, 140)">
    <circle cx="0" cy="40" r="55" fill="#27ae60" opacity="0.9"/>
    <text x="0" y="65" font-family="Arial, sans-serif" font-size="70" font-weight="bold" fill="white" text-anchor="middle">$</text>
  </g>
  
  <!-- Bottom Text -->
  <text x="256" y="480" font-family="Arial, sans-serif" font-size="36" font-weight="bold" fill="white" text-anchor="middle">CASHBOOK</text>
</svg>
SVGEOF

# Convert SVG to PNG using native macOS tools or basic conversion
if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 512 -h 512 icon.svg -o icon.png
elif command -v convert &> /dev/null; then
    convert -background none icon.svg -resize 512x512 icon.png
elif command -v sips &> /dev/null; then
    # macOS native tool - first convert svg to png using qlmanage
    qlmanage -t -s 512 -o . icon.svg 2>/dev/null || true
    if [ -f "icon.svg.png" ]; then
        mv icon.svg.png icon.png
    fi
fi

# Create multiple sizes for better quality
for size in 16 32 48 64 128 256 512; do
    if command -v sips &> /dev/null && [ -f icon.png ]; then
        sips -z $size $size icon.png --out icon-${size}.png 2>/dev/null
    fi
done

echo "Icon created successfully!"
