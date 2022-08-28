# Lux

A VPN or proxy client, Wndows only for now, inspired by [Outline-client](https://github.com/Jigsaw-Code/outline-client)(windows). **IPV6: not support**.
Note that this project only contains building scripts. See more source code in modules section.

## Features

- Supports Shadowsocks, Socks5
- Built-in Shadowsocks plugin: simple-obfs, v2ray
- Local Http proxy
- Supports UDP
- Built-in Dns, Dns over TCP

**Installation**

1. Download the release file and install it.
2. Enjoy.


# Architecture

![Relation between modules](https://github.com/igoogolx/lux/raw/main/doc/arch.png)

## Modules
* [lux-core](https://github.com/igoogolx/lux-core)
* [lux-js-sdk](https://github.com/igoogolx/lux-js-sdk)
* [lux-dashboard](https://github.com/igoogolx/lux-dashboard)
* [lux-geo-data](https://github.com/igoogolx/lux-geo-data)
* [lux-client](https://github.com/igoogolx/lux-client)

![Relation between modules](https://github.com/igoogolx/lux/raw/main/doc/modules.png)

## Build

### `yarn init-modules`

Download necessary modules

### `yarn build`

Builds the app for production to the `out` folder.<br />

## TODO
1. [ ] Support more platforms

## License

[MIT]