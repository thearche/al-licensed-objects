namespace TheArche.License;

pageextension 88888 Objects extends System.Reflection."All Objects with Caption"
{
    actions
    {
        addfirst(Promoted)
        {
            actionref(LicensedObjects_Promoted; LicensedObjects) { }
        }
        addfirst(Navigation)
        {
            action(LicensedObjects)
            {
                ApplicationArea = All;
                Caption = 'Licensed Objects';
                Ellipsis = true;
                Image = Payment;
                trigger OnAction()
                var
                    TempLicensedObject: Record LicensedObject temporary;
                begin
                    TempLicensedObject.CopyDataToTempTables(0, 50000, 99999);
                    TempLicensedObject.Get(Enum::ObjectType::Page, Page::LicensedObjects);
                    if TempLicensedObject.Licensed then
                        Page.Run(0, TempLicensedObject)
                    else
                        TempLicensedObject.ExportToCSVAndDownload();
                end;
            }
        }
    }
}