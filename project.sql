CREATE DATABASE EmployeeManagementSystem;

USE EmployeeManagementSystem;
 -- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;

desc JobDepartment;
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from SalaryBonus;
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from Employee;
-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from Qualification;
-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from Leaves;
-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from payroll;


SELECT COUNT(*) FROM JobDepartment;
SELECT COUNT(*) FROM SalaryBonus;
SELECT COUNT(*) FROM Employee;
SELECT COUNT(*) FROM Qualification;
SELECT COUNT(*) FROM Leaves;
SELECT COUNT(*) FROM Payroll;

/* ========================================================
1. EMPLOYEE INSIGHTS
==========================================================*/

-- 1. How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS unique_employees
FROM Employee;

-- 2.  Which departments have the highest number of employees?
SELECT 
    jd.jobdept AS department,
    COUNT(e.emp_ID) AS employee_count
FROM Employee e
JOIN JobDepartment jd
    ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY employee_count DESC;

-- 3. what  is the average salary per department?
SELECT 
    jd.jobdept AS department,
    AVG(sb.amount) AS average_salary
FROM JobDepartment jd
JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- 4.  Who are the top 5 highest-paid employees?
SELECT 
    e.emp_ID,
    CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
    sb.amount AS salary
FROM Employee e
JOIN SalaryBonus sb
    ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- 5.  What is the total salary expenditure across the company?
SELECT 
    SUM(sb.amount) AS total_salary_expenditure
FROM SalaryBonus sb;

/* ========================================================
2. JOB ROLE AND DEPARTMENT ANALYSIS
==========================================================*/

-- 1. How many different job roles exist in each department?
SELECT
    jobdept AS department,
    COUNT(*) AS job_role_count
FROM JobDepartment
GROUP BY jobdept
ORDER BY job_role_count DESC;

-- 2. What is the average salary range per department?
SELECT
    jd.jobdept AS department,
    AVG(sb.amount) AS average_salary
FROM JobDepartment jd
INNER JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
HAVING AVG(sb.amount) IS NOT NULL
ORDER BY average_salary DESC;

-- 3. Which job roles offer the highest salary?
SELECT
    jd.name AS job_role,
    jd.jobdept AS department,
    sb.amount AS salary
FROM JobDepartment jd
INNER JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
WHERE sb.amount = (
    SELECT MAX(amount)
    FROM SalaryBonus
);

-- 4. Which departments have the highest total salary allocation?
SELECT
    jd.jobdept AS department,
    SUM(sb.amount) AS total_salary_allocation
FROM JobDepartment jd
JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary_allocation DESC;

/* ========================================================
3. QUALIFICATION AND SKILLS ANALYSIS
==========================================================*/

-- 1. How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS employees_with_qualification
FROM Qualification;

-- 2. Which positions require the most qualifications?
SELECT
    Position,
    COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Position
HAVING COUNT(*) > 0
ORDER BY qualification_count DESC;

-- 3. Which employees have the highest number of qualifications?
SELECT
    Emp_ID,
    COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Emp_ID
HAVING COUNT(*) = (
    SELECT MAX(qualification_count)
    FROM (
        SELECT COUNT(*) AS qualification_count
        FROM Qualification
        GROUP BY Emp_ID
    ) AS employee_qualification_counts
);

/* ========================================================
4. LEAVE AND ABSENCE PATTERNS
==========================================================*/

-- 1. Which year had the most employees taking leaves?
SELECT
    YEAR(date) AS leave_year,
    COUNT(DISTINCT emp_ID) AS employees_on_leave
FROM Leaves
GROUP BY YEAR(date)
ORDER BY employees_on_leave DESC
LIMIT 1;

-- 2. What is the average number of leave days taken by its employees per department?
SELECT
    jd.jobdept AS department,
    AVG(leave_count) AS average_leave_days
FROM (
    SELECT
        e.Job_ID,
        e.emp_ID,
        COUNT(l.leave_ID) AS leave_count
    FROM Employee e
    LEFT JOIN Leaves l
        ON e.emp_ID = l.emp_ID
    GROUP BY e.Job_ID, e.emp_ID
) AS employee_leaves
JOIN JobDepartment jd
    ON employee_leaves.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- 3. Which employees have taken the most leaves?
SELECT
    emp_ID,
    COUNT(leave_ID) AS total_leave_days
FROM Leaves
GROUP BY emp_ID
HAVING COUNT(leave_ID) = (
    SELECT MAX(leave_count)
    FROM (
        SELECT COUNT(leave_ID) AS leave_count
        FROM Leaves
        GROUP BY emp_ID
    ) AS employee_leave_counts
);

-- 4. What is the total number of leave days taken company-wide?
SELECT
    COUNT(leave_ID) AS total_leave_days
FROM Leaves;
-- 5. How do leave days correlate with payroll amounts?
SELECT
    e.emp_ID,
    CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
    COALESCE(l.total_leave_days, 0) AS total_leave_days,
    COALESCE(p.total_payroll, 0) AS total_payroll
FROM Employee e
LEFT JOIN (
    SELECT
        emp_ID,
        COUNT(leave_ID) AS total_leave_days
    FROM Leaves
    GROUP BY emp_ID
) AS l
    ON e.emp_ID = l.emp_ID
LEFT JOIN (
    SELECT
        emp_ID,
        SUM(total_amount) AS total_payroll
    FROM Payroll
    GROUP BY emp_ID
) AS p
    ON e.emp_ID = p.emp_ID;
/* ========================================================
5. PAYROLL AND COMPENSATION ANALYSIS
==========================================================*/
-- 1. What is the total monthly payroll processed?
Desc payroll;
SELECT
    YEAR(date) AS payroll_year,
    MONTH(date) AS payroll_month,
    SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY payroll_year, payroll_month;
-- 2. What is the average bonus given per department?
SELECT
    jd.jobdept AS department,
    AVG(sb.bonus) AS average_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY average_bonus DESC;

-- 3. Which department receives the highest total bonuses?
SELECT
    jd.jobdept AS department,
    SUM(sb.bonus) AS total_bonus
FROM JobDepartment jd
INNER JOIN SalaryBonus sb
    ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
HAVING SUM(sb.bonus) = (
    SELECT MAX(department_bonus)
    FROM (
        SELECT SUM(bonus) AS department_bonus
        FROM SalaryBonus
        GROUP BY Job_ID
    ) AS bonus_totals
);

-- 4. What is the average value of total_amount after considering leave deductions?
SELECT
    AVG(
        CASE
            WHEN total_amount IS NOT NULL
            THEN total_amount
            ELSE NULL
        END
    ) AS average_payroll_after_leave_deductions
FROM Payroll;
