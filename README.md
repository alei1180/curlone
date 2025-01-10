![](img/curlone-logo-horizontal.png)

<p align="center">
<a href="https://github.com/alei1180/curlone/blob/master/LICENSE"><img alt="License" src="https://img.shields.io/github/license/alei1180/curlone?style=badge"></a>
<a href="https://github.com/alei1180/curlone/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/alei1180/curlone?style=badge"></a>
<a href="https://github.com/alei1180/curlone/releases/latest"><img alt="Last release" src="https://img.shields.io/github/v/release/alei1180/curlone?include_prereleases&label=last%20release&style=badge"></a>
<a href="https://github.com/alei1180/curlone/releases"><img alt="GitHub All Releases" src="https://img.shields.io/github/downloads/alei1180/curlone/total?style=flat-square"></a>
</p>

## Назначение

`curlone` - конвертер команды `curl` в код на языке `1С`.

## Сайт

[curlone.ru](http://curlone.ru/)

## Установка

* [Скачать](https://github.com/alei1180/curlone/releases/latest) `curlone.ospx`
* Установить командой `opm install curlone.ospx`

## Использование

### web приложение

Запуск приложения:

```shell
curlone web -op 3333
```

* `o` - открыть в браузере
* `p` - порт, на котором будет запущено приложение

Пример конвертации:

>Команда curl
>
>```shell
>curl http://example.com/api --request POST -d "key=value" -H "X-Header: value"
>```
>
>Код 1C
>
>```bsl
>Заголовки = Новый Соответствие();
>Заголовки.Вставить("X-Header", "value");
>Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
>
>Соединение = Новый HTTPСоединение("example.com", 80);
>HTTPЗапрос = Новый HTTPЗапрос("/api", Заголовки);
>HTTPЗапрос.УстановитьТелоИзСтроки("key=value");
>
>HTTPОтвет = Соединение.ВызватьHTTPМетод("POST", HTTPЗапрос);
>```

### cli приложение

Синтаксис команды:

```shell
curlone convert <команда> 
```

Пример команды:

>Оригинальная команда curl
>
>```shell
>curl http://example.com/api --request POST -d "key=value" -H "X-Header: value"
>```
>
>Команда curlone
>
>```shell
>curlone convert http://example.com/api --request POST -d "key=value" -H "X-Header: value"
>```

## Особенности использования

Команда `curl` указывается в нотации `bash`

## Благодарности

Сообществу за свободные инструмены:

* [OneScript](https://github.com/EvilBeaver/OneScript)
* [Autumn/ОСень](https://github.com/autumn-library/autumn)
* [WINOW](https://github.com/autumn-library/winow)
* [autumn-cli](https://github.com/autumn-library/autumn-cli)
* [cli](https://github.com/oscript-library/cli)
* [1connector](https://github.com/vbondarevsky/1connector)
* [tokenizer](https://github.com/Nivanchenko/tokenizer)
* [coloratos](https://github.com/240596448/coloratos)
* [Shiki 式](hhttps://github.com/shikijs/shiki)
