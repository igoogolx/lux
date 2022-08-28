## Underground

Lux is a system vpn.
So what's the difference between lux and other proxy tools like [shadowsocks-windows](https://github.com/shadowsocks/shadowsocks-windows)? Shadowsocks-windows will create a local server(socks/http) on your system, for example 'localhost:1080', which means your apps must understand what's socks or http proxy protocol and where is the proxy server. After that, apps can send and receive data by the proxy server.
Compared with shadowsocks-windows, lux is a transparent proxy, which means apps can't feel the existence of proxy server. Because lux will intercept all network connecions on the system, then decide whether and how to proxy a connection. From [OSI modal](https://en.wikipedia.org/wiki/OSI_model), shadowsocks-windows works on Layer 7: Application layer, and lux is not only on Layer 7: Application layer but also Layer 3: Network layer.
