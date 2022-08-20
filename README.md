# Lux

A VPN or proxy client, Wndows only for now, inspired by [Outline-client](https://github.com/Jigsaw-Code/outline-client)(windows). **IPV6: not support**

## Features

- Supports Shadowsocks, Socks5
- Built-in Shadowsocks plugin: simple-obfs, v2ray
- Local Http proxy
- Supports UDP
- Built-in Dns, Dns over TCP

**Installation**

1. Download the release file and install it.
2. Enjoy.

## Underground

Lux is a system vpn. 
So what's the difference between lux and other proxy tools like [shadowsocks-windows](https://github.com/shadowsocks/shadowsocks-windows)? Shadowsocks-windows will create a local server(socks/http) on your system, for example 'localhost:1080', which means your apps must understand what's socks or http proxy protocol and where is the proxy server. After that, apps can send and receive data by the proxy server.
Compared with shadowsocks-windows, lux is a transparent proxy, which means apps can't feel the existence of proxy server. Because lux will intercept all network connecions on the system, then decide whether and how to proxy a connection. From [OSI modal](https://en.wikipedia.org/wiki/OSI_model), shadowsocks-windows works on Layer 7: Application layer, and lux is not only on Layer 7: Application layer but also Layer 3: Network layer.

## Modules
* [lux-core](https://github.com/igoogolx/lux-core)
* [lux-js-sdk](https://github.com/igoogolx/lux-js-sdk)
* [lux-dashboard](https://github.com/igoogolx/lux-dashboard)
* [lux-geo-data](https://github.com/igoogolx/lux-geo-data)
* [lux-client](https://github.com/igoogolx/lux-client)

![Relation of module](https://github.com/igoogolx/lux/raw/main/doc/modules.png)

## Build

### `yarn init-modules`

Download necessary modules

### `yarn build`

Builds the app for production to the `out` folder.<br />

## TODO
1. [ ] Add doc
2. [ ] Support more platforms

## License

[MIT]