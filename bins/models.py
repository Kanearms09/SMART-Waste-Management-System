from django.db import models


class Bin(models.Model):
    address = models.CharField(max_length=255)
    latitude = models.FloatField()
    longitude = models.FloatField()
    fill_level = models.FloatField(default=0.0, help_text="Fill level as a percentage (0–100)")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Bin @ {self.address} ({self.fill_level:.0f}% full)"


class WeeklyRoute(models.Model):
    week_start = models.DateField(unique=True, help_text="Monday of the route week")
    total_distance_km = models.FloatField(default=0.0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Route w/c {self.week_start}"


class RouteStop(models.Model):
    route = models.ForeignKey(WeeklyRoute, on_delete=models.CASCADE, related_name="stops")
    bin = models.ForeignKey(Bin, on_delete=models.CASCADE, related_name="route_stops")
    order = models.PositiveIntegerField()
    distance_from_prev_km = models.FloatField(default=0.0)

    class Meta:
        ordering = ["order"]

    def __str__(self):
        return f"Stop {self.order} – {self.bin.address}"
