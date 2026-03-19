from datetime import date, timedelta

from django.core.management.base import BaseCommand, CommandError

from bins.models import RouteStop, WeeklyRoute
from bins.views import COLLECTION_THRESHOLD, DEPOT_LAT, DEPOT_LON, _knn_nearest_neighbor


class Command(BaseCommand):
    help = "Generate (or regenerate) the weekly KNN collection route."

    def add_arguments(self, parser):
        parser.add_argument(
            "--force",
            action="store_true",
            help="Delete any existing route for the week and recompute it.",
        )
        parser.add_argument(
            "--week",
            type=str,
            default=None,
            metavar="YYYY-MM-DD",
            help="Monday of the target week (defaults to the current week).",
        )

    def handle(self, *args, **options):
        if options["week"]:
            try:
                target_date = date.fromisoformat(options["week"])
            except ValueError:
                raise CommandError("--week must be in YYYY-MM-DD format.")
            week_start = target_date - timedelta(days=target_date.weekday())
        else:
            today = date.today()
            week_start = today - timedelta(days=today.weekday())

        self.stdout.write(f"Target week: {week_start} (Monday)")

        existing = WeeklyRoute.objects.filter(week_start=week_start).first()
        if existing:
            if options["force"]:
                existing.delete()
                self.stdout.write(self.style.WARNING("Deleted existing route – recomputing…"))
            else:
                self.stdout.write(
                    self.style.SUCCESS(
                        f"Route for w/c {week_start} already exists "
                        f"({existing.stops.count()} stops, {existing.total_distance_km} km). "
                        "Use --force to regenerate."
                    )
                )
                return

        from bins.models import Bin

        bins = list(Bin.objects.filter(is_active=True, fill_level__gte=COLLECTION_THRESHOLD))
        if not bins:
            bins = list(Bin.objects.filter(is_active=True))

        route = WeeklyRoute.objects.create(week_start=week_start)

        if not bins:
            self.stdout.write(self.style.WARNING("No active bins found – empty route created."))
            return

        ordered = _knn_nearest_neighbor(bins, DEPOT_LAT, DEPOT_LON)
        total_km = 0.0
        stops = []
        for idx, (bin_obj, dist) in enumerate(ordered, start=1):
            total_km += dist
            stops.append(
                RouteStop(
                    route=route,
                    bin=bin_obj,
                    order=idx,
                    distance_from_prev_km=round(dist, 3),
                )
            )

        RouteStop.objects.bulk_create(stops)
        route.total_distance_km = round(total_km, 3)
        route.save(update_fields=["total_distance_km"])

        self.stdout.write(
            self.style.SUCCESS(
                f"Route created: {len(stops)} stops, {route.total_distance_km} km total."
            )
        )
