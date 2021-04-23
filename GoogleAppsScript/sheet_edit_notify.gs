function onEdit(e) {
    var range = e.range;
    if (range.getSheet().getName()=='Setting') return;
    
    range.setNote('Last modified: ' + new Date());
  
    try{
      var Sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Setting");
      var edit_list = Sheet.getRange("Setting!A:C").getValues();
    }
    catch (exception){
      SpreadsheetApp.getActiveSpreadsheet().insertSheet('Setting');
      var Sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Setting");
      var edit_list = Sheet.getRange("Setting!A:C").getValues();
    }
  
    var i=0
    for (;i<edit_list.length;i++){
      if (edit_list[i][0]=='') {
        Sheet.getRange(i+1, 1).setValue(range.getSheet().getName());
        Sheet.getRange(i+1, 2).setValue(range.getRow());
        Sheet.getRange(i+1, 3).setValue(range.getColumn());
        return;
      }
    }
    Sheet.getRange(i+1, 1).setValue(range.getSheet().getName());
    Sheet.getRange(i+1, 2).setValue(range.getRow());
    Sheet.getRange(i+1, 3).setValue(range.getColumn());
  }
  
function check_edit()
  {
    try{
      var Sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Setting");
      var edit_list = Sheet.getRange("Setting!A:C").getValues();
    }
    catch (exception){
      SpreadsheetApp.getActiveSpreadsheet().insertSheet('Setting');
      var Sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Setting");
      var edit_list = Sheet.getRange("Setting!A:C").getValues();
    }
  
    counter = 0;
    mail_context = 'Hi,\n\n There are the updates at the cell \n';
  
    // Logger.log(edit_list);
    for (var i=0;i<edit_list.length;i++){
      if (edit_list[i][0]!='' && edit_list[i][1]!='' && edit_list[i][2]!='') {
        mail_context = mail_context + '- Sheet: ' + edit_list[i][0] + '!' + num_to_column(edit_list[i][2]) + edit_list[i][1] + ' \n';
        Sheet.getRange(i+1, 1).clear();
        Sheet.getRange(i+1, 2).clear();
        Sheet.getRange(i+1, 3).clear();
        counter++;
      }
    }
  
    if (counter > 0) notify_mail('Google Sheet Update ', mail_context);
  }
  
  