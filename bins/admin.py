from django.contrib import admin

from .models import Bin, RouteStop, WeeklyRoute


class RouteStopInline(admin.TabularInline):
    model = RouteStop
    extra = 0
    readonly_fields = ("order", "distance_from_prev_km")


@admin.register(Bin)
class BinAdmin(admin.ModelAdmin):
    list_display = ("address", "fill_level", "latitude", "longitude", "is_active", "created_at")
    list_filter = ("is_active",)
    search_fields = ("address",)


@admin.register(WeeklyRoute)
class WeeklyRouteAdmin(admin.ModelAdmin):
    list_display = ("week_start", "total_distance_km", "created_at")
    inlines = [RouteStopInline]


@admin.register(RouteStop)
class RouteStopAdmin(admin.ModelAdmin):
    list_display = ("route", "order", "bin", "distance_from_prev_km")
    list_filter = ("route",)
