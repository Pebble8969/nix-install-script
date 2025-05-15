menu () {
	clear
	echo "This is a simple nixos installer, a nix config file is preferrable"
	echo ""
	echo "[1] Partition and format your disk"
	echo "[2] Install NixOS"
	echo "[3] Exit"
	echo ""
	read -n 1 -s -p "Your choice:> " ans
	clear
	if [ $ans = "1" ]; then
		partchoice
	elif [ $ans = "2" ]; then
		choice
	elif [ $ans = "3" ]; then
		exit
	else
		menu
	fi
}
partchoice () {
	echo "This is the partition type selector"
	echo ""
	echo "[1] MBR partition table (legacy)"
	echo "[2] GPT partition table (modern)"
	echo ""
	read -n 1 -s -p "Your choice:> " pans
	clear
	if [ $pans = "1" ]; then
		partmbr
	elif [ $pans = "2" ]; then
		partgpt
	else
		partchoice
	fi
}
partmbr () {
	sudo parted /dev/sda -- mklabel msdos
	sudo parted /dev/sda -- mkpart primary 1MB -8GB
	sudo parted /dev/sda -- set 1 boot on
	sudo parted /dev/sda -- mkpart primary linux-swap -8GB 100%
	sudo mkfs.ext4 -L nixos /dev/sda1
	sudo mkswap -L swap /dev/sda2
	sudo mount /dev/sda1 /mnt
	sudo swapon /dev/sda2
	clear
	choice
}
partgpt () {
	sudo parted /dev/sda -- mklabel gpt
	sudo parted /dev/sda -- mkpart root ext4 512MB -8GB
	sudo parted /dev/sda -- mkpart swap linux-swap -8GB 100%
	sudo parted /dev/sda -- mkpart ESP fat32 1MB 512MB
	sudo parted /dev/sda -- set 3 esp on
	sudo mkfs.ext4 -L nixos /dev/sda1
	sudo mkswap -L swap /dev/sda2
	sudo mkfs.fat -F 32 -n boot /dev/sda3
	sudo mount /dev/sda1 /mnt
	sudo mkdir -p /mnt/boot
	sudo mount -o umask=077 /dev/sda3 /mnt/boot
	sudo swapon /dev/sda2
	clear
	choice
}
choice () {
	sudo nixos-generate-config --root /mnt
	clear
	echo "Do you want to use a nix config file from a github page or just the default minimal?"
	echo ""
	echo "[1] Github link"
	echo "[2] Minimal"
	echo ""
	read -n 1 -s -p "Your choice:> " gans
	clear
	if [ $gans = "1" ]; then
		guthib
	elif [ $gans = "2" ]; then
		minimall
	else
		choice
	fi
}
guthib () {
	echo "You have to put in the username and repo name seperatley."
	echo ""
	read -p "Github username:> " una
	echo ""
	read -p "Repository name:> " rna
	echo ""
	read -n 1 -s -p "Does https://github.com/$una/$rna.git look correct? [y/n] " rans
	clear
	if [ $rans = "y" ]; then
		git clone https://github.com/$una/$rna.git
		cd $rna
		sudo rm -rf /mnt/etc/nixos/configuration.nix
		sudo cp configuration.nix /mnt/etc/nixos
		sudo cp flake.nix /mnt/etc/nixos
		sudo cp flake.lock /mnt/etc/nixos
		final
	elif [ $rans = "n" ]; then
		guthib
	else
		guthib
	fi
}
minimall () {
	sudo nano /mnt/etc/nixos/configuration.nix
	final
}
final () {
	read -n 1 -s -p "Do you want to reboot? [y/n] " hans
	if [ $hard = "y" ]; then
		reboot
	elif [ $ans = "n" ]; then
		exit
	else
		final
	fi
}
menu
