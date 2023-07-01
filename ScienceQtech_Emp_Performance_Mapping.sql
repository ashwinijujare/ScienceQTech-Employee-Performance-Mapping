#1. Create a database named employee, then import data_science_team.csv proj_table.csv and emp_record_table.csv into the 
#employee database from the given resources.

#Created below table structures & imported the data using wizard
CREATE DATABASE employee;
USE employee;

drop table if exists data_science_team;
create table if not exists data_science_team
(emp_id varchar(10) not null, 
first_name varchar(25) not null,
last_name varchar(25) not null, 
gender varchar(1) not null,
role varchar(100) not null,
dept varchar(50) not null, 
exp int not null,
country varchar(25) not null,
continent varchar(25) not null,
primary key (emp_id));

drop table if exists proj_table;
create table if not exists proj_table 
(project_id varchar(4) not null,
proj_name varchar(100) not null,
domain varchar(25) not null,
start_date date not null,
closure_date date not null,
dev_qtr varchar(5) not null,
status varchar(25) not null,
primary key (project_id));

drop table if exists emp_record_table;
create table if not exists emp_record_table
(emp_id varchar(4) not null,
first_name varchar(25) not null,
last_name varchar(25) not null,
gender varchar(1) not null,
role varchar(100) not null,
dept varchar(25) not null,
exp int not null,
country varchar(25) not null,
continent varchar(25) not null,
salary int not null,
emp_rating int not null,
manager_id varchar(25),
proj_id varchar(4),
constraint emp_key foreign key(emp_id) references data_science_team(emp_id) on delete cascade on update cascade,
constraint proj_key foreign key(proj_id) references proj_table(project_id) on delete cascade on update cascade);

#2. Create an ER diagram for the given employee database.
#Steps -- from Menu -> Database -> Reverse Engineer -> provide required password -> select database (employee) -> Click Next, Next -> Execute

#3. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, and make a list of employees 
#   and details of their department.
SELECT 
    emp_id, first_name, last_name, gender, dept
FROM
    emp_record_table
ORDER BY emp_id;

#4. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
#i. less than two
SELECT 
    emp_id, first_name, last_name, gender, dept, emp_rating
FROM
    emp_record_table
WHERE
    emp_rating < 2;
#ii. greater than four 
SELECT 
    emp_id, first_name, last_name, gender, dept, emp_rating
FROM
    emp_record_table
WHERE
    emp_rating > 4;
#iii. between two and four
SELECT 
    emp_id, first_name, last_name, gender, dept, emp_rating
FROM
    emp_record_table
WHERE
    emp_rating > 2 and emp_rating < 4;
    
#5. Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from the employee table and then 
#   give the resultant column alias as NAME.
SELECT concat(first_name,' ', last_name) as NAME
FROM emp_record_table
WHERE dept = 'FINANCE';

#6. Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).
SELECT manager_id, count(emp_id) as No_of_reporters
FROM emp_record_table 
WHERE manager_id IS NOT NULL 
GROUP BY manager_id ORDER BY manager_id ASC;

#7. Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.
SELECT * FROM emp_record_table
WHERE dept = 'HEALTHCARE'
UNION
SELECT * FROM emp_record_table
WHERE dept = 'FINANCE';

#8. Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept.
#   Also include the respective employee rating along with the max emp rating for the department.
SELECT emp_id, first_name, last_name, role, dept, emp_rating, 
(select max(emp_rating) FROM emp_record_table m WHERE E.dept = m.dept GROUP BY dept) as Max_Rating
FROM emp_record_table e;

#9. Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.
SELECT DISTINCT role, (SELECT min(salary) from emp_record_table min WHERE min.role = e.role) as Min_salary_for_role,
(SELECT max(salary) from emp_record_table max WHERE max.role = e.role) as Max_salary_for_role
FROM emp_record_table e;

#10. Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.
SELECT concat(first_name,' ', last_name) as NAME, exp, rank() OVER (ORDER BY exp DESC) AS RANKS FROM emp_record_table;

#11. Write a query to create a view that displays employees in various countries whose salary is more than six thousand.
#    Take data from the employee record table.
CREATE VIEW emp_loc_salary_details
AS
SELECT emp_id, concat(first_name,' ', last_name) as NAME, role, dept, salary, emp_rating, country  FROM emp_record_table
WHERE salary > 6000;
SELECT * FROM emp_loc_salary_details;

#12. Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.
SELECT * FROM (SELECT concat(first_name,' ', last_name) AS emp_with_10_plus_yrs_exp, exp FROM emp_record_table WHERE exp > 10) 
AS emp;

#13. Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years.
#    Take data from the employee record table.
DELIMITER //
CREATE PROCEDURE EmpWith3PlusYrsExp()
BEGIN 
SELECT * FROM emp_record_table
WHERE exp > 3;
END //
DELIMITER ;
CALL EmpWith3PlusYrsExp();

#14. Write a query using stored functions in the project table to check whether the job profile assigned to each 
#    employee in the data science team matches the organization’s set standard.
DELIMITER //
CREATE FUNCTION check_job_profile(exp INT)
RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN
DECLARE profile VARCHAR(40);
IF exp <= 2 THEN SET profile = 'JUNIOR DATA SCIENTIST';
ELSEIF exp >= 2 AND exp <=5 THEN SET profile = 'ASSOCIATE DATA SCIENTIST';
ELSEIF exp >= 5 AND exp <=10 THEN SET profile = 'SENIOR DATA SCIENTIST';
ELSEIF exp >= 10 AND exp <=12 THEN SET profile = 'LEAD DATA SCIENTIST';
ELSEIF exp >=12 THEN SET profile = 'MANAGER';
END IF;
RETURN (profile);
END //

SELECT concat(first_name,' ', last_name) AS Name, exp, role, check_job_profile(exp) AS role_based_on_cmpy_std 
FROM emp_record_table;  

#15. Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in 
#    the employee table after checking the execution plan.
SELECT * FROM emp_record_table
WHERE first_name = 'Eric';

CREATE INDEX firstName ON emp_record_table(first_name);

#16. Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).
SELECT concat(first_name,' ', last_name) AS Name, salary, emp_rating, round(0.05 * salary * emp_rating,0) AS bonus
FROM emp_record_table;

#17. Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.
SELECT concat(first_name,' ', last_name) AS Name, salary, country, continent, 
round(avg(salary) OVER (PARTITION BY continent ORDER BY country),0) AS Average_salary
FROM emp_record_table;