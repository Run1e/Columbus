FileOld(file) {
	FileGetTime, ft, %file% ; file time
	ft-=a_now, s ; ft gets replaced with the time difference.
	return ft*-1
}