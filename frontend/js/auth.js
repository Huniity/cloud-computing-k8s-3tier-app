// Check authentication status and update UI
function checkAuthStatus() {
    const token = localStorage.getItem('token');
    const user = JSON.parse(localStorage.getItem('user') || 'null');
    
    const loginLink = document.getElementById('loginLink');
    const signupLink = document.getElementById('signupLink');
    const userMenu = document.getElementById('userMenu');
    const mentorMenu = document.getElementById('mentorMenu');
    const logoutMenu = document.getElementById('logoutMenu');
    
    if (token && user) {
        // User is logged in
        if (loginLink) loginLink.style.display = 'none';
        if (signupLink) signupLink.style.display = 'none';
        if (userMenu) userMenu.style.display = 'block';
        if (logoutMenu) logoutMenu.style.display = 'block';
        
        // Check if user is mentor
        if (user.groups && user.groups.includes('Mentor') && mentorMenu) {
            mentorMenu.style.display = 'block';
        }
        
        // Update user profile link
        if (document.getElementById('userProfile')) {
            document.getElementById('userProfile').textContent = `${user.username}`;
        }
    } else {
        // User is not logged in
        if (loginLink) loginLink.style.display = 'block';
        if (signupLink) signupLink.style.display = 'block';
        if (userMenu) userMenu.style.display = 'none';
        if (mentorMenu) mentorMenu.style.display = 'none';
        if (logoutMenu) logoutMenu.style.display = 'none';
    }
}

// Logout function
async function logout() {
    try {
        await logoutUser();
    } catch (error) {
        console.log('Logout API call failed, clearing local storage anyway');
    }
    
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/';
}

// Redirect to login if not authenticated
function requireAuth() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = '/login.html';
    }
}
