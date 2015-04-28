LangCode(code) {
	lang := { "0436": "Afrikaans", "041c": "Albanian", "0401": "Arabic Saudi Arabia", "0801": "Arabic Iraq", "0c01": "Arabic Egypt", "0401": "Arabic Saudi Arabia", "0801": "Arabic Iraq", "0c01": "Arabic Egypt", "1001": "Arabic Libya"
	, "1401": "Arabic Algeria", "1801": "Arabic Morocco", "1c01": "Arabic Tunisia", "2001": "Arabic Oman", "2401": "Arabic Yemen", "2801": "Arabic Syria", "2c01": "Arabic Jordan", "3001": "Arabic Lebanon", "3401": "Arabic Kuwait"
	, "3801": "Arabic UAE", "3c01": "Arabic Bahrain", "4001": "Arabic Qatar", "042b": "Armenian", "042c": "Azeri Latin", "082c": "Azeri Cyrillic", "042d": "Basque", "0423": "Belarusian", "0402": "Bulgarian", "0403": "Catalan"
	, "0404": "Chinese Taiwan", "0804": "Chinese PRC", "0c04": "Chinese Hong Kong", "1004": "Chinese Singapore", "1404": "Chinese Macau", "041a": "Croatian", "0405": "Czech", "0406": "Danish", "0413": "Dutch Standard"
	, "0813": "Dutch Belgian", "0409": "English United States", "0809": "English United Kingdom", "0c09": "English Australian", "1009": "English Canadian", "1409": "English New Zealand", "1809": "English Irish"
	, "1c09": "English South Africa", "2009": "English Jamaica", "2409": "English Caribbean", "2809": "English Belize", "2c09": "English Trinidad", "3009": "English Zimbabwe", "3409": "English Philippines", "0425": "Estonian"
	, "0438": "Faeroese", "0429": "Farsi", "040b": "Finnish", "040c": "French Standard", "080c": "French Belgian", "0c0c": "French Canadian", "100c": "French Swiss", "140c": "French Luxembourg", "180c": "French Monaco"
	, "0437": "Georgian", "0407": "German Standard", "0807": "German Swiss", "0c07": "German Austrian", "1007": "German Luxembourg", "1407": "German Liechtenstein", "0408": "Greek", "040d": "Hebrew", "0439": "Hindi"}
	lang2 := {"040e": "Hungarian", "040f": "Icelandic", "0421": "Indonesian", "0410": "Italian Standard", "0810": "Italian Swiss", "0411": "Japanese", "043f": "Kazakh", "0457": "Konkani", "0412": "Korean", "0426": "Latvian"
	, "0427": "Lithuanian", "042f": "Macedonian", "043e": "Malay Malaysia", "083e": "Malay Brunei Darussalam", "044e": "Marathi", "0414": "Norwegian Bokmal", "0814": "Norwegian Nynorsk", "0415": "Polish"
	, "0416": "Portuguese Brazilian", "0816": "Portuguese Standard", "0418": "Romanian", "0419": "Russian", "044f": "Sanskrit", "081a": "Serbian Latin", "0c1a": "Serbian Cyrillic", "041b": "Slovak", "0424": "Slovenian"
	, "040a": "Spanish Traditional Sort", "080a": "Spanish Mexican", "0c0a": "Spanish Modern Sort", "100a": "Spanish Guatemala", "140a": "Spanish Costa Rica", "180a": "Spanish Panama", "1c0a": "Spanish Dominican Republic"
	, "200a": "Spanish Venezuela", "240a": "Spanish Colombia", "280a": "Spanish Peru", "2c0a": "Spanish Argentina", "300a": "Spanish Ecuador", "340a": "Spanish Chile", "380a": "Spanish Uruguay", "3c0a": "Spanish Paraguay"
	, "400a": "Spanish Bolivia", "440a": "Spanish El Salvador", "480a": "Spanish Honduras", "4c0a": "Spanish Nicaragua", "500a": "Spanish Puerto Rico", "0441": "Swahili", "041d": "Swedish", "081d": "Swedish Finland"
	, "0449": "Tamil", "0444": "Tatar", "041e": "Thai", "041f": "Turkish", "0422": "Ukrainian", "0420": "Urdu", "0443": "Uzbek Latin", "0843": "Uzbek Cyrillic", "042a": "Vietnamese"}
	for x, y in [lang, lang2]
		for a, b in y
			if (a = code)
				return b
}