from django import forms
from my_course.models import Course
import logging 
"""
HTML Integrated form with excluded fields. Hidden from mentor to register and id and student hidden from Django Table.
"""
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


class CourseForm(forms.ModelForm):
    user = forms.IntegerField(widget=forms.HiddenInput, required = False)
    enroll_now = forms.BooleanField(widget=forms.HiddenInput, required = False)
    class Meta:
        model = Course
        exclude = ["id", "students"]

        def save(self, commit=True):
            try:
                instance = super().save(commit=commit)
                logger.info(f"Course form saved - ID: {instance.id}-{instance.course_title}")
                return instance
            except Exception as e:
                logger.error(f"{str(e)}")
                raise