from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.authtoken import views as auth_views
from my_course.api_views import UserViewSet, CourseViewSet

"""
DRF Router for API endpoints.
"""

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'courses', CourseViewSet, basename='course')

urlpatterns = [
    path('api/', include(router.urls)),
    path('api-token-auth/', auth_views.obtain_auth_token, name='api-token-auth'),
]