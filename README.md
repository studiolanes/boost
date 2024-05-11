# Boost 

macOS app to contextually chat with the text displayed in the application you are using.

## Instructions

2 modes of operation are supported by Boost

1. `cmd + shift + c` to start "contextual chat"
2. `cmd + shift + ?` to start "normal chat"

Contextual chat implies that Boost will try to recognize and let you "chat" with the following data from your macOS environment

- App name
- App window title
- App textual content
- Image representation of the app

## How does this work

AppleScript is being used as a cheap + fast way to extract information from applications.

## Installation

### Option 1

Clone the repo, build it yourself, and move the build product to your Applications folder

### Option 2

### Features

- [x] Highlight to talk with specific text in the application
- [x] OpenAI support
- [x] Safari support
- [x] Xcdoe support
- [ ] Chrome support
- [ ] Claude support
- [ ] VSCode support
- [ ] Cursor insert mode
- [ ] Notes / Messages support
