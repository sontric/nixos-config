# nix-config
NixOS Config files and setup info

## Github setup (if dev environment)
`gh auth login`

## Clone the repo, or copy manually
`gh repo clone davidnobles-eng/nixos-config`

## Symlink the repo
`sudo rm -rf /etc/nixos`  
`sudo ln -s ~/projects/nixos-config /etc/nixos`  

## Edit files as needed  
eg: rename user, remove unfree packages, disable/enable self-hosted runner

## Create GH Self-hosted runner tokens
  

## Rebuild
`sudo nixos-rebuild switch`