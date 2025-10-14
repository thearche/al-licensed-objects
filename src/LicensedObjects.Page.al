namespace TheArche.License;

page 88888 LicensedObjects
{
    ApplicationArea = All;
    Caption = 'Licensed Objects';
    SourceTable = LicensedObject;
    PageType = Worksheet;
    UsageCategory = Administration;
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ShowFilter = false;
    SaveValues = true;

    layout
    {
        area(Content)
        {
            group(Filter)
            {
                Caption = 'Filter';
                Editable = true;

                field(SelectedObjectType; SelectedObjectType)
                {
                    Caption = 'Object Type';
                    ToolTip = 'Specifies the type of the object.';
                }
                field(RangeMin; RangeMin)
                {
                    Caption = 'From Object No.';
                    ToolTip = 'Specifies the starting object number in the range.';
                }
                field(RangeMax; RangeMax)
                {
                    Caption = 'To Object No.';
                    ToolTip = 'Specifies the ending object number in the range.';
                }
            }

            group(Switches)
            {
                Caption = 'Switches';
                Editable = true;
                ShowCaption = false;
                field(HideMissingObjects; HideMissingObjects)
                {
                    Caption = 'Hide Missing Objects';
                    ToolTip = 'Specifies whether to hide objects that are missing but licensed.';
                }
                field(HideUnlicensedObjects; HideUnlicensedObjects)
                {
                    Caption = 'Hide Unlicensed Objects';
                    ToolTip = 'Specifies whether to hide unlicensed objects in the list.';
                }
            }
            repeater(Group)
            {
                Editable = false;
                field(ObjectType; Rec.ObjectType) { }
                field(ObjectNumber; Rec.ObjectNumber) { }
                field(ObjectName; Rec.ObjectName) { }
                field(ObjectCaption; Rec.ObjectCaption) { }
                field(ObjectSubtype; Rec.ObjectSubtype) { }
                field(AppPackageID; Rec.AppPackageID)
                {
                    Visible = false;
                }
                field(AppRuntimePackageID; Rec.AppRuntimePackageID)
                {
                    Visible = false;
                }
                field(AppName; Rec.AppName) { }
                field(AppVersion; Rec.AppVersion)
                {
                    Visible = false;
                }
                field(AppPublisher; Rec.AppPublisher)
                {
                    Visible = false;
                }
                field(ReadPermission; Rec.ReadPermission) { }
                field(InsertPermission; Rec.InsertPermission) { }
                field(ModifyPermission; Rec.ModifyPermission) { }
                field(DeletePermission; Rec.DeletePermission) { }
                field(ExecutePermission; Rec.ExecutePermission) { }
                field(LimitedUsagePermission; Rec.LimitedUsagePermission)
                {
                    Visible = false;
                }
            }
            group(Summary)
            {
                Caption = 'Summary';
                Editable = false;
                field(TotalCount; TotalCount)
                {
                    Caption = 'Total Objects';
                    ToolTip = 'Specifies the total number of objects in the current selection.';
                }
                field(MissingCount; TotalCountMissing)
                {
                    Caption = 'Missing Objects';
                    ToolTip = 'Specifies the number of missing objects in the current selection.';
                }
                field(UnlicensedCount; TotalCountUnlicensed)
                {
                    Caption = 'Unlicensed Objects';
                    ToolTip = 'Specifies the number of unlicensed objects in the current selection.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Refresh_Promoted; Refresh) { }
                actionref(AllObjects_Promoted; AllObjects) { }
                actionref(ExportHtml_Promoted; ExportHtml) { }
                actionref(ExportCsv_Promoted; ExportCsv) { }
            }
        }
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ToolTip = 'Refreshes the list of licensed objects.';
                Image = Refresh;
                trigger OnAction()
                begin
                    FillRec();
                end;
            }

            group(Export)
            {
                Caption = 'Export';

                action(ExportHtml)
                {
                    Caption = 'Export to HTML';
                    ToolTip = 'Exports the current data to an HTML file for download.';
                    Image = Export;

                    trigger OnAction()
                    begin
                        Rec.ExportToHTMLAndDownload();
                    end;
                }

                action(ExportCsv)
                {
                    Caption = 'Export to CSV';
                    ToolTip = 'Exports the current data to a CSV file for download.';
                    Image = ExportFile;

                    trigger OnAction()
                    begin
                        Rec.ExportToCSVAndDownload();
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(AllObjects)
            {
                Caption = 'All Objects';
                ToolTip = 'Shows All Objects with Caption.';
                RunObject = Page System.Reflection."All Objects with Caption";
                Image = ShowList;
            }
        }
    }

    trigger OnOpenPage()
    begin
        InitPage();
    end;

    var
        SelectedObjectType: Enum ObjectType;
        RangeMin, RangeMax : Integer;
        TotalCount, TotalCountMissing, TotalCountUnlicensed : Integer;
        HideUnlicensedObjects, HideMissingObjects : Boolean;

    local procedure FillRec()
    begin
        Rec.CopyDataToTempTables(SelectedObjectType.AsInteger(), RangeMin, RangeMax);
        UpdatePage();
    end;

    local procedure InitPage()
    begin
        HideMissingObjects := true;
        HideUnlicensedObjects := false;

        if Rec.IsEmpty() then begin
            RangeMin := 50000;
            RangeMax := 99999;
        end else
            SetRanges();
    end;

    local procedure SetRanges()
    begin
        Rec.SetCurrentKey(ObjectNumber);
        Rec.FindLast();
        RangeMax := Rec.ObjectNumber;
        Rec.FindFirst();
        RangeMin := Rec.ObjectNumber;
        UpdatePage();
    end;

    local procedure UpdatePage(): Boolean
    begin
        Rec.Reset();
        Rec.FilterGroup(2);
        TotalCount := Rec.Count();

        Rec.SetRange(Missing, true);
        TotalCountMissing := Rec.Count();
        Rec.SetRange(Missing);

        Rec.SetRange(Licensed, false);
        TotalCountUnlicensed := Rec.Count();
        Rec.SetRange(Licensed);

        if HideUnlicensedObjects then
            Rec.SetRange(Licensed, true);
        if HideMissingObjects then
            Rec.SetRange(Missing, false);

        Rec.FilterGroup(0);
        exit(Rec.FindFirst());
    end;
}
