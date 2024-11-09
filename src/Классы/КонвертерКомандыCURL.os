﻿#Использовать cli
#Использовать "../internal"

Перем ОписаниеЗапроса;

#Область ПрограммныйИнтерфейс

Функция Конвертировать(КоманднаяСтрока, пГенераторПрограммногоКода = Неопределено) Экспорт
	
	ОписаниеЗапроса = Новый ОписаниеЗапроса();

	Если пГенераторПрограммногоКода = Неопределено Тогда
		ГенераторПрограммногоКода = Новый ГенераторПрограммногоКода1С();
	Иначе
		ГенераторПрограммногоКода = пГенераторПрограммногоКода;
	КонецЕсли;

	Парсер = Новый ПарсерКонсольнойКоманды();
	АргументыКоманд = Парсер.Распарсить(КоманднаяСтрока);

	Приложение = Новый КонсольноеПриложение("curl", "", ЭтотОбъект);
	Приложение.УстановитьСпек("[URL...] [OPTIONS] [URL...]");

	Приложение.Аргумент("URL", "", "Адрес ресурса").ТМассивСтрок();
	Приложение.Опция("H header", "", "HTTP заголовок").ТМассивСтрок();
	Приложение.Опция("X request", "", "Метод запроса").ТСтрока();
	Приложение.Опция("u user", "", "Пользователь и пароль").ТСтрока();
	Приложение.Опция("d data", "", "Передаваемые данные по HTTP POST").ТМассивСтрок();
	Приложение.Опция("data-raw", "", "Передаваемые данные по HTTP POST без интерпретации символа @").ТМассивСтрок();
	Приложение.Опция("data-binary", "", "Передаваемые двоичные данные по HTTP POST").ТМассивСтрок();
	Приложение.Опция("T upload-file", "", "Загружаемый файл").ТМассивСтрок();
	
	Приложение.УстановитьОсновноеДействие(ЭтотОбъект);

	Если АргументыКоманд.Количество() = 0 Тогда
		ВызватьИсключение "Команда должна начинаться с ""curl""";
	КонецЕсли;

	Для Каждого АргументыКоманды Из АргументыКоманд Цикл
		Если Не (НРег(АргументыКоманды[0]) = "curl") Тогда
			ВызватьИсключение "Команда должна начинаться с ""curl""";
		КонецЕсли;
		АргументыКоманды.Удалить(0);
		Приложение.Запустить(АргументыКоманды);
	КонецЦикла;

	Возврат ГенераторПрограммногоКода.Получить(ОписаниеЗапроса);

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ВыполнитьКоманду(Команда) Экспорт

	ПрочитатьURL(Команда);
	ПрочитатьЗаголовки(Команда);
	ПрочитатьПользователя(Команда);
	ПрочитатьТекстовыеДанныеДляОтправки(Команда);
	ПрочитатьМетодЗапроса(Команда);
	
КонецПроцедуры

Процедура ПрочитатьМетодЗапроса(Команда)

	Метод = Команда.ЗначениеОпции("X");

	Если ЗначениеЗаполнено(Метод) Тогда
		ОписаниеЗапроса.Метод = Метод;
		Возврат;
	КонецЕсли;

	Если ЕстьОпцииГруппыData(Команда) Тогда
		ОписаниеЗапроса.Метод = "POST";
	ИначеЕсли ЕстьОпции(Команда, "T,upload-file") Тогда
		ОписаниеЗапроса.Метод = "PUT";
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьURL(Команда)
    ОписаниеЗапроса.URL = Команда.ЗначениеАргумента("URL");
КонецПроцедуры

Процедура ПрочитатьЗаголовки(Команда)

	ОписаниеЗапроса.Заголовки = РазобратьЗаголовки(Команда);
	ДополнитьЗаголовкиПриНаличииОпцииГруппыData(Команда);

КонецПроцедуры

Процедура ДополнитьЗаголовкиПриНаличииОпцииГруппыData(Команда)
	Если ЕстьОпцииГруппыData(Команда)
		И Не ЗначениеЗаполнено(ЗначениеЗаголовка(ОписаниеЗапроса.Заголовки, "Content-Type")) Тогда
		ОписаниеЗапроса.Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	КонецЕсли;
КонецПроцедуры

Функция РазобратьЗаголовки(Команда)

	Заголовки = Новый Соответствие;
	МассивЗаголовков = Команда.ЗначениеОпции("H");
	Для Каждого Строка Из МассивЗаголовков Цикл
		Имя = "";
		Значение = "";

		ПозицияДвоеточия = СтрНайти(Строка, ":");
		Если ПозицияДвоеточия Тогда
			Имя = СокрЛП(Сред(Строка, 1, ПозицияДвоеточия - 1));
			Значение = СокрЛП(Сред(Строка, ПозицияДвоеточия + 1));
		Иначе
			Имя = Строка;
		КонецЕсли;

		Заголовки.Вставить(Имя, Значение);
	КонецЦикла;

	Возврат Заголовки;

КонецФункции

Функция ЗначениеЗаголовка(Заголовки, Имя)

	Для Каждого КлючЗначение Из Заголовки Цикл
		Если НРег(КлючЗначение.Ключ) = НРег(Имя) Тогда
			Возврат КлючЗначение.Значение;
		КонецЕсли;
	КонецЦикла;

КонецФункции

Процедура ПрочитатьПользователя(Команда)
	ПользовательИПароль = Команда.ЗначениеОпции("u");
	МассивПодстрок = СтрРазделить(ПользовательИПароль, ":");

	ОписаниеЗапроса.ИмяПользователя = МассивПодстрок[0];
	Если МассивПодстрок.Количество() = 2 Тогда
		ОписаниеЗапроса.ПарольПользователя = МассивПодстрок[1];
	КонецЕсли
КонецПроцедуры

Процедура ПрочитатьТекстовыеДанныеДляОтправки(Команда)

	// -d, --data
	МассивДанных = Команда.ЗначениеОпции("d");

	Для Каждого Данные Из МассивДанных Цикл

		Если Лев(Данные, 1) = "@" Тогда
			ПутьКФайлу = Сред(Данные, 2);
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанныеИзФайла.Добавить(ПутьКФайлу);
		Иначе
			ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(Данные);
		КонецЕсли;
	
	КонецЦикла;

	// --data-raw
	МассивДанных = Команда.ЗначениеОпции("data-raw");

	Для Каждого Данные Из МассивДанных Цикл
		ОписаниеЗапроса.ОтправляемыеТекстовыеДанные.Добавить(Данные);
	КонецЦикла;

	// --data-binary
	МассивДанных = Команда.ЗначениеОпции("data-binary");
	Для Каждого ПутьКФайлу Из МассивДанных Цикл		
		Если Лев(ПутьКФайлу, 1) = "@" Тогда
			ПутьКФайлу = Сред(ПутьКФайлу, 2);
		КонецЕсли;

		ОписаниеЗапроса.ОтправляемыеДвоичныеДанныеИзФайла.Добавить(ПутьКФайлу);
	КонецЦикла;

	// T, --upload-file
	МассивДанных = Команда.ЗначениеОпции("T");

	Для Каждого Данные Из МассивДанных Цикл
		ОписаниеЗапроса.ОтправляемыеДвоичныеДанныеИзФайла.Добавить(Данные);
	КонецЦикла;

КонецПроцедуры

Функция ЕстьОпции(Команда, Опции)
	Для Каждого Опция Из СтрРазделить(Опции, ",") Цикл
		Если ЗначениеЗаполнено(Команда.ЗначениеОпции(Опция)) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;
КонецФункции

Функция ЕстьОпцииГруппыData(Команда)
	Возврат ЕстьОпции(Команда, "d,data,data-raw,data-binary");
КонецФункции

#КонецОбласти