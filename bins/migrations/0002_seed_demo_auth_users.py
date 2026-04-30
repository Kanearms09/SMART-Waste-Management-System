from django.contrib.auth.hashers import make_password
from django.db import migrations


DEMO_USERS = [
    {
        "username": "Kane",
        "password": "Chronic2001!",
        "group": "Admin",
        "is_superuser": True,
        "is_staff": True,
    },
    {
        "username": "Jane_Joe",
        "password": "handstand",
        "group": "Resident",
        "is_superuser": False,
        "is_staff": False,
    },
    {
        "username": "Bill_Bob",
        "password": "RoyAyers2001!",
        "group": "Collection Crew",
        "is_superuser": False,
        "is_staff": False,
    },
    {
        "username": "Eshan",
        "password": "Glock40!",
        "group": "Admin",
        "is_superuser": False,
        "is_staff": False,
    },
    {
        "username": "Maham",
        "password": "Rango20?",
        "group": "Admin",
        "is_superuser": False,
        "is_staff": False,
    },
    {
        "username": "Semayyah",
        "password": "Hippie10£",
        "group": "Admin",
        "is_superuser": False,
        "is_staff": False,
    },
]


def seed_demo_auth_users(apps, schema_editor):
    User = apps.get_model("auth", "User")
    Group = apps.get_model("auth", "Group")

    group_objects = {
        group_name: Group.objects.get_or_create(name=group_name)[0]
        for group_name in {user["group"] for user in DEMO_USERS}
    }

    for user_data in DEMO_USERS:
        user, _created = User.objects.get_or_create(username=user_data["username"])
        user.email = user.email or f"{user.username.lower()}@example.com"
        user.is_superuser = user_data["is_superuser"]
        user.is_staff = user_data["is_staff"] or user_data["is_superuser"]
        user.password = make_password(user_data["password"])
        user.save()

        if not user.groups.filter(name=user_data["group"]).exists():
            user.groups.clear()
            user.groups.add(group_objects[user_data["group"]])


class Migration(migrations.Migration):

    dependencies = [
        ("bins", "0001_initial"),
        ("auth", "0012_alter_user_first_name_max_length"),
    ]

    operations = [
        migrations.RunPython(seed_demo_auth_users, migrations.RunPython.noop),
    ]