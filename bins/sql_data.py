from __future__ import annotations

from collections import defaultdict
from datetime import date, datetime, timedelta
import calendar
from math import asin, cos, radians, sin, sqrt

from django.db import connection


def _sql_rows(query, params=()):
    with connection.cursor() as cursor:
        cursor.execute(query, params)
        columns = [column[0] for column in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def _parse_sql_date(value):
    if value in (None, ""):
        return None
    if isinstance(value, date):
        return value

    text = str(value).strip()
    for fmt in ("%m/%d/%Y", "%Y-%m-%d"):
        try:
            return datetime.strptime(text, fmt).date()
        except ValueError:
            continue
    return None


def _to_float(value, default=0.0):
    if value in (None, ""):
        return default
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _haversine_km(lat1, lon1, lat2, lon2):
    radius_km = 6371.0
    d_lat = radians(lat2 - lat1)
    d_lon = radians(lon2 - lon1)
    a = (
        sin(d_lat / 2) ** 2
        + cos(radians(lat1))
        * cos(radians(lat2))
        * sin(d_lon / 2) ** 2
    )
    return radius_km * 2 * asin(sqrt(a))


def _week_start(for_date=None):
    d = for_date or date.today()
    return d - timedelta(days=d.weekday())


def _count_mondays_in_month(year: int, month: int, upto: date | None = None) -> int:
    """Count Mondays in the given month up to `upto` (inclusive). If `upto` is None, use today.

    This counts each Monday that has occurred in the month (useful for weekly collections).
    """
    upto = upto or date.today()
    first_day = date(year, month, 1)
    last_day = calendar.monthrange(year, month)[1]
    end = date(year, month, last_day)
    # We only count up to `upto`.
    final = min(end, upto)
    count = 0
    d = first_day
    while d <= final:
        if d.weekday() == 0:  # Monday
            count += 1
        d += timedelta(days=1)
    return count


def _latest_report_by_bin():
    latest = {}
    for report in _sql_rows(
        "SELECT report_id, bin_id, fill_level, report_time, status FROM report ORDER BY report_id"
    ):
        latest[report["bin_id"]] = report
    return latest


def _report_rows():
    return _sql_rows(
        """
        SELECT
            r.report_id,
            r.bin_id,
            r.fill_level,
            r.report_time,
            r.status,
            b.status AS bin_status,
            bt.type_name,
            bt.colour_code,
            ha.street,
            ha.city,
            ha.postcode
        FROM report r
        LEFT JOIN bin b ON b.bin_id = r.bin_id
        LEFT JOIN bin_type bt ON bt.bin_type_id = b.bin_type_id
        LEFT JOIN home_address ha ON ha.address_id = b.address_id
        ORDER BY r.report_id DESC
        """
    )


def _route_rows():
    return _sql_rows(
        """
        SELECT
            r.route_id,
            r.zone_id,
            r.user_id,
            r.vehicle_id,
            r.assigned_driver_id,
            r.route_date,
            r.status,
            z.zone_name,
            z.region AS zone_region,
            su.forename || ' ' || su.surname AS assigned_user_name,
            v.license_plate,
            v.status AS vehicle_status
        FROM route r
        LEFT JOIN zone z ON z.zone_id = r.zone_id
        LEFT JOIN smart_user su ON su.user_id = r.user_id
        LEFT JOIN vehicle v ON v.vehicle_id = r.vehicle_id
        ORDER BY r.route_id
        """
    )


def _select_relevant_route(route_rows):
    if not route_rows:
        return None

    today = date.today()
    with_dates = []
    for row in route_rows:
        parsed = _parse_sql_date(row.get("route_date"))
        if parsed is not None:
            row = dict(row)
            row["parsed_route_date"] = parsed
            with_dates.append(row)

    if not with_dates:
        return route_rows[-1]

    candidates = [row for row in with_dates if row["parsed_route_date"] <= today]
    if candidates:
        return max(candidates, key=lambda row: (row["parsed_route_date"], row["route_id"]))

    return max(with_dates, key=lambda row: (row["parsed_route_date"], row["route_id"]))


def _route_stop_rows(route_id):
    return _sql_rows(
        f"""
        SELECT
            rs.route_stop_id,
            rs.route_id,
            rs.bin_id,
            rs.stop_order,
            rs.collection_status,
            rs.collection_date,
            rs.collection_time,
            b.address_id,
            b.bin_type_id,
            b.capacity_litre,
            b.status AS bin_status,
            bt.type_name,
            bt.description AS bin_type_description,
            bt.colour_code,
            ha.street,
            ha.city,
            ha.postcode,
            ha.latitude,
            ha.longitude
        FROM route_stop rs
        JOIN bin b ON b.bin_id = rs.bin_id
        JOIN bin_type bt ON bt.bin_type_id = b.bin_type_id
        JOIN home_address ha ON ha.address_id = b.address_id
        WHERE rs.route_id = {route_id}
        ORDER BY COALESCE(rs.stop_order, rs.route_stop_id)
        """,
    )


def _format_address(row):
    address = row.get("street") or "Unknown address"
    city = row.get("city")
    postcode = row.get("postcode")
    parts = [address]
    if city:
        parts.append(city)
    if postcode:
        parts.append(postcode)
    return ", ".join(parts)


def _priority_label(fill_level):
    if fill_level >= 80:
        return "High"
    if fill_level >= 60:
        return "Medium"
    return "Low"


def get_sql_route_snapshot():
    route_rows = _route_rows()
    route_row = _select_relevant_route(route_rows)
    if not route_row:
        return None

    week_start = _week_start()
    route_date = _parse_sql_date(route_row.get("route_date")) or date.today()
    stop_rows = _route_stop_rows(route_row["route_id"])
    latest_reports = _latest_report_by_bin()

    stops = []
    route_distance_km = 0.0
    previous_point = None

    for index, stop_row in enumerate(stop_rows, start=1):
        report = latest_reports.get(stop_row["bin_id"], {})
        latitude = _to_float(stop_row.get("latitude"))
        longitude = _to_float(stop_row.get("longitude"))
        current_point = (latitude, longitude)
        if previous_point is not None:
            route_distance_km += _haversine_km(previous_point[0], previous_point[1], latitude, longitude)
        previous_point = current_point

        fill_level = _to_float(report.get("fill_level"), 0.0)
        collection_status = stop_row.get("collection_status") or "Pending"
        stops.append(
            {
                "order": stop_row.get("stop_order") or index,
                "address": _format_address(stop_row),
                "latitude": latitude,
                "longitude": longitude,
                "collection_status": collection_status,
                "collection_date": _parse_sql_date(stop_row.get("collection_date")),
                "collection_time": stop_row.get("collection_time"),
                "fill_level": round(fill_level),
                "priority_label": _priority_label(fill_level),
                "bin_type": stop_row.get("type_name"),
                "bin_status": stop_row.get("bin_status"),
                "colour_code": stop_row.get("colour_code"),
            }
        )

    completed_count = sum(1 for stop in stops if stop["collection_status"] == "Completed")
    pending_count = len(stops) - completed_count

    route = {
        "route_id": route_row["route_id"],
        "week_start": week_start,
        "route_date": route_date,
        "status": route_row.get("status"),
        "zone_name": route_row.get("zone_name") or f"Zone {route_row.get('zone_id')}",
        "zone_region": route_row.get("zone_region"),
        "assigned_user_name": route_row.get("assigned_user_name") or f"User {route_row.get('user_id')}",
        "vehicle_plate": route_row.get("license_plate"),
        "vehicle_status": route_row.get("vehicle_status"),
        "stop_count": len(stops),
        "completed_count": completed_count,
        "pending_count": pending_count,
        "distance_km": round(route_distance_km, 1),
    }

    route_map_stops = [
        {
            "order": stop["order"],
            "name": stop["address"],
            "lat": stop["latitude"],
            "lon": stop["longitude"],
            "fill_level": stop["fill_level"],
            "status": stop["collection_status"],
        }
        for stop in stops
    ]

    return {
        "route": route,
        "stops": stops,
        "route_map_stops": route_map_stops,
        "week_end": week_start + timedelta(days=6),
    }


def get_sql_resident_context():
    routes = _route_rows()
    snapshot = get_sql_route_snapshot()
    latest_completed = next(
        (
            row
            for row in reversed(routes)
            if row.get("status") == "Completed" and _parse_sql_date(row.get("route_date"))
        ),
        None,
    )

    latest_report_values = list(_latest_report_by_bin().values())
    average_fill = 0
    if latest_report_values:
        average_fill = round(
            sum(_to_float(report.get("fill_level")) for report in latest_report_values)
            / len(latest_report_values)
        )

    # Compute consistent Monday boundaries: current week's Monday, previous and next Monday
    current_week_monday = _week_start()
    next_monday = current_week_monday + timedelta(days=7)
    prev_monday = current_week_monday - timedelta(days=7)

    if snapshot:
        # Keep route_date for internal route-based calculations, but expose next/previous Monday explicitly
        route_date = snapshot["route"].get("week_start") or snapshot["route"]["route_date"]
        # Collections occur every Monday — count Mondays that have occurred in the current month
        today = date.today()
        collections_this_month = _count_mondays_in_month(today.year, today.month, upto=today)
        coverage_addresses = [stop["address"] for stop in snapshot["stops"][:3]]
        pending_count = snapshot["route"]["pending_count"]
        high_capacity_count = sum(1 for stop in snapshot["stops"] if stop["fill_level"] >= 80)
    else:
        route_date = date.today()
        # Even without a snapshot, show how many Mondays have occurred so far this month
        today = date.today()
        collections_this_month = _count_mondays_in_month(today.year, today.month, upto=today)
        coverage_addresses = []
        pending_count = 0
        high_capacity_count = 0

    return {
        "resident_bin_fill_level": average_fill,
        "resident_next_collection": next_monday,
        "resident_last_collection": current_week_monday,
        "resident_collections_this_month": collections_this_month,
        "resident_zone_name": snapshot["route"].get("zone_name") if snapshot else "Local service zone",
        "resident_route_coverage_addresses": coverage_addresses,
        "resident_alert_summary": f"{pending_count} stops pending, {high_capacity_count} high-fill bins on the current route",
    }


def get_sql_collection_context():
    snapshot = get_sql_route_snapshot()
    if not snapshot:
        return {
            "crew_assigned_today_count": 0,
            "crew_completed_count": 0,
            "crew_high_capacity_count": 0,
            "crew_pending_count": 0,
            "crew_route_efficiency": 0,
            "crew_time_remaining": "0m",
            "crew_priority_stops": [],
        }

    stops = snapshot["stops"]
    assigned_count = len(stops)
    completed_count = sum(1 for stop in stops if stop["collection_status"] == "Completed")
    pending_count = assigned_count - completed_count
    high_capacity_count = sum(1 for stop in stops if stop["fill_level"] >= 80)
    route_efficiency = round((completed_count / assigned_count) * 100) if assigned_count else 0
    time_remaining = f"{pending_count * 18}m" if pending_count else "0m"

    priority_stops = sorted(
        stops,
        key=lambda stop: (-stop["fill_level"], stop["order"]),
    )[:3]

    return {
        "crew_assigned_today_count": assigned_count,
        "crew_completed_count": completed_count,
        "crew_high_capacity_count": high_capacity_count,
        "crew_pending_count": pending_count,
        "crew_route_efficiency": route_efficiency,
        "crew_time_remaining": time_remaining,
        "crew_priority_stops": priority_stops,
        "crew_route_date": snapshot["route"]["route_date"],
        "crew_route_status": snapshot["route"].get("status"),
        "crew_next_collection": _week_start() + timedelta(days=7),
        "crew_prev_collection": _week_start(),
    }


def get_sql_admin_context():
    routes = _route_rows()
    reports = _report_rows()
    vehicles = _sql_rows("SELECT vehicle_id, license_plate, status FROM vehicle")
    zones = _sql_rows("SELECT zone_id, zone_name, region FROM zone")
    smart_users = _sql_rows("SELECT user_id, forename, surname, role_id FROM smart_user")
    notifications = _sql_rows("SELECT notification_id, user_id, type, read_status FROM notification")

    latest_reports = _latest_report_by_bin()

    def _placeholder_route_date(status, route_id):
        today = date.today()
        seed = route_id or 0
        if status == "Completed":
            # Completed routes should not be in the future.
            return today - timedelta(days=(seed % 28) + 1)
        if status == "Scheduled":
            # Scheduled routes should be upcoming.
            return today + timedelta(days=(seed % 14) + 1)
        if status == "In Progress":
            # In-progress routes are typically today or very recent.
            return today - timedelta(days=seed % 2)
        return today - timedelta(days=seed % 7)

    recent_routes = []
    for row in sorted(
        routes,
        key=lambda item: (_parse_sql_date(item.get("route_date")) or date.min, item.get("route_id", 0)),
        reverse=True,
    ):
        route_date = _parse_sql_date(row.get("route_date"))
        if route_date is None:
            route_date = _placeholder_route_date(row.get("status"), row.get("route_id"))
        recent_routes.append(
            {
                "route_id": row.get("route_id"),
                "route_date": route_date,
                "status": row.get("status"),
                "zone_name": row.get("zone_name"),
                "zone_region": row.get("zone_region"),
                "assigned_user_name": row.get("assigned_user_name"),
                "vehicle_plate": row.get("license_plate"),
            }
        )

    reports_list = []
    for row in reports:
        reports_list.append(
            {
                "report_id": row.get("report_id"),
                "bin_id": row.get("bin_id"),
                "fill_level": _to_float(row.get("fill_level")),
                "report_time": row.get("report_time"),
                "status": row.get("status"),
                "bin_type": row.get("type_name"),
                "bin_status": row.get("bin_status"),
                "address": ", ".join(part for part in [row.get("street"), row.get("city"), row.get("postcode")] if part),
                "colour_code": row.get("colour_code"),
            }
        )

    priority_reports = reports_list[:8]

    fleet = []
    for row in vehicles:
        fleet.append(
            {
                "vehicle_id": row.get("vehicle_id"),
                "license_plate": row.get("license_plate"),
                "status": row.get("status"),
            }
        )

    zones_list = []
    for z in zones:
        zones_list.append(
            {
                "zone_id": z.get("zone_id"),
                "zone_name": z.get("zone_name"),
                "region": z.get("region"),
            }
        )

    return {
        "sql_total_routes": len(routes),
        "sql_scheduled_routes": sum(1 for row in routes if row.get("status") == "Scheduled"),
        "sql_in_progress_routes": sum(1 for row in routes if row.get("status") == "In Progress"),
        "sql_completed_routes": sum(1 for row in routes if row.get("status") == "Completed"),
        "sql_total_reports": len(reports),
        "sql_pending_reports": sum(1 for row in reports if row.get("status") in {"Pending", "Escalated"}),
        "sql_resolved_reports": sum(1 for row in reports if row.get("status") == "Resolved"),
        "sql_high_capacity_reports": sum(1 for report in latest_reports.values() if _to_float(report.get("fill_level")) >= 80),
        "sql_total_vehicles": len(vehicles),
        "sql_active_vehicles": sum(1 for row in vehicles if row.get("status") == "Active"),
        "sql_total_zones": len(zones),
        "sql_total_users": len(smart_users),
        "sql_unread_notifications": sum(1 for row in notifications if row.get("read_status") == "Unread"),
        "sql_recent_routes": recent_routes,
        "sql_reports": reports_list,
        "sql_priority_reports": priority_reports,
        "sql_fleet": fleet,
        "sql_zones": zones_list,
    }