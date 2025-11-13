namespace TheArche.License;

pageextension 88888 Objects extends System.Reflection."All Objects with Caption"
{
    layout
    {
        addlast(Control1102601000)
        {
            field(Licensed; this.IsLicensedObject())
            {
                ApplicationArea = All;
                Caption = 'Licensed';
                Editable = false;
                StyleExpr = PageStyleExpression;
            }
        }
    }
    actions
    {
        addfirst(Category_Process)
        {
            actionref(GetLicensedObjects_Promoted; GetLicensedObjects) { }
            actionref(InspectLicensedObjects_Promoted; InspectLicensedObjects) { }
        }
        addfirst(Navigation)
        {
            action(GetLicensedObjects)
            {
                ApplicationArea = All;
                Caption = 'Licensed Objects';
                Image = SetupPayment;
                trigger OnAction()
                begin
                    this.InitTempLicensedObject();
                end;
            }
        }
        addfirst(Processing)
        {
            action(InspectLicensedObjects)
            {
                ApplicationArea = All;
                Caption = 'View Licensed Objects (CSV)';
                Ellipsis = true;
                Image = Payment;
                Visible = LicensingVisible;
                trigger OnAction()
                begin
                    this.InspectLicensedObjectsCSV();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if LicensingVisible then
            this.UpdateLicensePage();
    end;

    protected var
        TempLicensedObject: Record LicensedObject temporary;
        LicensingVisible: Boolean;
        PageStyleExpression: Text;

    local procedure InspectLicensedObjectsCSV()
    begin
        if not LicensingVisible then
            exit;

        TempLicensedObject.Get(Enum::ObjectType::Page, Page::LicensedObjects);
        if TempLicensedObject.Licensed then
            Page.Run(0, TempLicensedObject)
        else
            TempLicensedObject.ExportToCSVAndDownload();
    end;

    local procedure GetPageStyleExpression(): Text
    var
        StyleExpression: PageStyle;
    begin
        StyleExpression := IsLicensedObject() ? PageStyle::Unfavorable : PageStyle::Favorable;
        exit(Format(StyleExpression));
    end;

    local procedure InitTempLicensedObject()
    begin
        TempLicensedObject.CopyDataToTempTables(0, 50000, 99999);
        LicensingVisible := not TempLicensedObject.IsEmpty();
        Rec.SetRange("Object ID", 50000, 99999);
        CurrPage.Update(false);
    end;

    local procedure IsLicensedObject(): Boolean
    begin
        if TempLicensedObject.Get(TempLicensedObject.GetObjectTypeEnum(Rec."Object Type"), Rec."Object ID") then
            exit(TempLicensedObject.Licensed);
    end;

    local procedure UpdateLicensePage()
    begin
        PageStyleExpression := this.GetPageStyleExpression();
    end;

}