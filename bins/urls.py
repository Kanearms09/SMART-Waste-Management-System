from django.urls import path
from django.views.generic import RedirectView

from .views import dashboard_view, login_view, logout_view, role_dashboard_view

urlpatterns = [
    path("", RedirectView.as_view(pattern_name="login", permanent=False)),
    path("login/", login_view, name="login"),
    path("dashboard/", dashboard_view, name="dashboard"),
    path("dashboard/<slug:role_slug>/", role_dashboard_view, name="role-dashboard"),
    path("logout/", logout_view, name="logout"),
]
