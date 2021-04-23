function num_to_column(column_number)
{
  if (column_number == 0){
    return String.fromCharCode(64 + 26);
  }
  else if (column_number > 0 && column_number < 27){
    return String.fromCharCode(64 + column_number);
  }
  else {
    if (column_number%26 == 0) return num_to_column((column_number-1)/26) + num_to_column(column_number%26);
    else return num_to_column(column_number/26) + num_to_column(column_number%26);
  }
}

