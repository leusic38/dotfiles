#!/bin/bash

# Get the screen information using xrandr
screen_info=$(xrandr)

# Initialize arrays to store monitor information
monitors=()
sizes=()
orientations=()
counthorizontal=0
countvertical=0
countxps=0
# Extract information for each connected monitor
while read -r line; do
	if [[ $line =~ ^[[:alnum:]]+-[0-9].*+[[:space:]]connected ]]; then
		monitor=$(echo "$line" | awk '{print $1}')
		size=$(echo "$line" | grep -oP '\d{3,4}x\d{3,4}')
		[[ $size = "1920x1080" ]] && ((++counthorizontal))
		[[ $size = "1080x1920" ]] && ((++countvertical))
		[[ $size = "1920x1200" ]] && ((++countxps))
		orientation=$(echo "$line" | grep -oP '\d+x\d+\+\d+\+\d+' | cut -dx -f1)
		# Store information in arrays
		monitors+=("$monitor")
		sizes+=("$size")
		orientations+=("$orientation")
	fi
done <<<"$screen_info"
# Display information for each connected monitor from the arrays
#!/bin/sh

# Specify the directory containing images
image_directory="/home/manu/Images/wallpapers"

inc=1
for v in horizontal vertical xps; do
	path="${image_directory}/${v}"
	count="count${v}"
	# Ensure the directory exists
	if [ ! -d "$path" ]; then
		echo "Error: Image directory not found! ${path}"
		exit 1
	fi
	find $path -name "*.jpg" -o -name "*.jpeg" -type f | shuf -n ${!count} | while read file; do
		cp "$file" "${image_directory}/${v}_$((inc++)).jpg"
	done
done
for ((i = 0; i < ${#monitors[@]}; i++)); do
	wallpaper+=" --output ${monitors[i]} --maximize ${image_directory}/"
	if [[ ${sizes[i]} = "1080x1920" && ${orientations[i]} = "1080" ]]; then
		((++vert))
		wallpaper+="vertical_${vert}.jpg"
	elif [[ ${sizes[i]} = "1920x1200" ]]; then
		((++xps))
		wallpaper+="xps_${xps}.jpg"
	else
		((++horiz))
		wallpaper+="horizontal_${horiz}.jpg"
	fi
done
xwallpaper $wallpaper
