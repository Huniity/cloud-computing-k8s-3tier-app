
"""
Admin table display in Django administration. Displayed, Editable and Sortable columns.
"""
from django.contrib import admin
from .models import *
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

class CourseAdmin(admin.ModelAdmin):
    list_display = ("id", "course_title", "category", "school_name", "description", "price", "available_until", "author", "user", "post_date")
    list_editable = ["available_until"]
    sortable_by = ("school_name", "author", "post_date", "category")

    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)
        logger.info(f"Course saved - {obj.course_title}{request.user}")

    def delete_model(self, request, obj):
        super().delete_model(request, obj)
        logger.warning(f"Course deleted - {obj.course_title}{request.user}")





admin.site.register(Course, CourseAdmin)