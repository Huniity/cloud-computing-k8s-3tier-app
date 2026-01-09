#!/usr/bin/env python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'learning_hub.settings')
django.setup()

from django.contrib.auth.models import User, Group

# Create or update mentor user
mentor_user, created = User.objects.get_or_create(username='TestMentor')
mentor_user.set_password('mentor123')
mentor_group, _ = Group.objects.get_or_create(name='Mentor')
mentor_user.groups.add(mentor_group)
mentor_user.save()

print("👤 Mentor User Created:")
print(f"   Username: TestMentor")
print(f"   Password: mentor123")
print()

# Create or update student user
student_user, created = User.objects.get_or_create(username='TestStudent')
student_user.set_password('student123')
student_group, _ = Group.objects.get_or_create(name='Student')
student_user.groups.add(student_group)
student_user.save()

print("👥 Student User Created:")
print(f"   Username: TestStudent")
print(f"   Password: student123")
