# brew

## revgeod

Installation:
1. `brew install jpmens/brew/revgeod`
2. edit `/usr/local/etc/revgeod.sh` and set OPENCAGE API key
3. Launch `/usr/local/etc/revgeod.sh`
4. Test using

```
$ curl 'http://127.0.0.1:8865/rev?lat=48.85593&lon=2.29431'
{"address":{"village":"4 r du Général Lambert, 75015 Paris, France","locality":"Paris","cc":"FR","s":"opencage"}}

$ curl 'http://127.0.0.1:8865/rev?lat=48.85593&lon=2.29431'
{"address":{"village":"4 r du Général Lambert, 75015 Paris, France","locality":"Paris","cc":"FR","s":"lmdb"}}
```

Note how the first invocation outputs a source (`s`) of `opencage` and the second a source of `lmdb`; this means the first call performed a remote lookup and the second responded from the LMDB cache.


You can also test with `/usr/local/var/revgeod/c-mini-test.sh` which should report an address in Paris, France. (Note, this uses `jq` which we don't require in the formula; feel free to alter the example program.)

## launch

Either launch `/usr/local/etc/revgeod.sh` (this doesn't daemonize) or start the service with `brew services start jpmens/brew/revgeod`
