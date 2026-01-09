from rest_framework import serializers
from django.contrib.auth.models import User, Group
from my_course.models import Course


class UserSerializer(serializers.ModelSerializer):
    groups = serializers.StringRelatedField(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'groups']


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    password2 = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2']
    
    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords must match."})
        return data
    
    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(**validated_data)
        # Add default "Student" group
        default_group = Group.objects.get(name='Student')
        user.groups.add(default_group)
        return user


class CourseSerializer(serializers.ModelSerializer):
    user_username = serializers.CharField(source='user.username', read_only=True)
    student_count = serializers.SerializerMethodField()
    is_enrolled = serializers.SerializerMethodField()
    
    class Meta:
        model = Course
        fields = [
            'id', 'course_title', 'category', 'school_name', 'description',
            'price', 'available_until', 'author', 'post_date', 'user',
            'user_username', 'student_count', 'is_enrolled'
        ]
        read_only_fields = ['id', 'post_date', 'user']
    
    def get_student_count(self, obj):
        return obj.students.count()
    
    def get_is_enrolled(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return request.user in obj.students.all()
        return False


class CourseDetailSerializer(CourseSerializer):
    students = UserSerializer(many=True, read_only=True)
    
    class Meta(CourseSerializer.Meta):
        fields = CourseSerializer.Meta.fields + ['students']
