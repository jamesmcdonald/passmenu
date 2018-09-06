#  Passmenu

A popup menu for macOS to search for [pass](https://www.passwordstore.org) passwords and allow you to easily paste them.

I constantly use the wonderful [passmenu dmenu script](https://git.zx2c4.com/password-store/tree/contrib/dmenu/passmenu) in Linux, so I wanted to be able to do something similar in macOS. This is very basic, but it works, so someone else may find it useful.

## Building
You will need Xcode and [Carthage](https://github.com/Carthage/Carthage), which you can install with Homebrew:
```
brew install carthage
```
Clone the repository and run `carthage update` to install the HotKey framework. You should now be able to just build in Xcode.

## Running
Passmenu depends on `pass`, which in turn depends on `gnupg`. You can install these with Homebrew. You will almost certainly also need to have `pinentry-mac` installed, and your `~/.gnupg/gpg-agent.conf` should contain the line:
```
pinentry-program /usr/local/bin/pinentry-mac
```

When you run Passmenu, it will show a status menu on the menu bar that says "pass". You can click this to quit or to search for a password. You can also press the global shortcut Command-Option-P at any time to open the search window.

The password search window simply allows you to type and will search the passwords you have stored in `~/.password-store` and display the results. You can use cursor keys to navigate and select an entry by double-clicking or hitting return. When you select an entry, passmenu will run `/usr/local/bin/pass` to decrypt the password, which should pop up the GPG dialog if necessary (if anything fails, it will probably just crash). Once the password is decrypted it will be copied to the clipboard. 45 seconds later, the clipboard will be cleared.

## Caveats
All the paths and configuration are hard coded. There is very little error-checking. This is just about good enough for me to use.
