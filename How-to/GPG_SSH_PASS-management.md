# GPG SSH PASS configuration notes.
> yet to be done.
# Initial setup.
## GPG
### Generate the Primary Key
```sh
$ gpg --expert --full-gen-key
```
> Your selection? 8  
> Your selection? s  
> Your selection? e  
> Your selection? q  
>   
> What key size do you want? (2048) 4096  
> Key is valid for? (0) 1y  
>   
> Real name: user  
> Email address: user@example.com  
>   
> Enter passphrase:  
>   
#### Check
```sh
$ gpg -k
$ gpg -K
```
### Add subkeys  

```sh
$ gpg --expert --edit-key user@example.com
```

Repeat this addkey process for **Encrypt,Sign,Authenticate**  
```sh
gpg> addkey
```
> Your selection? 8  

Encrypt: 
> Your selection? s  

Sign:
> Your selection? e  

Authenticate:
> Your selection? s  
> Your selection? e  
> Your selection? a  

> Your selection? q  
> What keysize do you want? (2048) 4096  
> Key is valid for? (0) 1y  
> Really create? (y/N) y  
> Enter passphrase:  
```sh
gpg> save
```
### Back Up the Primary privet key
```sh
$ gpg -a --export-secret-key user@example.com > user.gpg.sec.key
```
> Enter passphrase:  
### Generate and back up revoke.
```sh
$ gpg -a --gen-revoke user@example.com > user.gpg.revoke
```
> Your decision? 1  
> Is this okay? (y/N) y  
> Enter passphrase:  
### Remove the Primary Privet Key
```sh
$ gpg -a --export-secret-subkeys user@example.com > secret_subkeys.gpg
$ gpg --delete-secret-keys user@example.com
$ gpg --import secret_subkeys.gpg
```
#### To reimport the Primary Privet Key. (to be able to edit the keys)
```sh
$ gpg --allow-secret-key-import --import secret_subkeys.gpg.sec
```
#### Back up 
```sh
$ gpg -o user.gpg.keys --export-options backup --export-secret-keys keyid
```
#### Restore
```sh
$ gpg --import-options restore --import user.gpg.keys
```

#### To change the expiration date of a GPG key:
```sh
$ gpg --expert --edit-key user@example.com
```
Commands: list; toggle; key; expire; q.


## SSH Authentication
### Enable SSH support in gpg-agent:
```sh
echo 'default-cache-ttl 60480000
max-cache-ttl 60480000
default-cache-ttl-ssh 60480000
max-cache-ttl-ssh 60480000
pinentry-program /usr/bin/pinentry-curses
enable-ssh-support' > ~/.gnupg/gpg-agent.conf
```

### Initialize SSH_AUTH_SOCK and launch gpg-agent on bash start:
```sh
echo '# Initialize SSH_AUTH_SOCK and launch gpg-agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null' >> ~/.bashrc
```

### (re)starting gpg-agent to load the new config:
```sh
gpgconf --kill gpg-agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
```

### Adding  “keygrip” to ~/.gnupg/sshcontrol:
 and confirm it has been added
```sh
ssh-add -l
gpg -k --with-keygrip
echo "# The gpg auth keygrip for ssh-auth:" >> ~/.gnupg/sshcontrol
echo <KEYGRIP>  >> ~/.gnupg/sshcontrol
ssh-add -l
```
or
```sh
echo "# The gpg auth keygrip for ssh-auth:" >> ~/.gnupg/sshcontrol
gpg -k --with-keygrip | sed -n "/\[A\]/,\$p" | sed -n 's/^.*Keygrip\ =\ //p' >> ~/.gnupg/sshcontrol
```
### Export the Authentication GPG Sub Pub Key
```sh
mkdir ~/.ssh
gpg --export-ssh-key keyid > ~/.ssh/user.gpg.ssh.pub
cat ~/.ssh/user.gpg.ssh.pub >> ~/.ssh/authorized_keys
```

### Authorize the key on remote server(s).
#### with:
```sh
ssh-copy-id -f -i ~/.ssh/user.gpg.ssh.pub user@server
```
#### or by hand (github):
```sh
$ echo -n "$(cat ~/.ssh/maxprio.gpg.ssh.pub )" | xsel -i -b
```
### Authorize incoming connection from <CLIENT>
```sh
cat <CLIENT>.ssh.pub >> ~/.ssh/authorized_keys
```
