﻿#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяФайлаЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Заголовок", НСтр("ru = 'Выберите файл'"));
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файл загрузки|*.txt;*.y??'"));
	
	ОбменДаннымиКлиент.ОбработчикВыбораФайла(ЭтотОбъект, "ИмяФайлаЗагрузки", СтандартнаяОбработка, НастройкиДиалога);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаЗагрузкиОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ПроверитьСуществованиеФайла() Тогда
		ЗапуститьПриложение(ИмяФайлаЗагрузки);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(Команда)
	
	Если Не ПроверитьСуществованиеФайла() Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеПередаваемогоФайлаЗагрузки = Новый ОписаниеПередаваемогоФайла(ИмяФайлаЗагрузки);
	
	МассивПомещаемыхФайлов = Новый Массив;
	МассивПомещаемыхФайлов.Добавить(ОписаниеПередаваемогоФайлаЗагрузки);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьДанныеЗавершение", ЭтотОбъект);
	НачатьПомещениеФайлов(ОписаниеОповещения, МассивПомещаемыхФайлов, , Ложь, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокументы(Команда)
	
	СоздатьДокументыНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьГалки(Команда)
	
	Для Каждого СтрокаТаблицыЗагрузки Из Объект.ТаблицаЗагрузки Цикл
		СтрокаТаблицыЗагрузки.Загружать = Ложь;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроставитьДату(Команда)
	
	Для Каждого Стр Из Объект.ТаблицаЗагрузки Цикл
		Стр.Дата = Формат(ДатаНовая, "ДФ=dd") + "-" + Формат(ДатаНовая, "ДФ=ММ") + "-" + Формат(ДатаНовая, "ДФ=yyyy");
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗагрузитьДанныеЗавершение(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ПомещенныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ПереданныйФайл Из ПомещенныеФайлы Цикл
		ЗаполнитьТаблицу(ПереданныйФайл.Хранение);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Функция ПроверитьСуществованиеФайла()
	
	СтандартнаяОбработка = Ложь;
	Если ПустаяСтрока(ИмяФайлаЗагрузки) Тогда
		ТекстОшибки = НСтр("ru = 'Не указано имя файла загрузки!'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстОшибки, , "ИмяФайлаЗагрузки");
		Возврат Ложь;
	КонецЕсли;
	
	Файл = Новый Файл(ИмяФайлаЗагрузки);
	Если Не Файл.Существует() Тогда
		ТекстОшибки = НСтр("ru = 'Указанный файл загрузки не существует!'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстОшибки, , "ИмяФайлаЗагрузки");
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаСервере
Функция ПреобразоватьВДату(ИсхСтр)

	Стр = СокрЛП(ИсхСтр);
	ЭтоДата = Найти(Стр, ".") или Найти(Стр, "-") или Найти(Стр, "/");
	ЭтоВремя = Найти(Стр, ":");
	Если Не ЭтоДата и Не ЭтоВремя Тогда
		Возврат Дата(1, 1, 1, 1, 1, 1);
	КонецЕсли;
	МассивДат = Новый Массив;
	МассивВремени = Новый Массив;
	врСтр = "";
	Для а = 1 По СтрДлина(Стр) Цикл
		Если (Сред(Стр, а, 1) = "." или Сред(Стр, а, 1) = "-" или Сред(Стр, а, 1) = "/") и ЭтоДата Тогда
			МассивДат.Добавить(Число(врСтр));
			врСтр = "";
		ИначеЕсли Сред(Стр, а, 1) = ":" и Не ЭтоДата Тогда
			МассивВремени.Добавить(Число(врСтр));
			врСтр = "";
		ИначеЕсли Сред(Стр, а, 1) = " " или КодСимвола(Сред(Стр, а, 1)) < 48 или КодСимвола(Сред(Стр, а, 1)) > 57 Тогда
			Если МассивДат.Количество() > 0 и МассивДат.Количество() < 3 и врСтр <> "" Тогда
				МассивДат.Добавить(Число(врСтр));
			КонецЕсли;
			ЭтоДата = Ложь;
			врСтр = "";
		Иначе
			врСтр = врСтр + Сред(Стр, а, 1);
		КонецЕсли;
	КонецЦикла;

	Если МассивВремени.Количество() > 0 и МассивВремени.Количество() < 3 и врСтр <> "" Тогда
		МассивВремени.Добавить(Число(врСтр));
	ИначеЕсли МассивДат.Количество() > 0 и МассивДат.Количество() < 3 и врСтр <> "" Тогда
		МассивДат.Добавить(Число(врСтр));
	КонецЕсли;

	врДень = 0;
	врМесяц = 0;
	врГод = 0;
	Для Каждого дСтр Из МассивДат Цикл
		Если врДень <> 0 и врМесяц <> 0 Тогда
			врГод = дСтр;
		ИначеЕсли врГод <> 0 и врМесяц <> 0 Тогда
			врДень = дСтр;
		ИначеЕсли врГод <> 0 или врДень <> 0 Тогда
			врМесяц = дСтр;
		КонецЕсли;
		Если дСтр / 100 > 1 Тогда
			врГод = дСтр;
		КонецЕсли;
		Если врГод = 0 и врДень = 0 Тогда
			врДень = дСтр;
		КонецЕсли;
	КонецЦикла;

	врЧас = 0;
	врМин = 0;
	врСек = 0;
	Для Каждого вСтр из МассивВремени Цикл
		Если врЧас = 0 Тогда
			врЧас = вСтр;
		ИначеЕсли врМин = 0 Тогда
			врМин = вСтр;
		ИначеЕсли врСек = 0 Тогда
			врСек = вСтр;
		КонецЕсли;
	КонецЦикла;
	Если врГод = 0 или врГод > 9999 Тогда
		врГод = 1;
	ИначеЕсли врГод / 100 < 1 Тогда
		врГод = врГод + 2000;
	КонецЕсли;
	
	Если врМесяц = 0 или врМесяц > 12 Тогда
		врМесяц = 1;
	КонецЕсли;
	Если врДень = 0 или врДень > 31 Тогда
		врДень = 1;
	КонецЕсли;
	Если врЧас > 23 Тогда
		врЧас = 0;
	КонецЕсли;
	Если врМин > 59 Тогда
		врМин = 0;
	КонецЕсли;
	Если врСек > 59 Тогда
		врСек = 0;
	КонецЕсли;
	Возврат Дата(врГод, врМесяц, врДень, врЧас, врМин, врСек);

КонецФункции

&НаСервере
Процедура ЗаполнитьТаблицу(АдресФайла)
	
	Попытка
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
		ЧтениеДанных = Новый ЧтениеДанных(ДвоичныеДанные, КодировкаТекста.UTF8);
        ЧтениеТекста = Новый ЧтениеТекста(ЧтениеДанных.ИсходныйПоток());
        ТекстФайлаЗагрузки = ЧтениеТекста.Прочитать();
	Исключение
		ШаблонОшибки = НСтр("ru = 'Не удалось прочитать файл загрузки. %1'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат;
	КонецПопытки;
	
	Объект.ТаблицаЗагрузки.Очистить();
	МассивСтрокФайлаЗагрузки = СтрРазделить(ТекстФайлаЗагрузки, Символы.ПС, Ложь);
	ВерхняяГраницаМассиваЗагрузки = МассивСтрокФайлаЗагрузки.ВГраница();
	
	Если ВерхняяГраницаМассиваЗагрузки = -1 Тогда
		ТекстСообщения = НСтр("ru = 'Файл загрузки пустой!'");
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	// Получим структуру настроек файла загрузки
	СтруктураНастроекФайлаЗагрузки = Новый Структура;
	СтруктураНастроекФайлаЗагрузки.Вставить("Дата", 0);
	СтруктураНастроекФайлаЗагрузки.Вставить("Время", 1);
	СтруктураНастроекФайлаЗагрузки.Вставить("НомерЛС", 5);
	СтруктураНастроекФайлаЗагрузки.Вставить("ФИО", 6);
	СтруктураНастроекФайлаЗагрузки.Вставить("Комментарий", 7);
	СтруктураНастроекФайлаЗагрузки.Вставить("Сумма", 9);
	
	Для ИндексЗагружаемойСтроки = 0 По ВерхняяГраницаМассиваЗагрузки Цикл
		ЗагружаемаяСтрока = МассивСтрокФайлаЗагрузки.Получить(ИндексЗагружаемойСтроки);
		МассивЗагружаемойСтроки = ПолучитьМассивСтроки(ЗагружаемаяСтрока);
		
		Если МассивЗагружаемойСтроки = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = Объект.ТаблицаЗагрузки.Добавить();
		НоваяСтрока.Загружать = Истина;
		
		Для Каждого НастройкаЗагрузки Из СтруктураНастроекФайлаЗагрузки Цикл
			НоваяСтрока[НастройкаЗагрузки.Ключ] = МассивЗагружаемойСтроки[НастройкаЗагрузки.Значение];
		КонецЦикла;
		
		ЗапросНаПоискЛС = Новый Запрос;
		ЗапросНаПоискЛС.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	КУ_ЛицевыеСчета.Ссылка КАК Ссылка,
			|	КУ_ЛицевыеСчета.Контрагент КАК Контрагент
			|ИЗ
			|	Справочник.КУ_ЛицевыеСчета КАК КУ_ЛицевыеСчета
			|ГДЕ
			|	НЕ КУ_ЛицевыеСчета.ПометкаУдаления
			|	И КУ_ЛицевыеСчета.НомерЛицевогоСчета = &НомерЛицевогоСчета";
		
		ЗапросНаПоискЛС.УстановитьПараметр("НомерЛицевогоСчета", НоваяСтрока.НомерЛС);
		Выборка = ЗапросНаПоискЛС.Выполнить().Выбрать();
		
		Если Выборка.Следующий() Тогда
			НоваяСтрока.ЛС = Выборка.Ссылка;
			НоваяСтрока.Контрагент = Выборка.Контрагент;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивСтроки(ЗагружаемаяСтрока)
	
	Если ПустаяСтрока(ЗагружаемаяСтрока) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	РазделительПолей = ";";
	МассивЗагружаемойСтроки = СтрРазделить(ЗагружаемаяСтрока, РазделительПолей, Истина);
	
	ТребуемоеКоличествоЗначенийВСтроке = 12;
	ТекущееКоличествоЗначенийВСтроке = МассивЗагружаемойСтроки.Количество();
	
	Если ТекущееКоличествоЗначенийВСтроке < ТребуемоеКоличествоЗначенийВСтроке Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ТекущееКоличествоЗначенийВСтроке = ТребуемоеКоличествоЗначенийВСтроке Тогда
		Возврат МассивЗагружаемойСтроки;
	КонецЕсли;
	
	// Возможно наш реестр содержит информацию по счетчикм и начислениям. Удалим ее
	Для ИндексМассива = 9 По МассивЗагружаемойСтроки.ВГраница() - 5 Цикл
		МассивЗагружаемойСтроки.Удалить(9);
	КонецЦикла;
	
	Возврат МассивЗагружаемойСтроки;
	
КонецФункции

&НаСервере
Функция ПолучитьДоговор(Элемент)
	
	ЗапросКонтрагента = Новый Запрос;
	ЗапросКонтрагента.УстановитьПараметр("Контрагент", Элемент);
	ЗапросКонтрагента.УстановитьПараметр("Организация", Объект.Организация);
	ЗапросКонтрагента.УстановитьПараметр("ВидДоговора", Перечисления.ВидыДоговоровКонтрагентов.СПокупателем);
	ЗапросКонтрагента.Текст =
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
		|	ДоговорыКонтрагентов.Наименование КАК Наименование
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Владелец = &Контрагент
		|	И ДоговорыКонтрагентов.Организация = &Организация
		|	И ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора";
	Выборка = ЗапросКонтрагента.Выполнить().Выбрать();
	
	Если Выборка.Количество() > 0 Тогда
		
		Пока Выборка.Следующий() Цикл
			Если Лев(Выборка.Наименование, 3) = "Дог" Или Лев(Выборка.Наименование, 3) = "УМД" Тогда
				Возврат Выборка.Ссылка;
			КонецЕсли;
		КонецЦикла;
		
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
		
	Иначе
		
		Договор = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
		Договор.Организация = Объект.Организация;
		Договор.Владелец = Элемент;
		Договор.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СПокупателем;
		Договор.Наименование = "Основной";
		Договор.ВалютаВзаиморасчетов = Справочники.Валюты.НайтиПоКоду("643");
		Договор.Записать();
		
		Возврат Договор.Ссылка;
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура СоздатьДокументыНаСервере()
	
	ВсегоСтрок = Объект.ТаблицаЗагрузки.Количество();
	
	Для Каждого стр Из Объект.ТаблицаЗагрузки Цикл
		
		Если Стр.Загружать = Ложь Тогда
			Продолжить;
		КонецЕсли;
		
		Контрагент = Стр.Контрагент;
		Если Не ЗначениеЗаполнено(Контрагент) Тогда
			ШаблонОшибки = НСтр("ru = 'В строке № %1 не указан контрагент! Данная строка загружена не будет'");
			ТекстОшибки = СтрШаблон(ШаблонОшибки, Стр.НомерСтроки);
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
			Продолжить;
		КонецЕсли;
		
		Дата = Стр.Дата;
		Время = Стр.Время;
		Дата1 = СтрЗаменить(Дата, "-", ".") + " " + СтрЗаменить(Время, "-", ":");
		Дата = ПреобразоватьВДату(Дата1);
		СтатьяДвиженияДенежныхСредств = Справочники.СтатьиДвиженияДенежныхСредств.НайтиПоНаименованию("Поступления от деятельности УК (ЖКХ)");
		СубконтоКт1 = Справочники.ПрочиеДоходыИРасходы.НайтиПоНаименованию("Расходы на услуги банков");
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ПоступлениеНаРасчетныйСчет.Ссылка КАК Ссылка
			|ИЗ
			|	Документ.ПоступлениеНаРасчетныйСчет КАК ПоступлениеНаРасчетныйСчет
			|ГДЕ
			|	ПоступлениеНаРасчетныйСчет.Дата = &Дата
			|	И ПоступлениеНаРасчетныйСчет.Организация = &Организация
			|	И ПоступлениеНаРасчетныйСчет.Контрагент = &Контрагент
			|	И ПоступлениеНаРасчетныйСчет.СуммаДокумента = &СуммаДокумента
			|	И ПоступлениеНаРасчетныйСчет.СчетОрганизации = &СчетОрганизации";
		
		Запрос.УстановитьПараметр("Дата", Дата);
		Запрос.УстановитьПараметр("Организация", Объект.Организация);
		Запрос.УстановитьПараметр("Контрагент", Контрагент);
		Запрос.УстановитьПараметр("СчетОрганизации", Объект.БанковскийСчет);
		Запрос.УстановитьПараметр("СуммаДокумента", Стр.Сумма);
		
		Если Не Запрос.Выполнить().Пустой() Тогда
			
			Продолжить;
			
		Иначе
			
			ЗапросКомментарий = Новый Запрос;
			ЗапросКомментарий.Текст = "ВЫБРАТЬ
				|	ПоступлениеНаРасчетныйСчет.Ссылка КАК Ссылка
				|ИЗ
				|	Документ.ПоступлениеНаРасчетныйСчет КАК ПоступлениеНаРасчетныйСчет
				|ГДЕ
				|	ПоступлениеНаРасчетныйСчет.Дата = &Дата
				|	И ПоступлениеНаРасчетныйСчет.Организация = &Организация
				|	И ПоступлениеНаРасчетныйСчет.СуммаДокумента = &СуммаДокумента
				|	И ПоступлениеНаРасчетныйСчет.СчетОрганизации = &СчетОрганизации
				|	И ПоступлениеНаРасчетныйСчет.Комментарий ПОДОБНО &Комментарий";
			ЗапросКомментарий.УстановитьПараметр("Дата", Дата);
			ЗапросКомментарий.УстановитьПараметр("Организация", Объект.Организация);
			ЗапросКомментарий.УстановитьПараметр("Комментарий", Стр.НомерЛС);
			ЗапросКомментарий.УстановитьПараметр("СчетОрганизации", Объект.БанковскийСчет);
			ЗапросКомментарий.УстановитьПараметр("СуммаДокумента", Стр.Сумма);
			
			Если Не ЗапросКомментарий.Выполнить().Пустой() Тогда
				
				Продолжить;
				
			Иначе
				
				ДокументПП = Документы.ПоступлениеНаРасчетныйСчет.СоздатьДокумент();
				ДокументПП.Организация = Объект.Организация;
				ДокументПП.Дата = Дата;
				ДокументПП.СуммаДокумента = Стр.Сумма;
				ДокументПП.НазначениеПлатежа = Стр.Комментарий;
				ДокументПП.ДатаВходящегоДокумента = Дата;
				ДокументПП.ВидОперации = Перечисления.ВидыОперацийПоступлениеДенежныхСредств.ОплатаПокупателя;
				ДокументПП.Организация = Объект.Организация;
				ДокументПП.СчетОрганизации = Объект.БанковскийСчет;
				ДокументПП.Контрагент = Контрагент;
				ДокументПП.СчетБанк = ПланыСчетов.Хозрасчетный.РасчетныеСчета;
				ДокументПП.СчетУчетаРасчетовСКонтрагентом = ПланыСчетов.Хозрасчетный.ПрочиеРасходы;
				ДокументПП.СубконтоКт1 = СубконтоКт1;
				ДокументПП.ВалютаДокумента = Справочники.Валюты.НайтиПоКоду("643");
				ДокументПП.Комментарий = Стр.НомерЛС;
				ДокументПП.КУ_ЛицевойСчет = Стр.ЛС;
				
				Договор = КУ_ИнтерфейсСерверПовИсп.ПолучитьДоговорКонтрагента(Объект.Организация, Стр.ЛС, Неопределено);
				Если Не ЗначениеЗаполнено(Договор) Тогда
					Договор = ПолучитьДоговор(ДокументПП.Контрагент);
				КонецЕсли;
				
				НовыйЭлемент = ДокументПП.РасшифровкаПлатежа.Добавить();
				НовыйЭлемент.СтавкаНДС = Перечисления.СтавкиНДС.БезНДС;
				НовыйЭлемент.СуммаПлатежа = Стр.Сумма;
				НовыйЭлемент.СуммаВзаиморасчетов = Стр.Сумма;
				НовыйЭлемент.СтатьяДвиженияДенежныхСредств = СтатьяДвиженияДенежныхСредств;
				НовыйЭлемент.ДоговорКонтрагента = Договор;
				НовыйЭлемент.СпособПогашенияЗадолженности = Перечисления.СпособыПогашенияЗадолженности.Автоматически;
				НовыйЭлемент.СчетУчетаРасчетовСКонтрагентом = ПланыСчетов.Хозрасчетный.РасчетыСПрочимиПокупателямиИЗаказчиками;
				НовыйЭлемент.СчетУчетаРасчетовПоАвансам = ПланыСчетов.Хозрасчетный.РасчетыСПрочимиПокупателямиИЗаказчиками;
				НовыйЭлемент.КурсВзаиморасчетов = 1;
				НовыйЭлемент.ПорядокОтраженияАванса = Перечисления.ПорядокОтраженияАвансов.ДоходУСН;
				
				ДокументПП.КУ_ЗаполнитьЗадолженность(Истина, Неопределено, Стр.ЛС);
				ДокументПП.КУ_РаспределитьСуммуОплаты(Ложь);
				
				Отбор = Новый Структура;
				Отбор.Вставить("ДоговорКонтрагента", Справочники.ДоговорыКонтрагентов.ПустаяСсылка());
				МассивПустыхСтрок = ДокументПП.КУ_ВидыНачислений.НайтиСтроки(Отбор);
				
				Для каждого СтрокаМассива Из МассивПустыхСтрок Цикл
					СтрокаМассива.ДоговорКонтрагента = Договор;
				КонецЦикла;
				
				ДокументПП.Записать();
				Сообщить("Создан документ: " + ДокументПП);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
