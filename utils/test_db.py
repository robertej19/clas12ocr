"""

Informal tests for the database.py module.  These must
be run from the utils/ folder due to the import structure.  These should be 
formalized into unittest.TestCase tests, but a test database structure
needs to be coded first. 

"""

import fs
from database import (get_database_connection, 
                      load_database_credentials, 
                      get_users, select_by_user_submission_id)

if __name__ == '__main__':

    creds_file = '../msqlrw.txt'
    uname, pword = load_database_credentials(creds_file)

    db_connection, sql = get_database_connection(
        use_mysql=True, hostname='jsubmit.jlab.org', 
        username=uname, password=pword) 

    # A simple test query
    query = """ 
    SELECT User, timestamp FROM UserSubmissions 
        WHERE UserSubmissionID > 65 AND User = 'dmriser';
    """
    sql.execute(query)
    result = sql.fetchall()
    print(result)

    # Test function 
    users = get_users(sql)
    print(users)
    print(type(users))

    # Test selection by UserSubmissionID (with string, list)
    results = select_by_user_submission_id(usub_id=74, table='Gcards', 
                                           fields=['GcardID', 'gcard_text'], 
                                           sql=sql)
    print(results)

    results = select_by_user_submission_id(usub_id=74, table='UserSubmissions', 
                                           fields='timestamp', sql=sql)
    print(results)

    # User is responsible for closing the database before 
    # exiting the program. 
    db_connection.close() 
