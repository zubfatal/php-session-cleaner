# php-session-cleaner
Cleanup of PHP session files, useful if you use custom session.save_path for your sites

## Syntax
```
php-session-cleaner.sh [session-path-file]
```

## Custom session values
Each path can have a custom session lifetime value - see [php-session-cleaner.list-example](./php-session-cleaner.list-example)
The script will look for a file name **php-session-cleaner.list** in the same directory as the script itself, unless the file is passed as an argument.

# Crontab example
```
*/5	*	*	*	*	root	/root/cronjobs/php-session-cleaner.sh >/dev/null 2>&1
```
