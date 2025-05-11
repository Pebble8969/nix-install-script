step1 () {
	clear
	read -p "THIS WILL DESTROY THE HARD DRIVE!!!!! DO YOU WANT TO CONTINUE? [y/n] " -n 1 ans
	echo ""
	if [ $ans = "n" ]; then
		exit
	elif [ $ans = "y" ]; then
		sudo parted /dev/sda --mklabel msdos
		sudo parted /dev/sda -- mkpart primary 1MB -8GB
		sudo parted /dev/sda -- set 1 boot on
		sudo parted /dev/sda -- mkpart primary linux-swap -8GB 100%
		sudo mkfs.ext4 -L nixos /dev/sda1
		sudo mkswap -L swap /dev/sda2
		sudo mount /dev/sda1 /mnt
		sudo swapon /dev/sda2
		sudo nixos-generate-config --root /mnt
		sudo rm -rf /mnt/etc/nixos/configuration.nix
		sudo cp configuration.nix /mnt/etc/nixos
		sudo cp flake.nix /mnt/etc/nixos
		sudo cp flake.lock /mnt/etc/nixos
		clear
		echo "THE INSTALLATION WILL START NOW, IT WILL PROMPT TO SET THE ROOT PASSWORD!"
		echo ""
		echo "THIS INSTALLATION WILL TAKE A WHILE, ONLY WORRY IF ITS OVER 2hrs!!!"
		echo ""
		sudo nixos-install
		clear
		echo "YOU WILL NOW BE PROMPTED TO SET THE USER PASSWORD!"
		echo ""
		sudo nixos-enter --root /mnt -c 'passwd niko'
		sudo cp manual.txt /mnt/home/niko
		clear
		echo "congrats            "
		echo "    \ /\_/\         "
		echo "     (=o.o=)        "
		echo "      > ^ <  (      "
		echo "     (|| ||)_)      "
		echo ""
		echo "CONGRATULATIONS! You successfully installed NixOS!"
		echo ""
		echo "I have put a manual.txt file into your Home directory (the one that opens when you open the file manager) , pls read it"
		echo ""
		read -n 1 -s -r -p "Press any key to reboot... "
		sudo reboot
	else
		echo "PRESS EITHER Y key OR N key!!!!!!"
		step1
	fi
}
step1
