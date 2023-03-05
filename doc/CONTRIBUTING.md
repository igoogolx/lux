# Contributing

Thank you for your interest in contributing to lux! In this document, we'll outline what you need to know about contributing and how to get started.


### Prerequisite
1. Golang >= 1.20
2. Nodejs >= 16
3. Yarn
4. Git

Before next steps, plz read the [arch](https://github.com/igoogolx/lux/blob/main/doc/architecture.md) and understand child modules and why they exist.

### Init project
1. Clone this repo
2. Run `yarn init-modules` that will download child modules in modules dir.

### Start development

1.Download third parties

```sh
cd {lux_dir}

yarn create-core-dir
```


2.Run dashboard

```sh
cd {lux_dir}\modules\lux-dashboard

yarn install

yarn dev
```


3.Run Itun2socks. Note: must run as **admin**

```sh
cd {lux_dir}\modules\itun2socks

go run -tags="with_gvisor debug" .\main.go -home-dir ..\..\core
```

4.Develop with lux-js-sdk(optional)

```sh
cd {lux_dir}\modules\lux-js-sdk

yarn link

cd {lux_dir}\modules\lux-dashboard

yarn link lux-js-sdk
```