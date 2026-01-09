#!/usr/bin/env python
from datetime import datetime
import typer
import os
import django
import sys
from django.contrib.auth import get_user_model
import json


sys.path.append(os.path.dirname(os.path.dirname(__file__)))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "learning_hub.settings")
django.setup()

from django.contrib.auth.models import Group
from my_course.models import Course

app = typer.Typer(help="ADMIN | CLI for Admins only")
User = get_user_model()


"""
CLI Commands for Admin use only.
    - Create admin user if necessary.
    - Create a basic user on demand.
    - Can delete user on demand.
    - Set any existing group to a user. For mentors.
    - Remove any assigned group from a user.
    - List all existing course, in a regular or short print.
        Can be saved to a Json if needed.
"""


@app.command()
def super():
    """
    Create a Super User
    [CMD: super]
    """
    username = typer.prompt("Username")
    email = typer.prompt("Email", default="").strip()
    password = typer.prompt("Password", hide_input=True)
    password2 = typer.prompt("Confirm Password", hide_input=True)


    if password != password2:
        typer.echo("❌ Passwords do not match! ❌")
        raise typer.Exit()
    
    email = email or None

    User.objects.create_superuser(username=username, email=email, password=password)
    typer.echo(f"✅ SuperUser: {username} | Created successfully! ✅")


@app.command()
def create_user():
    """
    Create a  User
    [CMD: create-user]
    """
    username = typer.prompt("Username")
    password = typer.prompt("Password", hide_input=True)
    password2 = typer.prompt("Confirm Password", hide_input=True)


    if password != password2:
        typer.echo("❌ Passwords do not match! ❌")
        raise typer.Exit()
    

    User.objects.create_user(username=username, password=password)
    typer.echo(f"✅ User: {username} with password: {password} | Created successfully! ✅")


@app.command()
def delete_user(username: str):
    """
    Delete a user (Specify username)
    [CMD: delete-user <username>]
    """
    if typer.confirm(f"⚠️  Delete user {username}?"):
        try:
            user = User.objects.get(username=username)
            user.delete()
            typer.echo(f"✅ User {username} deleted!")
        except User.DoesNotExist:
            typer.echo(f"❌ User {username} not found!", err=True)
            raise typer.Exit(1)



@app.command()
def group_user(username: str = typer.Argument(...), group_name: str = typer.Argument(...)):
    """
    Set a group to a user
    [CMD: group-user <username> <group_name>]
    """
    try:
        user = User.objects.get(username=username)
    except User.DoesNotExist:
        typer.echo(f"❌ User {username} not found!", err=True)
        raise typer.Exit(1)

    # Check if group exists, if not, create it
    group, created = Group.objects.get_or_create(name=group_name)

    # Assign user to the group
    user.groups.set([group])
    
    if created:
        typer.echo(f"✅ Created new group: {group_name}")

    typer.echo(f"✅ Added {username} to {group_name} group!")

    

@app.command()
def reset_group(username: str = typer.Argument(...)):
    """
    Reset groups from user
    [CMD: reset-group <username>]
    """
    try:
        user = User.objects.get(username=username)
        user.groups.clear()
        typer.echo(f"✅ Removed all groups from {username}!")
    except User.DoesNotExist:
        typer.echo(f"❌ User {username} not found!", err=True)
        raise typer.Exit(1)


@app.command()
def list_courses(short: bool = False, long: bool = False, save: bool = False):
    """
    List courses of E-HUB
    [CMD: list-course]
    """
    courses = Course.objects.all().order_by('-post_date')
    
    if not courses.exists():
        typer.echo("❌ No courses found!")
        return
    try:
        if short:
            typer.echo("\n📚 Course available at E-HUB")
            typer.echo("-" * 75)
            typer.echo(f"{'Title':<50} | {'School':<18}")
            typer.echo("-" * 75)
    
            for course in courses:
                typer.echo(f"{course.course_title:<50} | {course.school_name:<18}")
            typer.echo("\n")
        else:
            typer.echo("\n📚 Course available at E-HUB")
            typer.echo("-" * 120)
            typer.echo(f"{'ID':<5} | {'Title':<50} | {'Category':<18} | {'School':<18} | {'Price':<8}")
            typer.echo("-" * 120)

            for course in courses:
                typer.echo(f"{course.id:<5} | {course.course_title:<50} | {course.category:<18} | {course.school_name:<18} | {course.price:<8}€")
            typer.echo("\n")
        if save:
            date_time = datetime.now()
            json_filename = (f"{date_time}_list_course.json")
            course_list = []
            for course in courses:
                course_list.append({
                    "id": course.id,
                    "title": course.course_title,
                    "category": course.category,
                    "school": course.school_name,
                    "description": course.description,
                    "price": float(course.price),
                    "available_until": course.available_until.isoformat(),
                    "post_date": course.post_date.isoformat(),
                    "user": course.user.username,
                    "author": course.author,
                })
            with open(json_filename, 'w') as f:
                json.dump(course_list, f, indent=2)
            typer.echo(f"✅ Json saved to: {json_filename}")
    except Exception as e:
        typer.echo(f"{e}")
        raise

    



if __name__ == "__main__":
    app()