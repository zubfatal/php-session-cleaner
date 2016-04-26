# php-session-cleaner
Cleanup of PHP session files, useful if you use custom session.save_path for your sites

## Syntax
```
php-session-cleaner.sh [session-path-file]
```

## Custom session values
Each path can have a custom session lifetime value - see [php-session-cleaner.list-example](./php-session-cleaner.list-example)
The script will look for a file name `php-session-cleaner.list` in the same directory as the script itself, unless the file is passed as an argument.

### php-session-cleaner.list syntax
```
<path/to/session files>:<max session lifetime in minutes>
```

A value of `-1` will prevent cleanup. Can be defined or overridden per directory.

## Per directory override
To better accommodate an environment where the user has access to the session data directory, but not the script or the php-session-cleaner.list file, a `.php-session-cleaner` file can be placed within the session data directory, containing the session lifetime value. This value will overrule the value of the `php-session-cleaner.list` file.

## Crontab example
```
*/5	*	*	*	*	root	/root/cronjobs/php-session-cleaner.sh >/dev/null 2>&1
```

This executes the script every 5 minutes as the root user.

## License
This project is licensed under the terms of the [MIT license](./LICENSE.txt).
