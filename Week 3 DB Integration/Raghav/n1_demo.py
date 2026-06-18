import mysql.connector
import time

DB_CONFIG = dict(host="localhost", user="root", password="root", database="college_db")


def run_n1_version():
    conn = mysql.connector.connect(**DB_CONFIG)
    cur = conn.cursor()
    query_count = 0
    start = time.perf_counter()

    cur.execute("SELECT enrollment_id, student_id, course_id FROM enrollments")
    query_count += 1
    enrollments = cur.fetchall()

    results = []
    for enrollment_id, student_id, course_id in enrollments:
        cur.execute(
            "SELECT first_name, last_name FROM students WHERE student_id = %s",
            (student_id,),
        )
        query_count += 1
        student = cur.fetchone()
        results.append((enrollment_id, student[0], student[1]))

    elapsed = time.perf_counter() - start
    cur.close()
    conn.close()
    print(f"[v1 - N+1]  {query_count} queries executed  |  {elapsed * 1000:.2f} ms  |  {len(results)} rows returned")
    return results


def run_join_version():
    conn = mysql.connector.connect(**DB_CONFIG)
    cur = conn.cursor()
    query_count = 0
    start = time.perf_counter()

    cur.execute(
        """
        SELECT e.enrollment_id, s.first_name, s.last_name, c.course_name
        FROM enrollments e
        JOIN students s ON s.student_id = e.student_id
        JOIN courses  c ON c.course_id  = e.course_id
        ORDER BY e.enrollment_id
        """
    )
    query_count += 1
    results = cur.fetchall()

    elapsed = time.perf_counter() - start
    cur.close()
    conn.close()
    print(f"[v2 - JOIN] {query_count} query executed   |  {elapsed * 1000:.2f} ms  |  {len(results)} rows returned")
    return results


if __name__ == "__main__":
    print("=" * 65)
    print("N+1 vs JOIN - Hands-On 4, Task 3")
    print("=" * 65)

    r1 = run_n1_version()
    r2 = run_join_version()

    print("-" * 65)
    print("Both versions return identical row counts:", len(r1) == len(r2))
    print()
    print("Extrapolation to 10,000 enrollments:")
    print("  N+1 version : 1 + 10,000 = 10,001 queries")
    print("  JOIN version: 1 query")
