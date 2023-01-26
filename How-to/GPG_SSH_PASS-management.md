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
 ```sh
 # generate a one-time password
gpg --armor --gen-random 1 16
 ```
- export and encrypt the keyring to a file
(enter the one-time password, the gpg password, then the one-time password again.)
 ```sh
gpg --armor --export-secret-keys KEY_ID(email) | gpg --armor --symmetric --output user.gpg.sec.asc
 ```
- transter the file to the device.
(use an FTP server app on the device, and FileZilla)
 ```sh
 # classic FTP client:
ftp 192.168.1.141 2121
Name (192.168.1.141:user): ftp
Password: ftp
ftp> cd Download/
ftp> put user.gpg.sec.asc
ftp> bye
 ```
- Import the keyring from the file with OpenKeychain. (manage my keyes)
- Link the Password Stare app to the keyring, in Openkeychain.

### Sync through a local bare git repo
---
 ```sh
 # Setup a local bare git repository for pass
git init --bare ~/.password-store.git
pass git init
pass git remote add main ~/.password-store.git
pass git push origin main
 ```
 **!!!**
 **SSH support in gpg-agent should be enabled**
 **The Authentication GPG Sub Pub Key shoulk be in:** ~/.ssh/authorized_keys
 
#### password store app
Settings-Edit git server settings
> **Server:** username@192.168.0.149:.password-store.git
> **Branch:**  main
> **Authentication mode:** OPENKEYCHAIN
 ```sh
# show local ip
ip addr | grep "inet "
 ```
- Select **OpenKeychain** as OpenPGP provider
- Select **clone from the server** while adding a new repository
- **a note:** use sync command, rather than pull or push ones 
