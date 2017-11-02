# ENVIRONMENT VARIABLES

| Variable | Notes |
|----------|-------|
| ENCRYPTME_EMAIL | Registration username - required if letsencrypt enabled (default). |
| ENCRYPTME_PASSWORD | Registration password |
| ENCRYPTME_TARGET_ID | Encrypt.me target ID from Team console |
| DISABLE_LETSENCRYPT| 1 = Disable automatic letsencrypt |

Registration variables are only used during the first run, and only if you wish
to automate registration.

You can bootstrap interactively if you run with a tty: `./go.sh init`.

Then set it to run on it's own afterwards: `./go.sh run`.

You will be prompted for your Encrypt.me email address unless it is exported as
an environmental variable (e.g. `ENCRYPTME_EMAIL=you@example.com ./go.sh init`.


# MOUNTPOINTS

  /etc/encryptme

  Location where config, certs, keys are stored.  These need to be kept across
  container restarts.


# Deploying

This container expects a CentOS 7 or compatible host for IPSEC.
