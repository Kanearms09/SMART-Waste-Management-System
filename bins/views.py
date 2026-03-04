from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render

from .forms import RoleBasedLoginForm


ROLE_SLUGS = {
	"Admin": "admin",
	"Resident": "resident",
	"Collection Crew": "collection-crew",
}


def get_user_primary_role(user):
	if user.is_superuser:
		return "Admin"

	for role_name in ROLE_SLUGS:
		if user.groups.filter(name=role_name).exists():
			return role_name

	return None


def role_slug_for_user(user):
	role_name = get_user_primary_role(user)
	if not role_name:
		return None
	return ROLE_SLUGS[role_name]


def login_view(request):
	if request.user.is_authenticated:
		slug = role_slug_for_user(request.user)
		if slug:
			return redirect("role-dashboard", role_slug=slug)
		return redirect("logout")

	form = RoleBasedLoginForm(request=request, data=request.POST or None)
	if request.method == "POST" and form.is_valid():
		login(request, form.get_user())
		slug = role_slug_for_user(request.user)
		if slug:
			return redirect("role-dashboard", role_slug=slug)
		return redirect("logout")

	return render(request, "bins/login.html", {"form": form})


@login_required
def dashboard_view(request):
	slug = role_slug_for_user(request.user)
	if not slug:
		return redirect("logout")
	return redirect("role-dashboard", role_slug=slug)


@login_required
def role_dashboard_view(request, role_slug):
	expected_slug = role_slug_for_user(request.user)
	if not expected_slug:
		return redirect("logout")

	if role_slug != expected_slug:
		return redirect("role-dashboard", role_slug=expected_slug)

	role_name = get_user_primary_role(request.user)
	return render(
		request,
		"bins/dashboard.html",
		{
			"group_name": role_name,
			"role_slug": role_slug,
		},
	)


@login_required
def logout_view(request):
	logout(request)
	return redirect("login")
