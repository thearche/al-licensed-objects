namespace TheArche.License;

table 88888 LicensedObject
{
    Scope = Cloud;
    TableType = Temporary;
    DataClassification = SystemMetadata;
    DrillDownPageId = LicensedObjects;
    LookupPageId = LicensedObjects;
    Permissions = tabledata System.Reflection.AllObjWithCaption = r, tabledata System.Security.AccessControl."License Permission" = r;

    fields
    {
        field(1; ObjectType; Enum ObjectType)
        {
            Caption = 'Object Type';
            ToolTip = 'Specifies the type of the object.';
        }
        field(2; ObjectNumber; Integer)
        {
            Caption = 'Object Number';
            ToolTip = 'Specifies the number of the object.';
        }
        field(4; ObjectName; Text[30])
        {
            Caption = 'Object Name';
            ToolTip = 'Specifies the name of the object.';
        }
        field(10; ReadPermission; Enum System.Security.AccessControl.Permission)
        {
            Caption = 'Read Permission';
            ToolTip = 'Specifies the read permission for the object.';
        }
        field(11; InsertPermission; Enum System.Security.AccessControl.Permission)
        {
            Caption = 'Insert Permission';
            ToolTip = 'Specifies the insert permission for the object.';
        }
        field(12; ModifyPermission; Enum System.Security.AccessControl.Permission)
        {
            Caption = 'Modify Permission';
            ToolTip = 'Specifies the modify permission for the object.';
        }
        field(13; DeletePermission; Enum System.Security.AccessControl.Permission)
        {
            Caption = 'Delete Permission';
            ToolTip = 'Specifies the delete permission for the object.';
        }
        field(14; ExecutePermission; Enum System.Security.AccessControl.Permission)
        {
            Caption = 'Execute Permission';
            ToolTip = 'Specifies the execute permission for the object.';
        }
        field(15; LimitedUsagePermission; Option)
        {
            Caption = 'Limited Usage Permission';
            ToolTip = 'Specifies the limited usage permission for the object.';
            OptionMembers = " ",Included,Excluded,Optional;
        }
        field(20; ObjectCaption; Text[249])
        {
            Caption = 'Object Caption';
            ToolTip = 'Specifies the caption of the object.';
        }
        field(30; ObjectSubtype; Text[30])
        {
            Caption = 'Object Subtype';
            ToolTip = 'Specifies the subtype of the object.';
        }
        field(60; AppPackageID; Guid)
        {
            Caption = 'App Package ID';
            ToolTip = 'Specifies the ID of the app package.';
        }
        field(61; AppRuntimePackageID; Guid)
        {
            Caption = 'App Runtime Package ID';
            ToolTip = 'Specifies the ID of the app runtime package.';
        }
        field(62; AppName; Text[250])
        {
            Caption = 'App Name';
            ToolTip = 'Specifies the name of the app.';
        }
        field(63; AppVersion; Text[50])
        {
            Caption = 'App Version';
            ToolTip = 'Specifies the version of the app.';
        }
        field(64; AppPublisher; Text[250])
        {
            Caption = 'App Publisher';
            ToolTip = 'Specifies the publisher of the app.';
        }
        field(100; Missing; Boolean)
        {
            Caption = 'Missing';
            ToolTip = 'Specifies whether the object is missing.';
        }
        field(101; Licensed; Boolean)
        {
            Caption = 'Licensed';
            ToolTip = 'Specifies whether the object is licensed.';
        }
        field(102; Temporary; Boolean)
        {
            Caption = 'Temporary';
            ToolTip = 'Specifies whether the record is temporary.';
        }
    }

    keys
    {
        key(PK; ObjectType, ObjectNumber)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; ObjectType, ObjectNumber, ObjectName) { }
        fieldgroup(Brick; ObjectType, ObjectNumber, ObjectName) { }
    }

    trigger OnInsert()
    begin
        Update();
    end;

    trigger OnModify()
    begin
        Update();
    end;

    internal procedure CopyDataToTempTables(SelectedObjectTypeValue: Integer; RangeMin: Integer; RangeMax: Integer)
    begin
        ClearRec();
        InsertLicensePermission(SelectedObjectTypeValue, RangeMin, RangeMax);
        UpsertFromAllObjects(SelectedObjectTypeValue, RangeMin, RangeMax);
    end;

    internal procedure ExportToCSVAndDownload()
    var
        TempBlob: Codeunit System.Utilities."Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        CSV: Text;
        FileName: Text;
        CsvFileTok: Label '.csv', Locked = true;
        DownloadCsvTok: Label 'CSV Files (*.csv)|*.csv', Locked = true;
        ExportLicensedObjectsTok: Label 'Export Licensed Objects', Locked = true;
        FilenamePrefixTok: Label 'LicensedObjects_', Locked = true;
        FormattedDateTimeTok: Label '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>', Locked = true;
    begin
        if Rec.IsEmpty() then
            exit;

        // CSV-Inhalt generieren
        CSV := GenerateCSVContent();

        // Temporäre Datei erstellen
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(CSV);
        TempBlob.CreateInStream(InStream);

        // Dateiname mit Zeitstempel erstellen
        FileName := FilenamePrefixTok + Format(CurrentDateTime(), 0, FormattedDateTimeTok) + CsvFileTok;

        // Datei zum Download anbieten
        DownloadFromStream(InStream, ExportLicensedObjectsTok, '', DownloadCsvTok, FileName);
    end;

    internal procedure ExportToHTMLAndDownload()
    var
        TempBlob: Codeunit System.Utilities."Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
        HtmlContent: Text;
        DownloadHtmlTok: Label 'HTML Files (*.html)|*.html', Locked = true;
        ExportLicensedObjectsTok: Label 'Export Licensed Objects', Locked = true;
        FilenamePrefixTok: Label 'LicensedObjects_', Locked = true;
        FormattedDateTimeTok: Label '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>', Locked = true;
        HtmlFileTok: Label '.html', Locked = true;
    begin
        if Rec.IsEmpty() then
            exit;

        // HTML-Inhalt generieren
        HtmlContent := GenerateHtmlContent();

        // Temporäre Datei erstellen
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(HtmlContent);
        TempBlob.CreateInStream(InStream);

        // Dateiname mit Zeitstempel erstellen
        FileName := FilenamePrefixTok + Format(CurrentDateTime(), 0, FormattedDateTimeTok) + HtmlFileTok;

        // Datei zum Download anbieten
        DownloadFromStream(InStream, ExportLicensedObjectsTok, '', DownloadHtmlTok, FileName);
    end;

    #region Permission

    procedure GetObjectTypeEnum(ObjectTypeOption: Option): Enum ObjectType
    begin
        exit(Enum::ObjectType.FromInteger(OptionToEnum(ObjectTypeOption)));
    end;

    local procedure ClearRec()
    begin
        Reset();
        if not IsEmpty() then
            DeleteAll();
    end;

    local procedure EnumToOption(EnumValue: Integer) OptionValue: Integer
    var
        ObjectTypeOption: Option "TableData","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System","FieldNumber","LimitedUsageTableData",,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension","PermissionSet","PermissionSetExtension","ReportExtension";
    begin
        case EnumValue of
            Enum::ObjectType::Table.AsInteger():
                OptionValue := ObjectTypeOption::"Table";
            Enum::ObjectType::Report.AsInteger():
                OptionValue := ObjectTypeOption::"Report";
            Enum::ObjectType::Codeunit.AsInteger():
                OptionValue := ObjectTypeOption::"Codeunit";
            Enum::ObjectType::XMLport.AsInteger():
                OptionValue := ObjectTypeOption::"XMLport";
            Enum::ObjectType::MenuSuite.AsInteger():
                OptionValue := ObjectTypeOption::"MenuSuite";
            Enum::ObjectType::Page.AsInteger():
                OptionValue := ObjectTypeOption::"Page";
            Enum::ObjectType::Query.AsInteger():
                OptionValue := ObjectTypeOption::"Query";
        end;
    end;

    local procedure InsertLicensePermission(ObjectTypeValue: Integer; RangeMin: Integer; RangeMax: Integer)
    var
        Iterator: Integer;
    begin
        if ObjectTypeValue <> 0 then
            InsertPermissionByType(ObjectTypeValue, RangeMin, RangeMax)
        else
            for Iterator := Enum::ObjectType::Table.AsInteger() to Enum::ObjectType::Query.AsInteger() do
                InsertPermissionByType(Iterator, RangeMin, RangeMax);
    end;

    local procedure InsertPermissionByType(ObjectTypeValue: Integer; RangeMin: Integer; RangeMax: Integer)
    var
        LicensePermission: Record System.Security.AccessControl."License Permission";
        ConfirmManagement: Codeunit System.Utilities."Confirm Management";
        ProgressDialog: Codeunit Microsoft.Utilities."Progress Dialog";
    begin
        LicensePermission.SetRange("Object Number", RangeMin, RangeMax);
        LicensePermission.SetRange("Object Type", EnumToOption(ObjectTypeValue));
        if ObjectTypeValue = Enum::ObjectType::Codeunit.AsInteger() then
            LicensePermission.SetRange("Execute Permission", LicensePermission."Execute Permission"::Yes)
        else
            LicensePermission.SetRange("Read Permission", LicensePermission."Read Permission"::Yes);

        if not ConfirmManagement.GetResponse('') then
            exit;

        if not LicensePermission.FindSet(false) then
            if GuiAllowed() then
                ProgressDialog.OpenCopyCountMax(Format(LicensePermission."Object Type"), LicensePermission.Count());
        repeat
            if GuiAllowed() then
                ProgressDialog.UpdateCopyCount();
            Init();
            ObjectType := GetObjectTypeEnum(LicensePermission."Object Type");
            ObjectNumber := LicensePermission."Object Number";
            Transfer(LicensePermission);
            Insert(true);
        until LicensePermission.Next() = 0;
    end;

    local procedure MapPermission(PermissionOption: Option " ",Yes,Indirect) PermissionEnum: Enum System.Security.AccessControl.Permission
    begin
        case PermissionOption of
            PermissionOption::Yes:
                exit(PermissionEnum::Direct);

            PermissionOption::Indirect:
                exit(PermissionEnum::Indirect);

            PermissionOption::" ":
                exit(PermissionEnum::None);
        end;
    end;

    local procedure OptionToEnum(OptionValue: Integer) EnumValue: Integer
    var
        ObjectTypeOption: Option "TableData","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System","FieldNumber","LimitedUsageTableData",,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension","PermissionSet","PermissionSetExtension","ReportExtension";
    begin
        case OptionValue of
            ObjectTypeOption::"Table":
                EnumValue := Enum::ObjectType::Table.AsInteger();
            ObjectTypeOption::"Report":
                EnumValue := Enum::ObjectType::Report.AsInteger();
            ObjectTypeOption::"Codeunit":
                EnumValue := Enum::ObjectType::Codeunit.AsInteger();
            ObjectTypeOption::"XMLport":
                EnumValue := Enum::ObjectType::XMLport.AsInteger();
            ObjectTypeOption::"MenuSuite":
                EnumValue := Enum::ObjectType::MenuSuite.AsInteger();
            ObjectTypeOption::"Page":
                EnumValue := Enum::ObjectType::Page.AsInteger();
            ObjectTypeOption::"Query":
                EnumValue := Enum::ObjectType::Query.AsInteger();
        end;
    end;

    local procedure SetAppInfo()
    var
        NAVAppInstalledApp: Record System.Apps."NAV App Installed App";
        Info: ModuleInfo;
    begin
        NAVAppInstalledApp.SetRange("Package ID", AppPackageID);
        if not NAVAppInstalledApp.FindFirst() then
            exit;

        NavApp.GetModuleInfo(NAVAppInstalledApp."App ID", Info);
        AppName := Info.Name();
        AppVersion := Format(Info.AppVersion());
        AppPublisher := Info.Publisher();
    end;

    local procedure Transfer(AllObjWithCaption: Record System.Reflection.AllObjWithCaption)
    begin
        ObjectName := AllObjWithCaption."Object Name";
        ObjectCaption := AllObjWithCaption."Object Caption";
        ObjectSubtype := AllObjWithCaption."Object Subtype";
        AppPackageID := AllObjWithCaption."App Package ID";
        AppRuntimePackageID := AllObjWithCaption."App Runtime Package ID";
        SetAppInfo();
    end;

    local procedure Transfer(LicensePermission: Record System.Security.AccessControl."License Permission")
    begin
        ReadPermission := MapPermission(LicensePermission."Read Permission");
        InsertPermission := MapPermission(LicensePermission."Insert Permission");
        ModifyPermission := MapPermission(LicensePermission."Modify Permission");
        DeletePermission := MapPermission(LicensePermission."Delete Permission");
        ExecutePermission := MapPermission(LicensePermission."Execute Permission");
        LimitedUsagePermission := LicensePermission."Limited Usage Permission";
    end;

    local procedure Update()
    begin
        Missing := ObjectName = '';
        Licensed := ReadPermission = ReadPermission::Direct;
        Temporary := ObjectSubtype = 'Temporary';
    end;

    local procedure UpsertFromAllObjects(ObjectTypeValue: Integer; RangeMin: Integer; RangeMax: Integer)
    var
        Iterator: Integer;
    begin
        if ObjectTypeValue <> 0 then
            UpsertFromAllObjectsByType(ObjectTypeValue, RangeMin, RangeMax)
        else
            for Iterator := Enum::ObjectType::Table.AsInteger() to Enum::ObjectType::Query.AsInteger() do
                UpsertFromAllObjectsByType(Iterator, RangeMin, RangeMax);
    end;

    local procedure UpsertFromAllObjectsByType(ObjectTypeValue: Integer; RangeMin: Integer; RangeMax: Integer)
    var
        AllObjWithCaption: Record System.Reflection.AllObjWithCaption;
        Found: Boolean;
    begin
        AllObjWithCaption.SetRange("Object ID", RangeMin, RangeMax);
        AllObjWithCaption.SetRange("Object Type", EnumToOption(ObjectTypeValue));
        if AllObjWithCaption.FindSet() then
            repeat
                Init();
                ObjectType := Enum::ObjectType.FromInteger(OptionToEnum(AllObjWithCaption."Object Type"));
                ObjectNumber := AllObjWithCaption."Object ID";
                Found := Find();

                Transfer(AllObjWithCaption);
                if Found then
                    Modify(true)
                else
                    Insert(true);
            until AllObjWithCaption.Next() = 0;
    end;

    #endregion

    #region CSV Export

    local procedure AddCSVHeader(var CSV: List of [List of [Text]])
    var
        CSVLine: List of [Text];
    begin
        CSVLine.Add('ObjectType');
        CSVLine.Add('FromObjectID');
        CSVLine.Add('ToObjectID');
        CSVLine.Add('Read');
        CSVLine.Add('Insert');
        CSVLine.Add('Modify');
        CSVLine.Add('Delete');
        CSVLine.Add('Execute');
        CSV.Add(CSVLine);
    end;

    local procedure Delimiter(): Char
    begin
        exit(',');
    end;

    local procedure FormatPermissionForCsv(Permission: Enum System.Security.AccessControl.Permission): Text
    begin
        case Permission of
            Permission::Direct:
                exit('Direct');
            Permission::Indirect:
                exit('Indirect');
            Permission::None:
                exit('');
        end;
    end;

    local procedure GenerateCSVContent(): Text
    var
        TempLicensedObject: Record LicensedObject temporary;
        CSV: List of [List of [Text]];
        CSVContent: List of [List of [Text]];
        CSVLine: List of [Text];
    begin
        TempLicensedObject.Copy(Rec, true);
        TempLicensedObject.FindSet();
        repeat
            CSVContent.Add(GenerateLine(TempLicensedObject));
        until TempLicensedObject.Next() = 0;

        AddCSVHeader(CSV);
        GroupLines(CSVContent);
        foreach CSVLine in CSVContent do
            CSV.Add(CSVLine);
        exit(ToText(CSV));
    end;

    local procedure GenerateLine(TempLicensedObject: Record LicensedObject temporary) CSVLine: List of [Text]
    begin
        CSVLine.Add(Format(TempLicensedObject.ObjectType));
        CSVLine.Add(Format(TempLicensedObject.ObjectNumber));
        CSVLine.Add(Format(TempLicensedObject.ObjectNumber));
        CSVLine.Add(FormatPermissionForCsv(TempLicensedObject.ReadPermission));
        CSVLine.Add(FormatPermissionForCsv(TempLicensedObject.InsertPermission));
        CSVLine.Add(FormatPermissionForCsv(TempLicensedObject.ModifyPermission));
        CSVLine.Add(FormatPermissionForCsv(TempLicensedObject.DeletePermission));
        CSVLine.Add(FormatPermissionForCsv(TempLicensedObject.ExecutePermission));
    end;

    local procedure GroupLines(var CSV: List of [List of [Text]])
    var
        CurrentLine: List of [Text];
        GroupedCSV: List of [List of [Text]];
        LastLine: List of [Text];
    begin
        foreach CurrentLine in CSV do
            if not LinesAreEqual(CurrentLine, LastLine) then begin
                if LastLine.Count() > 0 then
                    GroupedCSV.Add(LastLine);
                LastLine := CurrentLine;
            end else
                IncrementToObjectID(LastLine);

        GroupedCSV.Add(LastLine);
        CSV := GroupedCSV;
    end;

    local procedure IncrementToObjectID(var LastLine: List of [Text])
    begin
        LastLine.Set(3, IncStr(LastLine.Get(3)));
    end;

    local procedure LinesAreEqual(CurrentLine: List of [Text]; LastLine: List of [Text]): Boolean
    begin
        if LastLine.Count() = 0 then
            exit(false);

        exit(
            // ObjectType
            (CurrentLine.Get(1) = LastLine.Get(1)) and
            // ObjectNumber
            (CurrentLine.Get(2) = IncStr(LastLine.Get(3))) and
            // Read
            (CurrentLine.Get(4) = LastLine.Get(4)) and
            // Insert
            (CurrentLine.Get(5) = LastLine.Get(5)) and
            // Modify
            (CurrentLine.Get(6) = LastLine.Get(6)) and
            // Delete
            (CurrentLine.Get(7) = LastLine.Get(7)) and
            // Execute
            (CurrentLine.Get(8) = LastLine.Get(8))
        );
    end;

    local procedure ToText(var CSV: List of [List of [Text]]): Text
    var
        Column: Text;
        CSVLine: List of [Text];
        CSVContent: TextBuilder;
    begin
        foreach CSVLine in CSV do begin
            foreach Column in CSVLine do
                CSVContent.Append(Column + Delimiter());
            CSVContent.AppendLine();
        end;
        exit(CSVContent.ToText());
    end;

    #endregion

    #region HTML Export

    local procedure FormatBooleanForHtml(Value: Boolean): Text
    begin
        if Value then
            exit('<span style="color: #27ae60; font-weight: bold;">✓ Yes</span>')
        else
            exit('<span style="color: #e74c3c;">✗ No</span>');
    end;

    local procedure FormatPermissionForHtml(Permission: Enum System.Security.AccessControl.Permission): Text
    begin
        case Permission of
            Permission::Direct:
                exit('<span class="permission-direct">Direct</span>');
            Permission::Indirect:
                exit('<span class="permission-indirect">Indirect</span>');
            Permission::None:
                exit('<span class="permission-none">None</span>');
        end;
    end;

    local procedure GenerateHtmlContent(): Text
    var
        TempLicensedObject: Record LicensedObject temporary;
        PermissionText: Text;
        HtmlBuilder: TextBuilder;
    begin
        // HTML Header und CSS-Styling
        HtmlBuilder.AppendLine('<!DOCTYPE html>');
        HtmlBuilder.AppendLine('<html>');
        HtmlBuilder.AppendLine('<head>');
        HtmlBuilder.AppendLine('<meta charset="UTF-8">');
        HtmlBuilder.AppendLine('<title>Licensed Objects Export</title>');
        HtmlBuilder.AppendLine('<style>');
        HtmlBuilder.AppendLine('body { font-family: Arial, sans-serif; margin: 20px; }');
        HtmlBuilder.AppendLine('h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }');

        // Table Styling
        HtmlBuilder.AppendLine('table { border-collapse: collapse; width: 100%; margin-top: 20px; }');
        HtmlBuilder.AppendLine('th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }');
        HtmlBuilder.AppendLine('th { background-color: #3498db; color: white; font-weight: bold; position: sticky; top: 0; z-index: 10; }');
        HtmlBuilder.AppendLine('tr:nth-child(even) { background-color: #f2f2f2; }');
        HtmlBuilder.AppendLine('tr:hover { background-color: #e8f4f8; }');

        // CSS Classes for different object states
        HtmlBuilder.AppendLine('.missing { background-color: #ffebee !important; }');
        HtmlBuilder.AppendLine('.temporary { background-color: #fff3e0 !important; }');
        HtmlBuilder.AppendLine('.licensed { background-color: #e8f5e8 !important; }');
        HtmlBuilder.AppendLine('.unlicensed { background-color: #fce4ec !important; }');

        // Permission styling
        HtmlBuilder.AppendLine('.permission-direct { color: #27ae60; font-weight: bold; }');
        HtmlBuilder.AppendLine('.permission-indirect { color: #f39c12; }');
        HtmlBuilder.AppendLine('.permission-none { color: #e74c3c; }');

        // CSS Classes for different object states
        HtmlBuilder.AppendLine('.missing { background-color: #ffebee !important; }');
        HtmlBuilder.AppendLine('.temporary { background-color: #fff3e0 !important; }');
        HtmlBuilder.AppendLine('.licensed { background-color: #e8f5e8 !important; }');
        HtmlBuilder.AppendLine('.unlicensed { background-color: #fce4ec !important; }');

        HtmlBuilder.AppendLine('</style>');
        HtmlBuilder.AppendLine('</head>');
        HtmlBuilder.AppendLine('<body>');

        // Titel und Export-Info
        HtmlBuilder.AppendLine('<h1>Licensed Objects Export</h1>');
        HtmlBuilder.AppendLine('<p><strong>Export Date:</strong> ' + Format(CurrentDateTime, 0, '<Day,2>.<Month,2>.<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>') + '</p>');

        // Table Container
        HtmlBuilder.AppendLine('<div class="table-container">');

        // Tabellenkopf
        HtmlBuilder.AppendLine('<table>');
        HtmlBuilder.AppendLine('<thead>');
        HtmlBuilder.AppendLine('<tr>');
        HtmlBuilder.AppendLine('<th>Object Type</th>');
        HtmlBuilder.AppendLine('<th>Object Number</th>');
        HtmlBuilder.AppendLine('<th>Object Name</th>');
        HtmlBuilder.AppendLine('<th>Object Caption</th>');
        HtmlBuilder.AppendLine('<th>Read</th>');
        HtmlBuilder.AppendLine('<th>Insert</th>');
        HtmlBuilder.AppendLine('<th>Modify</th>');
        HtmlBuilder.AppendLine('<th>Delete</th>');
        HtmlBuilder.AppendLine('<th>Execute</th>');
        HtmlBuilder.AppendLine('<th>App Name</th>');
        HtmlBuilder.AppendLine('<th>App Version</th>');
        HtmlBuilder.AppendLine('<th>App Publisher</th>');
        HtmlBuilder.AppendLine('<th>Exists</th>');
        HtmlBuilder.AppendLine('<th>Licensed</th>');
        HtmlBuilder.AppendLine('<th>Temporary</th>');
        HtmlBuilder.AppendLine('</tr>');
        HtmlBuilder.AppendLine('</thead>');
        HtmlBuilder.AppendLine('<tbody>');

        // Datenzeilen
        TempLicensedObject.Copy(Rec, true);
        if TempLicensedObject.FindSet() then
            repeat
                HtmlBuilder.AppendLine('<tr class="' + GetCSSStyle(TempLicensedObject) + '">');

                HtmlBuilder.AppendLine('<td>' + Format(TempLicensedObject.ObjectType) + '</td>');
                HtmlBuilder.AppendLine('<td>' + Format(TempLicensedObject.ObjectNumber) + '</td>');
                HtmlBuilder.AppendLine('<td>' + TempLicensedObject.ObjectName + '</td>');
                HtmlBuilder.AppendLine('<td>' + TempLicensedObject.ObjectCaption + '</td>');

                // Berechtigungen mit Formatierung
                HtmlBuilder.AppendLine('<td>' + FormatPermissionForHtml(TempLicensedObject.ReadPermission) + '</td>');
                HtmlBuilder.AppendLine('<td>' + FormatPermissionForHtml(TempLicensedObject.InsertPermission) + '</td>');
                HtmlBuilder.AppendLine('<td>' + FormatPermissionForHtml(TempLicensedObject.ModifyPermission) + '</td>');
                HtmlBuilder.AppendLine('<td>' + FormatPermissionForHtml(TempLicensedObject.DeletePermission) + '</td>');
                HtmlBuilder.AppendLine('<td>' + FormatPermissionForHtml(TempLicensedObject.ExecutePermission) + '</td>');

                HtmlBuilder.AppendLine('<td>' + TempLicensedObject.AppName + '</td>');
                HtmlBuilder.AppendLine('<td>' + TempLicensedObject.AppVersion + '</td>');
                HtmlBuilder.AppendLine('<td>' + TempLicensedObject.AppPublisher + '</td>');
                HtmlBuilder.AppendLine('<td>' + FormatBooleanForHtml(not TempLicensedObject.Missing) + '</td>');
                HtmlBuilder.AppendLine('<td>' + FormatBooleanForHtml(TempLicensedObject.Licensed) + '</td>');
                HtmlBuilder.AppendLine('<td>' + SimpleFormatBooleanForHtml(TempLicensedObject.Temporary) + '</td>');
                HtmlBuilder.AppendLine('</tr>');
            until TempLicensedObject.Next() = 0;

        // HTML Footer
        HtmlBuilder.AppendLine('</tbody>');
        HtmlBuilder.AppendLine('</table>');
        HtmlBuilder.AppendLine('</div>'); // Close table-container

        HtmlBuilder.AppendLine('<p><small>Generated by Licensed Object View Extension</small></p>');
        HtmlBuilder.AppendLine('</body>');
        HtmlBuilder.AppendLine('</html>');

        exit(HtmlBuilder.ToText());
    end;

    local procedure GetCSSStyle(var LicensedObjectRec: Record LicensedObject temporary): Text
    begin
        if LicensedObjectRec.Missing then
            exit('missing');
        if not LicensedObjectRec.Licensed and not LicensedObjectRec.Temporary then
            exit('unlicensed');
        if LicensedObjectRec.Licensed and LicensedObjectRec.Temporary then
            exit('temporary');
        exit('licensed');
    end;

    local procedure SimpleFormatBooleanForHtml(Value: Boolean): Text
    begin
        if Value then
            exit('<span style="font-weight: bold;">✓ Yes</span>')
        else
            exit('<span>✗ No</span>');
    end;

    #endregion

}
