![](img/curlone-logo-horizontal.png)

<p align="center">
<a href="https://t.me/curlone_bot"><img alt="telegram bot" src="https://img.shields.io/badge/telegram-bot-blue?style=flat&logo=telegram"></a>
<a href="https://github.com/alei1180/curlone/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/alei1180/curlone?style=badge"></a>
<a href="https://github.com/alei1180/curlone/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/alei1180/curlone?style=badge"></a>
<a href="https://github.com/alei1180/curlone/releases/latest"><img alt="Last release" src="https://img.shields.io/github/v/release/alei1180/curlone?include_prereleases&label=last%20release&style=badge"></a>
<a href="https://sonar.openbsl.ru/dashboard?id=curlone"><img alt="SonarQube: quality gate" src="https://sonar.openbsl.ru/api/project_badges/measure?project=curlone&metric=alert_status&token=sqb_174d3352e142da6217583afe4bfbd7af29ee137d"></a>
<a href="https://sonar.openbsl.ru/dashboard?id=curlone"><img alt="SonarQube: coverage" src="https://sonar.openbsl.ru/api/project_badges/measure?project=curlone&metric=coverage&token=sqb_174d3352e142da6217583afe4bfbd7af29ee137d"></a>
</p>

## Назначение

`curlone` - конвертер команды `curl` в код на языке `1С`.

## Сайт

[curlone.ru](https://curlone.ru/)

## Телеграм бот
[@curlone_bot](https://t.me/curlone_bot)

## Установка

```shell
opm install curlone
```

## Использование

## web приложение

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
>
>Код Connector
>
>```bsl
>Заголовки = Новый Соответствие();
>Заголовки.Вставить("X-Header", "value");
>
>Данные = Новый Соответствие();
>Данные.Вставить("key", "value");
>
>ДополнительныеПараметры = Новый Структура();
>ДополнительныеПараметры.Вставить("Заголовки", Заголовки);
>
>Результат = КоннекторHTTP.Post("https://httpbin.org/post", Данные, ДополнительныеПараметры);
>```

Горячие клавиши:

* `ctrl + enter` - вызов команды `Конвертировать`

## cli приложение

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
>Код 1C
>
>```shell
>curlone convert 1c https://httpbin.org/post --request POST -d "key=value" -H "X-Header: value"
>```
>
>Код Connector
>
>```shell
>curlone convert connector https://httpbin.org/post --request POST -d "key=value" -H "X-Header: value"
>```

## библиотека

Пример использования:

>Код 1C
>
>```bsl
>#Использовать curlone
>
>КонсольнаяКоманда = "curl https://httpbin.org/post --request POST -d ""key=value"" -H ""X-Header: value""";
>
>Генератор = Новый ГенераторПрограммногоКода1С();
>
>КонвертерКомандыCURL = Новый КонвертерКомандыCURL();
>Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, Генератор);
>```
>
>Код Connector
>
>```bsl
>#Использовать curlone
>
>КонсольнаяКоманда = "curl https://httpbin.org/post --request POST -d ""key=value"" -H ""X-Header: value""";
>
>Генератор = Новый ГенераторПрограммногоКодаКоннекторHTTP();
>
>КонвертерКомандыCURL = Новый КонвертерКомандыCURL();
>Результат = КонвертерКомандыCURL.Конвертировать(КонсольнаяКоманда, Генератор);
>```

## API

[curlone.ru/api](https://curlone.ru/api)

## Особенности использования

Команда `curl` указывается в нотации `bash`

## Благодарности

Сообществу за свободные инструменты:

* [OneScript](https://github.com/EvilBeaver/OneScript)
* [Autumn/ОСень](https://github.com/autumn-library/autumn)
* [WINOW](https://github.com/autumn-library/winow)
* [autumn-cli](https://github.com/autumn-library/autumn-cli)
* [cli](https://github.com/oscript-library/cli)
* [Connector](https://github.com/vbondarevsky/Connector)
* [1commands](https://github.com/artbear/1commands)
* [tokenizer](https://github.com/Nivanchenko/tokenizer)
* [logos](https://github.com/oscript-library/logos)
* [1bdd](https://github.com/artbear/1bdd)
* [1testrunner](https://github.com/artbear/1testrunner)
* [asserts](https://github.com/oscript-library/asserts)
* [coverage](https://github.com/oscript-library/coverage)
* [coloratos](https://github.com/240596448/coloratos)
* [i18n](https://github.com/Stivo182/oscript-i18n)
* [Shiki 式](https://github.com/shikijs/shiki)

<a href="https://infostart.ru/public/2319069/" target="_blank"><img alt="Статья на Инфостарт" src="https://infostart.ru/bitrix/templates/sandbox_empty/assets/tpl/abo/img/logo.svg"></a>
