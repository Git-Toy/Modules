﻿// BSLLS:UsingObjectNotAvailableUnix-off
#Область ПрограммныйИнтерфейс

// Возвращает сведения о внешней обработке.
//
// Возвращаемое значение:
//   Структура - Подробнее см. ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке().
//
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Наименование = ЭтотОбъект.Метаданные().Синоним;
	ПараметрыРегистрации.Информация = ЭтотОбъект.Метаданные().Комментарий;
	ПараметрыРегистрации.Версия = Формат(ТекущаяДатаСеанса(), "ДФ=dd.MM.yyyy");
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.Представление = ПараметрыРегистрации.Наименование;
	НоваяКоманда.Идентификатор = ЭтотОбъект.Метаданные().Имя;
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ЗагрузитьГруппыТоваровИзКупца(Параметры, АдресРезультата) Экспорт
	
	Соединение = УстановитьСоединениеССервером(Параметры);
	Если Соединение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗагрузитьНоменклатурныеГруппыПервогоУровня(Соединение) Тогда
		Соединение.Close();
		Возврат;
	КонецЕсли;
	
	//Если Не ЗагрузитьНоменклатурныеГруппыВторогоУровня(Соединение) Тогда
	//	Соединение.Close();
	//	Возврат;
	//КонецЕсли;
	
	Соединение.Close();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИнициализироватьПрогресс(КоличествоЭлементов, Текст = "")
	
	КоличествоПараметровДляПрогресса = 2;
	КоличествоПараметровВТексте = СтрЧислоВхождений(Текст, "%");
	ТекстСодержитПрогресс = КоличествоПараметровВТексте = КоличествоПараметровДляПрогресса;
	КоличествоЭлементовСтрокой = Формат(КоличествоЭлементов, "ЧДЦ=; ЧН=0; ЧГ=0");
	
	ПараметрыПрогресса = Новый Структура;
	ПараметрыПрогресса.Вставить("ТекущееПоложениеПрогресса", 0);
	ПараметрыПрогресса.Вставить("ПредыдущийПроцентВыполнения", 0);
	ПараметрыПрогресса.Вставить("КоличествоЭлементов", КоличествоЭлементов);
	ПараметрыПрогресса.Вставить("КоличествоЭлементовСтрокой", КоличествоЭлементовСтрокой);
	ПараметрыПрогресса.Вставить("ТекстСодержитПрогресс", ТекстСодержитПрогресс);
	ПараметрыПрогресса.Вставить("Текст", Текст);
	
	Возврат ПараметрыПрогресса;
	
КонецФункции

Процедура ИзменитьПрогресс(ПараметрыПрогресса)
	
	СтоПроцентов = 100;
	ПараметрыПрогресса.ТекущееПоложениеПрогресса = ПараметрыПрогресса.ТекущееПоложениеПрогресса + 1;
	ПроцентВыполнения = ПараметрыПрогресса.ТекущееПоложениеПрогресса / ПараметрыПрогресса.КоличествоЭлементов;
	ПроцентВыполнения = Окр(СтоПроцентов * ПроцентВыполнения, 0);
	
	Если ПараметрыПрогресса.ПредыдущийПроцентВыполнения <> ПроцентВыполнения Тогда
		ТекстПрогресса = ПараметрыПрогресса.Текст;
		
		Если ПараметрыПрогресса.ТекстСодержитПрогресс Тогда
			КоличествоЭлементовСтрокой = ПараметрыПрогресса.КоличествоЭлементовСтрокой;
			ТекущееПоложениеПрогрессаСтрокой = Формат(ПараметрыПрогресса.ТекущееПоложениеПрогресса, "ЧДЦ=; ЧН=0; ЧГ=0");
			ТекстПрогресса = СтрШаблон(ТекстПрогресса, ТекущееПоложениеПрогрессаСтрокой, КоличествоЭлементовСтрокой);
		КонецЕсли;
		
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, ТекстПрогресса);
		ПараметрыПрогресса.ПредыдущийПроцентВыполнения = ПроцентВыполнения;
	КонецЕсли;
	
КонецПроцедуры

Функция УстановитьСоединениеССервером(Параметры)
	
	ШаблонСтрокиПодключения =
		"Provider=OraOLEDB.Oracle.1;
		|Password=%1;
		|Persist Security Info=True;
		|User ID=%2;
		|Data Source=%3";
	
	Пароль = Параметры.Пароль;
	Пользователь = Параметры.Пользователь;
	ИсточникДанных = Параметры.ИсточникДанных;
	СтрокаПодключения = СтрШаблон(ШаблонСтрокиПодключения, Пароль, Пользователь, ИсточникДанных);
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.ConnectionString = СтрокаПодключения;
	Соединение.CursorLocation = 3;
	Соединение.ConnectionTimeOut = 20;
	Соединение.CommandTimeout = 20;
	
	Попытка
		Соединение.Open();
	Исключение
		ШаблонСообщения = НСтр("ru = 'Не удалось подключиться к сервер!%1%2'");
		ТекстСообщения = СтрШаблон(ШаблонСообщения, Символы.ПС, ОписаниеОшибки());
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
	Возврат Соединение;
	
КонецФункции

Функция ПолучитьАртикул(Знач Артикул, Префикс = "0")
	
	// В Купце группы первого уровня, группы второго уровня и номенклатура хранятся
	// в разных таблицах. Поэтому коды данных элементов могут иметь одинаковые значения.
	// Чтобы однозначно их идентифицировать, преобразуем артикул к типу строки и
	// будем использовать префиксы:
	// 0 - префикс для номенклатуры
	// 1 - префикс для группы первого уровня
	// 2 - префикс для группы второго уровня
	
	Если ПустаяСтрока(Артикул) Тогда
		Возврат "";
	КонецЕсли;
	
	НовыйАртикул = Формат(Артикул, "ЧДЦ=0; ЧГ=");
	НовыйАртикул = Прав("000000" + НовыйАртикул, 7);
	НовыйАртикул = Префикс + НовыйАртикул;
	
	Возврат НовыйАртикул;
	
КонецФункции

Функция ЗагрузитьНоменклатурныеГруппыПервогоУровня(Соединение)
	
	// Получаем номенклатурные группы первого уровня
	ТекстЗапроса =
		"SELECT
		|    group_code,
		|    group_name
		|FROM
		|    goods_group";
	
	Попытка
		ВыборкаГрупп = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонСообщения = НСтр("ru = 'Ошибка получения номенклатурных групп первого уровня:%1%2%1%3'");
		ТекстСообщения = СтрШаблон(ШаблонСообщения, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
	КвалификаторАртикула = Новый КвалификаторыСтроки(8, ДопустимаяДлина.Переменная);
	ОписаниеТипаАртикула = Новый ОписаниеТипов("Строка", , КвалификаторАртикула);
	КвалификаторНаименования = Новый КвалификаторыСтроки(80, ДопустимаяДлина.Переменная);
	ОписаниеТипаНаименования = Новый ОписаниеТипов("Строка", КвалификаторНаименования);
	
	ТаблицаГрупп = Новый ТаблицаЗначений;
	ТаблицаГрупп.Колонки.Добавить("АртикулГруппы", ОписаниеТипаАртикула);
	ТаблицаГрупп.Колонки.Добавить("Наименование", ОписаниеТипаНаименования);
	
	// Добавляем в таблицу номенклатурные группы первого уровня
	Пока Не ВыборкаГрупп.Eof() Цикл
		АртикулГруппы = ПолучитьАртикул(ВыборкаГрупп.Fields("group_code").Value, "1");
		НаименованиеГруппы = ВыборкаГрупп.Fields("group_name").Value;
		
		НоваяСтрока = ТаблицаГрупп.Добавить();
		НоваяСтрока.АртикулГруппы = АртикулГруппы;
		НоваяСтрока.Наименование = НаименованиеГруппы;
		
		ВыборкаГрупп.MoveNext();
	КонецЦикла;
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаГрупп.АртикулГруппы КАК Артикул,
		|	ТаблицаГрупп.Наименование КАК Наименование
		|ПОМЕСТИТЬ ТаблицаГрупп
		|ИЗ
		|	&ТаблицаГрупп КАК ТаблицаГрупп
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДопСвойства.Ссылка КАК Свойство
		|ПОМЕСТИТЬ ТаблицаСвойств
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДопСвойства
		|ГДЕ
		|	ДопСвойства.Имя = ""КодКупца""
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	АртикулыНоменклатуры.Объект КАК Группа,
		|	ТаблицаСвойств.Свойство КАК Свойство,
		|	ТаблицаГрупп.Наименование КАК Наименование,
		|	ТаблицаГрупп.Артикул КАК Артикул
		|ИЗ
		|	ТаблицаГрупп КАК ТаблицаГрупп
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаСвойств КАК ТаблицаСвойств
		|		ПО (ИСТИНА)
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК АртикулыНоменклатуры
		|		ПО ТаблицаГрупп.Артикул = АртикулыНоменклатуры.Значение
		|			И (АртикулыНоменклатуры.Свойство = ТаблицаСвойств.Свойство)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатурныеГруппы
		|		ПО (АртикулыНоменклатуры.Объект = НоменклатурныеГруппы.Ссылка)
		|ГДЕ
		|	ТаблицаГрупп.Наименование <> ЕСТЬNULL(НоменклатурныеГруппы.Наименование, """")";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаГрупп", ТаблицаГрупп);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ШаблонПрогресса = НСтр("ru = 'Загрузка групп первого уровня: %1 из: %2'");
	ПараметрыПрогресса = ИнициализироватьПрогресс(Выборка.Количество(), ШаблонПрогресса);
	
	Пока Выборка.Следующий() Цикл
		ИзменитьПрогресс(ПараметрыПрогресса);
		
		ГруппаСсылка = Выборка.Группа;
		Если ЗначениеЗаполнено(ГруппаСсылка) Тогда
			ГруппаОбъект = ГруппаСсылка.ПолучитьОбъект();
		Иначе
			ГруппаОбъект = Справочники.Номенклатура.СоздатьГруппу();
		КонецЕсли;
		
		НачатьТранзакцию();
		
		Попытка
			ГруппаОбъект.Наименование = Выборка.Наименование;
			ГруппаОбъект.Записать();

			МенеджерЗаписи = РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.Объект = ГруппаОбъект.Ссылка;
			МенеджерЗаписи.Свойство = Выборка.Свойство;
			МенеджерЗаписи.Значение = Выборка.Артикул;
			МенеджерЗаписи.Записать();

			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ШаблонСообщения = НСтр("ru = 'Ошибка записи номенклатурной группы первого уровня:%1%2 (%3) %1%4'");
			ТекстСообщения = СтрШаблон(ШаблонСообщения, Символы.ПС, Выборка.Наименование, Выборка.Артикул, ОписаниеОшибки());
			ВызватьИсключение ТекстСообщения;
		КонецПопытки;
		
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

Функция ЗагрузитьНоменклатурныеГруппыВторогоУровня(Соединение)
	
	// Получаем номенклатурные группы второго уровня
	ТекстЗапроса =
		"SELECT
		|    subgroup_code,
		|    group_code,
		|    subgroup_name
		|FROM
		|    goods_subgroup";
	
	Попытка
		ВыборкаПодгрупп = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонСообщения = НСтр("ru = 'Ошибка получения номенклатурных групп второго уровня:%1%2%1%3'");
		ТекстСообщения = СтрШаблон(ШаблонСообщения, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
	КвалификаторАртикула = Новый КвалификаторыСтроки(8, ДопустимаяДлина.Переменная);
	ОписаниеТипаАртикула = Новый ОписаниеТипов("Строка", , КвалификаторАртикула);
	КвалификаторНаименования = Новый КвалификаторыСтроки(80, ДопустимаяДлина.Переменная);
	ОписаниеТипаНаименования = Новый ОписаниеТипов("Строка", КвалификаторНаименования);
	
	ТаблицаГрупп = Новый ТаблицаЗначений;
	ТаблицаГрупп.Колонки.Добавить("АртикулГруппы", ОписаниеТипаАртикула);
	ТаблицаГрупп.Колонки.Добавить("АртикулРодителя", ОписаниеТипаАртикула);
	ТаблицаГрупп.Колонки.Добавить("Наименование", ОписаниеТипаНаименования);
	
	// Добавляем в таблицу номенклатурные группы второго уровня
	Пока Не ВыборкаПодгрупп.Eof() Цикл
		АртикулРодителя = ПолучитьАртикул(ВыборкаПодгрупп.Fields("group_code").Value, "1");
		АртикулГруппы = ПолучитьАртикул(ВыборкаПодгрупп.Fields("subgroup_code").Value, "2");
		НаименованиеГруппы = ВыборкаПодгрупп.Fields("subgroup_name").Value;
		
		НоваяСтрока = ТаблицаГрупп.Добавить();
		НоваяСтрока.АртикулГруппы = АртикулГруппы;
		НоваяСтрока.АртикулРодителя = АртикулРодителя;
		НоваяСтрока.Наименование = НаименованиеГруппы;
		
		ВыборкаПодгрупп.MoveNext();
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти