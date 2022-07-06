-- MVP ######################################################################

/*Question 1.
How many employee records are lacking both a grade and salary?*/
SELECT
	count(id)
FROM  employees
WHERE grade IS NULL 
AND salary IS NULL;

/*Question 2.
Produce a table with the two following fields (columns):
  - the department
  - the employees full name (first and last name)
Order your resulting table alphabetically by department, and then by last name
*/
SELECT	
	department,
	concat(first_name, ' ', last_name) AS full_name
FROM employees
ORDER BY department ASC	, 
last_name ASC;

/*Question 3.
Find the details of the top ten highest paid employees who have a last_name 
beginning with 'A'.*/
SELECT *
FROM employees
WHERE last_name ~ '^A'
ORDER BY salary DESC NULLS	LAST		
LIMIT 10;

/*Question 4.
Obtain a count by department of the employees who started work with the 
corporation in 2003.*/
SELECT	
	department,
	count(id)
FROM employees
WHERE EXTRACT(YEAR FROM	start_date) = 2003
GROUP BY	department;

/*Question 5.
Obtain a table showing department, fte_hours and the number of employees in each 
department who work each fte_hours pattern. Order the table alphabetically by 
department, and then in ascending order of fte_hours.
Hint
You need to GROUP BY two columns here.*/
SELECT 
	department,
	fte_hours,
	count(id)
FROM employees
GROUP BY department, fte_hours
--ORDER fte_hours ASC	

/*Question 6.
Provide a breakdown of the numbers of employees enrolled, not enrolled, and with 
unknown enrollment status in the corporation pension scheme.*/
SELECT
	pension_enrol,
	count(id)
FROM employees
GROUP BY pension_enrol;

/*Question 7.
Obtain the details for the employee with the highest salary in the 'Accounting' 
department who is not enrolled in the pension scheme?*/
SELECT *
FROM employees
WHERE	department = 'Accounting' 
AND pension_enrol = FALSE;

/*Question 8.
Get a table of country, number of employees in that country, and the average salary
 of employees in that country for any countries in which more than 30 employees 
 are based. Order the table by average salary descending.
Hints
A HAVING clause is needed to filter using an aggregate function.
You can pass a column alias to ORDER BY.*/
SELECT
	country,
	count(id) AS num_employees,
	avg(salary) AS avg_salary
FROM employees
GROUP BY country
HAVING	count(id) > 30
ORDER BY avg_salary DESC;

/*Question 9.
11. Return a table containing each employees first_name, last_name, full-time 
equivalent hours (fte_hours), salary, and a new column effective_yearly_salary 
which should contain fte_hours multiplied by salary. Return only rows where 
effective_yearly_salary is more than 30000.
*/
SELECT
	first_name,
	last_name,
	salary,
	fte_hours,
	fte_hours * salary AS effective_yearly_salary 
FROM employees
WHERE fte_hours * salary > 30000;

/*Question 10
Find the details of all employees in either Data Team 1 or Data Team 2
Hint
name is a field in table `teams*/
SELECT
	*
FROM employees AS e INNER JOIN	teams AS t
ON e.team_id = t.id
WHERE t.name ~ 'Data Team';

/*Question 11
Find the first name and last name of all employees who lack a local_tax_code.
Hint
local_tax_code is a field in table pay_details, and first_name and last_name are
fields in table employees*/
SELECT
	e.first_name, 
	e.last_name
FROM employees AS e LEFT JOIN	pay_details AS pd
ON e.pay_detail_id = pd.id
WHERE local_tax_code IS NULL;

/*Question 12.
The expected_profit of an employee is defined as 
(48 * 35 * charge_cost - salary) * fte_hours, where charge_cost depends upon 
the team to which the employee belongs. Get a table showing expected_profit 
for each employee.

Hints
charge_cost is in teams, while salary and fte_hours are in employees, so a join
will be necessary You will need to change the type of charge_cost in order to 
perform the calculation*/
SELECT 
	e.salary,
	first_name,
	last_name,
	(48 * 35 * CAST(t.charge_cost AS INT) - salary) * fte_hours AS expected_profit
FROM employees AS e LEFT JOIN	teams AS t
ON e.team_id = t.id;

/*Question 13. [Tough]
Find the first_name, last_name and salary of the lowest paid employee in Japan 
who works the least common full-time equivalent hours across the corporation."
Hint
You will need to use a subquery to calculate the mode*/
WITH least_fte_hours AS (
	SELECT
		fte_hours,
		count(id) AS n_employees
	FROM employees
	GROUP BY fte_hours
	ORDER BY count(id) ASC	
	LIMIT 1
	)
SELECT 
	first_name, 
	last_name,
	salary
FROM employees
WHERE country = 'Japan' AND	
fte_hours = (SELECT fte_hours
			  FROM least_fte_hours);

/*Question 14.
Obtain a table showing any departments in which there are two or more employees 
lacking a stored first name. Order the table in descending order of the number 
of employees lacking a first name, and then in alphabetical order by department.
*/
SELECT
	department,
	count(id)
FROM employees
WHERE first_name IS NULL
GROUP BY department
HAVING	count(id) >= 2
ORDER BY count(id) DESC, department DESC;

/*Question 15. [Bit tougher]
Return a table of those employee first_names shared by more than one employee, 
together with a count of the number of times each first_name occurs. Omit 
employees without a stored first_name from the table. Order the table 
descending by count, and then alphabetically by first_name.
*/
SELECT
	first_name,
	count(id)
FROM employees
GROUP BY first_name
HAVING	first_name IS NOT NULL AND count(id) > 1
ORDER BY count(id) DESC;

/*Question 16. [Tough]
Find the proportion of employees in each department who are grade 1.
	Hints
	Think of the desired proportion for a given department as the number of 
	employees in that department who are grade 1, divided by the total number 
	of employees in that department.

	You can write an expression in a SELECT statement, e.g. grade = 1. 
	This would result in BOOLEAN values.

	If you could convert BOOLEAN to INTEGER 1 and 0, you could sum them. 
	The CAST() function lets you convert data types.

	In SQL, an INTEGER divided by an INTEGER yields an INTEGER. To get a REAL 
	value, you need to convert the top, bottom or both sides of the division 
	to REAL. */
SELECT
	department,
	CAST(sum(grade) AS decimal) / CAST(count(id) AS decimal) 
	AS proportion_grande_one
FROM employees
GROUP BY department;


-- EXTENSION #################################################################

/*Question 1. [Tough]
Get a list of the id, first_name, last_name, department, salary and fte_hours 
of employees in the largest department. Add two extra columns showing the ratio 
of each employee�s salary to that department�s average salary, and each 
employee�s fte_hours to that department�s average fte_hours.

[Extension - really tough! - how could you generalise your query to be able to
 handle the fact that two or more departments may be tied in their counts of 
 employees. In that case, we probably don�t want to arbitrarily return details 
 for employees in just one of these departments].
	Hints
	Writing a CTE to calculate the name, average salary and average fte_hours 
	of the largest department is an efficient way to do this.
	Another solution might involve combining a subquery with window functions.*/
WITH largest_department AS (
		SELECT 
			department ,
			count(id) AS num_employees,
			avg(salary) AS avg_salary,
			avg(fte_hours) AS avg_fte
		FROM employees 
		GROUP BY department 
		ORDER BY num_employees DESC
		LIMIT 1
)
SELECT 
	id ,
	first_name ,
	last_name ,
	department ,
	salary/(SELECT avg_salary FROM largest_department) AS salary_ratio,
	fte_hours/(SELECT avg_fte FROM largest_department) AS fte_ratio
FROM employees 

/*Question 2.
Have a look again at your table for MVP question 6. It will likely contain a 
blank cell for the row relating to employees with �unknown� pension enrollment 
status. This is ambiguous: it would be better if this cell contained �unknown� 
or something similar. Can you find a way to do this, perhaps using a 
combination of COALESCE() and CAST(), or a CASE statement?
	Hints
	*COALESCE() lets you substitute a chosen value for NULLs in a column, e.g. 
	*COALESCE(text_column, 'unknown') would substitute 'unknown' for every NULL 
	*in text_column. The substituted value has to match the data type of the 
	*column otherwise PostgreSQL will return an error.
	CAST() let�s you change the data type of a column, e.g. CAST(boolean_column 
	AS VARCHAR) will turn TRUE values in boolean_column into text 'true', 
	FALSE to text 'false', and will leave NULLs as NULL/ */
SELECT
	pension_enrol,
	count(id),
	CASE
		WHEN CAST(pension_enrol AS varchar) IS NULL then 'unknown'
		WHEN pension_enrol = TRUE  THEN 'enrolled'
		WHEN pension_enrol = FALSE THEN 'not enrolled'
	END AS pension_enrol_describe
FROM employees
GROUP BY pension_enrol;

/*Question 3. Find the first name, last name, email address and start date of 
 * all the employees who are members of the �Equality and Diversity� committee.
 *  Order the member employees by their length of service in the company, 
 * longest first. */
SELECT
	e.first_name,
	e.last_name,
	e.email,
	e.start_date
FROM 
	(employees AS e INNER JOIN	employees_committees AS ec
	ON e.id = ec.employee_id)
INNER JOIN committees AS c 
ON	ec.committee_id = c.id
WHERE c.name = 'Equality and Diversity'
ORDER BY start_date ASC;

/*Question 4. [Tough!]
Use a CASE() operator to group employees who are members of committees into 
salary_class of 'low' (salary < 40000) or 'high' (salary >= 40000). 
A NULL salary should lead to 'none' in salary_class. Count the number of 
committee members in each salary_class.

	Hints
	- You likely want to count DISTINCT() employees in each salary_class
	- You will need to GROUP BY salary_class*/
SELECT
	count(e.*) AS num_employees,
 	CASE	
 		WHEN e.salary <  40000 THEN 'low'
		WHEN e.salary >= 40000 THEN	'high'
		WHEN e.salary IS NULL  THEN 'null'
 	END salary_class
FROM
	(employees AS e INNER JOIN	employees_committees AS ec
	ON e.id = ec.employee_id)
INNER JOIN committees AS c 
ON	ec.committee_id = c.id
GROUP BY salary_class
ORDER BY count(e.*) DESC;






