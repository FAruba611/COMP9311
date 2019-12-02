# IMPORTANT:
#   POSTGRESQL must be running at the local machine and the database ASX has been created and populated.
#   Your POSTGRESQL user must have permission to connect
#   Find pg_hba.conf from this command
#       SHOW hba_file;
#   in POSTGRESQL
#
#

import psycopg2
from psycopg2.extensions import AsIs
import datetime
import subprocess
import os
import sys
from getpass import getpass

dbn = input("Input the name of your database (e.g. ASX): ")
uname = input("Input your login name to PostgreSQL of the local machine: ")
psd = getpass()
print("Processing...")
lines = []
conn = psycopg2.connect(dbname=dbn, user=uname, password=psd)
# For other IP, use this instead of the connect line: 
#conn = psycopg2.connect(dbname=dbn, user=uname, password=psd, host="127.0.0.1", port="5432")
#change to your IP and host
conn.autocommit = True
cur = conn.cursor()
for i in range(1, 16):
    s = "SELECT * FROM Q{};".format(i)
    cur.execute(s)
    lines.append("\n---------------\n" + s + "\n")
    columns = [desc[0] for desc in cur.description]
    lines.append("\t".join(columns))
    lines.append("--------------------------")
    count = 0
    for tup in cur:
        count += 1
        lines.append(tup)
    lines.append("--------------------------")
    lines.append("({} rows)".format(count))
# 16
lines.append(("\n---------------\n>>>Q16 trigger\t\n",))
lines.append("INSERT INTO Executive VALUES('AAD', 'Mr. Stephen John Mikkelsen BBS, CA');\n")
lines.append(">>>Insertion show be rejected:\n")
try:
    cur.execute("INSERT INTO Executive VALUES(%s,%s);", ('AAD', 'Mr. Stephen John Mikkelsen BBS, CA'))
except psycopg2.Error as e:
    lines.append("EXCEPTION: " + e.diag.message_primary + '\n')
lines.append(">>>'Mr. Stephen John Mikkelsen BBS, CA' should not appear below the query:\n")
lines.append("SELECT Person FROM Executive WHERE Code = 'AAD' AND Person = 'Mr. Stephen John Mikkelsen BBS, CA';\n")
cur.execute("SELECT Person FROM Executive WHERE Code = 'AAD' AND Person = 'Mr. Stephen John Mikkelsen BBS, CA';")
if cur.description is not None:
    columns = [desc[0] for desc in cur.description]
    lines.append("\t".join(columns))
    lines.append("--------------------------")
    count = 0
    for tup in cur:
        count += 1
        lines.append(tup)
    lines.append("--------------------------")
    lines.append("({} rows)".format(count))
# restore
lines.append("\n>>>Reverting changes...")
cur.execute("DELETE FROM Executive WHERE Code = 'AAD' AND Person = 'Mr. Stephen John Mikkelsen BBS, CA';")
# 17
lines.append(("\n---------------\n>>>Q17 trigger.\t\n",))
lines.append("INSERT INTO ASX VALUES('2012-03-31', 'WTF', '522000', '10.00');\n")
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 3, 31), 'WTF', 522000, 10.00))
lines.append(">>>Rating of WTF show be 5 now:\n")
cur.execute("SELECT Star FROM Rating WHERE Code = %s;", ('WTF',))
lines.append("SELECT Star FROM Rating WHERE Code = 'WTF';\n")
columns = [desc[0] for desc in cur.description]
lines.append("\t".join(columns))
lines.append("--------------------------")
count = 0
for tup in cur:
    count += 1
    lines.append(tup)
lines.append("--------------------------")
lines.append("({} rows)".format(count))
# restore 17
lines.append("\n>>>Reverting changes...")
cur.execute("DELETE FROM ASX WHERE %s > %s;", (AsIs('"Date"'), datetime.date(2012, 3, 30)))
cur.execute("UPDATE Rating SET Star = 3 WHERE Code = 'WTF';")
# 18
lines.append("\n---------------\nQ18 trigger.\t\n")
cur.execute('UPDATE ASX SET Price = 1.20 WHERE %s = %s AND Code = %s;',
            (AsIs('"Date"'), datetime.date(2012, 1, 3), 'AAD'))
lines.append("UPDATE ASX SET Price = 1.20 WHERE \"Date\" = '2012-01-03' AND Code = 'AAD';\n")
cur.execute('UPDATE ASX SET Price = 0.91 WHERE %s = %s AND Code = %s;',
            (AsIs('"Date"'), datetime.date(2012, 1, 3), 'AAD'))
lines.append("UPDATE ASX SET Price = 0.91 WHERE \"Date\" = '2012-01-03' AND Code = 'AAD';\n")
lines.append(">>>Records should appear in ASXLog now:\n\n")
cur.execute("SELECT * FROM ASXLog;")
lines.append("SELECT * FROM ASXLog;\n")
columns = [desc[0] for desc in cur.description]
lines.append("\t".join(columns))
lines.append("--------------------------")
count = 0
for tup in cur:
    count += 1
    lines.append(tup)
lines.append("--------------------------")
lines.append("({} rows)".format(count))
lines.append("\n>>>Reverting changes...")
cur.execute("DELETE FROM asxlog;")

filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "view_tests.txt")

with open(filepath, 'w') as f:
    for line in lines:
        if line is None:
            continue
        if isinstance(line, str):
            f.write(line)
        else:
            for item in line:
                f.write(str(item))
                f.write('\t')
        f.write('\n')

print("\nTest output file saved to:")
print(os.path.abspath(filepath))

if sys.platform.startswith('darwin'):
    subprocess.call(('open', filepath))
elif os.name == 'nt':
    os.startfile(filepath)
elif os.name == 'posix':
    subprocess.call(('vi', filepath))
