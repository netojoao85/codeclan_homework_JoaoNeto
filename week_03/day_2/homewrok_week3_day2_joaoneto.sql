-- Lab & Homework week03 day 2


--Q1: (a). Find the first name, last name and team name of employees who 
--         are members of teams.
SELECT
	e.first_name,
	e.last_name,
	t.name
FROM employees AS e INNER JOIN teams AS t
ON	e.team_id = t.id;

--Q1: (b). Find the first name, last name and team name of employees who 
--         are members of teams and are enrolled in the pension scheme.
SELECT
	e.first_name,
	e.last_name,
	t.name
FROM employees AS e INNER JOIN teams AS t
ON	e.team_id = t.id
WHERE e.pension_enrol = TRUE;

--Q1: (c). Find the first name, last name and team name of employees 
--         who are members of teams, where their team has a charge cost 
--         greater than 80.
SELECT
	e.first_name,
	e.last_name,
	t.name
FROM employees AS e INNER JOIN teams AS t
ON	e.team_id = t.id
WHERE CAST(t.charge_cost AS INT) > 80;

--Q2: (a). Get a table of all employees details, together with their 
--         local_account_no and local_sort_code, if they have them.
SELECT *
FROM employees AS e INNER JOIN pay_details AS pd
ON e.pay_detail_id = pd.id
WHERE pd.local_account_no NOTNULL
AND pd.local_sort_code NOTNULL;

--Q2: (b). Amend your query above to also return the name of the team that 
--         each employee belongs to.
SELECT 
	e.*,
	t.name AS team_name,
	pd.local_account_no,
	pd.local_sort_code
FROM (employees AS e INNER JOIN pay_details AS pd
ON e.pay_detail_id = pd.id) LEFT JOIN teams AS t ON	e.team_id = t.id
WHERE pd.local_account_no NOTNULL
AND local_sort_code NOTNULL;

--Q3: (a). Make a table, which has each employee id along with the team that 
--         employee belongs to.
SELECT 
	e.id,
	t.name
FROM employees AS e INNER JOIN teams AS t
ON e.team_id = t.id;

--Q3: (b). Breakdown the number of employees in each of the teams.
SELECT 
	t.name AS name_team,
	count(e.id) num_per_team
FROM employees AS e INNER JOIN teams AS t
ON e.team_id = t.id
GROUP BY t.name;


--Q3: (c). Order the table above by so that the teams with the least 
--         employees come first.
SELECT 
	t.name AS name_team,
	count(e.id) AS num_per_team
FROM employees AS e INNER JOIN teams AS t
ON e.team_id = t.id
GROUP BY t.name 
ORDER BY count(e.id);


--Q4: (a). Create a table with the team id, team name and the count of the 
--         number of employees in each team.
SELECT 
	t.id,
	t.name,
	count(e.id)
FROM teams AS t INNER JOIN	employees AS e
ON  t.id = e.team_id
GROUP BY t.id;

--Q4: (b). The total_day_charge of a team is defined as the charge_cost of 
--         the team multiplied by the number of employees in the team. 
--         Calculate the total_day_charge for each team.
SELECT 
	t.id,
	t.name,
	count(e.id),
	t.charge_cost
FROM teams AS t INNER JOIN	employees AS e
ON  t.id = e.team_id
GROUP BY t.id;


--Q4: (c). How would you amend your query from above to show only those teams
--         with a total_day_charge greater than 5000?
SELECT 
	t.id,
	t.name,
	count(e.id),
	t.charge_cost
FROM teams AS t INNER JOIN	employees AS e
ON  t.id = e.team_id
WHERE t.charge_cost < 50
GROUP BY t.id;


--Extension
--Q5: How many of the employees serve on one or more committees?
SELECT
	c.name AS name_committee,
	count(e.id) AS num_employees
FROM 
	(employees AS e INNER JOIN	employees_committees AS ec
	ON e.id = ec.employee_id)
INNER JOIN committees AS c 
ON	ec.committee_id = c.id
GROUP BY c.name
HAVING	count(e.id) >= 1;


SELECT DISTINCT 
count (employee_id) 
FROM employees_committees 
DISTINCT (committee_id);


--Q6: How many of the employees do not serve on a committee?
SELECT
	c.name AS name_committee,
	count(e.id) AS num_employees
FROM 
	(employees AS e INNER JOIN	employees_committees AS ec
	ON e.id = ec.employee_id)
INNER JOIN committees AS c 
ON	ec.committee_id = c.id
GROUP BY c.name
HAVING	count(e.id) IS NULL;

