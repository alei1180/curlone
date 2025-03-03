#Использовать "../../core"

Перем КонвертерКомандыCURL; // см. КонвертерКомандыCURL

&Контроллер("/")
Процедура ПриСозданииОбъекта()

КонецПроцедуры

&ТочкаМаршрута("")
&Отображение("./src/interface/view/index.html")
Процедура Главная(Ответ) Экспорт

КонецПроцедуры

&ТочкаМаршрута("/api")
Процедура API(Ответ) Экспорт
	Ответ.Перенаправить("/api/v1");
КонецПроцедуры

&ТочкаМаршрута("/api/v1")
&Отображение("./src/interface/view/api.html")
Процедура APIv1() Экспорт

КонецПроцедуры

&ТочкаМаршрута("/api/v1/convert")
Процедура Конвертировать(ПараметрыЗапросаИменные, Ответ) Экспорт
	Перем Ошибки;

	Данные = Новый Структура("result, errors", "", Новый Массив());
	
	ТекстКоманды = ПараметрыЗапросаИменные.Получить("cmd");
	Язык = ПараметрыЗапросаИменные.Получить("lang");
	Локаль = ПараметрыЗапросаИменные.Получить("locale");

	Если ТекстКоманды <> Неопределено Тогда
		Если КонвертерКомандыCURL = Неопределено Тогда
			КонвертерКомандыCURL = Новый КонвертерКомандыCURL();
		КонецЕсли;
		
		КонвертерКомандыCURL.УстановитьЯзыкПеревода(Локаль);
		Генератор = ПолучитьГенератор(Язык);

		Попытка
			Данные.result = КонвертерКомандыCURL.Конвертировать(ТекстКоманды, Генератор, Ошибки);

			Для Каждого Ошибка Из Ошибки Цикл
				Данные.errors.Добавить(НоваяОшибка(Ошибка.Текст, Ошибка.Критичная));
			КонецЦикла;
		Исключение
			Данные.errors.Добавить(НоваяОшибка(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()), Истина));
		КонецПопытки;
	КонецЕсли;

	Парсер = Новый ПарсерJSON();

	Ответ.УстановитьТипКонтента("json");
	Ответ.ТелоТекст = Парсер.ЗаписатьJSON(Данные);

КонецПроцедуры

Функция ПолучитьГенератор(Язык)
	Если Язык = "connector" Тогда
		Возврат Новый ГенераторПрограммногоКодаКоннекторHTTP();
	ИначеЕсли Язык = "1c" Тогда
		Возврат Новый ГенераторПрограммногоКода1С();
	Иначе
		Возврат ГенераторПоУмолчанию();
	КонецЕсли;
КонецФункции

Функция ГенераторПоУмолчанию()
	Возврат Новый ГенераторПрограммногоКода1С();
КонецФункции

Функция НоваяОшибка(Текст, Критичная = Ложь)
	Возврат Новый Структура("text, critical", Текст, Критичная);
КонецФункции