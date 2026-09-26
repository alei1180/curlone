![curlone](img/curlone-logo-horizontal.png)

<p align="center">
<a href="https://t.me/curlone_bot"><img alt="telegram bot" src="https://img.shields.io/badge/telegram-bot-blue?style=flat&logo=telegram"></a>
<a href="https://github.com/alei1180/curlone/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/alei1180/curlone?style=badge"></a>
<a href="https://github.com/alei1180/curlone/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/alei1180/curlone?style=badge"></a>
<a href="https://github.com/alei1180/curlone/releases/latest"><img alt="Last release" src="https://img.shields.io/github/v/release/alei1180/curlone?include_prereleases&label=last%20release&style=badge"></a>
<a href="https://sonar.openbsl.ru/dashboard?id=curlone"><img alt="SonarQube: quality gate" src="https://sonar.openbsl.ru/api/project_badges/measure?project=curlone&metric=alert_status&token=sqb_174d3352e142da6217583afe4bfbd7af29ee137d"></a>
<a href="https://sonar.openbsl.ru/dashboard?id=curlone"><img alt="SonarQube: coverage" src="https://sonar.openbsl.ru/api/project_badges/measure?project=curlone&metric=coverage&token=sqb_174d3352e142da6217583afe4bfbd7af29ee137d"></a>
<a href="https://litrosbadges.ru/package/curlone"><img src="https://litrosbadges.ru/package/curlone.svg" alt="Used by"></a>
</p>

# curlone

`curlone` преобразует команды `curl` в код OneScript для:

- платформенных `HTTPСоединение` и `FTPСоединение`;
- библиотеки [Connector](https://github.com/vbondarevsky/Connector).

Конвертер доступен как веб-приложение, консольная команда, HTTP API и библиотека OneScript. Он разбирает команду
`curl`, проверяет возможности выбранного генератора и возвращает сформированный код вместе с ошибками и
предупреждениями.

> Текущая версия `2.0.0-alpha.1` несовместима с интерфейсами curlone v1. Порядок обновления описан в
> [руководстве по миграции](docs/МиграцияНаCurlone2.md).

## Установка

Для работы требуется OneScript 2.0 или новее.

```shell
opm install curlone
```

После установки доступны команды `curlone convert` и `curlone serve`.

## Быстрый старт

```shell
curlone convert "curl https://example.com"
```

Результат:

```bsl
ЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL();

Соединение = Новый HTTPСоединение("example.com", 443, , , , , ЗащищенноеСоединение);
HTTPЗапрос = Новый HTTPЗапрос("/");

HTTPОтвет = Соединение.ВызватьHTTPМетод("GET", HTTPЗапрос);
```

По умолчанию curlone формирует платформенный код с русскими именами переменных.

## Веб-приложение

Запустите локальный веб-интерфейс и откройте его в браузере:

```shell
curlone serve --port 3333 --open
```

Если порт не указан, приложение использует порт из своей конфигурации. Готовая веб-версия доступна на
[curlone.ru](https://curlone.ru/).

Справка по параметрам запуска:

```shell
curlone serve --help
```

## Интерфейс командной строки

Команда `convert` принимает исходную команду в нотации Bash: строкой, отдельными аргументами, из файла или из
стандартного ввода:

```shell
# Команда одной строкой
curlone convert "curl https://example.com"

# Параметры curl передаются после разделителя --
curlone convert -- curl https://example.com

# Код для Connector с английскими именами переменных
curlone convert --target connector --locale en "curl https://example.com"

# Чтение команды из файла и запись кода в файл
curlone convert --input command.txt --output result.bsl

# Чтение из стандартного ввода
echo "curl https://example.com" | curlone convert

# Структурированный результат
curlone convert --format json "curl https://example.com"
```

Основные параметры:

| Параметр | Значения | Назначение |
| --- | --- | --- |
| `-t`, `--target` | `1c`, `connector` | Выбрать генератор, по умолчанию `1c` |
| `-l`, `--locale` | `ru`, `en` | Выбрать язык сформированного кода, по умолчанию `ru` |
| `-f`, `--format` | `text`, `json` | Выбрать формат результата, по умолчанию `text` |
| `-i`, `--input` | путь или `-` | Прочитать команду из файла или стандартного ввода |
| `-o`, `--output` | путь или `-` | Записать результат в файл или стандартный вывод |
| `--fail-on-warning` | | Вернуть код завершения `5`, если есть предупреждения |
| `--` | | Завершить параметры curlone и начать аргументы curl |

В формате `text` код записывается в стандартный вывод, а диагностика в поток ошибок. В формате `json` весь
результат записывается в стандартный вывод. Полную справку выводит `curlone convert --help`.

## HTTP API

HTTP API работает вместе с веб-приложением. Запустите сервер и отправьте запрос `POST /api/v2/convert`:

```shell
curl http://localhost:3333/api/v2/convert \
  -H "Content-Type: application/json" \
  -d '{"command":"curl https://example.com","target":"1c","locale":"ru"}'
```

Минимальное тело запроса содержит только поле `command`. Поля `target` и `locale` по умолчанию равны `1c` и `ru`:

```json
{
  "command": "curl https://example.com",
  "target": "1c",
  "locale": "ru",
  "generatorOptions": {
    "responseDeserializationFormat": "json"
  }
}
```

Ответ всегда содержит единый набор полей:

```json
{
  "success": true,
  "target": "1c",
  "code": "Сформированный код",
  "errors": [],
  "warnings": []
}
```

Описание схем, ограничений и ответов доступно после запуска приложения по адресу `/api/v2/openapi.json`.

## Библиотечный API

Подключите пакет и создайте параметры конвертации:

```bsl
#Использовать curlone

Параметры = Новый ПараметрыКонвертацииCURL("curl https://example.com");
Параметры.Цель = ЦелиКонвертацииCURL.ПлатформенныйHTTP();
Параметры.Локаль = ЛокалиКонвертацииCURL.Русская();

Результат = Новый КонвертерCURL().Конвертировать(Параметры);

Если Результат.Успешно() Тогда
    Сообщить(Результат.Код());
Иначе
    Для Каждого ЭлементДиагностики Из Результат.Диагностика() Цикл
        Сообщить(ЭлементДиагностики.Сообщение);
    КонецЦикла;
КонецЕсли;
```

Для Connector установите цель `ЦелиКонвертацииCURL.КоннекторHTTP()`. Для английских имён переменных используйте
`ЛокалиКонвертацииCURL.Английская()`.

`РезультатКонвертацииCURL` предоставляет сформированный код, ошибки, предупреждения, общую диагностику и
идентификатор использованного генератора.

## Поддержка команд curl

Встроенные генераторы поддерживают распространённые возможности curl: методы HTTP, заголовки, данные форм,
JSON, файлы, составные формы, аутентификацию, прокси, TLS, сохранение ответа и часть возможностей FTP.

Если семантику команды можно представить только приблизительно, curlone формирует код и возвращает
предупреждение. Если корректное представление невозможно, результат содержит ошибку без программного кода.

Точное состояние каждой возможности приведено в [матрице возможностей](docs/МатрицаВозможностейCURL.md):

- [платформенные HTTP и FTP](docs/generators/platform-http.md);
- [Connector HTTP](docs/generators/connector-http.md);
- [коды ошибок](docs/КодыОшибокCurlone.md).

## Документация

- [Оглавление документации](docs/README.md)
- [Веб-приложение](docs/ВебПриложение.md)
- [Интерфейс командной строки](docs/ИнтерфейсКоманднойСтроки.md)
- [HTTP API](docs/HTTPAPI.md)
- [Библиотечный API](docs/КонвертерCURL.md)
- [Миграция на curlone 2](docs/МиграцияНаCurlone2.md)
- [Матрица возможностей](docs/МатрицаВозможностейCURL.md)
- [Создание собственных генераторов](docs/spi/ГенераторКодаCURL.md)
- [Реестр генераторов](docs/РеестрГенераторовCURL.md)

## Разработка

Установите зависимости проекта и OneUnit:

```shell
opm install -l --dev
opm install oneunit
```

Запустите проверки:

```shell
oneunit execute --recursive
node --test tests/web/index.test.mjs
```

## Благодарности

curlone использует свободные библиотеки и инструменты:

- [OneScript](https://github.com/EvilBeaver/OneScript)
- [Autumn/ОСень](https://github.com/autumn-library/autumn)
- [WINOW](https://github.com/autumn-library/winow)
- [decorator](https://github.com/nixel2007/decorator)
- [i18n](https://github.com/oscript-library/i18n)
- [Jason](https://github.com/nixel2007/jason)
- [PackageInfo](https://github.com/Segate-ekb/packageinfo)
- [errors](https://github.com/Stivo182/oscript-errors)
- [url](https://github.com/Stivo182/oscript-url)
- [resilience](https://github.com/Stivo182/oscript-resilience)
- [Connector](https://github.com/vbondarevsky/1connector)
- [OneUnit](https://github.com/sfaqer/oneunit)
- [asserts](https://github.com/oscript-library/asserts)
- [Shiki 式](https://github.com/shikijs/shiki)


<a href="https://infostart.ru/public/2319069/" target="_blank"><img alt="Статья на Инфостарт" src="https://infostart.ru/bitrix/templates/sandbox_empty/assets/tpl/abo/img/logo.svg"></a>
