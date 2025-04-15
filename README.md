#  Passmenu

A popup menu for macOS to search for [pass](https://www.passwordstore.org) passwords and allow you to easily paste them.

I constantly use the wonderful [passmenu dmenu
script](https://git.zx2c4.com/password-store/tree/contrib/dmenu/passmenu) in
Linux, so I wanted to be able to do something similar in macOS. This is very
basic, but it works, so someone else may find it useful.

## Building

You should be able to just clone the repo and build in Xcode. HotKey will be
fetched from GitHub.

## Running

Passmenu depends on `pass`, which in turn depends on `gnupg`. You can install
these with Homebrew. You will almost certainly also need to have `pinentry-mac`
installed, and your `~/.gnupg/gpg-agent.conf` should contain a line like:

```
pinentry-program /usr/local/bin/pinentry-mac
```

When you run Passmenu, it will show a status menu on the menu bar that says
"pass". You can click this to quit or to search for a password. You can also
press the global shortcut Command-Option-P at any time to open the search
window.

The password search window simply allows you to type and will search the
passwords you have stored in `~/.password-store` and display the results. You
can use cursor keys to navigate and select an entry by double-clicking or
hitting return. When you select an entry, passmenu will run
`/usr/local/bin/pass` to decrypt the password, which should pop up the GPG
dialog if necessary (if anything fails, it will probably just crash). Once the
password is decrypted it will be copied to the clipboard. 45 seconds later, the
clipboard will be cleared.

From the menu, you can select Preferences to configure which repository to
search, which `pass` binary to use and the `PATH` to use when calling it (which should include `/usr/local/bin` or wherever you keep your Homebrew).

## Caveats

This is pretty basic, but it works. I've added some sanity checks so hopefully
you'll get more error notifications than crashes.

I'm not a macOS developer, so this is all from-scratch stuff based on googling
every function call I need. Turns out Swift is pretty neat, though. If any
experienced ninjas have cool suggestions for better ways to manage things, feel
free to create an issue or a PR.

## Planned features

It would be nice to be able to automatically search multiple pass repositories,
which isn't terribly hard to do. I'd need to show some indication of which repo
each result came from to allow you to choose between identical names.

I'd like to make the interaction between UserDefaults and the PassFacade object
a bit less clumsy.

More preferency things.

Fancy icons.
