USE college_db;

SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    COUNT(e.enrollment_id) AS course_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(e.enrollment_id) > (
    SELECT AVG(enroll_count)
    FROM (
        SELECT COUNT(*) AS enroll_count
        FROM enrollments
        GROUP BY student_id
    ) AS per_student
)
ORDER BY course_count DESC;

SELECT c.course_id, c.course_name, c.course_code
FROM courses c
WHERE EXISTS (
    SELECT 1 FROM enrollments e WHERE e.course_id = c.course_id
)
AND NOT EXISTS (
    SELECT 1 FROM enrollments e
    WHERE e.course_id = c.course_id
      AND (e.grade != 'A' OR e.grade IS NULL)
);

SELECT
    d.dept_name,
    p.prof_name,
    p.salary
FROM professors p
JOIN departments d ON p.department_id = d.department_id
WHERE p.salary = (
    SELECT MAX(p2.salary)
    FROM professors p2
    WHERE p2.department_id = p.department_id
)
ORDER BY p.salary DESC;


SELECT dept_summary.dept_name, dept_summary.avg_salary
FROM (
    SELECT d.department_id, d.dept_name, ROUND(AVG(p.salary), 2) AS avg_salary
    FROM departments d
    JOIN professors p ON d.department_id = p.department_id
    GROUP BY d.department_id, d.dept_name
) AS dept_summary
WHERE dept_summary.avg_salary > 85000
ORDER BY dept_summary.avg_salary DESC;

DROP VIEW IF EXISTS vw_student_enrollment_summary;
CREATE VIEW vw_student_enrollment_summary AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    d.dept_name,
    COUNT(e.enrollment_id) AS course_count,
    ROUND(
        AVG(
            CASE e.grade
                WHEN 'A' THEN 4
                WHEN 'B' THEN 3
                WHEN 'C' THEN 2
                WHEN 'D' THEN 1
                WHEN 'F' THEN 0
                ELSE NULL
            END
        ), 2
    ) AS gpa
FROM students s
JOIN departments d ON s.department_id = d.department_id
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name, d.dept_name;


SELECT * FROM vw_student_enrollment_summary ORDER BY gpa DESC;

DROP VIEW IF EXISTS vw_course_stats;
CREATE VIEW vw_course_stats AS
SELECT
    c.course_name,
    c.course_code,
    COUNT(e.enrollment_id) AS total_enrollments,
    ROUND(
        AVG(
            CASE e.grade
                WHEN 'A' THEN 4
                WHEN 'B' THEN 3
                WHEN 'C' THEN 2
                WHEN 'D' THEN 1
                WHEN 'F' THEN 0
                ELSE NULL
            END
        ), 2
    ) AS avg_gpa
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.course_code;

SELECT * FROM vw_course_stats ORDER BY course_code;

SELECT full_name, dept_name, course_count, gpa
FROM vw_student_enrollment_summary
WHERE gpa > 3.0
ORDER BY gpa DESC, full_name;



DROP VIEW IF EXISTS vw_student_enrollment_summary;
DROP VIEW IF EXISTS vw_course_stats;

CREATE VIEW vw_student_enrollment_summary AS
SELECT student_id, first_name, last_name, email, department_id, enrollment_year
FROM students
WHERE enrollment_year >= 2022
WITH CHECK OPTION;

SELECT * FROM vw_student_enrollment_summary ORDER BY enrollment_year, last_name;

CREATE TABLE IF NOT EXISTS department_transfer_log (
    log_id        INT PRIMARY KEY AUTO_INCREMENT,
    student_id    INT          NOT NULL,
    from_dept_id  INT,
    to_dept_id    INT          NOT NULL,
    transfer_date DATE         NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

DROP PROCEDURE IF EXISTS sp_enroll_student;
DELIMITER $$
CREATE PROCEDURE sp_enroll_student(
    IN p_student_id     INT,
    IN p_course_id      INT,
    IN p_enrollment_date DATE
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM enrollments
        WHERE student_id = p_student_id AND course_id = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Duplicate enrollment: student is already enrolled in this course';
    ELSE
        INSERT INTO enrollments (student_id, course_id, enrollment_date, grade)
        VALUES (p_student_id, p_course_id, p_enrollment_date, NULL);
        SELECT 'Enrollment successful' AS result;
    END IF;
END$$
DELIMITER ;

CALL sp_enroll_student(4, 1, '2024-01-15');

DROP PROCEDURE IF EXISTS sp_transfer_student;
DELIMITER $$
CREATE PROCEDURE sp_transfer_student(
    IN p_student_id  INT,
    IN p_to_dept_id  INT
)
BEGIN
    DECLARE v_from_dept_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT department_id INTO v_from_dept_id
    FROM students WHERE student_id = p_student_id;

    UPDATE students SET department_id = p_to_dept_id WHERE student_id = p_student_id;

    INSERT INTO department_transfer_log (student_id, from_dept_id, to_dept_id, transfer_date)
    VALUES (p_student_id, v_from_dept_id, p_to_dept_id, CURDATE());

    COMMIT;
    SELECT CONCAT('Student ', p_student_id, ' transferred from dept ',
                  v_from_dept_id, ' to dept ', p_to_dept_id) AS result;
END$$
DELIMITER ;

CALL sp_transfer_student(1, 2);
SELECT student_id, first_name, department_id FROM students WHERE student_id = 1;

SELECT * FROM department_transfer_log;
CALL sp_transfer_student(1, 1);

SELECT student_id, first_name, department_id FROM students WHERE student_id = 1;
SELECT COUNT(*) AS log_rows_for_failed_transfer FROM department_transfer_log WHERE to_dept_id = 99;

START TRANSACTION;
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade)
VALUES (7, 1, '2024-01-20', NULL);
SAVEPOINT sp1;

INSERT INTO enrollments (student_id, course_id, enrollment_date, grade)
VALUES (999, 1, '2024-01-20', NULL);

ROLLBACK TO SAVEPOINT sp1;
COMMIT;

SELECT student_id, course_id, enrollment_date FROM enrollments
WHERE student_id IN (7, 999)
ORDER BY student_id;