# Pullups

https://pullups.no

Gather with your friends and see who can complete the most amount of pullups in a year.

## Notes

https://dghaehre.com/notes/pullups/

## Setup

Create `.env`:

```bash
ENCRYPTION_KEY="12345678901234567890123456789012"
DATABASE_URL="test.db"
PORT=9001
```

where ENCRYPTION_KEY is generated with:

```janet
(import cipher)
(def key (cipher/password-key))
```
