
# vaultwarden-fly

Deploy a Vaultwarden private instance to Fly easily

## Requirements

1. Fly account (Trial Plan is okay)
2. flyctl
3. docker

## Deployment

1. Clone this repository
2. Run the following
	``` bash
	$ bash deploy.sh myvaultwarden | tee deploy.log   # Use myvaultwarden as app name
	```
3. Keep `deploy.log` in a safe place since it contains credentials which will not be shown again
4. Add users by creating email invitations in admin interface (no emails will actually be sent here)
5. Create user accounts in login interface with matching email invitations

## Credits

* https://github.com/dani-garcia/vaultwarden
* https://github.com/davidjameshowell/vaultwarden_heroku
* https://github.com/std2main/bitwardenrs_heroku

