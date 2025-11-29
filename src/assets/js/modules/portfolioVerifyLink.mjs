const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, PutCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');
const crypto = require('crypto');

const ddbClient = new DynamoDBClient({});
const ddb = DynamoDBDocumentClient.from(ddbClient);
const ses = new SESClient({});

// CONFIGURATION - Update these values
const YOUR_EMAIL = 'brian@kageki.com';
const FROM_EMAIL = 'b@brianmcconnell.me';
const SESSION_EXPIRY_HOURS = 24;
const COOKIE_DOMAIN = 'brianmcconnell.me';

// determine allowed origin
const getAllowedOrigin = (event) => {
  const origin = event.headers?.origin || event.headers?.Origin;
  const allowedOrigins = [
    'https://www.brianmcconnell.me',
    'https://dev.brianmcconnell.me'
  ];
  return allowedOrigins.includes(origin) ? origin : allowedOrigins[0];
};

exports.handler = async (event) => {
  try {
    // Get token and email from query parameters
    const token = event.queryStringParameters?.token;
    const email = event.queryStringParameters?.email?.toLowerCase().trim();

    if (!token || !email) {
      return {
        statusCode: 302,
        headers: {
          'Location': '/login.html?error=invalid_link'
        },
        body: ''
      };
    }

    // Get OTP record from DynamoDB
    const otpResult = await ddb.send(new GetCommand({
      TableName: 'portfolio-otp-codes',
      Key: { email }
    }));

    if (!otpResult.Item || otpResult.Item.magicToken !== token) {
      return {
        statusCode: 302,
        headers: {
          'Location': '/login.html?error=invalid_token'
        },
        body: ''
      };
    }

    // Check expiration
    const now = Math.floor(Date.now() / 1000);
    if (otpResult.Item.expiresAt < now) {
      await ddb.send(new DeleteCommand({
        TableName: 'portfolio-otp-codes',
        Key: { email }
      }));
      return {
        statusCode: 302,
        headers: {
          'Location': '/login.html?error=expired'
        },
        body: ''
      };
    }

    // Generate session token
    const sessionId = crypto.randomBytes(32).toString('hex');
    const expiresAt = Math.floor(Date.now() / 1000) + (SESSION_EXPIRY_HOURS * 3600);

    // Store session
    await ddb.send(new PutCommand({
      TableName: 'portfolio-sessions',
      Item: {
        sessionId,
        email,
        expiresAt,
        createdAt: Date.now(),
        ip: event.requestContext?.identity?.sourceIp || 'unknown'
      }
    }));

    // Log access permanently
    await ddb.send(new PutCommand({
      TableName: 'portfolio-access-log',
      Item: {
        id: crypto.randomUUID(),
        email,
        timestamp: Date.now(),
        ip: event.requestContext?.identity?.sourceIp || 'unknown',
        userAgent: event.headers?.['User-Agent'] || 'unknown',
        method: 'magic_link'
      }
    }));

    // Delete used OTP/magic token
    await ddb.send(new DeleteCommand({
      TableName: 'portfolio-otp-codes',
      Key: { email }
    }));

    // Send notification email
    try {
      await ses.send(new SendEmailCommand({
        Source: FROM_EMAIL,
        Destination: { ToAddresses: [YOUR_EMAIL] },
        Message: {
          Subject: { Data: '🔔 New Portfolio Login (Magic Link)' },
          Body: {
            Text: { 
              Data: `New login to your portfolio:\n\nEmail: ${email}\nMethod: Magic Link\nTime: ${new Date().toLocaleString()}\nIP: ${event.requestContext?.identity?.sourceIp || 'unknown'}`
            },
            Html: { 
              Data: `
                <h2>🔔 New Portfolio Login</h2>
                <p><strong>Email:</strong> ${email}</p>
                <p><strong>Method:</strong> Magic Link</p>
                <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
                <p><strong>IP:</strong> ${event.requestContext?.identity?.sourceIp || 'unknown'}</p>
              `
            }
          }
        }
      }));
    } catch (emailError) {
      console.error('Failed to send notification email:', emailError);
    }

    // Create secure cookie
    const expiryDate = new Date(expiresAt * 1000).toUTCString();
    const cookieValue = `portfolio_session=${sessionId}; Domain=${COOKIE_DOMAIN}; Path=/; Expires=${expiryDate}; HttpOnly; Secure; SameSite=Lax`;

    console.log(`Magic link session created for ${email}`);

    // Redirect to portfolio with cookie set
    return {
      statusCode: 302,
      headers: {
        'Location': '/portfolio/',
        'Set-Cookie': cookieValue
      },
      body: ''
    };

  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 302,
      headers: {
        'Location': '/login.html?error=server_error'
      },
      body: ''
    };
  }
};