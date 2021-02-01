cd utils
rm CLAS12OCR.db
python2 create_database.py --lite=CLAS12OCR.db
cd ../client
python2 src/SubMit.py --lite=../utils/CLAS12OCR.db -u=testuser scards/scard_type1.txt
#python2 src/SubMit.py --lite=../utils/CLAS12OCR.db -u=robertej scard_type2.txt
cd ..
cd utils
sqlite3 CLAS12OCR.db 'SELECT user FROM SUBMISSIONS';
cd ..
python2 server/src/Submit_UserSubmission.py -b 1 --lite=utils/CLAS12OCR.db -o=TestOutputDir -w -s 
#sqlite3 utils/CLAS12OCR.db 'SELECT user FROM SUBMISSIONS';
