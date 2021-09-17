&AtServerNoContext
Function FindScenario(Application, Path, Scenario = Undefined)
	
	QueryText =
		"SELECT TOP 1
		|	Scenarios.Ref AS Scenario
		|FROM
		|	Catalog.Scenarios AS Scenarios
		|WHERE
		|	Scenarios.Application IN (&Application, VALUE(Catalog.Applications.EmptyRef))
		|	AND Scenarios.Path = &Path";
	
	Query = New Query(QueryText);
	Query.SetParameter("Application", Application);
	Query.SetParameter("Path", Path);
	Selection = Query.Execute().Select();
	
	If Selection.Next() Then
		Scenario = Selection.Scenario;
		Return True;
	EndIf;
	
	Return False;
	
EndFunction

&AtServerNoContext
Function AddScenarios(Application, ParametersStructure, Scenario = Undefined)
	
	ParentName = Undefined;
	If Not ParametersStructure.Property("ParentName", ParentName) Then
		ParentName = "";
	EndIf;
	
	Parent = Undefined;
	If Not ParametersStructure.Property("Parent", Parent) Then
		If ValueIsFilled(ParentName) Then
			FindScenario(Application, ParentName, Parent);
		EndIf;
	EndIf;
	
	Description = ParametersStructure.Description;
	If ValueIsFilled(ParentName) Then
		Path = ParentName + "." + Description;
	Else
		Path = Description;
	EndIf;
	
	If FindScenario(Application, Path, Scenario) Then
		Return False;
	EndIf;
	
	ScenarioObject = Catalogs.Scenarios.CreateItem();
	ScenarioObject.Parent = Parent;
	ScenarioObject.Description = Description;
	ScenarioObject.Path = Path;
	ScenarioObject.Application = Application;
	ScenarioObject.Changed = CurrentUniversalDate();
	
	User = SessionParameters.User;
	ScenarioObject.Creator = User;
	ScenarioObject.LastCreator = User;
	
	Type = ParametersStructure.Type;
	ScenarioObject.Type = Type;
	Catalogs.Scenarios.SetSorting(ScenarioObject);
	
	If Type = Enums.Scenarios.Folder Then
		ScenarioObject.Tree = True;
	EndIf;
	
	Script = "";
	If ParametersStructure.Property("Script", Script) Then
		ScenarioObject.Script = Script;
	EndIf;
	
	Try
		ScenarioObject.Write();
		ErrorTemplate = NStr("ru = 'Создан сценарий: ""%1""'");
		ErrorText = StrTemplate(ErrorTemplate, Path);
		
		Message = New UserMessage();
		Message.Text = ErrorText;
		Message.Message();
	Except
		ErrorTemplate = NStr("ru = 'Ошибка записи сценария: ""%1"". %2'");
		ErrorText = StrTemplate(ErrorTemplate, Path, ErrorDescription());
		
		Message = New UserMessage();
		Message.Text = ErrorText;
		Message.Message();
		Return False;
	EndTry;
	
	Scenario = ScenarioObject.Ref;
	
	Return True;
	
EndFunction

&AtServerNoContext
Function GetParametersScript(ParentName, Description)
	
	If ParentName = "Документ" Then
		ScriptTemplate =
			"Параметры = Новый Структура();
			|Параметры.Вставить(""ВидОбъекта"", ""%1"");
			|Параметры.Вставить(""ФормаСписка"", ""%1"");
			|Параметры.Вставить(""ИмяФормы"", ""%1"");
			|Параметры.Вставить(""ОткрытьФорму"", Истина);
			|Параметры.Вставить(""Отбор"", Новый Соответствие());
			|Параметры.Отбор.Вставить(""Проведен"", ""Да"");
			|
			|Возврат Параметры;";
		
	ElsIf ParentName = "Справочник" Then
		ScriptTemplate =
			"Параметры = Новый Структура();
			|Параметры.Вставить(""ВидОбъекта"", ""%1"");
			|Параметры.Вставить(""ФормаСписка"", ""%1"");
			|Параметры.Вставить(""ИмяФормы"", ""%1"");
			|Параметры.Вставить(""ОткрытьФорму"", Истина);
			|Параметры.Вставить(""Отбор"", Новый Соответствие());
			|Параметры.Отбор.Вставить(""Пометка удаления"", ""Нет"");
			|Параметры.Отбор.Вставить(""Это группа"", ""Нет"");
			|
			|Возврат Параметры;";
		
	Else
		Return "";
	EndIf;
	
	ScriptText = StrTemplate(ScriptTemplate, Description);
	
	Return ScriptText;
	
EndFunction

&AtServerNoContext
Function GetObjectFormScript(ParentName, Description)
	
	If ParentName = "Документ" Then
		ScriptTemplate =
			"Параметры = Вызвать(""Документ.%1.Параметры"");
			|Вызвать(""Документ.Провести"", Параметры);";
		
	ElsIf ParentName = "Обработка" Then
		ScriptTemplate =
			"Вызвать(""Обработка.Подключить"", ""%1"");
			|ЗакрытьВсе();";
		
	ElsIf ParentName = "Отчет" Then
		ScriptTemplate =
			"Вызвать(""Отчет.Подключить"", ""%1"");
			|
			|// Устанавливаем период
			|Установить(""!НачалоПериода"", __.ДатаНачалаОтчетов);
			|Установить(""!КонецПериода"", __.ДатаОкончанияОтчетов);
			|
			|Вызвать(""Отчет.Сформировать"");";
		
	ElsIf ParentName = "Справочник" Then
		ScriptTemplate =
			"Параметры = Вызвать(""Справочник.%1.Параметры"");
			|Вызвать(""Справочник.Записать"", Параметры);";
		
	Else
		Return "";
	EndIf;
	
	ScriptText = StrTemplate(ScriptTemplate, Description);
	
	Return ScriptText;
	
EndFunction

&AtServerNoContext
Function GetListFormScript(ParentName, Description)
	
	If ParentName = "Документ" Then
		ScriptTemplate =
			"Параметры = Вызвать(""Документ.%1.Параметры"");
			|Вызвать(""Документ.ОткрытьФормуСписка"", Параметры);
			|ЗакрытьВсе();";
		
	ElsIf ParentName = "Справочник" Then
		ScriptTemplate =
			"Параметры = Вызвать(""Справочник.%1.Параметры"");
			|Вызвать(""Справочник.ОткрытьФормуСписка"", Параметры);
			|ЗакрытьВсе();";
		
	Else
		Return "";
	EndIf;
	
	ScriptText = StrTemplate(ScriptTemplate, Description);
	
	Return ScriptText;
	
EndFunction

&AtServerNoContext
Function GetSelectionFormScript(ParentName, Description)
	
	If ParentName = "Документ" Then
		ScriptTemplate =
			"Параметры = Вызвать(""Документ.%1.Параметры"");
			|Вызвать(""Документ.ОткрытьФормуВыбора"", Параметры.ВидОбъекта);";
		
	ElsIf ParentName = "Справочник" Then
		ScriptTemplate =
			"Параметры = Вызвать(""Справочник.%1.Параметры"");
			|Вызвать(""Справочник.ОткрытьФормуВыбора"", Параметры.ВидОбъекта);";
		
	Else
		Return "";
	EndIf;
	
	ScriptText = StrTemplate(ScriptTemplate, Description);
	
	Return ScriptText;
	
EndFunction

&AtServerNoContext
Procedure AddDocumentScripts(Application, Description)
	
	// Add parent folder
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Description", "Документ");
	ParametersStructure.Insert("Type", Enums.Scenarios.Folder);
	
	ParentFolder = Undefined;
	AddScenarios(Application, ParametersStructure, ParentFolder);
	
	If Not ValueIsFilled(ParentFolder) Then
		Return;
	EndIf;
	
	// Add folder
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", ParentFolder);
	ParametersStructure.Insert("ParentName", "Документ");
	ParametersStructure.Insert("Description", Description);
	ParametersStructure.Insert("Type", Enums.Scenarios.Folder);
	
	Parent = Undefined;
	AddScenarios(Application, ParametersStructure, Parent);
	
	If Not ValueIsFilled(Parent) Then
		Return;
	EndIf;
	
	// Add parameters
	Script = GetParametersScript("Документ", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Документ." + Description);
	ParametersStructure.Insert("Description", "Параметры");
	ParametersStructure.Insert("Type", Enums.Scenarios.Method);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
	// Add object form
	Script = GetObjectFormScript("Документ", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Документ." + Description);
	ParametersStructure.Insert("Description", "ФормаОбъекта");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
	// Add list form
	Script = GetListFormScript("Документ", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Документ." + Description);
	ParametersStructure.Insert("Description", "ФормаСписка");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
	// Add selection form
	Script = GetSelectionFormScript("Документ", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Документ." + Description);
	ParametersStructure.Insert("Description", "ФормаВыбора");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
EndProcedure

&AtServerNoContext
Procedure AddDataProcessorsScripts(Application, Description)
	
	
	
EndProcedure

&AtServerNoContext
Procedure AddReportsScripts(Application, Description)
	
	// Add parent folder
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Description", "Отчет");
	ParametersStructure.Insert("Type", Enums.Scenarios.Folder);
	
	ParentFolder = Undefined;
	AddScenarios(Application, ParametersStructure, ParentFolder);
	
	If Not ValueIsFilled(ParentFolder) Then
		Return;
	EndIf;
	
	// Add folder
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", ParentFolder);
	ParametersStructure.Insert("ParentName", "Отчет");
	ParametersStructure.Insert("Description", Description);
	ParametersStructure.Insert("Type", Enums.Scenarios.Folder);
	
	Parent = Undefined;
	AddScenarios(Application, ParametersStructure, Parent);
	
	If Not ValueIsFilled(Parent) Then
		Return;
	EndIf;
	
	// Add form
	Script = GetObjectFormScript("Отчет", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Отчет." + Description);
	ParametersStructure.Insert("Description", "Форма");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
EndProcedure

&AtServerNoContext
Procedure AddCatalogsScripts(Application, Description)
	
	// Add parent folder
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Description", "Справочник");
	ParametersStructure.Insert("Type", Enums.Scenarios.Folder);
	
	ParentFolder = Undefined;
	AddScenarios(Application, ParametersStructure, ParentFolder);
	
	If Not ValueIsFilled(ParentFolder) Then
		Return;
	EndIf;
	
	// Add folder
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", ParentFolder);
	ParametersStructure.Insert("ParentName", "Справочник");
	ParametersStructure.Insert("Description", Description);
	ParametersStructure.Insert("Type", Enums.Scenarios.Folder);
	
	Parent = Undefined;
	AddScenarios(Application, ParametersStructure, Parent);
	
	If Not ValueIsFilled(Parent) Then
		Return;
	EndIf;
	
	// Add parameters
	Script = GetParametersScript("Справочник", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Справочник." + Description);
	ParametersStructure.Insert("Description", "Параметры");
	ParametersStructure.Insert("Type", Enums.Scenarios.Method);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
	// Add object form
	Script = GetObjectFormScript("Справочник", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Справочник." + Description);
	ParametersStructure.Insert("Description", "ФормаОбъекта");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
	// Add list form
	Script = GetListFormScript("Справочник", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Справочник." + Description);
	ParametersStructure.Insert("Description", "ФормаСписка");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
	// Add selection form
	Script = GetSelectionFormScript("Справочник", Description);
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Parent", Parent);
	ParametersStructure.Insert("ParentName", "Справочник." + Description);
	ParametersStructure.Insert("Description", "ФормаВыбора");
	ParametersStructure.Insert("Type", Enums.Scenarios.Scenario);
	ParametersStructure.Insert("Script", Script);
	
	AddScenarios(Application, ParametersStructure);
	
EndProcedure

&AtClient
Procedure SaveScenario(Command)
	
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	If StrFind(ScenarioName, ".") < 1 Then
		ErrorTemplate = NStr("ru = 'Имя скрипта: ""%1"" имеет ошибочный формат'");
		ErrorText = StrTemplate(ErrorTemplate, ScenarioName);
		
		Message = New UserMessage();
		Message.Text = ErrorText;
		Message.Message();
		Return;
	EndIf;
	
	ArrayScenarioName = StrSplit(ScenarioName, ".");
	TypeObject = ArrayScenarioName[0];
	Description = ArrayScenarioName[1];
	
	If IsBlankString(Description) Then
		ErrorTemplate = NStr("ru = 'Имя скрипта: ""%1"" имеет ошибочный формат'");
		ErrorText = StrTemplate(ErrorTemplate, ScenarioName);
		
		Message = New UserMessage();
		Message.Text = ErrorText;
		Message.Message();
		Return;
	EndIf;
	
	If TypeObject = "Документ" Then
		AddDocumentScripts(Application, Description);
	ElsIf TypeObject = "Обработка" Then
		AddDataProcessorsScripts(Application, Description);
	ElsIf TypeObject = "Отчет" Then
		AddReportsScripts(Application, Description);
	ElsIf TypeObject = "Справочник" Then
		AddCatalogsScripts(Application, Description);
	Else
		ErrorTemplate = NStr("ru = 'Указан недопустимый тип объекта: ""%1""'");
		ErrorText = StrTemplate(ErrorTemplate, TypeObject);
		
		Message = New UserMessage();
		Message.Text = ErrorText;
		Message.Message();
		Return;
	EndIf;
	
	RepositoryFiles.Sync();
	
EndProcedure