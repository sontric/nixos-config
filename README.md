# nix-config
NixOS Config files and setup info

## Github setup (if dev environment)
`gh auth login`

## Clone the repo, or copy manually
`gh repo clone davidnobles-eng/nixos-config`

## Symlink the repo

Remove nixos config default dir  
CAUTION: might want to back this up first  
`sudo rm -rf /etc/nixos`  

Link to repo files  
`sudo ln -s ~/projects/nixos-config/[hostname] /etc/nixos`  

## Edit files as needed  
eg: rename user, remove unfree packages, disable/enable self-hosted runner

## Create GH Self-hosted runner tokens
and copy to:  
`/var/lib/github-runner.token`
  

## Rebuild
`sudo nixos-rebuild switch`