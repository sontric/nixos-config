# nix-config
NixOS Config files and setup info

## Usage  
On a Nixos system, copy configuration.nix to  
`/etc/nixos` 

## Edit configuration file as needed  
eg: rename user, remove unfree packages, disable/enable self-hosted runner

## Create GH Self-hosted runner tokens
and copy to:  
`/var/lib/github-runner.token`

## Rebuild
`sudo nixos-rebuild switch`

## Github setup (if dev environment)  
`gh auth login`  
`git config --global user.name "Your Name"`  
`git config --global user.email "your_email@example.com"`  

## Check on GH Self-hosted runner and restart
`systemctl status github-runner-sontric-shr-1.service`  
`systemctl restart github-runner-sontric-shr-1.service`

## Check on Tailscail
`sudo tailscale up`
