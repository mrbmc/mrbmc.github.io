// UPDATE THIS with your API Gateway endpoint
const API_ENDPOINT = 'https://9npc66dbde.execute-api.us-east-1.amazonaws.com/production';

const emailStep = document.getElementById('emailStep');
const otpStep = document.getElementById('otpStep');
const linkStep = document.getElementById('linkStep');
const emailForm = document.getElementById('emailForm');
const otpForm = document.getElementById('otpForm');
const emailInput = document.getElementById('email');
const otpInput = document.getElementById('otp');
const userEmailDisplay = document.getElementById('userEmail');
const backLink = document.getElementById('backLink');

let userEmail = '';

// Check for magic link parameters on page load
async function checkMagicLink() {
  const params = new URLSearchParams(window.location.search);
  const token = params.get('token');
  const email = params.get('email');

  if (token && email) {
    // Hide both forms and show verifying message
    emailStep.style.display = 'none';
    otpStep.style.display = 'none';
    linkStep.style.display = 'block';

    try {
      const response = await fetch(`${API_ENDPOINT}/verify-magic?token=${encodeURIComponent(token)}&email=${encodeURIComponent(email)}`, {
        method: 'GET',
        // credentials: 'include'
      });

      const data = await response.json();

      if (response.ok) {
        // Store session token
        localStorage.setItem('portfolio_session', data.sessionId);
        
        // Manually set cookie
        const expiryDate = new Date(data.expiresAt * 1000).toUTCString();
        document.cookie = `portfolio_session=${data.sessionId}; domain=.brianmcconnell.me; path=/; expires=${expiryDate}; secure; samesite=lax`;
        
        document.getElementById('magicMessage').textContent = '✓ Access verified! Redirecting...';
        setTimeout(() => window.location.href = '/portfolio/', 1000);
      } else {
        throw new Error(data.error || 'Verification failed');
      }
    } catch (error) {
      console.error('Magic link error:', error);
      document.querySelector('#linkStep').innerHTML = `
        <h1>Verification Failed</h1>
        <p class="message error">This link is invalid or has expired.</p>
        <button onclick="window.location.reload()">Try Again</button>
      `;
    }
  }
}

// Run magic link check on load
checkMagicLink();

// Request OTP
emailForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const btn = document.getElementById('emailBtn');
  const messageDiv = document.getElementById('emailMessage');
  
  btn.disabled = true;
  btn.textContent = 'Sending...';
  messageDiv.innerHTML = '';

  try {
    const response = await fetch(`${API_ENDPOINT}/request-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: emailInput.value })
    });

    const data = await response.json();

    if (response.ok) {
      userEmail = emailInput.value;
      userEmailDisplay.textContent = userEmail;
      emailStep.style.display = 'none';
      otpStep.style.display = 'block';
      linkStep.style.display = 'none';
      otpInput.focus();
    } else {
      messageDiv.innerHTML = `<div class="message error">${data.error || 'Failed to send code'}</div>`;
    }
  } catch (error) {
    messageDiv.innerHTML = '<div class="message error">Network error. Please try again.</div>';
  } finally {
    btn.disabled = false;
    btn.textContent = 'Send Access Code';
  }
});

// Verify OTP
otpForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const btn = document.getElementById('otpBtn');
  const messageDiv = document.getElementById('otpMessage');
  
  btn.disabled = true;
  btn.textContent = 'Verifying...';
  messageDiv.innerHTML = '';

  try {
    const response = await fetch(`${API_ENDPOINT}/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      // credentials: 'include',
      body: JSON.stringify({ 
        email: userEmail, 
        otp: otpInput.value 
      })
    });

    const data = await response.json();

    if (response.ok) {
      // Store session token in localStorage as backup
      localStorage.setItem('portfolio_session', data.sessionId);
      
      // Manually set cookie using JavaScript
      const expiryDate = new Date(data.expiresAt * 1000).toUTCString();
      document.cookie = `portfolio_session=${data.sessionId}; domain=.brianmcconnell.me; path=/; expires=${expiryDate}; secure; samesite=lax`;

      messageDiv.innerHTML = '<div class="message success">✓ Access granted! Redirecting...</div>';
      
      // Redirect to original page or home
      const params = new URLSearchParams(window.location.search);
      const redirect = decodeURIComponent(params.get('redirect') || '/');
      setTimeout(() => window.location.href = redirect, 1000);
    } else {
      messageDiv.innerHTML = `<div class="message error">${data.error || 'Invalid code'}</div>`;
      otpInput.value = '';
      otpInput.focus();
    }
  } catch (error) {
    messageDiv.innerHTML = '<div class="message error">Network error. Please try again.</div>';
  } finally {
    btn.disabled = false;
    btn.textContent = 'Verify & Access';
  }
});

// Back to email step
backLink.addEventListener('click', (e) => {
  e.preventDefault();
  otpStep.style.display = 'none';
  emailStep.style.display = 'block';
  linkStep.style.display = 'none';
  otpInput.value = '';
  document.getElementById('otpMessage').innerHTML = '';
});

// Auto-focus email on load
emailInput.focus();
