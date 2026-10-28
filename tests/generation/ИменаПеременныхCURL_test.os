#Использовать "../../src/public"
#Использовать "../../src/generation"
#Использовать "../../src/generators/platform-http"
#Использовать "../../src/generators/connector-http"

#Область Тесты

&ПараметризованныйТест
&ИсточникЗначение("1c")
&ИсточникЗначение("connector")
Процедура ТестДолжен_РазделитьПользовательскиеИСлужебныеИменаВКодеНаАнглийском(Цель) Экспорт

	// Подготовка
	Реестр = Новый РеестрГенераторовCURL;
	Реестр.Зарегистрировать(Новый ГенераторКодаПлатформыCURL);
	Реестр.Зарегистрировать(Новый ГенераторКодаКоннектораCURL);
	Сервис = Новый СервисКонвертацииCURL(Реестр);
	Параметры = Новый ПараметрыКонвертацииCURL(
		"curl http://example.com -H ""X-Test: $If/$Headers/$TOKEN/$token"""
	);
	Параметры.Цель = Цель;
	Параметры.Локаль = ЛокалиКонвертацииCURL.Английская();

	ОжидаемыйКод = "CURL_If = """";
	|CURL_Headers = """";
	|TOKEN = """";
	|token_2 = """";
	|
	|Headers = New Map();
	|Headers.Insert(""X-Test"", CURL_If + ""/"" + CURL_Headers + ""/"" + TOKEN + ""/"" + token_2);
	|
	|";

	Если Цель = "1c" Тогда
		ОжидаемыйКод = ОжидаемыйКод + "Connection = New HTTPConnection(""example.com"", 80);
		|HTTPRequest = New HTTPRequest(""/"", Headers);
		|
		|HTTPResponse = Connection.CallHTTPMethod(""GET"", HTTPRequest);";
	Иначе
		ОжидаемыйКод = ОжидаемыйКод + "AdditionalParameters = New Structure();
		|AdditionalParameters.Insert(""Headers"", Headers);
		|
		|Result = HTTPConnector.Get(""http://example.com"", , AdditionalParameters);";
	КонецЕсли;

	// Действие
	Результат = Сервис.Конвертировать(Параметры);

	// Проверка
	Ожидаем.Что(Результат.Успешно()).ЭтоИстина();
	Ожидаем.Что(Результат.Код()).Равно(ОжидаемыйКод);

КонецПроцедуры

#КонецОбласти
