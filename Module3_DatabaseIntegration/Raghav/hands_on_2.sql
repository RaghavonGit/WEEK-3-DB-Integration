
USE college_db;

SELECT 'departments' AS tbl, COUNT(*) AS cnt FROM departments
UNION ALL SELECT 'students',   COUNT(*) FROM students
UNION ALL SELECT 'courses',    COUNT(*) FROM courses
UNION ALL SELECT 'enrollments',COUNT(*) FROM enrollments
UNION ALL SELECT 'professors', COUNT(*) FROM professors;

INSERT INTO students (first_name, last_name, email, date_of_birth, department_id, enrollment_year) VALUES
  ('Kiran',  'Sharma',   'kiran.sharma@college.edu',   '2003-05-15', 2, 2022),
  ('Divya',  'Krishnan', 'divya.krishnan@college.edu', '2004-02-20', 3, 2023);

SELECT COUNT(*) AS students_after_insert FROM students;

SELECT student_id, course_id, grade FROM enrollments WHERE student_id = 5 AND course_id = 1;

UPDATE enrollments
SET grade = 'B'
WHERE student_id = 5 AND course_id = 1;


SELECT student_id, course_id, grade FROM enrollments WHERE student_id = 5 AND course_id = 1;

SELECT * FROM enrollments WHERE grade IS NULL;

set sql_safe_updates=0;
DELETE FROM enrollments WHERE grade IS NULL;

SELECT COUNT(*) AS enrollments_after_delete FROM enrollments;

SELECT 'students'    AS tbl, COUNT(*) AS cnt FROM students
UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments;

SELECT student_id, first_name, last_name, email, enrollment_year
FROM students
WHERE enrollment_year = 2022
ORDER BY last_name ASC;

SELECT course_id, course_name, course_code, credits
FROM courses
WHERE credits > 3
ORDER BY credits DESC;

SELECT professor_id, prof_name, email, salary
FROM professors
WHERE salary BETWEEN 80000 AND 95000;

SELECT student_id, first_name, last_name, email
FROM students
WHERE email LIKE '%@college.edu';

SELECT enrollment_year, COUNT(*) AS student_count
FROM students
GROUP BY enrollment_year
ORDER BY enrollment_year;

SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    d.dept_name
FROM students s
JOIN departments d ON s.department_id = d.department_id
ORDER BY s.student_id;


SELECT
    e.enrollment_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    c.course_name,
    e.enrollment_date,
    e.grade
FROM enrollments e
JOIN students s  ON s.student_id = e.student_id
JOIN courses  c  ON c.course_id  = e.course_id
ORDER BY e.enrollment_id;

SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    s.email
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

SELECT
    c.course_id,
    c.course_name,
    c.course_code,
    COUNT(e.enrollment_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.course_code
ORDER BY c.course_id;

SELECT
    d.dept_name,
    p.prof_name,
    p.salary
FROM departments d
LEFT JOIN professors p ON d.department_id = p.department_id
ORDER BY d.department_id, p.prof_name;

SELECT
    c.course_name,
    COUNT(e.enrollment_id) AS enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY enrollment_count DESC;

SELECT
    d.dept_name,
    ROUND(AVG(p.salary), 2) AS avg_salary
FROM departments d
JOIN professors p ON d.department_id = p.department_id
GROUP BY d.department_id, d.dept_name
ORDER BY d.department_id;

SELECT department_id, dept_name, budget
FROM departments
WHERE budget > 600000
ORDER BY budget DESC;

SELECT
    e.grade,
    COUNT(*) AS grade_count
FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_code = 'CS101'
GROUP BY e.grade
ORDER BY e.grade;

SELECT
    d.dept_name,
    COUNT(DISTINCT e.student_id) AS enrolled_students
FROM departments d
JOIN courses     c ON c.department_id = d.department_id
JOIN enrollments e ON e.course_id     = c.course_id
GROUP BY d.department_id, d.dept_name
HAVING COUNT(DISTINCT e.student_id) > 2
ORDER BY enrolled_students DESC;

