from django.urls import path
from django.views.generic import RedirectView

from .views import crew_route_view, dashboard_view, login_view, logout_view, role_dashboard_view
from .views import admin_routes_view, admin_fleet_view, admin_zones_view, admin_reports_view

urlpatterns = [
    path("", RedirectView.as_view(pattern_name="login", permanent=False)),
    path("login/", login_view, name="login"),
    path("dashboard/", dashboard_view, name="dashboard"),
    path("dashboard/<slug:role_slug>/", role_dashboard_view, name="role-dashboard"),
    path("route/crew/", crew_route_view, name="crew-route"),
    path("adminpanel/routes/", admin_routes_view, name="admin-routes"),
    path("adminpanel/fleet/", admin_fleet_view, name="admin-fleet"),
    path("adminpanel/zones/", admin_zones_view, name="admin-zones"),
    path("adminpanel/reports/", admin_reports_view, name="admin-reports"),
    path("logout/", logout_view, name="logout"),
]
