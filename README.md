# nix-config
NixOS Config files and setup info

## Github setup (if dev environment)  
`gh auth login`  
`git config --global user.name "Your Name"`  
`git config --global user.email "your_email@example.com"`  
  
## Clone the repo, or copy manually
`gh repo clone davidnobles-eng/nixos-config`

## Copy files to
`/etc/nixos` 

## Edit files as needed  
eg: rename user, remove unfree packages, disable/enable self-hosted runner

## Create GH Self-hosted runner tokens
and copy to:  
`/var/lib/github-runner.token`

## Rebuild
`sudo nixos-rebuild switch`
