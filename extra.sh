# Install code editor
if ! command -v code >/dev/null 2>&1; then
  sudo apt install -y wget gpg apt-transport-https ca-certificates software-properties-common # prereqs
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg # key to keyring file
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg # place key
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' # repo
  rm -f /tmp/packages.microsoft.gpg # cleanup
  sudo apt update # refresh lists
  sudo apt install -y code # install stable VS Code
fi

# ESP32 Dev
sudo apt install wget flex bison gperf cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0
if [[ ! -d "$GIT_DIR/esp-id" ]]; then
  git clone https://github.com/espressif/esp-idf.git "$GIT_DIR/esp-id"
  cd ~/esp/esp-idf
  ./install.sh esp32
  cd $DIR
fi
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Install video editor
KDENLIVE_APPIMAGE="$HOME/Applications/kdenlive.appimage"
if [[ ! -f "$KDENLIVE_APPIMAGE" ]] && ! command -v kdenlive >/dev/null 2>&1; then
  wget -O "$KDENLIVE_APPIMAGE" https://download.kde.org/stable/kdenlive/25.04/linux/kdenlive-25.04.2-x86_64.AppImage
  chmod +x "$KDENLIVE_APPIMAGE"
  echo "Kdenlive AppImage installed to $KDENLIVE_APPIMAGE"
fi

# Install Steam
if ! command -v steam >/dev/null 2>&1; then
  echo "Steam not found. Installing..."
  
  # 1. Enable 32-bit architecture
  sudo dpkg --add-architecture i386
  sudo apt update

  # 2. Install the 32-bit Nvidia libraries 
  # This command automatically detects your current driver version and installs the i386 matching libs
  sudo apt install -y libnvidia-gl-$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | cut -d. -f1):i386

  # 3. Install Steam
  # Using DEBIAN_FRONTEND=noninteractive helps skip some TUI prompts
  sudo DEBIAN_FRONTEND=noninteractive apt install -y steam
else
  echo "Steam is already installed."
fi
