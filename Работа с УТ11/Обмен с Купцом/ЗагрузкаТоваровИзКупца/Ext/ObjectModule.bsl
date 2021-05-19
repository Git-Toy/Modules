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

Процедура ЗагрузитьНоменклатуруИзКупца(Параметры, АдресРезультата) Экспорт
	
	ОжидатьЗапускПрогресса();
	
	ЗагрузитьЕдиницыИзмерения();
	
	ДопСвойствоКодКупца = Неопределено;
	Если Не ПолучитьДополнительноеСвойство(ДопСвойствоКодКупца, "КодКупца") Тогда
		Возврат;
	КонецЕсли;
	
	Соединение = Неопределено;
	Если Не УстановитьСоединениеССервером(Соединение, Параметры) Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗагрузитьСтраныМира(Соединение) Тогда
		Соединение.Close();
		Возврат;
	КонецЕсли;
	
	Если Не ЗагрузитьНоменклатурныеГруппыПервогоУровня(Соединение, ДопСвойствоКодКупца) Тогда
		Соединение.Close();
		Возврат;
	КонецЕсли;
	
	Если Не ЗагрузитьНоменклатурныеГруппыВторогоУровня(Соединение, ДопСвойствоКодКупца) Тогда
		Соединение.Close();
		Возврат;
	КонецЕсли;
	
	Если Не ЗагрузитьВидыНоменклатуры(Соединение, ДопСвойствоКодКупца) Тогда
		Соединение.Close();
		Возврат;
	КонецЕсли;
	
	Если Не ЗагрузитьНоменклатурныеПозиции(Соединение, ДопСвойствоКодКупца) Тогда
		Соединение.Close();
		Возврат;
	КонецЕсли;
	
	Соединение.Close();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ПроцедурыИФункцииРаботыСПрогрессом

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

Процедура ОжидатьЗапускПрогресса()
	
	// Назначение данной процедуры заключается в ожидании открытия окна прогресса.
	// Сообщения выведенные пользователю до открытия окна прогресса показаны не будут.
	ОбщегоНазначенияБТС.Пауза(0.5);
	
КонецПроцедуры

#КонецОбласти

#Область ВспомогательныеПроцедурыИФункцииЗагрузкиДанных

Функция УстановитьСоединениеССервером(Соединение, Параметры)
	
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
		ШаблонОшибки = НСтр("ru = 'Не удалось подключиться к сервер!%1%2'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

Функция ПолучитьОписаниеТипаСтроки(ДлинаСтроки)
	
	КвалификаторСтроки = Новый КвалификаторыСтроки(ДлинаСтроки, ДопустимаяДлина.Переменная);
	ОписаниеТипаСтрока = Новый ОписаниеТипов("Строка", , КвалификаторСтроки);
	
	Возврат ОписаниеТипаСтрока;
	
КонецФункции

Функция ПолучитьОписаниеТипаЧисла(ДлинаЧисла, ТочностьЧисла)
	
	КвалификаторЧисла = Новый КвалификаторыЧисла(ДлинаЧисла, ТочностьЧисла);
	ОписаниеТипаЧисла = Новый ОписаниеТипов("Число", КвалификаторЧисла);
	
	Возврат ОписаниеТипаЧисла;
	
КонецФункции

Функция ПолучитьТипКолонки(ПараметрыПоля)
	
	МассивТиповСтрока = Новый Массив;
	МассивТиповСтрока.Добавить(202);
	
	Если МассивТиповСтрока.Найти(ПараметрыПоля.Type) <> Неопределено Тогда
		ОписаниеТипаСтрока = ПолучитьОписаниеТипаСтроки(ПараметрыПоля.DefinedSize);
		Возврат ОписаниеТипаСтрока;
	КонецЕсли;
	
	МассивТиповЧисло = Новый Массив;
	МассивТиповЧисло.Добавить(131);
	МассивТиповЧисло.Добавить(139);
	
	Если МассивТиповЧисло.Найти(ПараметрыПоля.Type) <> Неопределено Тогда
		ОписаниеТипаЧисла = ПолучитьОписаниеТипаЧисла(15, 4);
		Возврат ОписаниеТипаЧисла;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ПолучитьТаблицуЗагрузки(Выборка)
	
	ТаблицЗагрузки = Новый ТаблицаЗначений;
	СписокПолей = Выборка.Fields;
	МассивИменПолей = Новый Массив;
	
	Для ИндексПоля = 0 По СписокПолей.Count - 1 Цикл
		ПараметрыПоля = СписокПолей.Item(ИндексПоля);
		ИмяКолонки = ПараметрыПоля.Name;
		ТипКолонки = ПолучитьТипКолонки(ПараметрыПоля);
		ТаблицЗагрузки.Колонки.Добавить(ИмяКолонки, ТипКолонки);
		МассивИменПолей.Добавить(ИмяКолонки);
	КонецЦикла;
	
	Пока Не Выборка.Eof() Цикл
		НоваяСтрока = ТаблицЗагрузки.Добавить();
		
		Для Каждого ИмяПоля Из МассивИменПолей Цикл
			ЗначениеПоля = Выборка.Fields(ИмяПоля).Value;
			НоваяСтрока[ИмяПоля] = ЗначениеПоля;
		КонецЦикла;
		
		Выборка.MoveNext();
	КонецЦикла;
	
	Возврат ТаблицЗагрузки;
	
КонецФункции

Функция ПолучитьДополнительноеСвойство(ДопСвойство, ИмяСвойства)
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ДопСвойства.Ссылка КАК Свойство
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДопСвойства
		|ГДЕ
		|	ДопСвойства.Имя = &ИмяСвойства";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ИмяСвойства", ИмяСвойства);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ДопСвойство = Выборка.Свойство;
		Возврат Истина;
	КонецЕсли;
	
	ШаблонОшибки = НСтр("ru = 'Дополнительное сведение с наименованием: ""%1"" не найдено!'");
	ТекстОшибки = СтрШаблон(ШаблонОшибки, ИмяСвойства);
	ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
	Возврат Ложь;
	
КонецФункции

Процедура ЗаписатьДопСвойство(Объект, Свойство, Значение)
	
	МенеджерЗаписи = РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Объект = Объект;
	МенеджерЗаписи.Свойство = Свойство;
	МенеджерЗаписи.Значение = Значение;
	МенеджерЗаписи.Записать();
	
КонецПроцедуры

Процедура ЗаписатьШтрихкод(Номенклатура, Штрихкод)
	
	Если НЕ ЗначениеЗаполнено(Штрихкод) Тогда
		Возврат;
	КонецЕсли;
	
	МенеджерЗаписи = РегистрыСведений.ШтрихкодыНоменклатуры.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Штрихкод = Штрихкод;
	МенеджерЗаписи.Номенклатура = Номенклатура;
	МенеджерЗаписи.Записать();
	
КонецПроцедуры

#КонецОбласти

#Область ФункцииЗагрузкиСправочников

Процедура ЗагрузитьЕдиницыИзмерения()
	
	ОписаниеТипаСтрока = ПолучитьОписаниеТипаСтроки(4);
	ТаблицаЕдиницИзмерения = Новый ТаблицаЗначений;
	ТаблицаЕдиницИзмерения.Колонки.Добавить("Код", ОписаниеТипаСтрока);
	
	НоваяСтрока = ТаблицаЕдиницИзмерения.Добавить();
	НоваяСтрока.Код = "163"; // Грамм, международное сокращение GRM
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаЕдиницИзмерения.Код КАК Код
		|ПОМЕСТИТЬ ТаблицаЕдиницИзмерения
		|ИЗ
		|	&ТаблицаЕдиницИзмерения КАК ТаблицаЕдиницИзмерения
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаЕдиницИзмерения.Код КАК Код
		|ИЗ
		|	ТаблицаЕдиницИзмерения КАК ТаблицаЕдиницИзмерения
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.УпаковкиЕдиницыИзмерения КАК ЕдиницыИзмерения
		|		ПО ТаблицаЕдиницИзмерения.Код = ЕдиницыИзмерения.Код
		|ГДЕ
		|	ЕдиницыИзмерения.Ссылка ЕСТЬ NULL";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаЕдиницИзмерения", ТаблицаЕдиницИзмерения);
	Результат = Запрос.Выполнить();
	
	Если Не Результат.Пустой() Тогда
		МассивКодов = Результат.Выгрузить().ВыгрузитьКолонку("Код");
		СписокКодов = СтрСоединить(МассивКодов, ",");
		Справочники.УпаковкиЕдиницыИзмерения.ЗаполнитьЕдиницыИзмеренияИзКлассификатора(СписокКодов);
	КонецЕсли;
	
КонецПроцедуры

Функция ЗагрузитьСтраныМира(Соединение)
	
	ТекстЗапроса =
		"SELECT
		|    country_name AS name,
		|    substr('000' || international_code, - 3) AS code,
		|    iso_code_2,
		|    iso_code_3
		|FROM
		|    countries";
	
	Попытка
		Выборка = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонОшибки = НСтр("ru = 'Ошибка получения стран мира:%1%2%1%3'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	ТаблицаСтран = ПолучитьТаблицуЗагрузки(Выборка);
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаСтран.name КАК Наименование,
		|	ТаблицаСтран.code КАК Код,
		|	ТаблицаСтран.iso_code_2 КАК КодАльфа2,
		|	ТаблицаСтран.iso_code_3 КАК КодАльфа3
		|ПОМЕСТИТЬ ТаблицаСтран
		|ИЗ
		|	&ТаблицаСтран КАК ТаблицаСтран
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаСтран.Код КАК Код,
		|	ТаблицаСтран.Наименование КАК Наименование,
		|	ТаблицаСтран.КодАльфа2 КАК КодАльфа2,
		|	ТаблицаСтран.КодАльфа3 КАК КодАльфа3,
		|	"""" КАК НаименованиеПолное,
		|	ЛОЖЬ КАК УчастникЕАЭС
		|ИЗ
		|	ТаблицаСтран КАК ТаблицаСтран
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтраныМира КАК СтраныМира
		|		ПО ТаблицаСтран.Код = СтраныМира.Код
		|ГДЕ
		|	СтраныМира.Ссылка ЕСТЬ NULL";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаСтран", ТаблицаСтран);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ШаблонПрогресса = НСтр("ru = 'Загрузка стран мира: %1 из: %2'");
	ПараметрыПрогресса = ИнициализироватьПрогресс(Выборка.Количество(), ШаблонПрогресса);
	
	ОшибкиЗагрузкиОтсутствуют = Истина;
	
	Пока Выборка.Следующий() Цикл
		ИзменитьПрогресс(ПараметрыПрогресса);
		
		ДанныеСтраны = УправлениеКонтактнойИнформацией.ДанныеКлассификатораСтранМираПоКоду(Выборка.Код);
		Если ДанныеСтраны = Неопределено Тогда
			ДанныеСтраны = Выборка;
		КонецЕсли;
		
		Попытка
			СтранаОбъект = Справочники.СтраныМира.СоздатьЭлемент();
			ЗаполнитьЗначенияСвойств(СтранаОбъект, ДанныеСтраны);
			СтранаОбъект.Записать();
		Исключение
			ШаблонОшибки = НСтр("ru = 'Ошибка записи страны мира:%1%2 (%3) %1%4'");
			ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, Выборка.Наименование, Выборка.Код, ОписаниеОшибки());
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
			ОшибкиЗагрузкиОтсутствуют = Ложь;
		КонецПопытки;
	КонецЦикла;
	
	Возврат ОшибкиЗагрузкиОтсутствуют;
	
КонецФункции

Функция ЗагрузитьНоменклатурныеГруппыПервогоУровня(Соединение, ДопСвойствоКодКупца)
	
	// Получаем номенклатурные группы первого уровня
	// В Купце группы первого уровня, группы второго уровня и номенклатура хранятся
	// в разных таблицах. Поэтому коды данных элементов могут иметь одинаковые значения.
	// Чтобы однозначно их идентифицировать, преобразуем код к типу строки и
	// будем использовать префиксы:
	// 1 - префикс для группы первого уровня
	// 2 - префикс для группы второго уровня
	// Коды номенклатуры префиксов иметь не будут.
	
	ТекстЗапроса =
		"SELECT
		|    '1' || substr('000000' || group_code, - 7) AS code,
		|    group_name AS name
		|FROM
		|    goods_group";
	
	Попытка
		Выборка = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонОшибки = НСтр("ru = 'Ошибка получения номенклатурных групп первого уровня:%1%2%1%3'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	ТаблицаГрупп = ПолучитьТаблицуЗагрузки(Выборка);
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаГрупп.code КАК Код,
		|	ТаблицаГрупп.name КАК Наименование
		|ПОМЕСТИТЬ ТаблицаГрупп
		|ИЗ
		|	&ТаблицаГрупп КАК ТаблицаГрупп
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КодыГрупп.Объект КАК Группа,
		|	ТаблицаГрупп.Наименование КАК Наименование,
		|	ТаблицаГрупп.Код КАК Код
		|ИЗ
		|	ТаблицаГрупп КАК ТаблицаГрупп
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыГрупп
		|		ПО ТаблицаГрупп.Код = КодыГрупп.Значение
		|			И (КодыГрупп.Свойство = &ДопСвойствоКодКупца)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатурныеГруппы
		|		ПО (КодыГрупп.Объект = НоменклатурныеГруппы.Ссылка)
		|ГДЕ
		|	ТаблицаГрупп.Наименование <> ЕСТЬNULL(НоменклатурныеГруппы.Наименование, """")";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаГрупп", ТаблицаГрупп);
	Запрос.УстановитьПараметр("ДопСвойствоКодКупца", ДопСвойствоКодКупца);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ШаблонПрогресса = НСтр("ru = 'Загрузка групп первого уровня: %1 из: %2'");
	ПараметрыПрогресса = ИнициализироватьПрогресс(Выборка.Количество(), ШаблонПрогресса);
	
	ОшибкиЗагрузкиОтсутствуют = Истина;
	
	Пока Выборка.Следующий() Цикл
		ИзменитьПрогресс(ПараметрыПрогресса);
		
		ГруппаСсылка = Выборка.Группа;
		Если ЗначениеЗаполнено(ГруппаСсылка) Тогда
			ГруппаОбъект = ГруппаСсылка.ПолучитьОбъект();
			ЗаписыватьКодКупца = Ложь;
		Иначе
			ГруппаОбъект = Справочники.Номенклатура.СоздатьГруппу();
			ЗаписыватьКодКупца = Истина;
		КонецЕсли;
		
		НачатьТранзакцию();
		
		Попытка
			ГруппаОбъект.Наименование = Выборка.Наименование;
			ГруппаОбъект.Записать();
			
			Если ЗаписыватьКодКупца Тогда
				ЗаписатьДопСвойство(ГруппаОбъект.Ссылка, ДопСвойствоКодКупца, Выборка.Код);
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ШаблонОшибки = НСтр("ru = 'Ошибка записи номенклатурной группы первого уровня:%1%2 (%3) %1%4'");
			ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, Выборка.Наименование, Выборка.Код, ОписаниеОшибки());
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
			ОшибкиЗагрузкиОтсутствуют = Ложь;
		КонецПопытки;
	КонецЦикла;
	
	Возврат ОшибкиЗагрузкиОтсутствуют;
	
КонецФункции

Функция ЗагрузитьНоменклатурныеГруппыВторогоУровня(Соединение, ДопСвойствоКодКупца)
	
	// Получаем номенклатурные группы второго уровня
	ТекстЗапроса =
		"SELECT
		|    '1' || substr('000000' || group_code, - 7) AS group_code,
		|    '2' || substr('000000' || subgroup_code, - 7) AS subgroup_code,
		|    subgroup_name AS subgroup_name
		|FROM
		|    goods_subgroup";
	
	Попытка
		Выборка = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонОшибки = НСтр("ru = 'Ошибка получения номенклатурных групп второго уровня:%1%2%1%3'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	ТаблицаГрупп = ПолучитьТаблицуЗагрузки(Выборка);
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаГрупп.group_code КАК КодРодителя,
		|	ТаблицаГрупп.subgroup_code КАК Код,
		|	ТаблицаГрупп.subgroup_name КАК Наименование
		|ПОМЕСТИТЬ ТаблицаГрупп
		|ИЗ
		|	&ТаблицаГрупп КАК ТаблицаГрупп
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КодыГрупп.Объект КАК Группа,
		|	КодыРодителей.Объект КАК Родитель,
		|	ТаблицаГрупп.Наименование КАК Наименование,
		|	ТаблицаГрупп.Код КАК Код
		|ИЗ
		|	ТаблицаГрупп КАК ТаблицаГрупп
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыГрупп
		|		ПО ТаблицаГрупп.Код = КодыГрупп.Значение
		|			И (КодыГрупп.Свойство = &ДопСвойствоКодКупца)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатурныеГруппы
		|		ПО (КодыГрупп.Объект = НоменклатурныеГруппы.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыРодителей
		|		ПО ТаблицаГрупп.КодРодителя = КодыРодителей.Значение
		|			И (КодыРодителей.Свойство = &ДопСвойствоКодКупца)
		|ГДЕ
		|	НЕ(ТаблицаГрупп.Наименование = ЕСТЬNULL(НоменклатурныеГруппы.Наименование, """")
		|				И ЕСТЬNULL(КодыРодителей.Объект = НоменклатурныеГруппы.Родитель, ЛОЖЬ))";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаГрупп", ТаблицаГрупп);
	Запрос.УстановитьПараметр("ДопСвойствоКодКупца", ДопСвойствоКодКупца);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ШаблонПрогресса = НСтр("ru = 'Загрузка групп второго уровня: %1 из: %2'");
	ПараметрыПрогресса = ИнициализироватьПрогресс(Выборка.Количество(), ШаблонПрогресса);
	
	ОшибкиЗагрузкиОтсутствуют = Истина;
	
	Пока Выборка.Следующий() Цикл
		ИзменитьПрогресс(ПараметрыПрогресса);
		
		ГруппаСсылка = Выборка.Группа;
		Если ЗначениеЗаполнено(ГруппаСсылка) Тогда
			ГруппаОбъект = ГруппаСсылка.ПолучитьОбъект();
			ЗаписыватьКодКупца = Ложь;
		Иначе
			ГруппаОбъект = Справочники.Номенклатура.СоздатьГруппу();
			ЗаписыватьКодКупца = Истина;
		КонецЕсли;
		
		НачатьТранзакцию();
		
		Попытка
			ГруппаОбъект.Родитель = Выборка.Родитель;
			ГруппаОбъект.Наименование = Выборка.Наименование;
			ГруппаОбъект.Записать();
			
			Если ЗаписыватьКодКупца Тогда
				ЗаписатьДопСвойство(ГруппаОбъект.Ссылка, ДопСвойствоКодКупца, Выборка.Код);
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ШаблонОшибки = НСтр("ru = 'Ошибка записи номенклатурной группы второго уровня:%1%2 (%3) %1%4'");
			ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, Выборка.Наименование, Выборка.Код, ОписаниеОшибки());
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
			ОшибкиЗагрузкиОтсутствуют = Ложь;
		КонецПопытки;
	КонецЦикла;
	
	Возврат ОшибкиЗагрузкиОтсутствуют;
	
КонецФункции

Функция ЗагрузитьВидыНоменклатуры(Соединение, ДопСвойствоКодКупца)
	
	ТекстЗапроса =
		"SELECT
		|    to_char(goods_types_list_code) AS code,
		|    type_name AS name
		|FROM
		|    merchant.goods_types_list";
	
	Попытка
		Выборка = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонОшибки = НСтр("ru = 'Ошибка получения видов номенклатуры:%1%2%1%3'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	ТаблицаВидовНоменклатуры = ПолучитьТаблицуЗагрузки(Выборка);
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаВидовНоменклатуры.code КАК Код,
		|	ТаблицаВидовНоменклатуры.name КАК Наименование
		|ПОМЕСТИТЬ ТаблицаВидовНоменклатуры
		|ИЗ
		|	&ТаблицаВидовНоменклатуры КАК ТаблицаВидовНоменклатуры
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КодыВидовНоменклатуры.Объект КАК ВидНоменклатуры,
		|	ТаблицаВидовНоменклатуры.Наименование КАК Наименование,
		|	ТаблицаВидовНоменклатуры.Код КАК Код
		|ИЗ
		|	ТаблицаВидовНоменклатуры КАК ТаблицаВидовНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыВидовНоменклатуры
		|		ПО ТаблицаВидовНоменклатуры.Код = КодыВидовНоменклатуры.Значение
		|			И (КодыВидовНоменклатуры.Свойство = &ДопСвойствоКодКупца)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВидыНоменклатуры КАК ВидыНоменклатуры
		|		ПО (КодыВидовНоменклатуры.Объект = ВидыНоменклатуры.Ссылка)
		|ГДЕ
		|	ТаблицаВидовНоменклатуры.Наименование <> ЕСТЬNULL(ВидыНоменклатуры.Наименование, """")";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаВидовНоменклатуры", ТаблицаВидовНоменклатуры);
	Запрос.УстановитьПараметр("ДопСвойствоКодКупца", ДопСвойствоКодКупца);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ШаблонПрогресса = НСтр("ru = 'Загрузка видов номенклатуры: %1 из: %2'");
	ПараметрыПрогресса = ИнициализироватьПрогресс(Выборка.Количество(), ШаблонПрогресса);
	
	ОшибкиЗагрузкиОтсутствуют = Истина;
	
	Пока Выборка.Следующий() Цикл
		ИзменитьПрогресс(ПараметрыПрогресса);
		
		ВидНоменклатурыСсылка = Выборка.ВидНоменклатуры;
		Если ЗначениеЗаполнено(ВидНоменклатурыСсылка) Тогда
			ВидНоменклатурыОбъект = ВидНоменклатурыСсылка.ПолучитьОбъект();
			ЗаписыватьКодКупца = Ложь;
		Иначе
			ВидНоменклатурыОбъект = Справочники.ВидыНоменклатуры.СоздатьЭлемент();
			ВидНоменклатурыОбъект.ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Товар;
			ВидНоменклатурыОбъект.ВариантОформленияПродажи = Перечисления.ВариантыОформленияПродажи.РеализацияТоваровУслуг;
			ЗаписыватьКодКупца = Истина;
		КонецЕсли;
		
		НачатьТранзакцию();
		
		Попытка
			ВидНоменклатурыОбъект.Наименование = Выборка.Наименование;
			ВидНоменклатурыОбъект.Записать();
			
			Если ЗаписыватьКодКупца Тогда
				ЗаписатьДопСвойство(ВидНоменклатурыОбъект.Ссылка, ДопСвойствоКодКупца, Выборка.Код);
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ШаблонОшибки = НСтр("ru = 'Ошибка записи вида номенклатуры:%1%2 (%3) %1%4'");
			ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, Выборка.Наименование, Выборка.Код, ОписаниеОшибки());
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
			ОшибкиЗагрузкиОтсутствуют = Ложь;
		КонецПопытки;
	КонецЦикла;
	
	Возврат ОшибкиЗагрузкиОтсутствуют;
	
КонецФункции

Функция ЗагрузитьНоменклатурныеПозиции(Соединение, ДопСвойствоКодКупца)
	
	// Получаем номенклатурные позиции
	ТекстЗапроса =
		"SELECT
		|    '2' || substr('000000' || goods.subgroup_code, - 7) AS subgroup_code,
		|    substr('000' || countries.international_code, - 3) AS country_code,
		|    to_char(goods.goods_types_list_code) AS goods_types_code,
		|    to_char(goods.ware_code) AS ware_code,
		|    goods.ware_name AS ware_name,
		|    goods.article AS article,
		|    goods.nds AS nds,
		|    goods.unit_weight AS unit_weight,
		|    goods.barcode AS barcode,
		|    goods.barcode2 AS barcode2,
		|    goods.barcode3 AS barcode3,
		|    goods.barcode4 AS barcode4,
		|    goods.barcode5 AS barcode5
		|FROM
		|    goods
		|    LEFT OUTER JOIN countries ON goods.country_code = countries.country_code
		|WHERE
		|    goods.is_active = 'Y'
		|    AND rownum <= 1000";
	
	Попытка
		Выборка = Соединение.Execute(ТекстЗапроса);
	Исключение
		ШаблонОшибки = НСтр("ru = 'Ошибка получения номенклатурных позиций:%1%2%1%3'");
		ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, ТекстЗапроса, ОписаниеОшибки());
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	ТаблицаНоменклатуры = ПолучитьТаблицуЗагрузки(Выборка);
	
	ТекстЗапроса =
		"ВЫБРАТЬ
		|	ТаблицаНоменклатуры.ware_code КАК Код,
		|	ВЫРАЗИТЬ(ТаблицаНоменклатуры.ware_name КАК СТРОКА(100)) КАК Наименование,
		|	ТаблицаНоменклатуры.ware_name КАК НаименованиеПолное,
		|	ТаблицаНоменклатуры.article КАК Артикул,
		|	ТаблицаНоменклатуры.subgroup_code КАК КодРодителя,
		|	ТаблицаНоменклатуры.goods_types_code КАК КодВидаНоменклатуры,
		|	ТаблицаНоменклатуры.country_code КАК КодСтраны,
		|	ТаблицаНоменклатуры.nds КАК Ставка,
		|	ТаблицаНоменклатуры.unit_weight * 1000 КАК Вес,
		|	ТаблицаНоменклатуры.barcode КАК Штрихкод1,
		|	ТаблицаНоменклатуры.barcode2 КАК Штрихкод2,
		|	ТаблицаНоменклатуры.barcode3 КАК Штрихкод3,
		|	ТаблицаНоменклатуры.barcode4 КАК Штрихкод4,
		|	ТаблицаНоменклатуры.barcode5 КАК Штрихкод5
		|ПОМЕСТИТЬ ТаблицаНоменклатуры
		|ИЗ
		|	&ТаблицаНоменклатуры КАК ТаблицаНоменклатуры
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(Перечисление.СтавкиНДС.НДС20) КАК СтавкаНДС,
		|	20 КАК Ставка
		|ПОМЕСТИТЬ ТаблицаСтавокНДС
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(Перечисление.СтавкиНДС.НДС10),
		|	10
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(Перечисление.СтавкиНДС.БезНДС),
		|	0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СправочникНоменклатура.Ссылка КАК Номенклатура,
		|	ТаблицаНоменклатуры.Код КАК КодКупца,
		|	ТаблицаНоменклатуры.Наименование КАК Наименование,
		|	ТаблицаНоменклатуры.НаименованиеПолное КАК НаименованиеПолное,
		|	ТаблицаНоменклатуры.Артикул КАК Артикул,
		|	КодыРодителей.Объект КАК Родитель,
		|	ВидыНоменклатуры.Ссылка КАК ВидНоменклатуры,
		|	ВидыНоменклатуры.ТипНоменклатуры КАК ТипНоменклатуры,
		|	ВидыНоменклатуры.ИспользованиеХарактеристик КАК ИспользованиеХарактеристик,
		|	ВидыНоменклатуры.ВариантОформленияПродажи КАК ВариантОформленияПродажи,
		|	СтраныМира.Ссылка КАК СтранаПроисхождения,
		|	ТаблицаСтавокНДС.СтавкаНДС КАК СтавкаНДС,
		|	ЕдиницаИзмеренияШтук.Значение КАК ЕдиницаИзмерения,
		|	ТаблицаНоменклатуры.Штрихкод1 КАК Штрихкод1,
		|	ТаблицаНоменклатуры.Штрихкод2 КАК Штрихкод2,
		|	ТаблицаНоменклатуры.Штрихкод3 КАК Штрихкод3,
		|	ТаблицаНоменклатуры.Штрихкод4 КАК Штрихкод4,
		|	ТаблицаНоменклатуры.Штрихкод5 КАК Штрихкод5,
		|	ТаблицаНоменклатуры.Вес КАК ВесЧислитель,
		|	ВЫБОР
		|		КОГДА ТаблицаНоменклатуры.Вес > 0
		|			ТОГДА 1
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК ВесЗнаменатель,
		|	ВЫБОР
		|		КОГДА ТаблицаНоменклатуры.Вес > 0
		|			ТОГДА ИСТИНА
		|		ИНАЧЕ ЛОЖЬ
		|	КОНЕЦ КАК ВесИспользовать,
		|	ВЫБОР
		|		КОГДА ТаблицаНоменклатуры.Вес > 0
		|			ТОГДА ЕдиницаИзмеренияВеса.Ссылка
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.УпаковкиЕдиницыИзмерения.ПустаяСсылка)
		|	КОНЕЦ КАК ВесЕдиницаИзмерения
		|ИЗ
		|	ТаблицаНоменклатуры КАК ТаблицаНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыНоменклатуры
		|		ПО ТаблицаНоменклатуры.Код = КодыНоменклатуры.Значение
		|			И (КодыНоменклатуры.Свойство = &ДопСвойствоКодКупца)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СправочникНоменклатура
		|		ПО (КодыНоменклатуры.Объект = СправочникНоменклатура.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыРодителей
		|		ПО ТаблицаНоменклатуры.КодРодителя = КодыРодителей.Значение
		|			И (КодыРодителей.Свойство = &ДопСвойствоКодКупца)
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК КодыВидовНоменклатуры
		|		ПО ТаблицаНоменклатуры.КодВидаНоменклатуры = КодыВидовНоменклатуры.Значение
		|			И (КодыВидовНоменклатуры.Свойство = &ДопСвойствоКодКупца)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВидыНоменклатуры КАК ВидыНоменклатуры
		|		ПО (КодыВидовНоменклатуры.Объект = ВидыНоменклатуры.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтраныМира КАК СтраныМира
		|		ПО ТаблицаНоменклатуры.КодСтраны = СтраныМира.Код
		|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаСтавокНДС КАК ТаблицаСтавокНДС
		|		ПО ТаблицаНоменклатуры.Ставка = ТаблицаСтавокНДС.Ставка
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихКоды1
		|		ПО ТаблицаНоменклатуры.Штрихкод1 = ШтрихКоды1.Штрихкод
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихКоды2
		|		ПО ТаблицаНоменклатуры.Штрихкод2 = ШтрихКоды2.Штрихкод
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихКоды3
		|		ПО ТаблицаНоменклатуры.Штрихкод3 = ШтрихКоды3.Штрихкод
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихКоды4
		|		ПО ТаблицаНоменклатуры.Штрихкод4 = ШтрихКоды4.Штрихкод
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихКоды5
		|		ПО ТаблицаНоменклатуры.Штрихкод5 = ШтрихКоды5.Штрихкод,
		|	Константа.ЕдиницаИзмеренияКоличестваШтук КАК ЕдиницаИзмеренияШтук,
		|	Справочник.УпаковкиЕдиницыИзмерения КАК ЕдиницаИзмеренияВеса
		|ГДЕ
		|	ЕдиницаИзмеренияВеса.МеждународноеСокращение = ""GRM""
		|	И НЕ(ТаблицаНоменклатуры.Наименование = ЕСТЬNULL(СправочникНоменклатура.Наименование, """")
		|				И ТаблицаНоменклатуры.НаименованиеПолное = ЕСТЬNULL(СправочникНоменклатура.НаименованиеПолное, """")
		|				И ТаблицаНоменклатуры.Артикул = ЕСТЬNULL(СправочникНоменклатура.Артикул, """")
		|				И ТаблицаНоменклатуры.Вес = ЕСТЬNULL(СправочникНоменклатура.ВесЧислитель, 0)
		|				И ТаблицаНоменклатуры.Штрихкод1 = ЕСТЬNULL(ШтрихКоды1.Штрихкод, """")
		|				И ТаблицаНоменклатуры.Штрихкод2 = ЕСТЬNULL(ШтрихКоды2.Штрихкод, """")
		|				И ТаблицаНоменклатуры.Штрихкод3 = ЕСТЬNULL(ШтрихКоды3.Штрихкод, """")
		|				И ТаблицаНоменклатуры.Штрихкод4 = ЕСТЬNULL(ШтрихКоды4.Штрихкод, """")
		|				И ТаблицаНоменклатуры.Штрихкод5 = ЕСТЬNULL(ШтрихКоды5.Штрихкод, """")
		|				И ЕСТЬNULL(КодыРодителей.Объект = СправочникНоменклатура.Родитель, ЛОЖЬ)
		|				И ЕСТЬNULL(ВидыНоменклатуры.Ссылка = СправочникНоменклатура.ВидНоменклатуры, ЛОЖЬ)
		|				И ЕСТЬNULL(ТаблицаСтавокНДС.СтавкаНДС = СправочникНоменклатура.СтавкаНДС, ЛОЖЬ)
		|				И ЕСТЬNULL(ЕдиницаИзмеренияШтук.Значение = СправочникНоменклатура.ЕдиницаИзмерения, ЛОЖЬ))";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ТаблицаНоменклатуры", ТаблицаНоменклатуры);
	Запрос.УстановитьПараметр("ДопСвойствоКодКупца", ДопСвойствоКодКупца);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ШаблонПрогресса = НСтр("ru = 'Загрузка номенклатурных позиций: %1 из: %2'");
	ПараметрыПрогресса = ИнициализироватьПрогресс(Выборка.Количество(), ШаблонПрогресса);
	
	ОшибкиЗагрузкиОтсутствуют = Истина;
	
	Пока Выборка.Следующий() Цикл
		ИзменитьПрогресс(ПараметрыПрогресса);
		
		НоменклатураСсылка = Выборка.Номенклатура;
		Если ЗначениеЗаполнено(НоменклатураСсылка) Тогда
			НоменклатураОбъект = НоменклатураСсылка.ПолучитьОбъект();
			ЗаписыватьКодКупца = Ложь;
		Иначе
			НоменклатураОбъект = Справочники.Номенклатура.СоздатьЭлемент();
			ЗаписыватьКодКупца = Истина;
		КонецЕсли;
		
		НачатьТранзакцию();
		
		Попытка
			ЗаполнитьЗначенияСвойств(НоменклатураОбъект, Выборка);
			НоменклатураОбъект.Записать();
			
			Для НомерШтрихкода = 1 По 5 Цикл
				ЗаписатьШтрихкод(НоменклатураОбъект.Ссылка, Выборка["Штрихкод" + НомерШтрихкода]);
			КонецЦикла;
			
			Если ЗаписыватьКодКупца Тогда
				ЗаписатьДопСвойство(НоменклатураОбъект.Ссылка, ДопСвойствоКодКупца, Выборка.КодКупца);
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ШаблонОшибки = НСтр("ru = 'Ошибка записи вида номенклатуры:%1%2 (%3) %1%4'");
			ТекстОшибки = СтрШаблон(ШаблонОшибки, Символы.ПС, Выборка.Наименование, Выборка.КодКупца, ОписаниеОшибки());
			ОбщегоНазначения.СообщитьПользователю(ТекстОшибки);
			ОшибкиЗагрузкиОтсутствуют = Ложь;
		КонецПопытки;
	КонецЦикла;
	
	Возврат ОшибкиЗагрузкиОтсутствуют;
	
КонецФункции

#КонецОбласти

#КонецОбласти