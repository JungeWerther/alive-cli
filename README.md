# alive-cli
🛠️  CLI application to automate your CI and more

## Installation

Clone this repo and enter the directory

```bash
git clone https://github.com/yourusername/alive-cli.git
cd alive-cli
```

The easiest way to install is to use the `cli/install.sh` script, which you can access with:

```bash
./alive install
```

Alternatively, follow the instructions for your platform:

### Platform-specific installation

Before installing, make sure you have the necessary permissions and that the `alive` file is executable:

```bash
chmod +x alive
```

Then, based on your operating system:


**macOS**
```bash
sudo ln -s "$(pwd)/alive" /usr/local/bin/alive
```

**Ubuntu/Debian**
```bash
sudo ln -s "$(pwd)/alive" /usr/bin/alive
```

**Raspberry Pi (Raspberry Pi OS/Raspbian)**
```bash
sudo ln -s "$(pwd)/alive" /usr/bin/alive
```

**Termux (Android)**
```bash
ln -s "$(pwd)/alive" $PREFIX/bin/alive
```

## Getting started

```
alive init
```

to create a config file
