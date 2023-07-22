# lirb
lua dirb alternative

```
Usage: lua lirb.lua --target <url> --wordlist <path> [options]
  --target or -t url                        : Target URL
  --wordlist or -w path                     : Path to wordlist
Options:
  --character-count or -cc int              : Character count of the response to filter
  --cookies or -c test=abc;token=xyz        : Add cookies to the requests
  --headers or -h Authorization Bearer 123  : Add custom headers to the requests. Use this for Authorization tokens
  --threads or -T int                       : How many requests can be sent in parallel
  --proxy or -P http://127.0.0.1:8080       : Add proxy
  --port or -p int                          : Add port
  --status_codes or -sc int,int,...         : Comma-separated list of status codes to whitelist
  --user_agent or -ua string                : Custom user-agent to use for requests
```

  Example output:
```
lua main.lua --target http://206.189.120.31:31962 --wordlist ~/tools/SecLists/Discovery/Web-Content/common.txt --proxy http://127.0.0.1:8080

=====================================================
proxy               : http://127.0.0.1:8080
wordlist            : /home/test/tools/SecLists/Discovery/Web-Content/common.txt
status_codes        : 200, 301, 302, 401
threads             : 1
port                : 31962
target              : http://206.189.120.31
user_agent          : Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3
=====================================================

Progress: 4715 / 4715
Valid URLs:

=====================================================
Finished
=====================================================

```


  TODO:

  Proper request handling, analysing what is in the response for known 404 errors. 
  Using some pre-kick off requests to determine if the target is valid and how it handles requests.


  Add fuzzing

  Enhance the script to be more of automation tool than a dirbuster. 
