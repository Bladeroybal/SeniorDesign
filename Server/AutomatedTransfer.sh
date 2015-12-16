echo "Continuously checking for new files..."
while inotifywait -r "/home/matthanm/data"
do
	echo "Directory updated, attempting transfer..."
	scp -rv -P 2222 /home/matthanm/data team12@50.24.131.62:/var/www/html
	echo "Done."
	sleep 1
done
