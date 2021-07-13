# Setting up GPG and Pass on Android (OnePlus 5, LineageOS 16)
### Soft:
- **GPG:** OpenKeychain
- **Pass:** Password Store
- **eMail:** K-9 Mail
- **OTP:** andOTP
- **Jabber:** Conversations
- **File transfer:** FTP server
### OpenKeychain
---
#### Transfering the keyring
- generate a one-time password
 ```sh
gpg --armor --gen-random 1 16 
 ```
- export and encrypt the keyring to a file
 ```sh
gpg --armor --export-secret-keys KEY_ID(email) | gpg --armor --symmetric --output user.gpg.sec.asc
 ```
- transter the file to the device, using the FTP server app.
 ```sh
ftp 192.168.1.141 2121
Name (192.168.1.141:user): ftp
Password: ftp
ftp> cd Download/
ftp> put user.gpg.sec.asc
ftp> bye
 ```
- import the keyring from the file with OpenKeychain
### Password Store 
---
#### Setting up sync through a local bare git repo
- Setup a local bare git repository for pass
 ```sh
git init --bare ~/.pass.git.repo
pass git init
pass git remote add origin ssh://user@localhost:/home/user/.pass.git.repo
 ```
- do not use the gpg auth subkey
 ```sh
sudo  pacman -Sy openssh
ssh-keygen -m PEM -t rsa -b 4096
 ```
> Enter file in which to save the key (/home/user/.ssh/id_rsa): pass_store
- Authorize the pub key for incomming conection and push
 ```sh
cat ~/.ssh/id_rsa/pass_store.pub >> ~/.ssh/authorized_keys
pass git push origin master
 ```
   - **a note:** use pull,push rather than just push for sync
 - copy the ssh key to the android device, using the FTP server app
 ```sh
cd ~/.ssh/id_rsa/
ftp 192.168.1.141 2121
Name (192.168.1.141:user): ftp
Password: ftp
ftp> cd Download/
ftp> put pass_srore
ftp> bye
 ```
- password store app: Settings-Edit git server settings
> **Username:** USER	
> **Server:** IP of the computer.
 ```sh
# show local ip
hostname -I
 ```
> **Port:** 22
> **Repo path:** absolute location of the git repo
> **Authentication mode:** SSH key
- **password store app:** Settings-Import SSH key _(from the file)_
- Select **OpenKeychain** as OpenPGP provider
- Select **clone from the server** while adding a new repository
- **a note:** use sync command, rather than pull or push ones 
