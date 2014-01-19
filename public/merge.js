$(function() {
  //
  // Created By: Brij Mohan
  // Website: http://techbrij.com
  //
  // modified by github://roobert
  //
  function groupTable($rows, startIndex, total){

    if (total === 0) { return; }

    var currentIndex = startIndex;
    var count        = 1;
    var lst          = [];
    var tds          = $rows.find('td:eq('+ currentIndex +')');
    var ctrl         = $(tds[0]);

    lst.push($rows[0]);

    var i;

    for (i=1; i<=tds.length; i++) {

      if (
        ctrl.text() == $(tds[i]).text() &&
//        ctrl.text() != "" &&
        // we don't want to merge column cells between different network interfaces
        $(tds[i]).closest('tr').attr('interface') == undefined
      ) {
        console.log(ctrl.text())
        console.log(ctrl.closest('tr').attr('interface'))
        count++;
        $(tds[i]).addClass('deleted');
        lst.push($rows[i]);
      } else {
        if (count>1) {
          ctrl.attr('rowspan',count);
          groupTable($(lst),startIndex+1,total-1)
        }
        count=1;
        lst = [];
        ctrl=$(tds[i]);
        lst.push($rows[i]);
      }
    }
  }
  // FIXME: silly hack because this javascript doesnt work properly..
  groupTable($('#table tr:has(td)'),0,1);
  groupTable($('#table tr:has(td)'),1,1);
  groupTable($('#table tr:has(td)'),2,1);
  groupTable($('#table tr:has(td)'),3,1);
  groupTable($('#table tr:has(td)'),4,1);
  groupTable($('#table tr:has(td)'),5,1);
  groupTable($('#table tr:has(td)'),6,1);
  groupTable($('#table tr:has(td)'),7,1);
  groupTable($('#table tr:has(td)'),8,1);
  groupTable($('#table tr:has(td)'),9,1);
  groupTable($('#table tr:has(td)'),10,1);
  groupTable($('#table tr:has(td)'),11,1);
  // FIXME: should merge blank cells for this column
  //groupTable($('#table tr:has(td)'),12,1);
  groupTable($('#table tr:has(td)'),13,1);
  groupTable($('#table tr:has(td)'),14,1);
  groupTable($('#table tr:has(td)'),15,1);
  groupTable($('#table tr:has(td)'),16,1);
  groupTable($('#table tr:has(td)'),17,1);
  $('#table .deleted').remove();
});
