from django import forms
from django.contrib.auth import authenticate


class RoleBasedLoginForm(forms.Form):
    USER_TYPE_CHOICES = (
        ("Admin", "Admin"),
        ("Resident", "Resident"),
        ("Collection Crew", "Collection Crew"),
    )

    user_type = forms.ChoiceField(choices=USER_TYPE_CHOICES)
    username = forms.CharField(max_length=150)
    password = forms.CharField(widget=forms.PasswordInput)

    error_messages = {
        "invalid_login": "Please enter a correct username and password.",
        "invalid_role": "This account is not assigned to the selected user type.",
    }

    def __init__(self, request=None, *args, **kwargs):
        self.request = request
        self.user = None
        super().__init__(*args, **kwargs)

    def clean(self):
        cleaned_data = super().clean()
        user_type = cleaned_data.get("user_type")
        username = cleaned_data.get("username")
        password = cleaned_data.get("password")

        if username and password:
            self.user = authenticate(self.request, username=username, password=password)
            if self.user is None:
                raise forms.ValidationError(self.error_messages["invalid_login"])

            in_selected_group = self.user.groups.filter(name=user_type).exists()
            admin_override = user_type == "Admin" and self.user.is_superuser
            if not in_selected_group and not admin_override:
                raise forms.ValidationError(self.error_messages["invalid_role"])

        return cleaned_data

    def get_user(self):
        return self.user
