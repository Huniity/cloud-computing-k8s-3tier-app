from django.apps import AppConfig
import logging

"""
My App declaration.
"""

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

class MyCourseConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "my_course"

    def ready(self):
        logger.info("APP started")