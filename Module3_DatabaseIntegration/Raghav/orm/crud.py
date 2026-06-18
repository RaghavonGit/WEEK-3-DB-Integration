from datetime import date
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, joinedload
from models import Base, Department, Student, Course, Enrollment, Professor

DB_URL = "mysql+mysqlconnector://root:root@localhost/college_db_orm"


def get_session(echo=False):
    engine = create_engine(DB_URL, echo=echo)
    Session = sessionmaker(bind=engine)
    return Session()


def insert_departments_and_students():
    session = get_session()

    cs   = Department(dept_name='Computer Science', hod_name='Dr. Ramesh Kumar', budget=850000.00)
    ec   = Department(dept_name='Electronics',      hod_name='Dr. Priya Nair',   budget=620000.00)
    mech = Department(dept_name='Mechanical',       hod_name='Dr. Suresh Iyer',  budget=540000.00)
    session.add_all([cs, ec, mech])
    session.commit()

    students = [
        Student(first_name='Arjun',  last_name='Mehta',  email='arjun.mehta@orm.edu',  department_id=cs.department_id,   enrollment_year=2022),
        Student(first_name='Priya',  last_name='Suresh', email='priya.suresh@orm.edu',  department_id=cs.department_id,   enrollment_year=2022),
        Student(first_name='Rohan',  last_name='Verma',  email='rohan.verma@orm.edu',   department_id=ec.department_id,   enrollment_year=2021),
        Student(first_name='Sneha',  last_name='Patel',  email='sneha.patel@orm.edu',   department_id=mech.department_id, enrollment_year=2023),
        Student(first_name='Vikram', last_name='Das',    email='vikram.das@orm.edu',    department_id=cs.department_id,   enrollment_year=2022),
    ]
    session.add_all(students)
    session.commit()
    print("Inserted: %d departments, %d students" % (session.query(Department).count(), session.query(Student).count()))
    session.close()


def insert_courses_and_enrollments():
    session = get_session()

    cs_dept = session.query(Department).filter_by(dept_name='Computer Science').first()

    dsa  = Course(course_name='Data Structures & Algorithms', course_code='CS101', credits=4, department_id=cs_dept.department_id)
    dbms = Course(course_name='Database Management Systems',  course_code='CS102', credits=3, department_id=cs_dept.department_id)
    oop  = Course(course_name='Object Oriented Programming',  course_code='CS103', credits=4, department_id=cs_dept.department_id)
    session.add_all([dsa, dbms, oop])
    session.commit()

    s1 = session.query(Student).filter_by(email='arjun.mehta@orm.edu').first()
    s2 = session.query(Student).filter_by(email='priya.suresh@orm.edu').first()
    s3 = session.query(Student).filter_by(email='rohan.verma@orm.edu').first()
    s4 = session.query(Student).filter_by(email='sneha.patel@orm.edu').first()

    enrollments = [
        Enrollment(student_id=s1.student_id, course_id=dsa.course_id,  enrollment_date=date(2022, 7, 1), grade='A'),
        Enrollment(student_id=s2.student_id, course_id=dbms.course_id, enrollment_date=date(2022, 7, 1), grade='B'),
        Enrollment(student_id=s3.student_id, course_id=dsa.course_id,  enrollment_date=date(2021, 7, 1), grade='A'),
        Enrollment(student_id=s4.student_id, course_id=oop.course_id,  enrollment_date=date(2023, 7, 1), grade=None),
    ]
    session.add_all(enrollments)
    session.commit()
    print("Inserted: %d courses, %d enrollments" % (session.query(Course).count(), session.query(Enrollment).count()))
    session.close()


def read_cs_students():
    session = get_session()
    students = (
        session.query(Student)
        .join(Department)
        .filter(Department.dept_name == 'Computer Science')
        .all()
    )
    print("\nStudents in Computer Science:")
    for s in students:
        print("  %s %s (%d)" % (s.first_name, s.last_name, s.enrollment_year))
    session.close()


def read_enrollments_n1():
    engine = create_engine(DB_URL, echo=True)
    Session = sessionmaker(bind=engine)
    session = Session()

    print("\n--- Enrollments with LAZY LOADING (echo=True) ---")
    enrollments = session.query(Enrollment).all()
    for e in enrollments:
        _ = e.student.first_name
        _ = e.course.course_name
        print("  %s -> %s | grade=%s" % (e.student.first_name, e.course.course_name, e.grade))
    session.close()


def update_student():
    session = get_session()
    student = session.query(Student).filter_by(email='arjun.mehta@orm.edu').first()
    student.enrollment_year = 2023
    session.commit()
    print("\nUpdated: %s enrollment_year = %d" % (student.first_name, student.enrollment_year))
    session.close()


def delete_enrollment():
    session = get_session()
    enrollment = session.query(Enrollment).filter_by(grade=None).first()
    if enrollment:
        print("\nDeleting enrollment_id=%d (grade=None)" % enrollment.enrollment_id)
        session.delete(enrollment)
        session.commit()
    print("Enrollments remaining: %d" % session.query(Enrollment).count())
    session.close()


def read_enrollments_joinedload():
    engine = create_engine(DB_URL, echo=True)
    Session = sessionmaker(bind=engine)
    session = Session()

    print("\n--- Enrollments with JOINEDLOAD (echo=True) ---")
    enrollments = (
        session.query(Enrollment)
        .options(
            joinedload(Enrollment.student),
            joinedload(Enrollment.course)
        )
        .all()
    )
    for e in enrollments:
        print("  %s -> %s | grade=%s" % (e.student.first_name, e.course.course_name, e.grade))
    session.close()


if __name__ == '__main__':
    insert_departments_and_students()
    insert_courses_and_enrollments()
    read_cs_students()
    read_enrollments_n1()
    update_student()
    delete_enrollment()
    read_enrollments_joinedload()
