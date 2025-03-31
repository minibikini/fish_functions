function mov2mp4 -d "Convert MOV file to compressed MP4 using ffmpeg"
    # Check if ffmpeg is installed
    if not command -sq ffmpeg
        echo "Error: ffmpeg is not installed. Please install it first."
        return 1
    end

    # Check if a file was provided
    if test (count $argv) -lt 1
        echo "Usage: mov2mp4 [input.mov] [output.mp4 (optional)]"
        return 1
    end

    set -l input $argv[1]

    # Validate that input file exists and is a MOV file
    if not test -f $input
        echo "Error: Input file '$input' does not exist."
        return 1
    end

    if not string match -q "*.mov" $input
        echo "Warning: Input file doesn't have .mov extension. Continuing anyway."
    end

    # Set output filename (either provided or derived from input)
    set -l output
    if test (count $argv) -ge 2
        set output $argv[2]
    else
        set output (string replace -r '\.mov$' '.mp4' $input)
    end

    echo "Converting $input to $output..."

    # Convert with reasonable default settings for screen recordings
    # -crf: Constant Rate Factor (0-51, lower means better quality, 23 is default)
    # -preset: Encoding speed (slower = better compression)
    ffmpeg -i $input -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k $output

    set -l status_code $status
    if test $status_code -eq 0
        echo "Conversion completed successfully!"
        echo "Output file: $output"
    else
        echo "Conversion failed with status code $status_code"
    end
end
