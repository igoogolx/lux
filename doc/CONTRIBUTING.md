# Contributing

Thank you for your interest in contributing to lux! In this document, we'll outline what you need to know about contributing and how to get started.


### Prerequisite
1. Golang >= 1.20
2. Nodejs >= 16
3. Yarn
4. Git

Before next steps, plz read the arch and understand child modules and why they exist.

### Init project
1. Clone this repo
2. Run `yarn init-modules` that will download child modules in modules dir.

### Start development
1. Run dashboard

```sh
yarn dev
```

2. Run itun2socks
```sh
go run -tags="with_gvisor debug" .\main.go -home-dir ..\..\core
```