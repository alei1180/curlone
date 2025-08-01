#Использовать "../../internal"

Перем Конструктор; // см. КонструкторПрограммногоКода
Перем ИсходящиеОшибки; // Массив из Структура:
                       //   * Текст - Строка - Текст ошибки
                       //   * КритичнаяОшибка - Булево - Признак критичиной ошибки 
Перем ОписаниеЗапроса; // см. ОписаниеЗапроса

Перем Состояние; // см. НовоеСостояние
Перем ПрочитанныеФайлы; // Массив из Структура:
                        //   - ПередаваемыйФайл - см. ПередаваемыйФайл
                        //   - ИмяПеременной - Строка
Перем ДанныеЗапросаСборка; // Строка
Перем URLСборка; // Строка
Перем КодЛокализации; // Строка
Перем ПакетРесурсов; // Объект.ПакетРесурсовЛокализации, Объект.ГруппаПакетовРесурсовЛокализации
Перем ДесериализоватьОтветИзJSON; // Булево

Перем ИмяПараметраЗаголовки; // Строка
Перем ИмяПараметраАутентификация; // Строка
Перем ИмяПараметраПрокси; // Строка
Перем ИмяПараметраДополнительныеПараметры; // Строка
Перем ИмяПараметраДанныеЗапроса; // Строка
Перем ИмяПараметраФайлы; // Строка
Перем ИмяПараметраПараметрыЗапроса; // Строка
Перем ИмяПараметраURL; // Строка

#Область ПрограммныйИнтерфейс

// Генерирует программный код для коннектора из переданного описания запроса
//
// Параметры:
//   Описание - см. ОписаниеЗапроса - Описание запроса
//   Ошибки - Неопределено - Выходной параметр. Передает обнаруженные при конвертации ошибки:
//      Массив из Структура:
//        * Текст - Строка - Текст ошибки
//        * Критичная - Булево - Признак критичиной ошибки 
//
// Возвращаемое значение:
//   Строка - Программный код
Функция Получить(Описание, Ошибки = Неопределено) Экспорт
	
	Если Ошибки = Неопределено Тогда
		Ошибки = Новый Массив();
	КонецЕсли;

	ОписаниеЗапроса = Описание;
	ИсходящиеОшибки = Ошибки;
	Конструктор = Новый КонструкторПрограммногоКода(ОписаниеЗапроса.ИменаПеременных);
	Состояние = НовоеСостояние();
	ПрочитанныеФайлы.Очистить();

	ПакетРесурсов = МенеджерРесурсовЛокализации.ПолучитьПакеты(
		"Общий, КлючевыеСловаЯзыка, ГенераторПрограммногоКодаКоннекторHTTP", 
		КодЛокализации
	);

	ДобавитьПеременные();
	ДобавитьЧтениеФайлов();
	ДобавитьДанныеЗапроса();
	ДобавитьФайлы();
	ДобавитьПараметрыЗапроса();
	ДобавитьЗаголовки();
	ДобавитьАутентификацию();
	ДобавитьПрокси();
	ДобавитьЗапросы();

	Результат = Конструктор.ПолучитьРезультат();

	ПакетРесурсов.ЗаполнитьШаблон(Результат);

	Если Не КодЛокализации = "ru" Тогда
		Переводчик = Новый ПереводПрограммногоКода(ПакетРесурсов);
		Результат = Переводчик.Перевести(Результат);
	КонецЕсли;

	Возврат Результат;

КонецФункции

// Устанавливает язык перевода
//
// Параметры:
//   Локаль - Строка - Код локализации (ru, en)
Процедура УстановитьЯзыкПеревода(Локаль) Экспорт
	КодЛокализации = Локаль;
КонецПроцедуры

// Будут использованы методы GetJson, PostJson и т.д.
//
// Параметры:
//   Десериализовать - Булево
Процедура ДесериализоватьОтветИзJSON(Десериализовать = Истина) Экспорт
	ДесериализоватьОтветИзJSON = Десериализовать;
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ПоддерживаемыеОпции() Экспорт

	ПоддерживаемыеОпции = "url
	|H
	|header
	|X
	|request
	|u
	|user
	|d
	|data
	|data-ascii
	|data-raw
	|data-binary
	|data-urlencode
	|T
	|upload-file
	|G
	|get
	|I
	|head
	|E
	|cert
	|ca-native
	|cacert
	|url-query
	|x
	|proxy
	|U
	|proxy-user
	|proxy-basic
	|proxy-ntlm
	|m
	|max-time
	|connect-timeout
	|json
	|A
	|user-agent
	|oauth2-bearer
	|L
	|location
	|no-location
	|retry
	|retry-max-time
	|F
	|form
	|form-string
	|basic
	|digest
	|ntlm
	|negotiate
	|aws-sigv4";

	Возврат СтрРазделить(ПоддерживаемыеОпции, Символы.ПС, Ложь);

КонецФункции

Функция ПоддерживаемыеПротоколы() Экспорт

	Протоколы = Новый Массив();
	Протоколы.Добавить(ПротоколыURL.HTTP);
	Протоколы.Добавить(ПротоколыURL.HTTPS);

	Возврат Протоколы;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПриСозданииОбъекта()

	ПрочитанныеФайлы = Новый Массив();
	
	УстановитьЯзыкПеревода("ru");
	ДесериализоватьОтветИзJSON(Ложь);

	ИмяПараметраЗаголовки = "Заголовки";
	ИмяПараметраАутентификация = "Аутентификация";
	ИмяПараметраПрокси = "Прокси";
	ИмяПараметраДополнительныеПараметры = "ДополнительныеПараметры";
	ИмяПараметраДанныеЗапроса = "Данные";
	ИмяПараметраФайлы = "Файлы";
	ИмяПараметраПараметрыЗапроса = "ПараметрыЗапроса";
	ИмяПараметраURL = "URL";
	
КонецПроцедуры

Процедура ДобавитьПеременные()

	Код = Новый ГенераторКодаИменаПеременных(ОписаниеЗапроса).Получить();

	Если Не ПустаяСтрока(Код) Тогда
		Конструктор
			.ДобавитьПустуюСтроку()
			.ДобавитьСтроку(Код);
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьЗаголовки()
	
	Заголовки = ПередаваемыеЗаголовки();
	Если Заголовки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	Состояние.ЕстьЗаголовки = Истина;

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку("%1 = Новый Соответствие();", ИмяПараметраЗаголовки);

	Для Каждого Заголовок Из ОписаниеЗапроса.Заголовки Цикл

		Если Не ПередаватьЗаголовок(Заголовок) Тогда
			Продолжить;
		КонецЕсли;

		ПараметрыФункции = Новый Массив();
		ПараметрыФункции.Добавить(Конструктор.ПараметрВСтроку(Заголовок.Ключ));
		ПараметрыФункции.Добавить(Конструктор.ПараметрВСтроку(Заголовок.Значение));

		Конструктор
			.ДобавитьСтроку(
				"%1.Вставить(%2);",
				ИмяПараметраЗаголовки, 
				Конструктор.ПараметрыФункцииВСтроку(ПараметрыФункции)
			);

	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьЧтениеФайлов()

	ФайлыДляЧтения = Новый Массив();
	Для Каждого ПередаваемыйФайл Из ОписаниеЗапроса.Файлы Цикл

		Если Не (ПередаваемыйФайл.ПрочитатьСодержимое 
			Или ПередаваемыйФайл.Назначение = НазначенияПередаваемыхДанных.СтрокаЗапроса) Тогда
			Продолжить;
		КонецЕсли;

		ФайлыДляЧтения.Добавить(ПередаваемыйФайл);

	КонецЦикла;

	Код = Новый ГенераторКодаЧтениеТекстовыхФайлов(ОписаниеЗапроса, ФайлыДляЧтения, ПрочитанныеФайлы).Получить();

	Если Не ПустаяСтрока(Код) Тогда
		Конструктор
			.ДобавитьПустуюСтроку()
			.ДобавитьСтроку(Код);
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьДанныеЗапроса()

	ДанныеЗапросаСборка = "";
	Состояние.ТелоЗапросаВJSON = Ложь;

	Если Не Состояние.ПереданоТелоЗапроса Тогда
		Возврат;
	КонецЕсли;

	НазначениеДанных = НазначенияПередаваемыхДанных.ТелоЗапроса;

	Если ВозможнаПередачаДанныхЧерезСоответствие(НазначениеДанных) Тогда
	
		ДобавитьДанныеЗапросаЧерезСоответствие(НазначениеДанных, ИмяПараметраДанныеЗапроса, ДанныеЗапросаСборка);

	ИначеЕсли ОписаниеЗапроса.ОтправлятьКакMultipartFormData Тогда

		ТекстОшибки = "Данные формы невозможно передать в структурированный объект для отправки в КоннекторHTTP";
		ИсходящиеОшибки.Добавить(ОбщийНаборИнструментов.НоваяОшибка(ТекстОшибки));

	Иначе

		ДобавитьТекстовыеДанныеЗапросаЧерезСтроку(НазначениеДанных, ИмяПараметраДанныеЗапроса, ДанныеЗапросаСборка);

	КонецЕсли;	

КонецПроцедуры

Процедура ДобавитьПараметрыЗапроса()

	НазначениеДанных = НазначенияПередаваемыхДанных.СтрокаЗапроса;
	
	Если Не Состояние.ПереданаСтрокаЗапроса
		Или Не ВозможнаПередачаДанныхЧерезСоответствие(НазначениеДанных) Тогда
		Возврат;
	КонецЕсли;

	ДобавитьДанныеЗапросаЧерезСоответствие(НазначениеДанных, ИмяПараметраПараметрыЗапроса);

КонецПроцедуры

Процедура ДобавитьДанныеЗапросаЧерезСоответствие(Назначение, ИмяПараметра, РезультатСборка = "")

	КонструкторДанных = Новый КонструкторПрограммногоКода(ОписаниеЗапроса.ИменаПеременных);

	ДобавитьДанныеЗапросаИзТекстовыхДанныхЧерезСоответствие(КонструкторДанных, Назначение, ИмяПараметра);
	ДобавитьДанныеЗапросаИзПрочитанныхФайловЧерезСоответствие(КонструкторДанных, Назначение, ИмяПараметра);

	Если Не КонструкторДанных.Пустой() Тогда

		Конструктор
			.ДобавитьПустуюСтроку()
			.ДобавитьСтроку("%1 = Новый Соответствие();", ИмяПараметра)
			.ДобавитьСтроку(КонструкторДанных.ПолучитьРезультат());

		РезультатСборка = ИмяПараметра;

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьДанныеЗапросаИзТекстовыхДанныхЧерезСоответствие(КонструкторДанных, Назначение, ИмяПараметра)

	Для Каждого ПередаваемыйТекст Из ОписаниеЗапроса.ОтправляемыеТекстовыеДанные Цикл
		
		Если Не ПередаваемыйТекст.Назначение = Назначение Тогда
			Продолжить;
		КонецЕсли;

		Если ЗначениеЗаполнено(ПередаваемыйТекст.ИмяПоля) Тогда
			Ключ = ПередаваемыйТекст.ИмяПоля;
			Значение = ПередаваемыйТекст.Значение;
		Иначе
			Ключ = ПередаваемыйТекст.Значение;
			Значение = "";
		КонецЕсли;

		ПараметрыМетода = Новый Массив();
		ПараметрыМетода.Добавить(Конструктор.ПараметрВСтроку(Ключ));
		ПараметрыМетода.Добавить(Конструктор.НеобязательныйПараметрВСтроку(Значение));

		КонструкторДанных.ДобавитьСтроку(
			"%1.Вставить(%2);", 
			ИмяПараметра,
			Конструктор.ПараметрыФункцииВСтроку(ПараметрыМетода)
		);
		
	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьДанныеЗапросаИзПрочитанныхФайловЧерезСоответствие(КонструкторДанных, Назначение, ИмяПараметра)

	ЗначенияПолей = Новый Соответствие();
	Для Каждого ПрочитанныйФайл Из ПрочитанныеФайлы Цикл
		
		ПередаваемыйФайл = ПрочитанныйФайл.ПередаваемыйФайл;

		Если Не ПередаваемыйФайл.Назначение = Назначение 
			Или Не ПередаваемыйФайл.ПрочитатьСодержимое Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяПоля = ПередаваемыйФайл.ИмяПоля;
		Если ЗначенияПолей[ИмяПоля] = Неопределено Тогда

			ЗначенияПолей.Вставить(ИмяПоля, ПрочитанныйФайл.ИмяПеременной);

		ИначеЕсли ТипЗнч(ЗначенияПолей[ИмяПоля]) = Тип("Массив") Тогда
		
			ЗначенияПолей[ИмяПоля].Добавить(ПрочитанныйФайл.ИмяПеременной);

		Иначе

			МассивЗначений = Новый Массив();
			МассивЗначений.Добавить(ЗначенияПолей[ИмяПоля]);
			МассивЗначений.Добавить(ПрочитанныйФайл.ИмяПеременной);

			ЗначенияПолей.Вставить(ИмяПоля, МассивЗначений);

		КонецЕсли;

	КонецЦикла;

	Для Каждого Данные Из ЗначенияПолей Цикл

		ИмяПоля = Данные.Ключ;

		Если ТипЗнч(Данные.Значение) = Тип("Массив") Тогда

			МассивПеременныхФайлов = Данные.Значение;

			КонструкторДанных.ДобавитьСтроку(
				"%1.Вставить(%2, Новый Массив());", 
				ИмяПараметра, 
				КонструкторДанных.ПараметрВСтроку(ИмяПоля)
			);
			
			Для Каждого ИмяПеременнойФайла Из МассивПеременныхФайлов Цикл

				КонструкторДанных.ДобавитьСтроку(
					"%1[%2].Добавить(%3));", 
					ИмяПараметра,
					КонструкторДанных.ПараметрВСтроку(ИмяПоля),
					КонструкторДанных.ПараметрВСтроку(ИмяПеременнойФайла)
				);

			КонецЦикла;

		Иначе

			ИмяПеременнойФайла = Данные.Значение;

			ПараметрыМетода = Новый Массив();
			ПараметрыМетода.Добавить(КонструкторДанных.ПараметрВСтроку(ИмяПоля));
			ПараметрыМетода.Добавить(ИмяПеременнойФайла);

			КонструкторДанных.ДобавитьСтроку(
				"%1.Вставить(%2);", 
				ИмяПараметра,
				КонструкторДанных.ПараметрыФункцииВСтроку(ПараметрыМетода)
			);

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьТекстовыеДанныеЗапросаЧерезСтроку(НазначениеДанных, ИмяПараметра, РезультатСборка)

	Сборка = Новый ГенераторКодаДанныеЗапроса(
		ОписаниеЗапроса, 
		НазначениеДанных, 
		ПрочитанныеФайлы
	).Получить();

	Если Не ЗначениеЗаполнено(Сборка) Тогда
		Возврат;
	КонецЕсли;

	ТипКонтента = НРег(ОписаниеЗапроса.ЗначениеЗаголовка("Content-Type"));
	Если СтрНайти(ТипКонтента, "application/json") Тогда

		ТекстJson = Сред(Сборка, 2, СтрДлина(Сборка) - 2);
		ТекстJson = СтрЗаменить(ТекстJson, Символы.ПС + "|", Символы.ПС);
		ТекстJson = СтрЗаменить(ТекстJson, """""", """");
		
		Результат = ОбщийНаборИнструментов.ПопытатьсяПрочитатьJSON(ТекстJson);
		Если Не Результат = Неопределено Тогда

			Конструктор
				.ДобавитьПустуюСтроку()
				.ДобавитьСоответствие(Результат, ИмяПараметра);

			РезультатСборка = ИмяПараметра;
			Состояние.ТелоЗапросаВJSON = Истина;

			Возврат;

		КонецЕсли;

	КонецЕсли;

	Если СтрЧислоСтрок(Сборка) = 1 Тогда
		
		РезультатСборка = Сборка;

	Иначе

		Конструктор
			.ДобавитьПустуюСтроку()
			.ДобавитьСтроку("%1 = %2;", ИмяПараметра, Сборка);

		РезультатСборка = ИмяПараметра;

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьФайлы()

	Если Не ОписаниеЗапроса.ОтправлятьКакMultipartFormData Тогда
		Возврат;
	КонецЕсли;

	Назначение = НазначенияПередаваемыхДанных.ТелоЗапроса;
	КонструкторФайлов = Новый КонструкторПрограммногоКода(ОписаниеЗапроса.ИменаПеременных);

	Для Каждого ПередаваемыйФайл Из ОписаниеЗапроса.Файлы Цикл
		
		Если Не ПередаваемыйФайл.Назначение = Назначение 
			Или ПередаваемыйФайл.ПрочитатьСодержимое Тогда
			Продолжить;
		КонецЕсли;

		КонструкторФайлов
			.ДобавитьПустуюСтроку()
			.ДобавитьСтроку("Файл = Новый Структура();")
			.ДобавитьСтроку(
				"Файл.Вставить(""{t(Параметр.Файл.Имя)}"", %1);",
				КонструкторФайлов.ПараметрВСтроку(ПередаваемыйФайл.ИмяПоля)
			);

		Если ЗначениеЗаполнено(ПередаваемыйФайл.ИмяФайла) Тогда
			КонструкторФайлов.ДобавитьСтроку("Файл.Вставить(""{t(Параметр.Файл.ИмяФайла)}"", %1);", 
			КонструкторФайлов.ПараметрВСтроку(ПередаваемыйФайл.ИмяФайла));
		КонецЕсли;

		КонструкторФайлов.ДобавитьСтроку(
			"Файл.Вставить(""{t(Параметр.Файл.Данные)}"", Новый ДвоичныеДанные(%1));", 
			КонструкторФайлов.ПараметрВСтроку(ПередаваемыйФайл.ПолноеИмяФайла)
		);

		Если ЗначениеЗаполнено(ПередаваемыйФайл.ТипMIME) Тогда
			КонструкторФайлов.ДобавитьСтроку(
				"Файл.Вставить(""{t(Параметр.Файл.Тип)}"", %1);", 
				КонструкторФайлов.ПараметрВСтроку(ПередаваемыйФайл.ТипMIME)
			);
		КонецЕсли;

		Если ЗначениеЗаполнено(ПередаваемыйФайл.Заголовки) Тогда
			КонструкторФайлов.ДобавитьСтроку("Файл.Вставить(""{t(Параметр.Файл.Заголовки)}"", Новый Соответствие());");

			Для Каждого Заголовок Из ПередаваемыйФайл.Заголовки Цикл
				ПараметрыМетода = Новый Массив();
				ПараметрыМетода.Добавить(КонструкторФайлов.ПараметрВСтроку(Заголовок.Ключ));
				ПараметрыМетода.Добавить(КонструкторФайлов.ПараметрВСтроку(Заголовок.Значение));

				КонструкторФайлов.ДобавитьСтроку(
					"Файл.{t(Параметр.Заголовки)}.{t(Структура.Вставить)}(%1);",
					КонструкторФайлов.ПараметрыФункцииВСтроку(ПараметрыМетода)
				);
			КонецЦикла;
		КонецЕсли;

		КонструкторФайлов.ДобавитьСтроку("Файлы.Добавить(Файл);");

	КонецЦикла;

	Если Не КонструкторФайлов.Пустой() Тогда

		Состояние.ЕстьФайлыMultipart = Истина;

		Конструктор
			.ДобавитьПустуюСтроку()
			.ДобавитьСтроку("%1 = Новый Массив();", ИмяПараметраФайлы)
			.ДобавитьСтроку(КонструкторФайлов.ПолучитьРезультат());

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьПоследовательнуюОтправкуДвоичныхДанныхРесурса(ОписаниеРесурса)

	ДлинаИмениФайлаВКомментарии = 100;

	ПередаваемыеФайлы = ОписаниеЗапроса.ФайлыОтправляемыеОтдельно(ОписаниеРесурса);

	КоличествоФайлов = ПередаваемыеФайлы.Количество();
	НомерФайла = 0;
	Для Каждого ПередаваемыйФайл Из ПередаваемыеФайлы Цикл

		НомерФайла = НомерФайла + 1;

		Если КоличествоФайлов > 1 Тогда
			ИмяФайла = Лев(ПередаваемыйФайл.ПолноеИмяФайла, ДлинаИмениФайлаВКомментарии);
			Конструктор
				.ДобавитьПустуюСтроку()
				.ДобавитьКомментарий("{t(Текст.ПередачаФайла)} %1. %2",
					НомерФайла,
					ИмяФайла
				);
		КонецЕсли;

		СтруктураURL = Новый ПарсерURL(ОписаниеРесурса.URL);
		Если ПередаваемыйФайл.ДобавлятьИмяФайлаКURL Тогда
			СтруктураURL.Путь = ОбщийНаборИнструментов.ДополнитьИменемФайлаПутьURL(ПередаваемыйФайл.ПолноеИмяФайла, СтруктураURL.Путь);
		КонецЕсли;

		Конструктор.ДобавитьСтроку(
			"%1 = Новый ДвоичныеДанные(%2);", 
			ИмяПараметраДанныеЗапроса, 
			Конструктор.ПараметрВСтроку(ПередаваемыйФайл.ПолноеИмяФайла)
		);

		ДобавитьВызовМетода(ОписаниеРесурса, СтруктураURL, ИмяПараметраДанныеЗапроса);

	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьАутентификацию()

	ДобавитьАутентификациюBasic();
	ДобавитьАутентификациюDigest();
	ДобавитьАутентификациюОС();
	ДобавитьАутентификациюAWS4();
	ДобавитьАутентификациюBearer();

КонецПроцедуры

Процедура ДобавитьАутентификациюBasic()

	Если Не ОписаниеЗапроса.ТипАутентификации = ТипыАутентификации.Basic Тогда
		Возврат;
	КонецЕсли;

	ПараметрыМетода = Новый Массив();
	ПараметрыМетода.Добавить(Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ИмяПользователя));
	ПараметрыМетода.Добавить(Конструктор.НеобязательныйПараметрВСтроку(ОписаниеЗапроса.ПарольПользователя));

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку(
			"%1 = Новый Структура(""{t(Параметр.Пользователь)}, {t(Параметр.Пароль)}"", %2, %3);", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ИмяПользователя),
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ПарольПользователя)
		);

КонецПроцедуры

Процедура ДобавитьАутентификациюDigest()

	Если Не ОписаниеЗапроса.ТипАутентификации = ТипыАутентификации.Digest Тогда
		Возврат;
	КонецЕсли;

	ПараметрыМетода = Новый Массив();
	ПараметрыМетода.Добавить(Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ИмяПользователя));
	ПараметрыМетода.Добавить(Конструктор.НеобязательныйПараметрВСтроку(ОписаниеЗапроса.ПарольПользователя));

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку(
			"%1 = Новый Структура(""{t(Параметр.Аутентификация.Тип)}, {t(Параметр.Пользователь)}, {t(Параметр.Пароль)}"", ""Digest"", %2, %3);", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ИмяПользователя),
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ПарольПользователя)
		);

КонецПроцедуры

Процедура ДобавитьАутентификациюОС()

	Если Не ОписаниеЗапроса.ТипАутентификации = ТипыАутентификации.NTLM
		И Не ОписаниеЗапроса.ТипАутентификации = ТипыАутентификации.Negotiate Тогда
		Возврат;
	КонецЕсли;

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку(
			"%1 = Новый Структура(""{t(Параметр.ИспользоватьАутентификациюОС)}"", Истина);",
			ИмяПараметраАутентификация
		);

КонецПроцедуры

Процедура ДобавитьАутентификациюAWS4()

	Если Не ОписаниеЗапроса.ТипАутентификации = ТипыАутентификации.AWS4 Тогда
		Возврат;
	КонецЕсли;

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку(
			"%1 = Новый Структура();",
			ИмяПараметраАутентификация
		)
		.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.Аутентификация.Тип)}"", ""AWS4-HMAC-SHA256"");",
			ИмяПараметраАутентификация
		)
		.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.AWS4.ИдентификаторКлючаДоступа)}"", %2);", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.AWS4.КлючДоступа)
		)
		.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.AWS4.СекретныйКлюч)}"", %2);", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.AWS4.СекретныйКлюч)
		)
		.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.AWS4.Сервис)}"", %2);", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.AWS4.Сервис)
		)
		.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.AWS4.Регион)}"", %2);", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.AWS4.Регион)
		);

КонецПроцедуры

Процедура ДобавитьАутентификациюBearer()

	Если Не ОписаниеЗапроса.ТипАутентификации = ТипыАутентификации.Bearer Тогда
		Возврат;
	КонецЕсли;

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку(
			"%1 = Новый Структура(""{t(Параметр.Bearer.Токен)}, {t(Параметр.Аутентификация.Тип)}"", %2, ""Bearer"");", 
			ИмяПараметраАутентификация,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ТокенBearer)
		);

КонецПроцедуры

Процедура ДобавитьПрокси()

	Если Не ОписаниеЗапроса.ИспользуетсяПрокси() Тогда
		Возврат;
	КонецЕсли;

	Если Не ОбщийНаборИнструментов.ПротоколПроксиПоддерживается(ОписаниеЗапроса.ПроксиПротокол) Тогда
		ТекстОшибки = СтрШаблон("Прокси протокол %1 не поддерживается", ОписаниеЗапроса.ПроксиПротокол);
		ИсходящиеОшибки.Добавить(ОбщийНаборИнструментов.НоваяКритичнаяОшибка(ТекстОшибки));
		Возврат;
	КонецЕсли;

	Конструктор
		.ДобавитьПустуюСтроку()
		.ДобавитьСтроку(Новый ГенераторКодаИнтернетПрокси(ОписаниеЗапроса, ИмяПараметраПрокси).Получить());

КонецПроцедуры

Процедура ДобавитьЗапросы()
	
	МаксимальнаяДлинаАдресаВКомментарии = 100;
		
	КоличествоURL = ОписаниеЗапроса.АдресаРесурсов.Количество();
	НомерЗапроса = 0;

	Для Каждого ОписаниеРесурса Из ОписаниеЗапроса.АдресаРесурсов Цикл
		
		НомерЗапроса = НомерЗапроса + 1;
		СтруктураURL = Новый ПарсерURL(ОписаниеРесурса.URL);
		Состояние.ВызванМетодПоТекущемуURL = Ложь;

		Если Не ОбщийНаборИнструментов.ЭтоHTTP(СтруктураURL.Схема) Тогда
			ТекстОшибки = СтрШаблон("Протокол ""%1"" не поддерживается", СтруктураURL.Схема);
			ИсходящиеОшибки.Добавить(ОбщийНаборИнструментов.НоваяКритичнаяОшибка(ТекстОшибки));
		КонецЕсли;
			
		Конструктор.ДобавитьПустуюСтроку();

		Если КоличествоURL > 1 Тогда	
			Конструктор.ДобавитьКомментарий(
				"{t(Текст.Запрос)} %1. %2",
				НомерЗапроса, 
				Лев(ОписаниеРесурса.URL, МаксимальнаяДлинаАдресаВКомментарии)
			);
		КонецЕсли;

		ДобавитьПоследовательнуюОтправкуДвоичныхДанныхРесурса(ОписаниеРесурса);

		Если Не Состояние.ВызванМетодПоТекущемуURL Тогда
			ДобавитьВызовМетода(ОписаниеРесурса);
		КонецЕсли;

		Если ОбщийНаборИнструментов.ЕстьКритичныеОшибки(ИсходящиеОшибки) Тогда
			Конструктор.Очистить();
			Возврат;
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ДобавитьВызовМетода(ОписаниеРесурса, Знач СтруктураURL = Неопределено, Знач ДанныеЗапроса = Неопределено)

	Если СтруктураURL = Неопределено Тогда
		СтруктураURL = Новый ПарсерURL(ОписаниеРесурса.URL);
	КонецЕсли;

	Если ДанныеЗапроса = Неопределено Тогда
		ДанныеЗапроса = ДанныеЗапросаСборка;
	КонецЕсли;

	ДобавитьURL(СтруктураURL);
	ДобавитьДополнительныеПараметры(ОписаниеРесурса, ДанныеЗапроса);

	ИмяФункции = ИмяФункцииБиблиотекиПоМетоду(ОписаниеРесурса.Метод);
	ПараметрыФункции = Новый Массив;

	Если ОписаниеРесурса.Метод = "GET" Тогда

		ПараметрПараметрыЗапроса = "";
		Если Состояние.ПереданаСтрокаЗапроса 
			И ВозможнаПередачаДанныхЧерезСоответствие(НазначенияПередаваемыхДанных.СтрокаЗапроса) Тогда
			ПараметрПараметрыЗапроса = ИмяПараметраПараметрыЗапроса;
		КонецЕсли;

		ПараметрыФункции.Добавить(URLСборка);
		ПараметрыФункции.Добавить(ПараметрПараметрыЗапроса);

	ИначеЕсли ВозможноПередатьДанныеЗапросаВПараметрыФункцииВызоваМетода(ОписаниеРесурса.Метод) Тогда

		ПараметрыФункции.Добавить(URLСборка);
		ПараметрыФункции.Добавить(?(Не Состояние.ТелоЗапросаВJSON, ДанныеЗапроса, Неопределено));

	ИначеЕсли ОписаниеРесурса.Метод = "HEAD" Или ОписаниеРесурса.Метод = "OPTIONS" Тогда

		ПараметрыФункции.Добавить(URLСборка);
		
	Иначе

		ПараметрыФункции.Добавить(Конструктор.ПараметрВСтроку(ОписаниеРесурса.Метод));
		ПараметрыФункции.Добавить(URLСборка);

		ИмяФункции = ПакетРесурсов.ПолучитьСтроку("КоннекторHTTP.ВызватьМетод");

	КонецЕсли;

	Если Состояние.ЕстьДополнительныеПараметры Тогда
		ПараметрыФункции.Добавить(ИмяПараметраДополнительныеПараметры);
	КонецЕсли;

	Конструктор.ДобавитьСтроку(
		"{t(Переменная.Результат)} = {t(КоннекторHTTP)}.%1(%2);", 
		ИмяФункции,
		Конструктор.ПараметрыФункцииВСтроку(ПараметрыФункции)
	);

	Состояние.ВызванМетодПоТекущемуURL = Истина;

КонецПроцедуры

Процедура ДобавитьURL(СтруктураURL)

	URLСборка = "";
	НазначениеДанных = НазначенияПередаваемыхДанных.СтрокаЗапроса;
	
	Если Состояние.ПереданаСтрокаЗапроса
		И ВозможнаПередачаДанныхЧерезСоответствие(НазначениеДанных) Тогда

		URLСборка = Новый ГенераторКодаURL(ОписаниеЗапроса, СтруктураURL).Получить();

	Иначе

		URLСборка = Новый ГенераторКодаURL(
			ОписаниеЗапроса,
			СтруктураURL,
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные, 
			ПрочитанныеФайлы
		).Получить();

	КонецЕсли;

	Если СтрЧислоСтрок(URLСборка) > 1 Тогда

		Конструктор
			.ДобавитьСтроку("%1 = %2;", ИмяПараметраURL, URLСборка)
			.ДобавитьПустуюСтроку();

		URLСборка = ИмяПараметраURL;

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьДополнительныеПараметры(ОписаниеРесурса, ДанныеЗапроса)

	Состояние.ЕстьДополнительныеПараметры = Ложь;

	КонструкторДопПараметров = Новый КонструкторПрограммногоКода(ОписаниеЗапроса.ИменаПеременных);

	ДобавитьЗаголовкиВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьАутентификациюВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьПроксиВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьСертификатыВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьТаймаутВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьРазрешениеПеренаправленийВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьПовторныеПопыткиВДополнительныеПараметры(КонструкторДопПараметров);
	ДобавитьПараметрыЗапросаВДополнительныеПараметры(КонструкторДопПараметров, ОписаниеРесурса);
	ДобавитьДанныеВДополнительныеПараметры(КонструкторДопПараметров, ОписаниеРесурса, ДанныеЗапроса);
	ДобавитьФайлыВДополнительныеПараметры(КонструкторДопПараметров);

	Если Не КонструкторДопПараметров.Пустой() Тогда

		Состояние.ЕстьДополнительныеПараметры = Истина;

		Конструктор
			.ДобавитьСтроку("%1 = Новый Структура();", ИмяПараметраДополнительныеПараметры)
			.ДобавитьСтроку(КонструкторДопПараметров.ПолучитьРезультат())
			.ДобавитьПустуюСтроку();

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьЗаголовкиВДополнительныеПараметры(КонструкторДопПараметров)

	Если Не Состояние.ЕстьЗаголовки Тогда
		Возврат;
	КонецЕсли;

	КонструкторДопПараметров.ДобавитьСтроку(
		"%1.Вставить(""{t(Параметр.Заголовки)}"", %2);", 
		ИмяПараметраДополнительныеПараметры,
		ИмяПараметраЗаголовки
	);

КонецПроцедуры

Процедура ДобавитьПроксиВДополнительныеПараметры(КонструкторДопПараметров)
	
	Если Не ОписаниеЗапроса.ИспользуетсяПрокси() Тогда
		Возврат;
	КонецЕсли;

	КонструкторДопПараметров.ДобавитьСтроку(
		"%1.Вставить(""{t(Параметр.Прокси)}"", %2);", 
		ИмяПараметраДополнительныеПараметры,
		ИмяПараметраПрокси
	);	

КонецПроцедуры

Процедура ДобавитьАутентификациюВДополнительныеПараметры(КонструкторДопПараметров)

	Если Не ЗначениеЗаполнено(ОписаниеЗапроса.ТипАутентификации) Тогда
		Возврат;
	КонецЕсли;

	КонструкторДопПараметров.ДобавитьСтроку(
		"%1.Вставить(""{t(Параметр.Аутентификация)}"", %2);", 
		ИмяПараметраДополнительныеПараметры,
		ИмяПараметраАутентификация
	);

КонецПроцедуры

Процедура ДобавитьТаймаутВДополнительныеПараметры(КонструкторДопПараметров)

	Таймаут = 0;
	Если ЗначениеЗаполнено(ОписаниеЗапроса.Таймаут) И ЗначениеЗаполнено(ОписаниеЗапроса.ТаймаутСоединения) Тогда
		Таймаут = ОписаниеЗапроса.Таймаут + ОписаниеЗапроса.ТаймаутСоединения;
	Иначе
		Возврат;
	КонецЕсли;

	КонструкторДопПараметров.ДобавитьСтроку(
		"%1.Вставить(""{t(Параметр.Таймаут)}"", %2);", 
		ИмяПараметраДополнительныеПараметры,
		Конструктор.ПараметрВСтроку(Таймаут)
	);

КонецПроцедуры

Процедура ДобавитьСертификатыВДополнительныеПараметры(КонструкторДопПараметров)
	
	// Сертификаты УЦ
	Если ЗначениеЗаполнено(ОписаниеЗапроса.ИмяФайлаСертификатовУЦ) Тогда
			
		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.ПроверятьSSL)}"", Новый СертификатыУдостоверяющихЦентровФайл(%2));", 
			ИмяПараметраДополнительныеПараметры,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ИмяФайлаСертификатовУЦ)
		);

	КонецЕсли;

	// Сертификат клиента
	Если ЗначениеЗаполнено(ОписаниеЗапроса.ИмяФайлаСертификатаКлиента) Тогда

		ПараметрыОбъекта = Новый Массив;
		ПараметрыОбъекта.Добавить(Конструктор.ПараметрВСтроку(ОписаниеЗапроса.ИмяФайлаСертификатаКлиента));
		ПараметрыОбъекта.Добавить(Конструктор.НеобязательныйПараметрВСтроку(ОписаниеЗапроса.ПарольСертификатаКлиента));
		
		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.КлиентскийСертификатSSL)}"", Новый СертификатКлиентаФайл(%2));", 
			ИмяПараметраДополнительныеПараметры,
			КонструкторДопПараметров.ПараметрыФункцииВСтроку(ПараметрыОбъекта)
		);

	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьПараметрыЗапросаВДополнительныеПараметры(КонструкторДопПараметров, ОписаниеРесурса)
	
	Если Состояние.ПереданаСтрокаЗапроса
		И ВозможнаПередачаДанныхЧерезСоответствие(НазначенияПередаваемыхДанных.СтрокаЗапроса)
		И Не ВозможноПередатьПараметрыЗапросаВПараметрыФункцииВызоваМетода(ОписаниеРесурса.Метод) Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.ПараметрыЗапроса)}"", %2);", 
			ИмяПараметраДополнительныеПараметры,
			ИмяПараметраПараметрыЗапроса
		);

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьДанныеВДополнительныеПараметры(КонструкторДопПараметров, ОписаниеРесурса, ДанныеЗапроса)
	
	Если Не ЗначениеЗаполнено(ДанныеЗапроса) Тогда
		Возврат;
	КонецЕсли;

	Если Состояние.ТелоЗапросаВJSON Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""Json"", %2);", 
			ИмяПараметраДополнительныеПараметры,
			ДанныеЗапроса
		);

	ИначеЕсли Не ВозможноПередатьДанныеЗапросаВПараметрыФункцииВызоваМетода(ОписаниеРесурса.Метод) Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.Данные)}"", %2);", 
			ИмяПараметраДополнительныеПараметры,
			ДанныеЗапроса
		);

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьФайлыВДополнительныеПараметры(КонструкторДопПараметров)
	
	Если Состояние.ЕстьФайлыMultipart Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.Файлы)}"", %2);", 
			ИмяПараметраДополнительныеПараметры,
			ИмяПараметраФайлы
		);

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьРазрешениеПеренаправленийВДополнительныеПараметры(КонструкторДопПараметров)
	
	Если ОписаниеЗапроса.ЗапретитьПеренаправление Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.РазрешитьПеренаправление)}"", Ложь);", 
			ИмяПараметраДополнительныеПараметры
		);

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьПовторныеПопыткиВДополнительныеПараметры(КонструкторДопПараметров)
	
	Если ОписаниеЗапроса.МаксимальноеКоличествоПовторов > 0 Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.МаксимальноеКоличествоПовторов)}"", %2);",
			ИмяПараметраДополнительныеПараметры,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.МаксимальноеКоличествоПовторов)
		);

	КонецЕсли;
	
	Если ОписаниеЗапроса.МаксимальноеВремяПовторов > 0 Тогда

		КонструкторДопПараметров.ДобавитьСтроку(
			"%1.Вставить(""{t(Параметр.МаксимальноеВремяПовторов)}"", %2);",
			ИмяПараметраДополнительныеПараметры,
			Конструктор.ПараметрВСтроку(ОписаниеЗапроса.МаксимальноеВремяПовторов)
		);

	КонецЕсли;

КонецПроцедуры

Функция ВозможноПередатьДанныеЗапросаВПараметрыФункцииВызоваМетода(Метод)

	Возврат (
			Метод = "POST" 
			Или Метод = "PUT" 
			Или Метод = "PATCH" 
			Или Метод = "DELETE"
		);

КонецФункции

Функция ВозможноПередатьПараметрыЗапросаВПараметрыФункцииВызоваМетода(Метод)
	Возврат Метод = "GET";
КонецФункции

Функция ВозможнаПередачаДанныхЧерезСоответствие(Назначение)

	ЭтоДанныеMultipart = ОписаниеЗапроса.ОтправлятьКакMultipartFormData 
		И Назначение = НазначенияПередаваемыхДанных.ТелоЗапроса;

	Для Каждого ПередаваемыйТекст Из ОписаниеЗапроса.ОтправляемыеТекстовыеДанные Цикл

		Если Не ПередаваемыйТекст.Назначение = Назначение Тогда
			Продолжить;
		КонецЕсли;

		Если Не ЗначениеЗаполнено(ПередаваемыйТекст.ИмяПоля) Тогда
			Возврат Ложь;
		КонецЕсли;
		
		РазделительОтличенОтАмперсанда = Не ПередаваемыйТекст.РазделительТелаЗапроса = "&";
		Если РазделительОтличенОтАмперсанда И Не ЭтоДанныеMultipart Тогда
			Возврат Ложь;
		КонецЕсли;

	КонецЦикла;

	Для Каждого ПрочитанныйФайл Из ПрочитанныеФайлы Цикл

		ПередаваемыйФайл = ПрочитанныйФайл.ПередаваемыйФайл;

		Если Не ПередаваемыйФайл.Назначение = Назначение Тогда
			Продолжить;
		КонецЕсли;

		Если Не ЗначениеЗаполнено(ПередаваемыйФайл.ИмяПоля) Тогда
			Возврат Ложь;
		КонецЕсли;
		
		РазделительОтличенОтАмперсанда = Не ПередаваемыйФайл.РазделительТелаЗапроса = "&";
		Если РазделительОтличенОтАмперсанда И Не ЭтоДанныеMultipart Тогда
			Возврат Ложь;
		КонецЕсли;

	КонецЦикла;

	Возврат Истина;
	
КонецФункции

Функция ПередаваемыеЗаголовки()

	Заголовки = Новый Соответствие();
	Для Каждого Заголовок Из ОписаниеЗапроса.Заголовки Цикл
		Если ПередаватьЗаголовок(Заголовок) Тогда
			Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
		КонецЕсли;
	КонецЦикла;

	Возврат Заголовки;

КонецФункции

Функция ПередаватьЗаголовок(Заголовок)
	
	Имя = НРег(Заголовок.Ключ);
	Значение = НРег(Заголовок.Значение);

	Если Имя = "content-type" Тогда

		Если Состояние.ПереданоТелоЗапроса 
			И Значение = "application/x-www-form-urlencoded" Тогда
			Возврат Ложь;
		КонецЕсли;

	Иначе

		Возврат Истина;

	КонецЕсли;

	Возврат Истина;

КонецФункции

Функция НовоеСостояние()

	Результат = Новый Структура();
	
	Результат.Вставить("ПереданоТелоЗапроса", ОписаниеЗапроса.ПереданоТелоЗапроса());
	Результат.Вставить("ПереданаСтрокаЗапроса", ОписаниеЗапроса.ПереданаСтрокаЗапроса());
	Результат.Вставить("ЕстьЗаголовки", Ложь);
	Результат.Вставить("ЕстьФайлыMultipart", Ложь);
	Результат.Вставить("ЕстьДополнительныеПараметры", Ложь);
	Результат.Вставить("ВызванМетодПоТекущемуURL", Ложь);
	Результат.Вставить("ТелоЗапросаВJSON", Ложь);

	Возврат Результат;

КонецФункции

Функция ИмяФункцииБиблиотекиПоМетоду(Метод)

	ИмяМетода = Лев(Метод, 1) + НРег(Сред(Метод, 2));

	Если ДесериализоватьОтветИзJSON 
		И СтрНайти("Get,Post,Put,Delete", ИмяМетода) Тогда
		ИмяМетода = ИмяМетода + "Json";
	КонецЕсли;

	Возврат ИмяМетода;

КонецФункции

#КонецОбласти