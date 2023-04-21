# wp
Setup a Ubuntu 22.04 server instance with a blank wordpress site

## Initial Actions
1. Create a VirtualBox VM.
2. Mount the iso to the optical drive, add a host only network adaptor alongside the NAT adaptor.
3. Install Ubuntu server (Not minimal, include OpenSSH server)

## Install Wordpress & dependencies
- Use the wp.sh script contained in this repo.
  - `git clone https://github.com/tlafrank/wp`
- The script was constructed following advice from https://ubuntu.com/tutorials/install-and-configure-wordpress#1-overview

