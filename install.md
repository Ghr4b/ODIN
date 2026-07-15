## Installing ruby via Version Manager
since the tutorial included instructions for only debian-based systems, i made this documentation for the installation of ruby on Arch Linux.
also i decided to use [chruby](https://github.com/postmodern/chruby) and [ruby-install](https://github.com/postmodern/ruby-install) to manage ruby versions. instead of using rbenv.
chruby is preferred because it modifies standard shell environment variables directly to switch Ruby runtimes, completely avoiding the runtime overhead, latency, and system-level edge cases introduced by rbenv's command-intercepting shims.
### Installing compiling tools
```bash 
sudo pacman -S base-devel libyaml openssl zlib
```
### Install chruby and ruby-install
```bash
yay -S chruby ruby-install
```
### Installing Ruby (4.0.6)
```bash
ruby-install ruby 4.0.6
```
### Setting up chruby
```bash
echo "source /usr/share/chruby/chruby.sh" >> ~/.zshrc
echo "source /usr/share/chruby/auto.sh" >> ~/.zshrc
# Set default ruby version
echo "chruby ruby-4.0.6" >> ~/.zshrc
```
## Verifying the installation
```bash
ruby -v
gem env

```
