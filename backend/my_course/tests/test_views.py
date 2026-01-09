import pytest
from my_course.models import Course
from django.contrib.auth.models import Group
from django.urls import reverse

"""
Fixture that can be re-used if needed a student user.
"""

@pytest.fixture
def student_user(django_user_model):
    user = django_user_model.objects.create_user(username="student", password="useruser")
    Group.objects.create(name="Student")
    user.groups.add(Group.objects.get(name="Student"))
    return user

"""
Fixture that can be re-used if needed a mentor user.
"""

@pytest.fixture
def mentor_user(django_user_model):
    user = django_user_model.objects.create_user(username="mentor", password="useruser")
    Group.objects.create(name="Mentor")
    user.groups.add(Group.objects.get(name="Mentor"))
    return user

"""
Fixture that can be re-used if needed a course model.
"""

@pytest.fixture
def test_course(mentor_user):
    return Course.objects.create(
        course_title="Bananas",
        category="Bananas",
        school_name="Bananas",
        author="Bananas",
        user=mentor_user,
        available_until="2026-01-01",
    )

#---------------------- HOME PAGE TEST --------------------#

"""
Testing homepage access with in a successful ending.
"""

@pytest.mark.django_db
def test_homepage(client):
    response = client.get("/")
    assert response
    assert response.status_code == 200

"""
Testing homepage access with an unsuccessful ending.
"""

@pytest.mark.django_db
def test_course_not_logged_in(client):
    response = client.get("/course")
    assert response
    assert response.status_code != 200

#---------------------- ADMIN TEST --------------------#

"""
Testing admin page with a successful ending with right credentials.
"""

@pytest.mark.django_db
def test_admin_page(client, django_user_model):
    django_user_model.objects.create_superuser(username="admin", password="admin") 
    client.login(username="admin", password="admin")
    response = client.get("/admin/")
    assert response.status_code == 200

"""
Testing admin page with an unsuccessful ending with blank password as credentials.
"""

@pytest.mark.django_db
def test_failure_admin_page(client, django_user_model):
    django_user_model.objects.create_superuser(username="admin", password="admin") 
    client.login(username="admin", password="")
    response = client.get("/admin/")
    assert response.status_code != 200

#---------------------- LOGIN TEST --------------------#

"""
Testing user signup with a successful ending with credentials.
"""

@pytest.mark.django_db
def test_signup_sucess(client):
    Group.objects.create(name="Student")
    response = client.post("/signup", {
        "username": "student",
        "password1": "useruser",
        "password2": "useruser"
    })
    assert response.status_code == 302
    assert client.login(username="student", password="useruser")

"""
Testing user signup with an unsuccessful ending with wrong password confirmation as credentials.
"""

@pytest.mark.django_db
def test_signup_error(client):
    Group.objects.create(name="Student")
    response = client.post("/signup", {
        "username": "student",
        "password1": "useruser",
        "password2": "useruserr"
    })
    assert response.status_code == 200
    assert "The two password fields didn’t match" in response.content.decode()
    assert not client.login(username="student", password="useruser")

#---------------------- COURSE ENROLLMENT TEST --------------------#

"""
Testing user course enrollment with successful ending.
"""

@pytest.mark.django_db
def test_course_enrollment(client, student_user, test_course):
    client.force_login(student_user)
    url = reverse('course_enroll', kwargs={'pk': test_course.pk})
    response = client.post(url)
    assert response.status_code == 302
    test_course.refresh_from_db()
    assert student_user in test_course.students.all()

#---------------------- DELETE COURSE TEST --------------------#

"""
Testing course deletion from mentor with successful ending.
"""

@pytest.mark.django_db
def test_successful_course_deletion(client, mentor_user, test_course):
    client.force_login(mentor_user)
    url = reverse('course_delete', kwargs={'pk': test_course.pk})
    assert Course.objects.count() == 1
    response = client.post(url)
    assert response.status_code == 302
    assert Course.objects.count() == 0
    

#--------------------- UPDATE COURSE TEST ---------------------#

"""
Testing course update from mentor with successful ending.
"""

@pytest.mark.django_db
def test_successful_course_update(client, mentor_user, test_course):
    client.force_login(mentor_user)
    url = reverse('course_update', kwargs={'pk': test_course.pk}) 
    response = client.post(url, {
        'course_title': 'More Bananas',
        'category': 'Bananas',
        'school_name': 'Bananas',
        'description': 'More Bananas',
        'price': '100.00',
        'available_until': '2026-01-01',
        'author': 'Bananas',
    })
    
    test_course.refresh_from_db()
    assert response.status_code == 302
    assert test_course.course_title == 'More Bananas'
    assert test_course.description == 'More Bananas'