Перем _Спецификация; // ФиксированнаяСтруктура:
                     //   * ВсеОпции - ФиксированныйМассив из ОписаниеОпцииCURL
                     //   * ИндексПсевдонимов - ФиксированноеСоответствие из КлючИЗначение:
                     //       ** Ключ - Строка - Псевдоним опции
                     //       ** Значение - ОписаниеОпцииCURL - Описание опции
Перем _БлокировкаИнициализации; // БлокировкаРесурса

#Область ПрограммныйИнтерфейс

// Возвращает каталог опций curl 8.16.0, известных прежней реализации.
//
// Возвращаемое значение:
//   ФиксированныйМассив из ОписаниеОпцииCURL - Неизменяемые описания опций.
//
// Исключения:
//   internal.invariant_violation - Встроенный каталог содержит повторяющееся имя или псевдоним.
Функция Все() Экспорт

	Спецификация = ПолучитьСпецификацию();
	Возврат Спецификация.ВсеОпции;

КонецФункции

// Находит описание по короткому или длинному имени с допустимым префиксом.
//
// Параметры:
//   Имя - Строка - Псевдоним без дефисов, короткая форма с одним дефисом или длинная форма с двумя.
//
// Возвращаемое значение:
//   ОписаниеОпцииCURL, Неопределено - Найденное описание или Неопределено.
//
// Исключения:
//   internal.invariant_violation - Встроенный каталог содержит повторяющееся имя или псевдоним.
Функция НайтиПоИмени(Имя) Экспорт

	Если ТипЗнч(Имя) <> Тип("Строка") Тогда
		Возврат Неопределено;
	КонецЕсли;

	Спецификация = ПолучитьСпецификацию();
	Если СтрНачинаетсяС(Имя, "--") Тогда
		Псевдоним = Сред(Имя, 3);
		Если СтрДлина(Псевдоним) <= 1 Тогда
			Возврат Неопределено;
		КонецЕсли;
	ИначеЕсли СтрНачинаетсяС(Имя, "-") Тогда
		Псевдоним = Сред(Имя, 2);
		Если СтрДлина(Псевдоним) <> 1 Тогда
			Возврат Неопределено;
		КонецЕсли;
	Иначе
		Псевдоним = Имя;
	КонецЕсли;

	Возврат Спецификация.ИндексПсевдонимов.Получить(Псевдоним);

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСпецификацию()

	Если _Спецификация <> Неопределено Тогда
		Возврат _Спецификация;
	КонецЕсли;

	_БлокировкаИнициализации.Заблокировать();

	Попытка
		Если _Спецификация = Неопределено Тогда
			_Спецификация = ПостроитьСпецификацию();
		КонецЕсли;
	Исключение
		_БлокировкаИнициализации.Разблокировать();
		ВызватьИсключение;
	КонецПопытки;

	_БлокировкаИнициализации.Разблокировать();

	Возврат _Спецификация;

КонецФункции

Функция ПостроитьСпецификацию()

	Состояние = Новый Структура(
		"Опции, ИндексПсевдонимов, КаноническиеИмена",
		Новый Массив,
		Новый Соответствие,
		Новый Соответствие
	);

	ДобавитьОпределения(Состояние, ПоддерживаемыеОпределения(), Истина);
	ДобавитьОпределения(Состояние, НеподдерживаемыеОпределения(), Ложь);
	ДобавитьNext(Состояние);

	Возврат Новый ФиксированнаяСтруктура(
		"ВсеОпции, ИндексПсевдонимов",
		Новый ФиксированныйМассив(Состояние.Опции),
		Новый ФиксированноеСоответствие(Состояние.ИндексПсевдонимов)
	);

КонецФункции

Процедура ДобавитьОпределения(Состояние, Данные, ПоддерживаласьВV1)

	Строки = СтрРазделить(СтрЗаменить(Данные, Символы.ВК, ""), Символы.ПС, Ложь);
	Для Каждого СтрокаОпределения Из Строки Цикл
		Если ПустаяСтрока(СтрокаОпределения) Тогда
			Продолжить;
		КонецЕсли;

		КодТипа = Лев(СтрокаОпределения, 1);
		Псевдонимы = СтрРазделить(Сред(СтрокаОпределения, 3), " ", Ложь);
		ДобавитьОписание(Состояние, Псевдонимы, КодТипа, ПоддерживаласьВV1);
	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьОписание(Состояние, ИсходныеПсевдонимы, КодТипа, ПоддерживаласьВV1)

	КаноническоеИмя = ИсходныеПсевдонимы[ИсходныеПсевдонимы.ВГраница()];
	Если КаноническоеИмя = "no-location" Тогда
		Возврат;
	КонецЕсли;

	ДопускаетОтрицательнуюФорму = КодТипа = "B";
	НеПринимаетЗначение = ДопускаетОтрицательнуюФорму Или КодТипа = "F";
	Псевдонимы = Новый Массив;
	ОтрицательныеПсевдонимы = Новый Массив;

	Если ДопускаетОтрицательнуюФорму И СтрНачинаетсяС(КаноническоеИмя, "no-") Тогда
		Для Каждого Псевдоним Из ИсходныеПсевдонимы Цикл
			Псевдонимы.Добавить(Псевдоним);
			ОтрицательныеПсевдонимы.Добавить(Псевдоним);
		КонецЦикла;

		КаноническоеИмя = Сред(КаноническоеИмя, 4);
		Псевдонимы.Добавить(КаноническоеИмя);
	Иначе
		Для Каждого Псевдоним Из ИсходныеПсевдонимы Цикл
			Псевдонимы.Добавить(Псевдоним);
		КонецЦикла;

		Если ДопускаетОтрицательнуюФорму Тогда
			ОтрицательныйПсевдоним = "no-" + КаноническоеИмя;
			Псевдонимы.Добавить(ОтрицательныйПсевдоним);
			ОтрицательныеПсевдонимы.Добавить(ОтрицательныйПсевдоним);
		КонецЕсли;
	КонецЕсли;

	Если НеПринимаетЗначение Тогда
		РежимЗначения = РежимыЗначенияОпцийCURL.НеПринимает();
		ТипЗначения = ТипыЗначенийОпцийCURL.Булевое();
	Иначе
		РежимЗначения = РежимЗначенияОпции(КаноническоеИмя);
		ТипЗначения = ТипЗначенияОпции(КаноническоеИмя, КодТипа);
	КонецЕсли;

	Описание = Новый ОписаниеОпцииCURL(
		КаноническоеИмя,
		Псевдонимы,
		ОтрицательныеПсевдонимы,
		РежимЗначения,
		ТипЗначения,
		ОбластьДействия(КаноническоеИмя),
		ПравилоПовторения(КаноническоеИмя, НеПринимаетЗначение),
		"",
		ПоддерживаласьВV1,
		Ложь
	);

	Зарегистрировать(Состояние, Описание);

КонецПроцедуры

Процедура ДобавитьNext(Состояние)

	Псевдонимы = Новый Массив;
	Псевдонимы.Добавить(":");
	Псевдонимы.Добавить("next");

	Описание = Новый ОписаниеОпцииCURL(
		"next",
		Псевдонимы,
		Новый Массив,
		РежимыЗначенияОпцийCURL.НеПринимает(),
		ТипыЗначенийОпцийCURL.Булевое(),
		ОбластиДействияОпцийCURL.Глобальная(),
		ПравилаПовторенияОпцийCURL.БезДополнительногоЭффекта(),
		"",
		Ложь,
		Истина
	);
	Зарегистрировать(Состояние, Описание);

КонецПроцедуры

Процедура Зарегистрировать(Состояние, Описание)

	КаноническоеИмя = Описание.КаноническоеИмя();

	Если Состояние.КаноническиеИмена.Получить(КаноническоеИмя) <> Неопределено Тогда
		ВызватьИсключение СтандартныеОшибки.НарушенВнутреннийИнвариант(
			"Канонические имена опций уникальны",
			"Повторяющееся каноническое имя опции: " + КаноническоеИмя
		);
	КонецЕсли;

	Состояние.КаноническиеИмена.Вставить(КаноническоеИмя, Истина);

	Для Каждого Псевдоним Из Описание.Псевдонимы() Цикл
		Если Состояние.ИндексПсевдонимов.Получить(Псевдоним) <> Неопределено Тогда
			ВызватьИсключение СтандартныеОшибки.НарушенВнутреннийИнвариант(
				"Псевдонимы опций уникальны",
				"Повторяющийся псевдоним опции: " + Псевдоним
			);
		КонецЕсли;

		Состояние.ИндексПсевдонимов.Вставить(Псевдоним, Описание);
	КонецЦикла;

	Состояние.Опции.Добавить(Описание);

КонецПроцедуры

Функция ОбластьДействия(КаноническоеИмя)

	Глобальные = ",fail-early,libcurl,parallel-immediate,parallel-max,parallel,rate,show-error,stderr,"
		+ "styled-output,trace-ascii,trace-config,trace-ids,trace-time,trace,verbose,";
	
	Если СтрНайти(Глобальные, "," + КаноническоеИмя + ",") > 0 Тогда
		Возврат ОбластиДействияОпцийCURL.Глобальная();
	КонецЕсли;

	Возврат ОбластиДействияОпцийCURL.Локальная();

КонецФункции

Функция ПравилоПовторения(КаноническоеИмя, НеПринимаетЗначение)

	Добавляемые = ",url,header,data-ascii,data-raw,data-binary,data-urlencode,url-query,form,form-string,"
		+ "resolve,connect-to,mail-rcpt,quote,variable,alt-svc,config,cookie,hsts,json,proxy-header,"
		+ "telnet-option,trace-config,output,remote-name,upload-file,";
	
	Если СтрНайти(Добавляемые, "," + КаноническоеИмя + ",") > 0 Тогда
		Возврат ПравилаПовторенияОпцийCURL.Добавление();
	КонецЕсли;

	Если КаноническоеИмя = "help" Тогда
		Возврат ПравилаПовторенияОпцийCURL.ПервоеЗначение();
	КонецЕсли;

	Если НеПринимаетЗначение Или КаноническоеИмя = "ftp-ssl-ccc-mode" Тогда
		Возврат ПравилаПовторенияОпцийCURL.БезДополнительногоЭффекта();
	КонецЕсли;

	Возврат ПравилаПовторенияОпцийCURL.ПоследнееЗначение();

КонецФункции

Функция РежимЗначенияОпции(КаноническоеИмя)

	Если КаноническоеИмя = "help" Тогда
		Возврат РежимыЗначенияОпцийCURL.Необязательное();
	КонецЕсли;

	Возврат РежимыЗначенияОпцийCURL.Требует();

КонецФункции

Функция ТипЗначенияОпции(КаноническоеИмя, КодТипа)

	Числовые = ",max-time,connect-timeout,retry,retry-max-time,continue-at,create-file-mode,expect100-timeout,"
		+ "happy-eyeballs-timeout-ms,keepalive-cnt,keepalive-time,max-filesize,max-redirs,parallel-max,"
		+ "retry-delay,speed-limit,speed-time,tftp-blksize,vlan-priority,";
	
	Если КодТипа = "N" Или СтрНайти(Числовые, "," + КаноническоеИмя + ",") > 0 Тогда
		Возврат ТипыЗначенийОпцийCURL.Числовое();
	КонецЕсли;

	Возврат ТипыЗначенийОпцийCURL.Строковое();

КонецФункции

Функция ПоддерживаемыеОпределения()

	Возврат "S:url
		|S:H header
		|S:X request
		|S:u user
		|S:d data data-ascii
		|S:data-raw
		|S:data-binary
		|S:data-urlencode
		|S:T upload-file
		|B:G get
		|B:I head
		|S:E cert
		|B:ca-native
		|S:cacert
		|S:url-query
		|S:o output
		|S:output-dir
		|B:create-dirs
		|B:O remote-name
		|B:remote-name-all
		|S:x proxy
		|S:U proxy-user
		|B:proxy-basic
		|B:proxy-ntlm
		|N:m max-time
		|N:connect-timeout
		|S:json
		|S:A user-agent
		|S:oauth2-bearer
		|F:ftp-pasv
		|S:P ftp-port
		|B:l list-only
		|B:L location
		|B:no-location
		|N:retry
		|N:retry-max-time
		|S:F form
		|S:form-string
		|B:basic
		|B:digest
		|B:ntlm
		|B:negotiate
		|S:aws-sigv4";

КонецФункции

Функция НеподдерживаемыеОпределения()

	Возврат "S:abstract-unix-socket
		|S:alt-svc
		|F:anyauth
		|B:a append
		|S:capath
		|B:cert-status
		|S:cert-type
		|S:ciphers
		|B:compressed
		|B:compressed-ssh
		|S:K config
		|S:connect-to
		|S:C continue-at
		|S:b cookie
		|S:c cookie-jar
		|S:create-file-mode
		|B:crlf
		|S:crlfile
		|S:curves
		|S:delegation
		|B:q disable
		|B:disable-eprt
		|B:disable-epsv
		|B:disallow-username-in-url
		|S:dns-interface
		|S:dns-ipv4-addr
		|S:dns-ipv6-addr
		|S:dns-servers
		|B:doh-cert-status
		|B:doh-insecure
		|S:doh-url
		|F:dump-ca-embed
		|S:D dump-header
		|S:ech
		|S:egd-file
		|S:engine
		|S:etag-compare
		|S:etag-save
		|S:expect100-timeout
		|B:f fail
		|B:fail-early
		|B:fail-with-body
		|B:false-start
		|B:form-escape
		|S:ftp-account
		|S:ftp-alternative-to-user
		|B:ftp-create-dirs
		|S:ftp-method
		|B:ftp-pret
		|B:ftp-skip-pasv-ip
		|B:ftp-ssl-ccc
		|S:ftp-ssl-ccc-mode
		|B:ftp-ssl-control
		|B:g globoff
		|S:happy-eyeballs-timeout-ms
		|S:haproxy-clientip
		|B:haproxy-protocol
		|S:h help
		|S:hostpubmd5
		|S:hostpubsha256
		|S:hsts
		|B:http0.9
		|F:0 http1.0
		|F:http1.1
		|F:http2
		|F:http2-prior-knowledge
		|F:http3
		|F:http3-only
		|B:ignore-content-length
		|B:k insecure
		|S:interface
		|S:ip-tos
		|S:ipfs-gateway
		|F:4 ipv4
		|F:6 ipv6
		|B:j junk-session-cookies
		|S:keepalive-cnt
		|S:keepalive-time
		|S:key
		|S:key-type
		|S:krb
		|S:libcurl
		|S:limit-rate
		|S:local-port
		|B:location-trusted
		|S:login-options
		|S:mail-auth
		|S:mail-from
		|S:mail-rcpt
		|B:mail-rcpt-allowfails
		|B:M manual
		|S:max-filesize
		|S:max-redirs
		|B:metalink
		|B:mptcp
		|B:n netrc
		|S:netrc-file
		|B:netrc-optional
		|B:no-alpn
		|B:N no-buffer
		|B:no-clobber
		|B:no-keepalive
		|B:no-npn
		|B:no-progress-meter
		|B:no-sessionid
		|S:noproxy
		|B:ntlm-wb
		|B:Z parallel
		|B:parallel-immediate
		|S:parallel-max
		|S:pass
		|B:path-as-is
		|S:pinnedpubkey
		|B:post301
		|B:post302
		|B:post303
		|S:preproxy
		|S:proto
		|S:proto-default
		|S:proto-redir
		|B:proxy-anyauth
		|B:proxy-ca-native
		|S:proxy-cacert
		|S:proxy-capath
		|S:proxy-cert
		|S:proxy-cert-type
		|S:proxy-ciphers
		|S:proxy-crlfile
		|B:proxy-digest
		|S:proxy-header
		|B:proxy-http2
		|B:proxy-insecure
		|S:proxy-key
		|S:proxy-key-type
		|B:proxy-negotiate
		|S:proxy-pass
		|S:proxy-pinnedpubkey
		|S:proxy-service-name
		|B:proxy-ssl-allow-beast
		|B:proxy-ssl-auto-client-cert
		|S:proxy-tls13-ciphers
		|S:proxy-tlsauthtype
		|S:proxy-tlspassword
		|S:proxy-tlsuser
		|F:proxy-tlsv1
		|S:proxy1.0
		|B:p proxytunnel
		|S:pubkey
		|S:Q quote
		|S:random-file
		|S:r range
		|S:rate
		|B:raw
		|S:e referer
		|B:J remote-header-name
		|B:R remote-time
		|B:remove-on-error
		|S:request-target
		|S:resolve
		|B:retry-all-errors
		|B:retry-connrefused
		|S:retry-delay
		|S:sasl-authzid
		|B:sasl-ir
		|S:service-name
		|B:S show-error
		|B:i show-headers
		|B:s silent
		|B:skip-existing
		|S:socks4
		|S:socks4a
		|S:socks5
		|B:socks5-basic
		|B:socks5-gssapi
		|B:socks5-gssapi-nec
		|S:socks5-gssapi-service
		|S:socks5-hostname
		|S:Y speed-limit
		|S:y speed-time
		|B:ssl
		|B:ssl-allow-beast
		|B:ssl-auto-client-cert
		|B:ssl-no-revoke
		|B:ssl-reqd
		|B:ssl-revoke-best-effort
		|F:2 sslv2
		|F:3 sslv3
		|S:stderr
		|B:styled-output
		|B:suppress-connect-headers
		|B:tcp-fastopen
		|B:tcp-nodelay
		|S:t telnet-option
		|S:tftp-blksize
		|B:tftp-no-options
		|S:z time-cond
		|B:tls-earlydata
		|S:tls-max
		|S:tls13-ciphers
		|S:tlsauthtype
		|S:tlspassword
		|S:tlsuser
		|F:1 tlsv1
		|F:tlsv1.0
		|F:tlsv1.1
		|F:tlsv1.2
		|F:tlsv1.3
		|B:tr-encoding
		|S:trace
		|S:trace-ascii
		|S:trace-config
		|B:trace-ids
		|B:trace-time
		|S:unix-socket
		|B:B use-ascii
		|S:variable
		|B:v verbose
		|B:V version
		|S:vlan-priority
		|S:w write-out
		|B:xattr";

КонецФункции

#КонецОбласти

_БлокировкаИнициализации = Новый БлокировкаРесурса();
