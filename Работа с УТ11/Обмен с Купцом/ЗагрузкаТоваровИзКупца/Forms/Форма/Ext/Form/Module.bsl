﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьНоменклатуруИзКупца(Команда)
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ИмяФайлаОбработки = ПолучитьИмяОбработки();
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеЗагрузкиОбработкиНаСервер", ЭтотОбъект);
	НачатьПомещениеФайла(ОписаниеОповещения, , ИмяФайлаОбработки, Ложь, УникальныйИдентификатор);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьИмяОбработки()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ИмяФайлаОбработки = ОбработкаОбъект.ИспользуемоеИмяФайла;
	Возврат ИмяФайлаОбработки;
	
КонецФункции

&НаКлиенте
Процедура ПослеЗагрузкиОбработкиНаСервер(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	
	ПараметрыМетода = Новый Структура;
	ПараметрыМетода.Вставить("ИсточникДанных", ИсточникДанных);
	ПараметрыМетода.Вставить("Пользователь", Пользователь);
	ПараметрыМетода.Вставить("Пароль", Пароль);
	
	НаименованиеЗадания = НСтр("ru = 'Обработка данных'");
	
	ВыполнитьМетодВФоне(
		"ЗагрузитьНоменклатуруИзКупца",
		НаименованиеЗадания,
		Адрес,
		ПараметрыМетода);
	
КонецПроцедуры

&НаСервере
Функция ВыполнитьМетодВФонеНаСервере(ИмяМетода, Адрес, ПараметрыМетода = Неопределено)
	
	Если ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		Попытка
			ЗаданиеВыполнено = ДлительныеОперации.ЗаданиеВыполнено(ИдентификаторЗадания);
		Исключение
			ЗаданиеВыполнено = Истина;
		КонецПопытки;
	Иначе
		ЗаданиеВыполнено = Истина;
	КонецЕсли;
	
	Если НЕ ЗаданиеВыполнено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ВыполняемыйМетод = "ДлительныеОперации.ВыполнитьПроцедуруМодуляОбъектаОбработки";
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ИдентификаторФормы", ЭтаФорма.УникальныйИдентификатор);
	СтруктураПараметров.Вставить("ИмяФормы", ЭтаФорма.ИмяФормы);
	
	Если ТипЗнч(ПараметрыМетода) = Тип("Структура") Тогда
		Для Каждого ПараметрМетода Из ПараметрыМетода Цикл
			СтруктураПараметров.Вставить(ПараметрМетода.Ключ, ПараметрМетода.Значение);
		КонецЦикла;
	КонецЕсли;
	
	Данные = ПолучитьИзВременногоХранилища(Адрес);
	ИмяОбработки = ПолучитьИмяВременногоФайла("epf");
	Данные.Записать(ИмяОбработки);
	
	ИмяОбработки = ПолучитьИмяОбработки(); // Отладка!!
	
	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("ИмяОбработки", ИмяОбработки);
	ПараметрыЗадания.Вставить("ИмяМетода", ИмяМетода);
	ПараметрыЗадания.Вставить("ПараметрыВыполнения", СтруктураПараметров);
	ПараметрыЗадания.Вставить("ЭтоВнешняяОбработка", Истина);
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(ЭтаФорма.УникальныйИдентификатор);
	ПараметрыВыполнения.ЗапуститьВФоне = Истина;
	
	РезультатФоновогоЗадания = ДлительныеОперации.ВыполнитьВФоне(ВыполняемыйМетод, ПараметрыЗадания, ПараметрыВыполнения);
	ИдентификаторЗадания = РезультатФоновогоЗадания.ИдентификаторЗадания;
	
	Возврат РезультатФоновогоЗадания;
	
КонецФункции

&НаКлиенте
Процедура ПослеФоновойОбработкиДанных(Задание, ДополнительныеПараметры) Экспорт
	
	Если Задание <> Неопределено Тогда
		Если Задание.Статус = "Ошибка" Тогда
			ТекстОшибки = Задание.ПодробноеПредставлениеОшибки;
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьМетодВФоне(ИмяМетода, НаименованиеЗадания, Адрес, ПараметрыМетода = Неопределено)
	
	Задание = ВыполнитьМетодВФонеНаСервере(ИмяМетода, Адрес, ПараметрыМетода);
	
	Если Задание <> Неопределено Тогда
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ПослеФоновойОбработкиДанных", ЭтотОбъект);
		
		НастройкиОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		НастройкиОжидания.ТекстСообщения = НаименованиеЗадания;
		НастройкиОжидания.ВыводитьПрогрессВыполнения = Истина;
		НастройкиОжидания.ВыводитьСообщения = Истина;
		НастройкиОжидания.Интервал = 1;
		
		ДлительныеОперацииКлиент.ОжидатьЗавершение(Задание, ОповещениеОЗавершении, НастройкиОжидания);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти