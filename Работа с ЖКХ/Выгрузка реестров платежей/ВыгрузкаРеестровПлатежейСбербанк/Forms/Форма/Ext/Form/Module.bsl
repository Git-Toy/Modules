﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ТекущаяДата = ОбщегоНазначенияКлиент.ДатаСеанса();
	ДатаРеестра = КонецМесяца(ТекущаяДата);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяФайлаВыгрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Заголовок", НСтр("ru = 'Выберите файл'"));
	НастройкиДиалога.Вставить("Фильтр", "txt (*.txt)|*.txt");
	НастройкиДиалога.Вставить("ПроверятьСуществованиеФайла", Ложь);
	
	ОбменДаннымиКлиент.ОбработчикВыбораФайла(ЭтотОбъект, "ИмяФайлаВыгрузки", СтандартнаяОбработка, НастройкиДиалога);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаВыгрузкиОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ПроверитьФайлВыгрузки(Истина) Тогда
		ЗапуститьПриложение(ИмяФайлаВыгрузки);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыРеестр

&НаКлиенте
Процедура РеестрЛицевойСчетПриИзменении(Элемент)
	
	НоваяСтрока = ЭтаФорма.Элементы.Реестр.ТекущиеДанные;
	Если НоваяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЛицевойСчет = НоваяСтрока.ЛицевойСчет;
	Если Не ЗначениеЗаполнено(ЛицевойСчет) Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураРеквизитов = ПолучитьРеквизитыЛицевогоСчета(ЛицевойСчет);
	Если СтруктураРеквизитов.Задолженность = 0 Тогда
		ШаблонОшибки = НСтр("ru = 'По лицевому счету ""%1"" нет задолженности!'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, ЛицевойСчет);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
		Объект.Реестр.Удалить(НоваяСтрока);
	Иначе
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтруктураРеквизитов);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(Команда)
	
	ЗаполнитьНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура Выгрузить(Команда)
	
	Если Не ПроверитьФайлВыгрузки() Тогда
		Возврат;
	КонецЕсли;
	
	ДокументВыгрузки = Новый ТекстовыйДокумент();
	ДатаРеестраСтрокой = Формат(ДатаРеестра, "ДФ=MMyy");
	
	Для Каждого Стр Из Объект.Реестр Цикл
		СуммаЗадолженностиСтрокой = Формат(Стр.Задолженность, "ЧЦ=15; ЧДЦ=2; ЧРД=.; ЧГ=");
		НаименованиеПомещения = "Сочи," + Стр.ПомещениеНаименование;
		
		МассивСтроки = Новый Массив;
		МассивСтроки.Добавить(Стр.НомерЛицевогоСчета);
		МассивСтроки.Добавить(Стр.ЛицевойСчетНаименование);
		МассивСтроки.Добавить(НаименованиеПомещения);
		МассивСтроки.Добавить(ДатаРеестраСтрокой);
		МассивСтроки.Добавить(СуммаЗадолженностиСтрокой);
		
		НоваяСтрока = СтрСоединить(МассивСтроки, ";");
		ДокументВыгрузки.ДобавитьСтроку(НоваяСтрока);
	КонецЦикла;
	
	ДокументВыгрузки.Записать(ИмяФайлаВыгрузки, КодировкаТекста.ANSI);
	
	ТекстСообщения = НСтр("ru = 'Выгрузка завершена'");
	ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ПроверитьФайлВыгрузки(ПроверятьНаСуществование = Ложь)
	
	СтандартнаяОбработка = Ложь;
	Если ПустаяСтрока(ИмяФайлаВыгрузки) Тогда
		ТекстОшибки = НСтр("ru = 'Не указано имя файла выгрузки!'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстОшибки, , "ИмяФайлаВыгрузки");
		Возврат Ложь;
	КонецЕсли;
	
	Если ПроверятьНаСуществование Тогда
		Файл = Новый Файл(ИмяФайлаВыгрузки);
		Если Не Файл.Существует() Тогда
			ТекстОшибки = НСтр("ru = 'Указанный файл выгрузки не существует!'");
			ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстОшибки, , "ИмяФайлаВыгрузки");
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	Объект.Реестр.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет КАК ЛицевойСчет,
		|	КУ_ВзаиморасчетыОстатки.СуммаНачисленияОстаток + КУ_ВзаиморасчетыОстатки.СуммаАвансаОстаток + КУ_ВзаиморасчетыОстатки.СуммаПениОстаток КАК Задолженность,
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет.Наименование КАК ЛицевойСчетНаименование,
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет.Помещение.Наименование КАК ПомещениеНаименование,
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет.НомерЛицевогоСчета КАК НомерЛицевогоСчета
		|ИЗ
		|	РегистрНакопления.КУ_Взаиморасчеты.Остатки(
		|			&ГраницаОстатков,
		|			ЛицевойСчет <> ЗНАЧЕНИЕ(Справочник.Ку_ЛицевыеСчета.ПустаяСсылка)
		|				И ЛицевойСчет.Здание В ИЕРАРХИИ (&Здание)) КАК КУ_ВзаиморасчетыОстатки
		|ГДЕ
		|	КУ_ВзаиморасчетыОстатки.СуммаНачисленияОстаток + КУ_ВзаиморасчетыОстатки.СуммаАвансаОстаток + КУ_ВзаиморасчетыОстатки.СуммаПениОстаток <> 0";
	
	Если ЗначениеЗаполнено(Здание) Тогда
		Запрос.УстановитьПараметр("Здание", Здание);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "И ЛицевойСчет.Здание В ИЕРАРХИИ (&Здание)", "");
	КонецЕсли;
	
	ГраницаОстатков = Новый Граница(КонецДня(ДатаРеестра), ВидГраницы.Включая);
	Запрос.УстановитьПараметр("ГраницаОстатков", ГраницаОстатков);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		НоваяСтрока = Объект.Реестр.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРеквизитыЛицевогоСчета(ЛицевойСчет)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КУ_ВзаиморасчетыОстатки.СуммаНачисленияОстаток + КУ_ВзаиморасчетыОстатки.СуммаАвансаОстаток + КУ_ВзаиморасчетыОстатки.СуммаПениОстаток КАК Задолженность,
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет.Наименование КАК ЛицевойСчетНаименование,
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет.Помещение.Наименование КАК ПомещениеНаименование,
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет.НомерЛицевогоСчета КАК НомерЛицевогоСчета
		|ИЗ
		|	РегистрНакопления.КУ_Взаиморасчеты.Остатки(
		|			&ГраницаОстатков,
		|			ЛицевойСчет = &ЛицевойСчет
		|				И ЛицевойСчет.Здание В ИЕРАРХИИ (&Здание)) КАК КУ_ВзаиморасчетыОстатки
		|ГДЕ
		|	КУ_ВзаиморасчетыОстатки.СуммаНачисленияОстаток + КУ_ВзаиморасчетыОстатки.СуммаАвансаОстаток + КУ_ВзаиморасчетыОстатки.СуммаПениОстаток <> 0";
	
	Если ЗначениеЗаполнено(Здание) Тогда
		Запрос.УстановитьПараметр("Здание", Здание);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "И ЛицевойСчет.Здание В ИЕРАРХИИ (&Здание)", "");
	КонецЕсли;
	
	ГраницаОстатков = Новый Граница(КонецДня(ДатаРеестра), ВидГраницы.Включая);
	Запрос.УстановитьПараметр("ГраницаОстатков", ГраницаОстатков);
	Запрос.УстановитьПараметр("ЛицевойСчет", ЛицевойСчет);
	Выборка = Запрос.Выполнить().Выбрать();
	
	СтруктураРезультат = Новый Структура;
	СтруктураРезультат.Вставить("Задолженность", 0);
	СтруктураРезультат.Вставить("ЛицевойСчетНаименование", "");
	СтруктураРезультат.Вставить("ПомещениеНаименование", "");
	СтруктураРезультат.Вставить("НомерЛицевогоСчета", "");
	
	Если Выборка.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(СтруктураРезультат, Выборка);
	КонецЕсли;
	
	Возврат СтруктураРезультат;
	
КонецФункции

#КонецОбласти