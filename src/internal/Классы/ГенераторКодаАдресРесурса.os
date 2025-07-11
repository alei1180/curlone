
Перем _ОписаниеЗапроса; // ОписаниеЗапроса
Перем _СтруктураURL; // ПарсерURL
Перем _ТекстовыеДанные; // Массив из ПередаваемыйТекст
Перем _ПрочитанныеФайлы; // Массив из Структура:
                         //   - ПередаваемыйФайл - см. ПередаваемыйФайл
                         //   - ИмяПеременной - Строка
Перем _Конструктор; // КонструкторПрограммногоКода
Перем _РазделительПараметров; // Строка
Перем _КонкатенацияСПереносомСтрокиИРазделителем; // Строка
Перем _КонкатенацияСПереносомСтроки; // Строка

Процедура ПриСозданииОбъекта(
		ОписаниеЗапроса,
		СтруктураURL,
		ТекстовыеДанные = Неопределено,
		ПрочитанныеФайлы = Неопределено
	)

	_ОписаниеЗапроса = ОписаниеЗапроса;
	_СтруктураURL = СтруктураURL;
	_ТекстовыеДанные = ТекстовыеДанные;
	_ПрочитанныеФайлы = ПрочитанныеФайлы;
	_Конструктор = Новый КонструкторПрограммногоКода(_ОписаниеЗапроса.ИменаПеременных);

	_РазделительПараметров = "&";
	_КонкатенацияСПереносомСтрокиИРазделителем = "
	|	+ ""%1"" + ";
	_КонкатенацияСПереносомСтроки = "
	|	+ ";

КонецПроцедуры

#Область ПрограммныйИнтерфейс

Функция Получить() Экспорт

	ПараметрыЗапросаСтрокой = ПараметрыЗапросаСтрокой();
	ПараметрыЗапросаИзФайловСтрокой = ПараметрыЗапросаИзФайловСтрокой();

	ЕстьПараметрыЗапроса = Не ПустаяСтрока(ПараметрыЗапросаСтрокой) Или Не ПустаяСтрока(ПараметрыЗапросаИзФайловСтрокой);

	Адрес = _СтруктураURL.Путь + ?(ЕстьПараметрыЗапроса, "?", "") + ПараметрыЗапросаСтрокой;
	Фрагмент = ?(Не ПустаяСтрока(_СтруктураURL.Фрагмент), "#" + _СтруктураURL.Фрагмент, "");

	Если ПустаяСтрока(ПараметрыЗапросаИзФайловСтрокой) Тогда
		Возврат АдресРесурсаБезПараметровИзФайла(Адрес, Фрагмент);
	Иначе
		Возврат АдресРесурсаСПараметрамиИзФайла(Адрес, Фрагмент, ПараметрыЗапросаСтрокой, ПараметрыЗапросаИзФайловСтрокой);
	КонецЕсли;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция АдресРесурсаБезПараметровИзФайла(Адрес, Фрагмент)
			
	Результат = Адрес + Фрагмент;
		
	Если ЗначениеЗаполнено(Результат) Тогда
		Результат = _Конструктор.ПараметрВСтроку(Результат);
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция АдресРесурсаСПараметрамиИзФайла(Адрес, Фрагмент, ПараметрыЗапросаСтрокой, ПараметрыЗапросаИзФайловСтрокой)
			
	ВозможноОднойСтрокой = ПустаяСтрока(Фрагмент) И СтрЧислоСтрок(ПараметрыЗапросаИзФайловСтрокой) = 1;

	Если ВозможноОднойСтрокой Тогда
		Возврат АдресРесурсаСПараметрамиИзФайлаОднострочный(Адрес, ПараметрыЗапросаСтрокой, ПараметрыЗапросаИзФайловСтрокой);
	Иначе
		Возврат АдресРесурсаСПараметрамиИзФайлаМногострочный(
			Адрес,
			Фрагмент,
			ПараметрыЗапросаСтрокой,
			ПараметрыЗапросаИзФайловСтрокой
		);
	КонецЕсли;

КонецФункции

Функция АдресРесурсаСПараметрамиИзФайлаОднострочный(Адрес, ПараметрыЗапросаСтрокой, ПараметрыЗапросаИзФайловСтрокой)

	Возврат ""
		+ _Конструктор.ПараметрВСтроку(Адрес + ?(ПустаяСтрока(ПараметрыЗапросаСтрокой), "", _РазделительПараметров))
		+ " + "
		+ ПараметрыЗапросаИзФайловСтрокой;

КонецФункции

Функция АдресРесурсаСПараметрамиИзФайлаМногострочный(
	Адрес,
	Фрагмент,
	ПараметрыЗапросаСтрокой,
	ПараметрыЗапросаИзФайловСтрокой)

	Результат = _Конструктор.ПараметрВСтроку(Адрес);

	Если ПустаяСтрока(ПараметрыЗапросаСтрокой) Тогда
		Результат = Результат 
			+ _КонкатенацияСПереносомСтроки 
			+ ПараметрыЗапросаИзФайловСтрокой;
	ИначеЕсли Лев(ПараметрыЗапросаИзФайловСтрокой, 1) = """" Тогда
		Результат = Результат 
			+ _КонкатенацияСПереносомСтроки
			+ """" + _РазделительПараметров
			+ Сред(ПараметрыЗапросаИзФайловСтрокой, 2);
	Иначе
		Результат = Результат 
			+ СтрШаблон(_КонкатенацияСПереносомСтрокиИРазделителем, _РазделительПараметров)
			+ ПараметрыЗапросаИзФайловСтрокой;
	КонецЕсли;

	Если Не ПустаяСтрока(Фрагмент) Тогда
		Результат = Результат 
			+ _КонкатенацияСПереносомСтроки
			+ _Конструктор.ПараметрВСтроку(Фрагмент);
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция ПараметрыЗапросаСтрокой()
	
	ПараметрыЗапроса = Новый Массив();

	Для Каждого Параметр Из _СтруктураURL.ПараметрыЗапроса Цикл

		Если ЗначениеЗаполнено(Параметр.Значение) Тогда
			КлючИЗначение = СтрШаблон("%1=%2", 
				КодироватьСтроку(Параметр.Ключ, СпособКодированияСтроки.КодировкаURL),
				КодироватьСтроку(Параметр.Значение, СпособКодированияСтроки.КодировкаURL));
		Иначе
			КлючИЗначение = КодироватьСтроку(Параметр.Ключ, СпособКодированияСтроки.КодировкаURL);
		КонецЕсли;

		ПараметрыЗапроса.Добавить(КлючИЗначение);

	КонецЦикла;

	ДополнитьПараметрыЗапроса(ПараметрыЗапроса);

	Возврат СтрСоединить(ПараметрыЗапроса);

КонецФункции

Процедура ДополнитьПараметрыЗапроса(ПараметрыЗапроса)
		
	Если _ТекстовыеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Для Каждого ПередаваемыйТекст Из _ТекстовыеДанные Цикл
		Если ПередаваемыйТекст.Назначение = НазначенияПередаваемыхДанных.СтрокаЗапроса Тогда

			Если ПараметрыЗапроса.Количество() И Не ПустаяСтрока(ПередаваемыйТекст.РазделительТелаЗапроса) Тогда
				ПараметрыЗапроса.Добавить(ПередаваемыйТекст.РазделительТелаЗапроса);
			КонецЕсли;

			ПараметрыЗапроса.Добавить(ПередаваемыйТекст.ПолноеЗначение());

		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Функция ПараметрыЗапросаИзФайловСтрокой()
		
	ПараметрыЗапросаИзФайловСтрокой = "";
	Если _ПрочитанныеФайлы = Неопределено Тогда
		Возврат ПараметрыЗапросаИзФайловСтрокой;
	КонецЕсли;

	Для Каждого ПрочитанныйФайл Из _ПрочитанныеФайлы Цикл
		
		ПередаваемыйФайл = ПрочитанныйФайл.ПередаваемыйФайл;

		Если ПередаваемыйФайл.Назначение = НазначенияПередаваемыхДанных.СтрокаЗапроса Тогда

			Если ЗначениеЗаполнено(ПередаваемыйФайл.ИмяПоля) Тогда
				Префикс = ПередаваемыйФайл.ИмяПоля + "=";
				ПрефиксВКоде = _Конструктор.ПараметрВСтроку(Префикс) + " + ";
			Иначе
				Префикс = "";
				ПрефиксВКоде = "";
			КонецЕсли;

			ИмяПеременной = ПрочитанныйФайл.ИмяПеременной;

			Если ПараметрыЗапросаИзФайловСтрокой = "" Тогда
				ПараметрыЗапросаИзФайловСтрокой = ПрефиксВКоде + ИмяПеременной;
			Иначе
				ПараметрыЗапросаИзФайловСтрокой = ПараметрыЗапросаИзФайловСтрокой
					+ СтрШаблон(_КонкатенацияСПереносомСтрокиИРазделителем, _РазделительПараметров + Префикс)
					+ ИмяПеременной;
			КонецЕсли;

		КонецЕсли;

	КонецЦикла;
	
	Возврат ПараметрыЗапросаИзФайловСтрокой;

КонецФункции

#КонецОбласти