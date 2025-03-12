create table departments(
department_id serial primary key,
department_name varchar(50) not null,
location varchar(50)
);
select * from departments;

create table employees(
employee_id serial primary key,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(50) unique not null,
phone_number varchar(15),
hire_date date not null,
job_title varchar(50) not null,
salary decimal(10,2) not null,
department_id int references departments(department_id) on delete set null
);

select * from employees;

create table projects(
project_id serial primary key,
project_name varchar(50) not null,
start_date date not null,
end_date date,
department_id int references departments(department_id) on delete set null
);

select * from projects;

create table employee_projects(
employee_id int references employees(employee_id) on delete cascade,
project_id int references projects(project_id) on delete cascade,
assigned_date date not null,
primary key(employee_id, project_id)
);

select * from employee_projects;

create table salaries(
salary_id serial primary key,
employee_id int references employees(employee_id) on delete cascade,
salary decimal(10,2) not null,
effective_date date not null
);

select * from salaries;

--INSERTING VALUES INTO THE TABLES
insert into  departments(department_name,location) values
('HR','New York'),
('Engineering','San Francisco'),
('Marketing','Chicago');
select * from departments;

insert into employees(first_name,last_name,email,phone_number,hire_date,job_title,salary,department_id) values
('John','Doe','john.doe@gmail.com','1234627','2022-05-10','Software Engineer',75000.00,2),
('Jane','Smith','jane@gmail.com','7643737','2021-09-15','HR Manager',65000.00,1),
('Robert','Brown','robert.brown@gmail.com','783738','2023-01-20','Marketing Specialist', 60000.00,3);
select * from employees;

insert into projects(project_name,start_date,end_date,department_id) values
('Website Redesign','2023-02-01',null,2),
('Employee Onboarding System','2023-03-15','2023-08-30',1);
select * from projects;

insert into employee_projects(employee_id, project_id, assigned_date) values
(1,1,'2023-02-05'),
(2,2,'2023-04-01');
select * from employee_projects;

insert into salaries(employee_id,salary,effective_date) values
(1,75000.00,'2022-05-10'),
(2,65000.00,'2021-09-15'),
(3,60000.00,'2023-01-20');
select * from salaries;

--QUERIES

--get the first name,last name and job title of all employees;
select first_name,last_name,job_title from employees;

--find all employees who are software engineers
select first_name,last_name
from employees
where job_title='Software Engineer';

--list all departments in alphabetical order.
select * from departments
order by department_name asc;

--find employees who were hired afer january 1,2022
select first_name,last_name, hire_date
from employees
where hire_date>'2022-01-01';

--get the names and salaries of all employees earning more thn 60000
select first_name, last_name, salary
from employees
where salary>60000;

--retrieve all projects and thier start dates
select project_name,start_date from projects;

--find the department of an employee named 'John Doe'
select e.first_name,e.last_name,d.department_name
from employees e
join departments d on e.department_id=d.department_id
where e.first_name='John' and e.last_name='Doe';

--list employees in descending order of salary
select first_name,last_name,salary
from employees
order by salary desc;

--find all employees working in engineering department
select first_name,last_name
from employees
where department_id=(select department_id from departments where department_name='Engineering');

--find the total number of employees in each department
select d.department_name, count(e.employee_id) as total_employees
from employees e
join departments d on e.department_id=d.department_id
group by department_name;

--list all employees along with their department names
select e.first_name, e.last_name, d.department_name
from employees e
join departments d on e.department_id=d.department_id;

--find averyage salary of employees in each department
select  avg(e.salary) as avgsalary,d.department_name
from employees e 
join departments d on e.department_id=d.department_id
group by department_name;

--get the employee with the highest salary
select first_name,last_name,salary
from employees
order by salary desc
limit 1;

--list all projects with their department names
select p.project_name, d.department_name
from projects p
join departments d on p.department_id=d.department_id;

--find employees who are assigned to atleast one project
select distinct e.first_name,e.last_name,ep.project_id
from employees e 
join employee_projects ep on e.employee_id=ep.employee_id;

select * from employee_projects;

--find the total salary expense for each department
select d.department_name, sum(e.salary) as totalsalary
from employees e
join departments d on e.department_id=d.department_id
group by d.department_id;

--retrieve projects that have not been assigned to any employee
select project_name
from projects
where project_id not in (select project_id from employee_projects);

select * from employee_projects;
select * from employees;

--list employees who are not assigned to any project
select first_name,last_name,employee_id
from employees
where employee_id not in (select employee_id from employee_projects);

--Find the number of employees working in each department, only for departments with more than one employee.
select d.department_name,count(e.employee_id) as employeecount
from departments d
join employees e on d.department_id=e.department_id
group by department_name
having count(e.employee_id)>1;

--find the second highest salary in the company
select * from employees;

select salary
from employees
order by salary desc
limit 1 offset 1;

--find employees with higest salary in each department
select e.employee_id,e.first_name,e.last_name,e.salary,d.department_name
from employees e
join departments d on e.department_id=d.department_id
where e.salary=(select max(salary) from employees where e.department_id=d.department_id);

--list employees along with number of projects they are assigned to
select e.first_name, e.last_name,count(ep.project_id) as projectcount
from employees e
join employee_projects ep on e.employee_id=ep.employee_id
group by e.employee_id;

--Use a CASE statement to categorize employees based on salary.
select * from employees;
select first_name,last_name,salary,
case 
	when salary > 70000 then 'High Salary'
	when salary between 65000 and 70000 then 'Medium Salary'
	when salary<65000 then 'Low Salary'
end as salary_category
from employees;

--Find the total salary increase over time for each employee.

SELECT e.first_name, e.last_name, s.salary, s.effective_date 
FROM salaries s 
JOIN employees e ON s.employee_id = e.employee_id 
ORDER BY e.employee_id, s.effective_date;

--Calculate the percentage of total company salary spent on each department.

select d.department_name, sum(e.salary) as department_salary, (sum(e.salary) * 100)/(select sum(salary) from employees ) as totalpercentage
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name;

--find employees along with their rank based on salarys
select first_name,last_name,salary,
rank() over(order by salary desc) as salary_rank
from employees;

--show employees who earn more than their departments average salary
select e.first_name,e.last_name,e.salary,d.department_name
from employees e
join departments d on e.department_id=d.department_id
where e.salary >(select avg(salary) from employees where department_id=e.department_id);

--list employees with the difference in salary from the department average
select e.first_name,e.last_name,e.salary,d.department_name,
e.salary-avg(e.salary) over (partition by d.department_id)
from employees e 
join departments d on e.department_id=d.department_id;


--find the employees who worked on the most projects
select e.first_name,e.last_name,count(ep.project_id) as project_count
from employees e
join employee_projects ep on e.employee_id=ep.employee_id
group by e.employee_id
order by project_count desc
limit 1;

--find employees who received multiple salary increments
SELECT employee_id, COUNT(salary_id) AS salary_increments
FROM salaries
GROUP BY employee_id
having count(salary_id)>1;

--identitfy projects that took longer duration
SELECT project_name, start_date, end_date, 
       (end_date - start_date) AS duration
FROM projects
WHERE end_date IS NOT NULL
ORDER BY duration DESC;

--find the highest paid employee in each department(with ties)
SELECT first_name, last_name, salary, department_name
FROM (
    SELECT e.first_name, e.last_name, e.salary, d.department_name,
           RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS rank
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
) AS ranked_employees
WHERE rank = 1;

--list employees with their latest salary update
select e.first_name,e.last_name,s.salary,s.effective_date
from employees e
join salaries s on e.employee_id=s.employee_id
where s.effective_date=(select max(effective_date) from salaries where employee_id=e.employee_id);

--retrieve employees who have worked in multiple departments
select e.first_name,e.last_name,count(distinct e.department_id) as dept_count
from employees e
group by e.employee_id
having count( e.department_id)>1;


--get the employees who joined within a specific range and worked on projects
select e.first_name,e.last_name,e.hire_date,count(ep.project_id)
from employees e
join employee_projects ep on e.employee_id=ep.employee_id
where e.hire_date between '2022-01-01' and '2023-12-31'
group by e.employee_id;

select * from employees;
select * from departments;
select * from projects;
select * from salaries;
select * from employee_projects;

--INSERTING MORE VALUES INTO EVERY TABLE

insert into departments(department_name,location) values
('Finance','Boston'),
('Sales','Los Angeles'),
('IT Support','Seattle'),
('Research','Denver'),
('Legal','Washington DC');

INSERT INTO employees(first_name, last_name, email, phone_number, hire_date, job_title, salary, department_id) VALUES
('Alice', 'Johnson', 'alice.johnson@gmail.com', '1112223333', '2020-03-12', 'Financial Analyst', 72000.00, 4),
('David', 'Lee', 'david.lee@gmail.com', '2223334444', '2019-06-23', 'Sales Manager', 68000.00, 5),
('Emma', 'Wilson', 'emma.wilson@gmail.com', '3334445555', '2022-11-17', 'IT Support Engineer', 58000.00, 6),
('Michael', 'Clark', 'michael.clark@gmail.com', '4445556666', '2021-07-19', 'Research Scientist', 90000.00, 7),
('Sophia', 'Martinez', 'sophia.martinez@gmail.com', '5556667777', '2018-09-25', 'Legal Advisor', 95000.00, 8);

INSERT INTO projects(project_name, start_date, end_date, department_id) VALUES
('Mobile App Development', '2022-01-10', '2022-12-30', 2),
('AI Research Initiative', '2023-06-01', NULL, 7),
('Customer Support Automation', '2023-09-05', NULL, 6),
('Financial Risk Analysis', '2022-05-15', '2023-05-30', 4),
('Corporate Legal Compliance', '2021-11-20', '2023-03-15', 8);

INSERT INTO employee_projects(employee_id, project_id, assigned_date) VALUES
(1, 3, '2023-10-01'),
(2, 1, '2022-02-01'),
(3, 5, '2021-12-01'),
(4, 2, '2023-07-10'),
(5, 4, '2022-06-01');

INSERT INTO salaries(employee_id, salary, effective_date) VALUES
(1, 75000.00, '2021-03-12'),
(2, 68000.00, '2019-06-23'),
(3, 58000.00, '2022-11-17'),
(4, 90000.00, '2021-07-19'),
(5, 95000.00, '2018-09-25'),
(1, 78000.00, '2022-03-12'), 
(2, 70000.00, '2020-06-23'), 
(3, 60000.00, '2023-11-17'); 

--QUERIES

--find employees earning between 60000 and 80000
select first_name,last_name,salary
from employees
where salary between 60000 and 80000;

--list employees hired in 2022
select first_name,last_name,hire_date
from employees
where hire_date between '2022-01-01' and '2022-12-31';

--retrieve all projects started in or after 2023
select project_name,start_date
from projects
where start_date>='2023-01-01';

--find the total number of employees in each department
select d.department_name, count(e.employee_id) as total_employees
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name;

--show employees who received multiple salary increments
select e.first_name,e.last_name,s.employee_id,count(salary_id) as salary_increments
from salaries s
join employees e on e.employee_id=s.employee_id
group by s.employee_id,first_name,last_name
having count(salary_id)>1;

--find projects that are still going on
select project_name,start_date,end_date
from projects
where end_date is null;

--categorize employees by experience level

SELECT first_name, last_name, hire_date,
CASE 
WHEN hire_date <= CURRENT_DATE - INTERVAL '6 years' THEN 'Senior'
WHEN hire_date > CURRENT_DATE - INTERVAL '6 years' 
AND hire_date <= CURRENT_DATE - INTERVAL '4 years' THEN 'Mid-Senior'
ELSE 'Junior'
END AS experience_level
FROM employees;

--deternmine employee bonus based on salary and years worked
select first_name,last_name,salary,hire_date,
case 
when salary>80000 and (current_date-hire_date) > (6*365) then '20% bonus'
when salary between 50000 and 80000 then '10% bonus'
else '5% bonus'
end as bonus
from employees;