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
curlone web -o -p 3333
```

* `-o` или `--open` - открыть в браузере
* `-p` или `--port` - порт, на котором будет запущено приложение

Пример конвертации:

>Команда curl
>
>```shell
>curl https://httpbin.org/post --request POST -d "key=value" -H "X-Header: value"
>```
>
>Код 1C
>
>```bsl
>Заголовки = Новый Соответствие();
>Заголовки.Вставить("X-Header", "value");
>Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
>
>ЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL();
>
>Соединение = Новый HTTPСоединение("httpbin.org", 443, , , , , ЗащищенноеСоединение);
>HTTPЗапрос = Новый HTTPЗапрос("/post", Заголовки);
>HTTPЗапрос.УстановитьТелоИзСтроки("key=value");
>
>HTTPОтвет = Соединение.ВызватьHTTPМетод("POST", HTTPЗапрос);
>```

Горячие клавиши:

* `ctrl + enter` - вызов команды `Конвертировать`

### cli приложение

Синтаксис команды:

```shell
curlone convert <команда> 
```

Пример команды:

>Оригинальная команда curl
>
>```shell
>curl https://httpbin.org/post --request POST -d "key=value" -H "X-Header: value"
>```
>
>Команда curlone
>
>```shell
>curlone convert https://httpbin.org/post --request POST -d "key=value" -H "X-Header: value"
>```

### библиотека

Пример использования:

```bsl
#Использовать curlone

КонсольнаяКоманда = "curl https://httpbin.org/post --request POST -d ""key=value"" -H ""X-Header: value""";

КонвертерКомандыCURL = Новый КонвертерКомандыCURL();
Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда);
```

## Особенности использования

Команда `curl` указывается в нотации `bash`

## Благодарности

Сообществу за свободные инструменты:

* [OneScript](https://github.com/EvilBeaver/OneScript)
* [Autumn/ОСень](https://github.com/autumn-library/autumn)
* [WINOW](https://github.com/autumn-library/winow)
* [autumn-cli](https://github.com/autumn-library/autumn-cli)
* [cli](https://github.com/oscript-library/cli)
* [1connector](https://github.com/vbondarevsky/1connector)
* [1commands](https://github.com/artbear/1commands)
* [tokenizer](https://github.com/Nivanchenko/tokenizer)
* [logos](https://github.com/oscript-library/logos)
* [1bdd](https://github.com/artbear/1bdd)
* [1testrunner](https://github.com/artbear/1testrunner)
* [asserts](https://github.com/oscript-library/asserts)
* [coverage](https://github.com/oscript-library/coverage)
* [coloratos](https://github.com/240596448/coloratos)
* [Shiki 式](https://github.com/shikijs/shiki)
