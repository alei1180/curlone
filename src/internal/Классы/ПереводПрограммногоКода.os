#Использовать tokenizer
#Использовать i18n

Перем _ПакетРесурсов; // Ссылка на объект ПакетРесурсовЛокализации, ГруппаПакетовРесурсовЛокализации

#Область ПрограммныйИнтерфейс

// Переводит программный код 1С в упрощенном варианте и только с учетом потребностей curlone
//
// Параметры:
//   Код - Строка - Программный код
//
// Возвращаемое значение:
//   Строка - Переведенный программный код
Функция Перевести(Код) Экспорт

	Спецификация = Спецификация();
	Токенайзер = Новый Токенайзер(Спецификация);
	Токенайзер.Инит(Код);

	Поток = Новый ПотокВПамяти();
	ЗаписьДанных = Новый ЗаписьДанных(Поток, , , "", "");

	ТекущееСостояние = Новый Структура();
	ТекущееСостояние.Вставить("ЭтоТекст", Ложь);
	ТекущееСостояние.Вставить("ЭтоКомментарий", Ложь);
	ТекущееСостояние.Вставить("ЭтоНачалоНовойОперации", Истина);
	ТекущееСостояние.Вставить("ИмяОбъектаПрисваивания", "");
	ТекущееСостояние.Вставить("ТипыОбъектов", Новый Соответствие());
	ТекущееСостояние.Вставить("ЗаписьДанных", ЗаписьДанных);

	Пока Токенайзер.ЕстьЕщеТокены() Цикл

		Токен = Токенайзер.СледующийТокен();
		ОбработатьТокен(Токен, ТекущееСостояние);

	КонецЦикла;

	ЗаписьДанных.Закрыть();
	Результат = ПолучитьСтрокуИзДвоичныхДанных(Поток.ЗакрытьИПолучитьДвоичныеДанные());	

	Возврат Результат;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПриСозданииОбъекта(ПакетРесурсов)

	_ПакетРесурсов = ПакетРесурсов;

КонецПроцедуры

Функция Спецификация()

	Спецификация = Новый Массив();
	Спецификация.Добавить(Новый СпецификацияТокенСимвол("""", "ДвойнаяКавычка"));
	Спецификация.Добавить(Новый СпецификацияТокенСимвол(";", "ТочкаСЗапятой"));
	Спецификация.Добавить(Новый СпецификацияТокенСимвол(Символы.ПС, "ПереносСтроки"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^\/\/+", "Комментарий"));  
	Спецификация.Добавить(ТокенРегулярноеВыражение("^Новый\s+[a-zA-Zа-яА-Я]+", "НовыйОбъект"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^[a-zA-Zа-яА-Я_\d]+\s*=", "ОперацияПрисваивания"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^[a-zA-Zа-яА-Я_\d]+\s*(\.\s*[a-zA-Zа-яА-Я_\d]+)+\s*\(", "ВызовМетодаОбъекта"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^[a-zA-Zа-яА-Я_\d]+\s*(\.\s*[a-zA-Zа-яА-Я_\d]+)+", "ОбращениеКОбъекту"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^[a-zA-Zа-яА-Я_\d]+\s*\(", "ВызовФункцииПроцедуры"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^\b(Истина|True|Ложь|False|Если|If|Тогда|Then|Иначе|Else|ИначеЕсли|ElseIf|КонецЕсли|EndIf|Не|Not)\b", "Оператор"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^[a-zA-Zа-яА-Я_\d]+(\.[a-zA-Zа-яА-Я_\d]+)*", "ИмяОбъекта"));
	Спецификация.Добавить(ТокенРегулярноеВыражение("^.", "ЛюбойСимвол"));

	Возврат Спецификация;
	
КонецФункции

Функция ТокенРегулярноеВыражение(Паттерн, ТипТокена)
	РегулярноеВыражение = Новый РегулярноеВыражение(Паттерн);
	РегулярноеВыражение.Многострочный = Ложь;
	Возврат Новый СпецификацияТокенРегулярноеВыражение(РегулярноеВыражение, ТипТокена);
КонецФункции

Процедура ОбработатьТокен(Токен, ТекущееСостояние)
	
	ТипТокена = Токен.ТипТокена();
	Значение = Токен.Значение();
	
	Если ТипТокена = "ДвойнаяКавычка" Тогда

		ТекущееСостояние.ЭтоТекст = Не ТекущееСостояние.ЭтоТекст;

	ИначеЕсли ТекущееСостояние.ЭтоТекст Тогда

		// Ничего
		
	ИначеЕсли ТипТокена = "ПереносСтроки" Тогда

		ТекущееСостояние.ЭтоНачалоНовойОперации = Истина;
		ТекущееСостояние.ЭтоКомментарий = Ложь;

	ИначеЕсли ТипТокена = "Комментарий" Тогда

		ТекущееСостояние.ЭтоКомментарий = Истина;

	ИначеЕсли ТекущееСостояние.ЭтоКомментарий Тогда

		// Ничего

	ИначеЕсли ТипТокена = "ТочкаСЗапятой" Тогда

		ТекущееСостояние.ЭтоНачалоНовойОперации = Истина;
		ТекущееСостояние.ИмяОбъектаПрисваивания = "";

	ИначеЕсли ТипТокена = "ОперацияПрисваивания" И ТекущееСостояние.ЭтоНачалоНовойОперации Тогда

		ОбработатьТокенОперацияПрисваивания(Значение, ТекущееСостояние);

	ИначеЕсли ТипТокена = "НовыйОбъект" Тогда

		ОбработатьТокенНовыйОбъект(Значение, ТекущееСостояние);

	ИначеЕсли ТипТокена = "ВызовМетодаОбъекта" Тогда

		ОбработатьТокенВызовМетодаОбъекта(Значение, ТекущееСостояние);

	ИначеЕсли ТипТокена = "ОбращениеКОбъекту" Тогда

		ОбработатьТокенОбращениеКОбъекту(Значение, ТекущееСостояние);

	ИначеЕсли ТипТокена = "ВызовФункцииПроцедуры" Тогда

		ИмяФункции = СокрЛП(Сред(Значение, 1, СтрДлина(Значение) - 1));
		Значение = СтрШаблон("%1(", ПолучитьПеревод(ИмяФункции, ИмяФункции));
	
	ИначеЕсли ТипТокена = "ИмяОбъекта" Тогда
	
		Значение = ПолучитьПеревод("Переменная." + СокрЛП(Значение), Значение);
	
	ИначеЕсли ТипТокена = "Оператор" Тогда
	
		Значение = ПолучитьПеревод(Значение, Значение);

	КонецЕсли;

	ТекущееСостояние.ЗаписьДанных.ЗаписатьСимволы(Значение);

	Если Не ТекущееСостояние.ЭтоТекст
		И Не ТипТокена = "ПереносСтроки" И Не ТипТокена = "ТочкаСЗапятой" Тогда
		ТекущееСостояние.ЭтоНачалоНовойОперации = Ложь;
	КонецЕсли;

КонецПроцедуры

Процедура ОбработатьТокенОперацияПрисваивания(Значение, ТекущееСостояние)

	ПозицияПробела = СтрНайти(Значение, " ");

	ИмяОбъекта = Сред(Значение, 1, ПозицияПробела - 1);
	ОстальнаяЧасть = Сред(Значение, ПозицияПробела);

	Значение = СтрШаблон("%1%2",
		ПолучитьПеревод("Переменная." + ИмяОбъекта, ИмяОбъекта),
		ОстальнаяЧасть);
	
	ТекущееСостояние.ИмяОбъектаПрисваивания = ИмяОбъекта;

КонецПроцедуры

Процедура ОбработатьТокенНовыйОбъект(Значение, ТекущееСостояние)
	
	Подстроки = СтрРазделить(Значение, " ", Ложь);

	ОператорНовый = СокрЛП(Подстроки[0]);
	Тип = СокрЛП(Подстроки[1]);
	
	Значение = СтрШаблон("%1 %2",
		ПолучитьПеревод(ОператорНовый, ОператорНовый),
		ПолучитьПеревод(Тип, Тип));

	Если Не ПустаяСтрока(ТекущееСостояние.ИмяОбъектаПрисваивания) Тогда
		ТекущееСостояние.ТипыОбъектов.Вставить(ТекущееСостояние.ИмяОбъектаПрисваивания, Тип);
	КонецЕсли;

КонецПроцедуры

Процедура ОбработатьТокенВызовМетодаОбъекта(Значение, ТекущееСостояние)

	ЗначениеБезСкобки = Сред(Значение, 1, СтрДлина(Значение) - 1);
	Подстроки = СтрРазделить(ЗначениеБезСкобки, ".", Ложь);

	ПутьСТочкой = "";
	Если Подстроки.Количество() > 2 Тогда
		Путь = Новый Массив();
		Для к = 1 По Подстроки.ВГраница() - 1 Цикл
			Путь.Добавить(СокрЛП(Подстроки[к]));
		КонецЦикла;

		ПутьСТочкой = "." + СтрСоединить(Путь, ".");
	КонецЕсли;

	ИмяОбъекта = СокрЛП(Подстроки[0]);
	ИмяМетода = СокрЛП(Подстроки[Подстроки.ВГраница()]);

	ТипКонечногоОбъекта = ТекущееСостояние.ТипыОбъектов[ИмяОбъекта + ПутьСТочкой];
	Если Не ТипКонечногоОбъекта = Неопределено Тогда

		Значение = СтрШаблон("%1%2.%3(",
			ПолучитьПеревод("Переменная." + ИмяОбъекта, ИмяОбъекта),
			ПутьСТочкой,
			ПолучитьПеревод(ТипКонечногоОбъекта + "." + ИмяМетода, ИмяМетода));

	Иначе

		Значение = СтрШаблон("%1%2.%3(",
			ПолучитьПеревод("Переменная." + ИмяОбъекта, ИмяОбъекта),
			ПутьСТочкой,
			ИмяМетода);

	КонецЕсли;

КонецПроцедуры

Процедура ОбработатьТокенОбращениеКОбъекту(Значение, ТекущееСостояние)

	Подстроки = СтрРазделить(Значение, ".", Ложь);
	Если Не Подстроки.Количество() = 2 Тогда
		Возврат;
	КонецЕсли;

	ИмяОбъекта = СокрЛП(Подстроки[0]);
	ИмяСвойства = СокрЛП(Подстроки[1]);
	
	// Перечисление
	ПереводПеречисления = _ПакетРесурсов.ПолучитьСтроку(ИмяОбъекта + "." + ИмяСвойства);
	Если Не ПереводПеречисления = Неопределено Тогда
		Значение = ПереводПеречисления;
	КонецЕсли;
	
	// Свойство объекта
	Если ПереводПеречисления = Неопределено Тогда
		ТипОбъекта = ТекущееСостояние.ТипыОбъектов[ИмяОбъекта];
		Если Не ТипОбъекта = Неопределено Тогда
			Значение = СтрШаблон("%1.%2",
				ПолучитьПеревод("Переменная." + ИмяОбъекта, ИмяОбъекта),
				ПолучитьПеревод(ТипОбъекта + "." + ИмяСвойства, ИмяСвойства));
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Функция ПолучитьПеревод(ИмяРесурса, ЗначениеПоУмолчанию)
	Ресурс = _ПакетРесурсов.ПолучитьРесурс(ИмяРесурса);
	Если ЗначениеЗаполнено(Ресурс) Тогда
		Возврат Ресурс;
	Иначе
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;
КонецФункции

#КонецОбласти