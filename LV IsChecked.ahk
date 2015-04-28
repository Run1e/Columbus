LV_IsChecked(row) {
	RowNumber = 0
	Loop {
		if !(RowNumber := LV_GetNext(RowNumber, "C"))
			break
		if (RowNumber = row)
			return LV_Modify(A_EventInfo, "Col" 3, 1)
	} return false
}