##############################################################
#
# 09/10/2010  TW  Create skeleton xml document for testing
#
# Usage:
#
# awk -f xmldoc.awk cs_comp_createRecordHway.sql > cs_comp_createRecordHway.xml
#
#############################################################

BEGIN {
	FS = " AS "
}

	{ gsub(/\047/, "") }
	/xmldoc./ && !/FROM / { print "<"$2"><\/"$2">" }
