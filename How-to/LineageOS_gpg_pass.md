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
- enter the passphrase, then the gpg password, then the passphrase again.

- transter the file to the device.
- (an FTP server app on the device, and FileZilla)

- FTP client:
 ```sh
ftp 192.168.1.141 2121
Name (192.168.1.141:user): ftp
Password: ftp
ftp> cd Download/
ftp> put user.gpg.sec.asc
ftp> bye
 ```
- import the keyring from the file with OpenKeychain
- (manage my keyes)
- Allow the Password Stare app in Openkeychain

### Password Store 
---
#### Setting up sync through a local bare git repo
- Setup a local bare git repository for pass
 ```sh
git init --bare ~/.password-store.git
pass git init
pass git remote add main /home/user/.password-store.git
pass git push origin main
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
> **Authentication mode:** OPENKEYCHAIN
- Select **OpenKeychain** as OpenPGP provider
- Select **clone from the server** while adding a new repository
- **a note:** use sync command, rather than pull or push ones 
