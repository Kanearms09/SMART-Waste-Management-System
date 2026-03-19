import math
from datetime import date, timedelta

from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render

from .forms import RoleBasedLoginForm
from .models import Bin, RouteStop, WeeklyRoute

COLLECTION_THRESHOLD = 70
DEPOT_LAT = 51.5074
DEPOT_LON = -0.1278

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


def _haversine_km(lat1, lon1, lat2, lon2):
	R = 6371.0
	d_lat = math.radians(lat2 - lat1)
	d_lon = math.radians(lon2 - lon1)
	a = (
		math.sin(d_lat / 2) ** 2
		+ math.cos(math.radians(lat1))
		* math.cos(math.radians(lat2))
		* math.sin(d_lon / 2) ** 2
	)
	return R * 2 * math.asin(math.sqrt(a))


def _week_start(for_date=None):
	d = for_date or date.today()
	return d - timedelta(days=d.weekday())


def _next_monday(for_date=None):
	d = for_date or date.today()
	days_ahead = (7 - d.weekday()) % 7
	if days_ahead == 0:
		days_ahead = 7
	return d + timedelta(days=days_ahead)


def _previous_monday(for_date=None):
	d = for_date or date.today()
	days_back = d.weekday()
	if days_back == 0:
		days_back = 7
	return d - timedelta(days=days_back)


def _mondays_elapsed_in_month(for_date=None):
	d = for_date or date.today()
	cursor = d.replace(day=1)
	count = 0
	while cursor <= d:
		if cursor.weekday() == 0:
			count += 1
		cursor += timedelta(days=1)
	return count


def _knn_nearest_neighbor(bins, start_lat, start_lon):
	remaining = list(bins)
	ordered = []
	cur_lat, cur_lon = start_lat, start_lon

	while remaining:
		nearest = min(
			remaining,
			key=lambda b: _haversine_km(cur_lat, cur_lon, b.latitude, b.longitude),
		)
		dist = _haversine_km(cur_lat, cur_lon, nearest.latitude, nearest.longitude)
		ordered.append((nearest, dist))
		cur_lat, cur_lon = nearest.latitude, nearest.longitude
		remaining.remove(nearest)

	return ordered


def _get_or_create_weekly_route():
	week_start = _week_start()

	try:
		return WeeklyRoute.objects.get(week_start=week_start)
	except WeeklyRoute.DoesNotExist:
		pass

	bins = list(Bin.objects.filter(is_active=True, fill_level__gte=COLLECTION_THRESHOLD))
	if not bins:
		bins = list(Bin.objects.filter(is_active=True))

	route = WeeklyRoute.objects.create(week_start=week_start)

	if not bins:
		return route

	ordered = _knn_nearest_neighbor(bins, DEPOT_LAT, DEPOT_LON)
	total_km = 0.0
	stops = []
	for idx, (bin_obj, dist) in enumerate(ordered, start=1):
		total_km += dist
		stops.append(
			RouteStop(route=route, bin=bin_obj, order=idx, distance_from_prev_km=round(dist, 3))
		)

	RouteStop.objects.bulk_create(stops)
	route.total_distance_km = round(total_km, 3)
	route.save(update_fields=["total_distance_km"])

	return route

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

	ROLE_TEMPLATES = {
		"resident": "bins/resident_dashboard.html",
		"collection-crew": "bins/collection_crew_dashboard.html",
		"admin": "bins/dashboard.html",
	}
	template = ROLE_TEMPLATES.get(role_slug, "bins/dashboard.html")

	context = {
		"group_name": role_name,
		"role_slug": role_slug,
	}

	if role_slug == "resident":
		today = date.today()
		context.update(
			{
				"resident_bin_fill_level": 62,
				"resident_next_collection": _next_monday(today),
				"resident_last_collection": _previous_monday(today),
				"resident_collections_this_month": _mondays_elapsed_in_month(today),
			}
		)

	return render(request, template, context)


@login_required
def crew_route_view(request):
	if get_user_primary_role(request.user) not in ("Collection Crew", "Admin"):
		return redirect("role-dashboard", role_slug=role_slug_for_user(request.user))

	weekly_route = _get_or_create_weekly_route()
	week_end = weekly_route.week_start + timedelta(days=6)

	stops = weekly_route.stops.select_related("bin")
	route_map_stops = [
		{
			"order": stop.order,
			"address": stop.bin.address,
			"latitude": stop.bin.latitude,
			"longitude": stop.bin.longitude,
		}
		for stop in stops
	]

	return render(
		request,
		"bins/crew_route.html",
		{
			"route": weekly_route,
			"stops": stops,
			"route_map_stops": route_map_stops,
			"week_end": week_end,
			"depot_lat": DEPOT_LAT,
			"depot_lon": DEPOT_LON,
		},
	)


@login_required
def logout_view(request):
	logout(request)
	return redirect("login")
