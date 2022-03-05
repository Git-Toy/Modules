
&AtServer
Function FindTest(TestName)
	
	Test = Catalogs.Scenarios.FindByAttribute("Path", TestName);
	If ValueIsFilled(Test) Then
		Return True;
	EndIf;
	
	Return False;
	
EndFunction

&AtServer
Procedure ShowResult(MapUsers)
	
	TableResult.Clear();
	DataProcessorsObject = FormAttributeToValue("Object");
	TemplateResult = DataProcessorsObject.GetTemplate("Template");
	LineArea = TemplateResult.GetArea("Line");
	
	For Each UserMapItem In MapUsers Do
		UserName = UserMapItem.Key;
		ScenariosList = StrConcat(UserMapItem.Value, ";");
		
		LineArea.Parameters.UserName = UserName;
		LineArea.Parameters.ScenariosList = ScenariosList;
		
		TableResult.Put(LineArea);
	EndDo;
	
EndProcedure

&AtClient
Procedure RunProcessing(Command)
	
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	MapUsers = New Map;
	ArrayUsersTests = StrSplit(TestsList, Chars.LF, False);
	TestArraySize = 3;
	
	For Each StringUserTest In ArrayUsersTests Do
		If IsBlankString(StringUserTest) Then
			Continue;
		EndIf;
		
		ArrayUserTest = StrSplit(StringUserTest, Chars.Tab, False);
		If ArrayUserTest.Count() <> TestArraySize Then
			Continue;
		EndIf;
		
		UserName = TrimAll(ArrayUserTest[0]);
		If IsBlankString(UserName) Then
			Continue;
		EndIf;
		
		TestName = TrimAll(ArrayUserTest[1]);
		If IsBlankString(TestName) Then
			Continue;
		EndIf;
		
		If Not FindTest(TestName) Then
			ErrorTemplate = NStr("ru = 'Тест не найден: %1'");
			ErrorText = StrTemplate(ErrorTemplate, TestName);
			
			Message = New UserMessage();
			Message.Text = ErrorText;
			Message.Message();
			Continue;
		EndIf;
		
		ArrayTests = MapUsers.Get(UserName);
		If ArrayTests = Undefined Then
			ArrayTests = New Array;
			MapUsers.Insert(UserName, ArrayTests);
		EndIf;
		
		If ArrayTests.Find(TestName) = Undefined Then
			ArrayTests.Add(TestName);
		EndIf;
	EndDo;
	
	ShowResult(MapUsers);

EndProcedure
