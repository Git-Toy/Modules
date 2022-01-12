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

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выгрузить(Команда)
	
	Если Не ПроверитьФайлВыгрузки() Тогда
		Возврат;
	КонецЕсли;
	
	ПолучаемыеФайлы = Новый Массив;
	ВыгрузитьРеестрНаСервере(ПолучаемыеФайлы, ИмяФайлаВыгрузки);
	
	Если ПолучаемыеФайлы.Количество() > 0 Тогда
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ВыполнитьПослеПолученияФайлов", ЭтотОбъект);
		НачатьПолучениеФайлов(ОповещениеОЗавершении, ПолучаемыеФайлы, , Ложь);
	КонецЕсли;
	
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
Процедура ВыгрузитьРеестрНаСервере(ПолучаемыеФайлы, ИмяФайла)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КУ_ЛицевыеСчета.Ссылка КАК ЛицевойСчет,
		|	КУ_ЛицевыеСчета.Помещение КАК Помещение
		|ПОМЕСТИТЬ ТаблицаЛицевыхСчетов
		|ИЗ
		|	Справочник.КУ_ЛицевыеСчета КАК КУ_ЛицевыеСчета
		|ГДЕ
		|	КУ_ЛицевыеСчета.ДатаЗакрытия = ДАТАВРЕМЯ(1, 1, 1)
		|	И КУ_ЛицевыеСчета.ГИСЖКХЕдиныйЛицевойСчет <> """"
		|	И КУ_ЛицевыеСчета.Здание В ИЕРАРХИИ(&Здание)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КУ_ВзаиморасчетыОстатки.ЛицевойСчет КАК ЛицевойСчет,
		|	КУ_ВзаиморасчетыОстатки.ВидНачисления КАК ВидНачисления,
		|	КУ_ВзаиморасчетыОстатки.СуммаНачисленияОстаток + КУ_ВзаиморасчетыОстатки.СуммаАвансаОстаток + КУ_ВзаиморасчетыОстатки.СуммаПениОстаток КАК Задолженность
		|ПОМЕСТИТЬ ТаблицаЗадолженности
		|ИЗ
		|	РегистрНакопления.КУ_Взаиморасчеты.Остатки(
		|			&ГраницаОстатков,
		|			ЛицевойСчет В
		|				(ВЫБРАТЬ
		|					ТаблицаЛицевыхСчетов.ЛицевойСчет КАК ЛицевойСчет
		|				ИЗ
		|					ТаблицаЛицевыхСчетов КАК ТаблицаЛицевыхСчетов)) КАК КУ_ВзаиморасчетыОстатки
		|ГДЕ
		|	КУ_ВзаиморасчетыОстатки.СуммаНачисленияОстаток + КУ_ВзаиморасчетыОстатки.СуммаАвансаОстаток + КУ_ВзаиморасчетыОстатки.СуммаПениОстаток <> 0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КУ_Счетчики.Ссылка КАК Счетчик
		|ПОМЕСТИТЬ ТаблицаСчетчиков
		|ИЗ
		|	Справочник.КУ_Счетчики КАК КУ_Счетчики
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТаблицаЛицевыхСчетов КАК ТаблицаЛицевыхСчетов
		|		ПО КУ_Счетчики.Помещение = ТаблицаЛицевыхСчетов.Помещение
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КУ_ПоказанияСчетчиковСрезПоследних.Счетчик КАК Счетчик,
		|	КУ_ПоказанияСчетчиковСрезПоследних.ПредыдущееПоказание КАК ПредыдущееПоказание
		|ПОМЕСТИТЬ ТаблицаПоказанийСчетчиков
		|ИЗ
		|	РегистрСведений.КУ_ПоказанияСчетчиков.СрезПоследних(
		|			&ГраницаОстатков,
		|			Счетчик В
		|				(ВЫБРАТЬ
		|					ТаблицаСчетчиков.Счетчик КАК Счетчик
		|				ИЗ
		|					ТаблицаСчетчиков КАК ТаблицаСчетчиков)) КАК КУ_ПоказанияСчетчиковСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	1 КАК Порядок,
		|	""Счетчик"" КАК ТипПоказателя,
		|	КУ_Счетчики.Помещение КАК Помещение,
		|	КУ_Счетчики.Код КАК КодПоказателя,
		|	КУ_Счетчики.Ссылка КАК НаименованиеПоказателя,
		|	ТаблицаПоказанийСчетчиков.ПредыдущееПоказание КАК ЗначениеПоказателя
		|ПОМЕСТИТЬ ТаблицаПоказателей
		|ИЗ
		|	ТаблицаПоказанийСчетчиков КАК ТаблицаПоказанийСчетчиков
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_Счетчики КАК КУ_Счетчики
		|		ПО ТаблицаПоказанийСчетчиков.Счетчик = КУ_Счетчики.Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	2,
		|	""Разделитель"",
		|	КУ_Счетчики.Помещение,
		|	"""",
		|	"""",
		|	0
		|ИЗ
		|	ТаблицаПоказанийСчетчиков КАК ТаблицаПоказанийСчетчиков
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_Счетчики КАК КУ_Счетчики
		|		ПО ТаблицаПоказанийСчетчиков.Счетчик = КУ_Счетчики.Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	КУ_Счетчики.Помещение
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	3,
		|	""Услуга"",
		|	КУ_ЛицевыеСчета.Помещение,
		|	КУ_ВидыНачисленийНаЖилье.Код,
		|	КУ_ВидыНачисленийНаЖилье.Ссылка,
		|	ТаблицаЗадолженности.Задолженность
		|ИЗ
		|	ТаблицаЗадолженности КАК ТаблицаЗадолженности
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_ЛицевыеСчета КАК КУ_ЛицевыеСчета
		|		ПО ТаблицаЗадолженности.ЛицевойСчет = КУ_ЛицевыеСчета.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_ВидыНачисленийНаЖилье КАК КУ_ВидыНачисленийНаЖилье
		|		ПО ТаблицаЗадолженности.ВидНачисления = КУ_ВидыНачисленийНаЖилье.Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаЗадолженности.ЛицевойСчет КАК ЛицевойСчет,
		|	СУММА(ТаблицаЗадолженности.Задолженность) КАК Задолженность
		|ПОМЕСТИТЬ ТаблицаИтоговойЗадолженности
		|ИЗ
		|	ТаблицаЗадолженности КАК ТаблицаЗадолженности
		|
		|СГРУППИРОВАТЬ ПО
		|	ТаблицаЗадолженности.ЛицевойСчет
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КУ_ЛицевыеСчета.Ссылка КАК ЛицевойСчет,
		|	КУ_ЛицевыеСчета.Наименование КАК ФИОПлательщика,
		|	КУ_ЛицевыеСчета.ГИСЖКХЕдиныйЛицевойСчет КАК ЕдиныйЛицевойСчет,
		|	КУ_ЛицевыеСчета.НомерЛицевогоСчета КАК НомерЛицевогоСчета,
		|	КУ_ЖилыеЗдания.КодДомаПоФИАС КАК КодДомаПоФИАС,
		|	ВЫРАЗИТЬ(КУ_ЖилыеЗдания.Адрес КАК СТРОКА(1000)) КАК Адрес,
		|	КУ_ПомещенияЖилогоДома.НомерКвартиры КАК НомерКвартиры,
		|	ТаблицаИтоговойЗадолженности.Задолженность КАК Задолженность,
		|	ТаблицаПоказателей.ТипПоказателя КАК ТипПоказателя,
		|	ТаблицаПоказателей.КодПоказателя КАК КодПоказателя,
		|	ТаблицаПоказателей.НаименованиеПоказателя КАК НаименованиеПоказателя,
		|	ТаблицаПоказателей.ЗначениеПоказателя КАК ЗначениеПоказателя
		|ИЗ
		|	ТаблицаИтоговойЗадолженности КАК ТаблицаИтоговойЗадолженности
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_ЛицевыеСчета КАК КУ_ЛицевыеСчета
		|		ПО ТаблицаИтоговойЗадолженности.ЛицевойСчет = КУ_ЛицевыеСчета.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_ПомещенияЖилогоДома КАК КУ_ПомещенияЖилогоДома
		|		ПО (КУ_ЛицевыеСчета.Помещение = КУ_ПомещенияЖилогоДома.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КУ_ЖилыеЗдания КАК КУ_ЖилыеЗдания
		|		ПО (КУ_ЛицевыеСчета.Здание = КУ_ЖилыеЗдания.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаПоказателей КАК ТаблицаПоказателей
		|		ПО (КУ_ЛицевыеСчета.Помещение = ТаблицаПоказателей.Помещение)
		|
		|УПОРЯДОЧИТЬ ПО
		|	ЛицевойСчет,
		|	ТаблицаПоказателей.Порядок
		|ИТОГИ
		|	МАКСИМУМ(КодДомаПоФИАС),
		|	МАКСИМУМ(Адрес),
		|	МАКСИМУМ(НомерКвартиры),
		|	МАКСИМУМ(Задолженность)
		|ПО
		|	ЛицевойСчет";
	
	Если ЗначениеЗаполнено(Здание) Тогда
		Запрос.УстановитьПараметр("Здание", Здание);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "И КУ_ЛицевыеСчета.Здание В ИЕРАРХИИ(&Здание)", "");
	КонецЕсли;
	
	ГраницаОстатков = Новый Граница(КонецДня(ДатаРеестра), ВидГраницы.Включая);
	Запрос.УстановитьПараметр("ГраницаОстатков", ГраницаОстатков);
	
	ПериодОплаты = Формат(ДатаРеестра, "ДФ=MMyyyy");
	МассивВыгружаемыхДанных = Новый Массив;
	
	ВыборкаПоЛицевымСчетам = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаПоЛицевымСчетам.Следующий() Цикл
		МассивВыгружаемойСтроки = Новый Массив;
		
		// ФИО
		ФИОПлательщика = СокрЛП(ВыборкаПоЛицевымСчетам.ФИОПлательщика);
		МассивВыгружаемойСтроки.Добавить(ФИОПлательщика);
		
		// ЕЛС - Единый лицевой счет плательщика
		ЕдиныйЛицевойСчет = СокрЛП(ВыборкаПоЛицевымСчетам.ЕдиныйЛицевойСчет);
		МассивВыгружаемойСтроки.Добавить(ЕдиныйЛицевойСчет);
		
		// Код ФИАС
		КодДомаПоФИАС = СокрЛП(ВыборкаПоЛицевымСчетам.КодДомаПоФИАС);
		НомерКвартиры = ВыборкаПоЛицевымСчетам.НомерКвартиры;
		
		Если НомерКвартиры > 0 Тогда
			КодДомаПоФИАС = КодДомаПоФИАС + "," + Формат(НомерКвартиры, "ЧГ="); 
		КонецЕсли;
		
		МассивВыгружаемойСтроки.Добавить(КодДомаПоФИАС);
		
		// Адрес
		Адрес = СокрЛП(ВыборкаПоЛицевымСчетам.Адрес);
		МассивВыгружаемойСтроки.Добавить(Адрес);
		
		// Номер лицевого счета плательщика
		НомерЛицевогоСчета = СокрЛП(ВыборкаПоЛицевымСчетам.НомерЛицевогоСчета);
		МассивВыгружаемойСтроки.Добавить(НомерЛицевогоСчета);
		
		// Сумма задолженности
		СуммаЗадолженности = Формат(ВыборкаПоЛицевымСчетам.Задолженность, "ЧДЦ=2; ЧРД=.; ЧГ=");
		МассивВыгружаемойСтроки.Добавить(СуммаЗадолженности);
		
		// Период оплаты (формат ммгггг)
		МассивВыгружаемойСтроки.Добавить(ПериодОплаты);
		
		МассивПоказателей = Новый Массив;
		
		ВыборкаПоПоказателям = ВыборкаПоЛицевымСчетам.Выбрать();
		Пока ВыборкаПоПоказателям.Следующий() Цикл
			ТипПоказателя = ВыборкаПоПоказателям.ТипПоказателя;
			Если ТипПоказателя = "Счетчик" Тогда
				// Код счетчика
				КодСчетчика = СокрЛП(ВыборкаПоПоказателям.КодПоказателя);
				МассивПоказателей.Добавить(КодСчетчика);
				
				// Наименование счетчика
				НаименованиеСчетчика = СокрЛП(ВыборкаПоПоказателям.НаименованиеПоказателя);
				МассивПоказателей.Добавить(НаименованиеСчетчика);
				
				// Предыдущее показание счетчика
				ЗначениеПоказателя = Формат(ВыборкаПоПоказателям.ЗначениеПоказателя, "ЧДЦ=3; ЧРД=.; ЧГ=");
		        МассивПоказателей.Добавить(ЗначениеПоказателя);
			ИначеЕсли ТипПоказателя = "Услуга" Тогда
				// Код услуги
				КодУслуги = СокрЛП(ВыборкаПоПоказателям.КодПоказателя);
				МассивПоказателей.Добавить(КодУслуги);
				
				// Наименование услуги
				НаименованиеУслуги = СокрЛП(ВыборкаПоПоказателям.НаименованиеПоказателя);
				МассивПоказателей.Добавить(НаименованиеУслуги);
				
				// Сумма к оплате по услуге
				ЗначениеПоказателя = Формат(ВыборкаПоПоказателям.ЗначениеПоказателя, "ЧДЦ=2; ЧРД=.; ЧГ=");
		        МассивПоказателей.Добавить(ЗначениеПоказателя);
			Иначе
				МассивПоказателей.Добавить("[!]");
			КонецЕсли;
		КонецЦикла;
		
		// Показатели - счетчики и услуги
		СтрокаПоказателей = СтрСоединить(МассивПоказателей, ":");
		МассивВыгружаемойСтроки.Добавить(СтрокаПоказателей);
		
		// Пустое поле
		МассивВыгружаемойСтроки.Добавить("");
		
		// Скрытие кодов услуг. Если требуется скрыть, то проставляется значение "1", иначе оставить поле пустым.
		МассивВыгружаемойСтроки.Добавить("1");
		
		ВыгружаемаяСтрока = СтрСоединить(МассивВыгружаемойСтроки, ";");
		МассивВыгружаемыхДанных.Добавить(ВыгружаемаяСтрока);
	КонецЦикла;
	
	СохраняемыйТекст = СтрСоединить(МассивВыгружаемыхДанных, Символы.ПС);
	СохранитьТекстВФайл(ПолучаемыеФайлы, СохраняемыйТекст, ИмяФайла);
	
КонецПроцедуры

&НаСервере
Процедура СохранитьТекстВФайл(ПолучаемыеФайлы, СохраняемыйТекст, ИмяФайла)
	
	ПотокПамяти = Новый ПотокВПамяти;
	ЗаписьДанных = Новый ЗаписьДанных(ПотокПамяти);
	ЗаписьДанных.ЗаписатьСимволы(СохраняемыйТекст);
	ЗаписьДанных.Закрыть();
	
	ДвоичныеДанные = ПотокПамяти.ЗакрытьИПолучитьДвоичныеДанные();
	АдресФайлаВХранилище = ПоместитьВоВременноеХранилище(ДвоичныеДанные, Новый УникальныйИдентификатор);
	ОписаниеПередаваемогоФайла = Новый ОписаниеПередаваемогоФайла(ИмяФайла, АдресФайлаВХранилище);
	ПолучаемыеФайлы.Добавить(ОписаниеПередаваемогоФайла);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПослеПолученияФайлов(ПолученныеФайлы, ДополнительныеПараметры) Экспорт
	
	Для Каждого Файл Из ПолученныеФайлы Цикл
		УдалитьИзВременногоХранилища(Файл.Хранение);
	КонецЦикла;
	
	ТекстСообщения = НСтр("ru = 'Выгрузка завершена'");
	ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры

#КонецОбласти