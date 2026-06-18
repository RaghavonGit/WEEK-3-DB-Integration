CREATE DATABASE college_db;
USE college_db;

CREATE TABLE departments(
department_id int primary key auto_increment,
dept_name varchar(100) not null,
hod_name varchar(100),
budget decimal(12,2));

CREATE TABLE students(
student_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(100) unique not null,
date_of_birth date,
department_id int, foreign key(department_id) references departments(department_id),
enrollment_year int);

CREATE TABLE courses(
course_id int primary key auto_increment,
course_name varchar(150) not null,
course_code varchar(20) unique,
credits int,
department_id int, foreign key(department_id) references departments(department_id));

CREATE TABLE enrollments(
enrollment_id int primary key auto_increment,
student_id int, foreign key(student_id) references students(student_id),
course_id int, foreign key(course_id) references courses(course_id),
enrollment_date date,
grade char(2));

CREATE TABLE professors(
professor_id int primary key auto_increment,
prof_name varchar(100) not null,
email varchar(100) unique,
department_id int, foreign key(department_id) references departments(department_id),
salary decimal(10,2));

INSERT INTO departments (dept_name, hod_name, budget) VALUES
  ('Computer Science', 'Dr. Ramesh Kumar', 850000.00),
  ('Electronics', 'Dr. Priya Nair', 620000.00),
  ('Mechanical', 'Dr. Suresh Iyer', 540000.00),
  ('Civil', 'Dr. Ananya Sharma', 430000.00);

INSERT INTO students (first_name, last_name, email, date_of_birth, department_id, enrollment_year) VALUES
  ('Arjun',  'Mehta',    'arjun.mehta@college.edu',    '2003-04-12', 1, 2022),
  ('Priya',  'Suresh',   'priya.suresh@college.edu',   '2003-07-25', 1, 2022),
  ('Rohan',  'Verma',    'rohan.verma@college.edu',    '2002-11-08', 2, 2021),
  ('Sneha',  'Patel',    'sneha.patel@college.edu',    '2004-01-30', 3, 2023),
  ('Vikram', 'Das',      'vikram.das@college.edu',     '2003-09-14', 1, 2022),
  ('Kavya',  'Menon',    'kavya.menon@college.edu',    '2002-05-17', 2, 2021),
  ('Aditya', 'Singh',    'aditya.singh@college.edu',   '2004-03-22', 4, 2023),
  ('Deepika','Rao',      'deepika.rao@college.edu',    '2003-08-09', 1, 2022);

INSERT INTO courses (course_name, course_code, credits, department_id) VALUES
  ('Data Structures & Algorithms', 'CS101', 4, 1),
  ('Database Management Systems',  'CS102', 3, 1),
  ('Object Oriented Programming',  'CS103', 4, 1),
  ('Circuit Theory',               'EC101', 3, 2),
  ('Thermodynamics',               'ME101', 3, 3);

INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
  (1, 1, '2022-07-01', 'A'), (1, 2, '2022-07-01', 'B'),
  (2, 1, '2022-07-01', 'B'), (2, 3, '2022-07-01', 'A'),
  (3, 4, '2021-07-01', 'A'), (4, 5, '2023-07-01', NULL),
  (5, 1, '2022-07-01', 'C'), (5, 2, '2022-07-01', 'A'),
  (6, 4, '2021-07-01', 'B'), (7, 5, '2023-07-01', NULL),
  (8, 1, '2022-07-01', 'A'), (8, 3, '2022-07-01', 'B');

INSERT INTO professors (prof_name, email, department_id, salary) VALUES
  ('Dr. Anand Krishnan', 'anand.k@college.edu', 1, 95000.00),
  ('Dr. Meena Pillai',   'meena.p@college.edu', 1, 88000.00),
  ('Dr. Sunil Rajan',    'sunil.r@college.edu', 2, 82000.00),
  ('Dr. Latha Gopal',    'latha.g@college.edu', 3, 79000.00),
  ('Dr. Kartik Bose',    'kartik.b@college.edu', 4, 76000.00);

DESCRIBE departments;
DESCRIBE students;
DESCRIBE courses;
DESCRIBE enrollments;
DESCRIBE professors;

ALTER TABLE students ADD COLUMN phone_number VARCHAR(15);
ALTER TABLE courses ADD COLUMN max_seats INT DEFAULT 60;
ALTER TABLE enrollments ADD CONSTRAINT chk_grade CHECK (grade IN ('A','B','C','D','F') OR grade IS NULL);
ALTER TABLE departments CHANGE hod_name head_of_dept VARCHAR(100);
ALTER TABLE students DROP COLUMN phone_number;
