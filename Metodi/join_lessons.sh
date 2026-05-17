#!/bin/bash

BASE_DIR="$(pwd)"
OUTPUT_DIR="$BASE_DIR/pdf_completo"
MASTER_TEX="$OUTPUT_DIR/main.tex"
IMAGES_DIR="$OUTPUT_DIR/images"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$IMAGES_DIR"

# Write preamble and title page
cat << 'EOF' > "$MASTER_TEX"
\documentclass[12px]{article}

\title{Metodi Numerici di Approssimazione - Appunti Completi}
\author{Federico De Sisti}
\date{\today}

\input{../../setup.tex}

\begin{document}
\maketitle
\tableofcontents
\newpage
EOF

# Find all Lezione folders and sort them to process in order
for DIR in $(ls -d Lezione_* | sort); do
    if [ -d "$DIR" ] && [ -f "$DIR/main.tex" ]; then
        echo "Processing $DIR..."
        
        # 1. Copy images
        # If there's an images subdirectory, copy its contents
        if [ -d "$DIR/images" ]; then
            cp -r "$DIR/images/"* "$IMAGES_DIR/" 2>/dev/null
        fi
        
        # Also copy any images in the lesson's root folder just in case
        find "$DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -exec cp {} "$IMAGES_DIR/" \; 2>/dev/null
        
        # Extract title from the preamble to use as a \part in the combined document
        LESSON_TITLE=$(grep -m 1 '^[[:space:]]*\\title{' "$DIR/main.tex" | sed -n 's/.*\\title{\(.*\)}/\1/p')
        if [ -n "$LESSON_TITLE" ]; then
            echo "\\part{$LESSON_TITLE}" >> "$MASTER_TEX"
        else
            echo "\\part{${DIR//_/ }}" >> "$MASTER_TEX"
        fi
        
        # 2. Extract content from main.tex
        echo "% --- Content from $DIR ---" >> "$MASTER_TEX"
        
        # We use awk to extract everything between \begin{document} and \end{document}
        # and we filter out the \maketitle and \newpage commands that might be at the top
        awk '
            /\\begin\{document\}/ {flag=1; next}
            /\\end\{document\}/ {flag=0}
            flag {
                # Skip \maketitle and \newpage if they appear alone on a line
                if ($0 !~ /^[[:space:]]*\\maketitle[[:space:]]*$/ && $0 !~ /^[[:space:]]*\\newpage[[:space:]]*$/) {
                    print $0
                }
            }
        ' "$DIR/main.tex" >> "$MASTER_TEX"
        
        # Add a newpage after each lesson
        echo "" >> "$MASTER_TEX"
        echo "\\newpage" >> "$MASTER_TEX"
    fi
done

# End the document
echo "\end{document}" >> "$MASTER_TEX"

echo "Merge complete! Compiling the PDF to generate the Table of Contents..."

# Compile twice to generate a working table of contents
cd "$OUTPUT_DIR" || exit
pdflatex -interaction=nonstopmode main.tex > /dev/null
pdflatex -interaction=nonstopmode main.tex > /dev/null

echo "Done! The combined PDF is located in $OUTPUT_DIR/main.pdf"
