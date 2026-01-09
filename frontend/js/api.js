// API base URL
const API_BASE_URL = '/api';

// Generic API call function
async function apiCall(endpoint, method = 'GET', data = null) {
    const options = {
        method: method,
        headers: {
            'Content-Type': 'application/json',
        }
    };
    
    const token = localStorage.getItem('token');
    if (token) {
        options.headers['Authorization'] = `Token ${token}`;
    }
    
    if (data) {
        options.body = JSON.stringify(data);
    }
    
    const response = await fetch(`${API_BASE_URL}${endpoint}`, options);
    
    if (!response.ok) {
        if (response.status === 401) {
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location.href = '/login.html';
        }
        throw new Error(`API Error: ${response.status}`);
    }
    
    // Handle empty responses
    const text = await response.text();
    if (!text) {
        return null;
    }
    
    return JSON.parse(text);
}

// Get all courses
async function getCourses() {
    return apiCall('/courses/');
}

// Get single course
async function getCourse(id) {
    return apiCall(`/courses/${id}/`);
}

// Create course
async function createCourse(data) {
    return apiCall('/courses/', 'POST', data);
}

// Update course
async function updateCourse(id, data) {
    return apiCall(`/courses/${id}/`, 'PUT', data);
}

// Delete course
async function deleteCourse(id) {
    return apiCall(`/courses/${id}/`, 'DELETE');
}

// Enroll in course
async function enrollCourse(courseId) {
    return apiCall(`/courses/${courseId}/enroll/`, 'POST');
}

// Unenroll from course
async function unenrollCourse(courseId) {
    return apiCall(`/courses/${courseId}/unenroll/`, 'POST');
}

// Get my enrollments
async function getMyEnrollments() {
    return apiCall('/courses/my_enrollments/');
}

// Get my courses (mentor)
async function getMyCourses() {
    return apiCall('/courses/my_courses/');
}

// Get categories
async function getCategories() {
    return apiCall('/courses/categories/');
}

// Login
async function loginUser(username, password) {
    return apiCall('/users/login/', 'POST', { username, password });
}

// Signup
async function signupUser(username, email, password, password2) {
    return apiCall('/users/signup/', 'POST', { username, email, password, password2 });
}

// Logout
async function logoutUser() {
    return apiCall('/users/logout/', 'POST');
}

// Get current user
async function getCurrentUser() {
    return apiCall('/users/me/');
}
