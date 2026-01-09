from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User, Group
from django.shortcuts import get_object_or_404
from my_course.models import Course
from my_course.serializers import (
    UserSerializer, 
    UserCreateSerializer, 
    CourseSerializer,
    CourseDetailSerializer
)
import logging


logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


class IsMentorOrReadOnly(permissions.BasePermission):
    """Only mentors can create/update courses."""
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_authenticated and request.user.groups.filter(name='Mentor').exists()


class IsOwnerMentorOrAdmin(permissions.BasePermission):
    """Mentors can modify their own courses, admins can modify any."""
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Admins can do anything
        if request.user and request.user.is_superuser:
            return True
        
        # Mentors can only modify their own courses (compare by ID)
        if request.user and request.user.groups.filter(name='Mentor').exists():
            return obj.user_id == request.user.id
        
        return False


class UserViewSet(viewsets.ModelViewSet):
    """API endpoint for user management and authentication."""
    
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return UserCreateSerializer
        return UserSerializer
    
    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def signup(self, request):
        """Register a new user."""
        serializer = UserCreateSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # Add user to Student group by default
            student_group, _ = Group.objects.get_or_create(name='Student')
            user.groups.add(student_group)
            
            token, _ = Token.objects.get_or_create(user=user)
            logger.info(f"New user registered: {user.username}")
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def login(self, request):
        """Login user and return authentication token."""
        username = request.data.get('username')
        password = request.data.get('password')
        
        if not username or not password:
            return Response(
                {'error': 'Username and password required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user = get_object_or_404(User, username=username)
        if user.check_password(password):
            token, _ = Token.objects.get_or_create(user=user)
            logger.info(f"User logged in: {username}")
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key
            }, status=status.HTTP_200_OK)
        
        return Response(
            {'error': 'Invalid credentials'},
            status=status.HTTP_401_UNAUTHORIZED
        )
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def me(self, request):
        """Get current authenticated user."""
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def logout(self, request):
        """Logout user (delete token)."""
        request.user.auth_token.delete()
        logger.info(f"User logged out: {request.user.username}")
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)


class CourseViewSet(viewsets.ModelViewSet):
    """API endpoint for course management."""
    
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    
    def get_permissions(self):
        """Set permission classes based on action."""
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [permissions.IsAuthenticated(), IsOwnerMentorOrAdmin()]
        elif self.action in ['enroll', 'unenroll', 'my_enrollments', 'my_courses']:
            return [permissions.IsAuthenticated()]
        else:
            return [permissions.AllowAny()]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return CourseDetailSerializer
        return CourseSerializer
    
    def get_queryset(self):
        """Filter courses by category if provided."""
        queryset = Course.objects.all()
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category__iexact=category)
        return queryset
    
    def perform_create(self, serializer):
        """Set the course creator to current user (must be mentor)."""
        if self.request.user.groups.filter(name='Mentor').exists() or self.request.user.is_superuser:
            serializer.save(user=self.request.user)
            logger.info(f"Course created by {self.request.user.username}: {serializer.instance.course_title}")
        else:
            raise permissions.PermissionDenied("Only mentors can create courses")
    
    def perform_destroy(self, instance):
        """Only admins or mentor owner can delete courses."""
        if instance.user_id == self.request.user.id:
            logger.info(f"Course deleted by {self.request.user.username}: {instance.course_title}")
            instance.delete()
        elif self.request.user.is_superuser:
            logger.info(f"Course deleted by admin {self.request.user.username}: {instance.course_title}")
            instance.delete()
        else:
            raise permissions.PermissionDenied("You can only delete your own courses")
    
    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def enroll(self, request, pk=None):
        """Enroll current user to a course."""
        course = self.get_object()
        if request.user not in course.students.all():
            course.students.add(request.user)
            logger.info(f"{request.user.username} enrolled to {course.course_title}")
            return Response({'message': 'Enrolled successfully'}, status=status.HTTP_200_OK)
        return Response(
            {'message': 'Already enrolled'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def unenroll(self, request, pk=None):
        """Unenroll current user from a course."""
        course = self.get_object()
        if request.user in course.students.all():
            course.students.remove(request.user)
            logger.info(f"{request.user.username} unenrolled from {course.course_title}")
            return Response({'message': 'Unenrolled successfully'}, status=status.HTTP_200_OK)
        return Response(
            {'message': 'Not enrolled'},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_enrollments(self, request):
        """Get courses user is enrolled in."""
        enrolled_courses = request.user.enrolled_courses.all()
        serializer = CourseSerializer(enrolled_courses, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_courses(self, request):
        """Get courses created by current user (mentor only)."""
        if request.user.groups.filter(name='Mentor').exists():
            mentor_courses = Course.objects.filter(user=request.user)
            serializer = CourseDetailSerializer(mentor_courses, many=True, context={'request': request})
            return Response(serializer.data)
        return Response(
            {'error': 'Only mentors have courses'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    @action(detail=False, methods=['get'])
    def categories(self, request):
        """Get all available course categories."""
        categories = Course.objects.values_list('category', flat=True).distinct()
        return Response({'categories': list(categories)})
