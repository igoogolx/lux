<a name="readme-top"></a>

<br />
<div align="center">
  <a href="https://github.com/igoogolx/lux">
    <img src="assets/logo.png" alt="Logo" width="100" height="100">
  </a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![Build Status][build-shield]][build-url]
[![Version][version-shield]][version-url]
[![Downloads][downloads-shield]][downloads-url]

<h3 align="center">Lux</h3>
A light desktop tun proxy client.
<br />
<a href="https://igoogolx.github.io/lux-docs/"><strong>lux-docs »</strong></a>
<br />
<br />
<b>Download for </b>
macOS
·
Windows
<br />
  <p align="center">
    <a href="https://github.com/igoogolx/lux/issues">Report Bug</a>
    ·
    <a href="https://github.com/igoogolx/lux/issues">Request Feature</a>
  </p>
</div>



- [Motivation](#motivation)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Monorepo structure](#monorepo-structure)
- [Roadmap](#roadmap)
- [Built With](#built-with)
- [License](#license)
- [Contact](#contact)
- [Sponsors](#sponsors)



## Motivation

There are many great proxy clients available on GitHub. However, some of them are a little hard to use or not open sourced.
As a proxy tool, I think it should be easy to use. Open source technology is the only way to ensure we retain absolute control over the data.



<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

See the [docs](https://igoogolx.github.io/lux-docs/docs/category/getting-started) for more.





## Architecture

This project is using what I'm calling the "FGRT" stack (Flutter, Go, React, TypeScript).

* React on Flutter? Here flutter is not responsible for UI. It's more like a launcher: 
  start the core process and open the webpage in browser.
* The core (itun2socks) is written in pure Go.


## Monorepo structure
* [itun2socks](https://github.com/igoogolx/itun2socks):  The Go core, referred to internally as lux-core. Contains tun, networking stack and clash logic. Can be deployed in windows and macOS. 
* [lux-client](https://github.com/igoogolx/lux-client):  A React app using fluent-ui. It's the UI of lux.
* [lux-rules](https://github.com/igoogolx/lux-rules): A Go utility tool used to generate built in proxy rules.
* [lux-docs](https://github.com/igoogolx/lux-docs): The docs build with docusaurus.

## Roadmap

- [x] Add splash screen
- [x] Improve UI of About page
- [x] Improve UI Dark mode
- [x] Support DNS over https
- [x] Support Mac OS
- [x] Support adding rules
- [ ] Support IPV6

See the [open issues](https://github.com/igoogolx/lux/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



## Built With

* [![React][React.js]][React-url]
* [![Flutter][Flutter]][Flutter-url]
* [![Go][Go.dev]][Golang-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the GPL License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Project Link: [https://github.com/igoogolx/lux](https://github.com/igoogolx/lux)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- Sponsors -->
## Sponsors

<a href="https://jb.gg/OpenSourceSupport">
<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jetbrains.png" alt="JetBrains logo.">
</a>

Thanks to Jetbrains provided license!

<p align="right">(<a href="#readme-top">back to top</a>)</p>


[contributors-shield]: https://img.shields.io/github/contributors/igoogolx/lux.svg
[contributors-url]: https://github.com/igoogolx/lux/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/igoogolx/lux.svg
[forks-url]: https://github.com/igoogolx/lux/network/members
[stars-shield]: https://img.shields.io/github/stars/igoogolx/lux.svg
[stars-url]: https://github.com/igoogolx/lux/stargazers
[issues-shield]: https://img.shields.io/github/issues/igoogolx/lux.svg
[issues-url]: https://github.com/igoogolx/lux/issues
[license-shield]: https://img.shields.io/github/license/igoogolx/lux.svg
[license-url]: https://github.com/igoogolx/lux/blob/master/LICENSE
[build-shield]: https://github.com/igoogolx/lux/actions/workflows/build.yml/badge.svg
[build-url]: https://github.com/igoogolx/lux/actions/workflows/build.yml
[version-shield]: https://img.shields.io/github/v/release/igoogolx/lux
[version-url]: https://github.com/igoogolx/lux/releases

[downloads-shield]: https://img.shields.io/github/downloads/igoogolx/lux/total
[downloads-url]: https://github.com/igoogolx/lux/releases

[React.js]: https://img.shields.io/badge/React-20232A?logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Flutter]: https://img.shields.io/badge/Flutter-%2302569B.svg?logo=flutter&logoColor=61DAFB
[Flutter-url]: https://flutter.dev/
[Go.dev]: https://img.shields.io/badge/Go-20232A?logo=go&logoColor=61DAFB
[Golang-url]: https://go.dev/
[Node-url]: https://nodejs.org/
