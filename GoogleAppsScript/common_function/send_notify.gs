function notify_mail(subject, body) {
  var d = new Date();
  const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  var sendlist = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Setting").getRange("Setting!E:F").getValues();

  var sendto = [];
  var sendcc = [];

  for (var i=1;i<sendlist.length;i++){
    if (sendlist[i][0]!='') sendto.push(sendlist[i][0]);
    if (sendlist[i][1]!='') sendcc.push(sendlist[i][1]);
  }
  
  // sendto.push("ming.chou1994@gmail.com");
  // sendto = sendto.join(',');
  sendto = sendto.join(',');
  sendcc = sendcc.join(',');

  MailApp.sendEmail({
    to: sendto,
    cc: sendcc,
    subject: subject+' ('+d.getDate()+'-'+monthNames[d.getMonth()]+'-'+d.getYear()+')',
      body: body});
}

