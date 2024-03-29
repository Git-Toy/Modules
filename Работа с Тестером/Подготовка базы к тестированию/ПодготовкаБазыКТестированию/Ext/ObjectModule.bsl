﻿#Область ПрограммныйИнтерфейс

// Возвращает сведения о внешней обработке.
//
// Возвращаемое значение:
//	Структура - Подробнее см. ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке().
//
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Наименование = ЭтотОбъект.Метаданные().Синоним;
	ПараметрыРегистрации.Информация = ЭтотОбъект.Метаданные().Комментарий;
	ПараметрыРегистрации.Версия = Формат(ТекущаяДатаСеанса(), "ДФ=dd.MM.yyyy");
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.Представление = ПараметрыРегистрации.Наименование;
	НоваяКоманда.Идентификатор = ЭтотОбъект.Метаданные().Имя;
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

#КонецОбласти