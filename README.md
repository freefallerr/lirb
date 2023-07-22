# lirb
lua dirb alternative

```
Usage: lua lirb.lua -url <url> -wl <path> [options]
  --target or -t url                        : Target URL
  --wordlist or -w path                     : Path to wordlist
Options:
  --character-count or -cc int               : Character count of the response to filter
  --cookies or -c test=abc;token=xyz        : Add cookies to the requests
  --headers or -h Authorization Bearer 123 : Add custom headers to the requests. Use this for Authorization tokens
  --threads or -T int                       : How many requests can be sent in parallel
  --proxy or -P http://127.0.0.1:8080       : Add proxy
  --port or -p int                          : Add port
  --status-codes or -sc int,int,...          : Comma-separated list of status codes to whitelist
  --user-agent or -ua string                : Custom user-agent to use for requests
```

  Example output:
```
=====================================================
  target:	http://144.126.206.249:30338
  wordlist:	/home/test/tools/SecLists/Discovery/Web-Content/common.txt
  proxy:	http://127.0.0.1:8080
=====================================================

http://144.126.206.249/.bash_history - Status Code: 200, Response Length: 81
http://144.126.206.249/.bashrc - Status Code: 200, Response Length: 75
http://144.126.206.249/.cache - Status Code: 200, Response Length: 74
http://144.126.206.249/.config - Status Code: 200, Response Length: 75
Progress: 82 / 4715
```


  TODO:

  Proper request handling, analysing what is in the response for known 404 errors. 
  Using some pre-kick off requests to determine if the target is valid and how it handles requests.


  Add fuzzing

  Enhance the script to be more of automation tool than a dirbuster. 