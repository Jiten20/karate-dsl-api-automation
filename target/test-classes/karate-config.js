function() {
  var config = { author: 'Tester', baseURL: 'https://automationintesting.online' };
  var env = karate.env; // get environment from system property
  karate.log('Running tests in environment:', env);
  if (env == 'dev') {
    config.baseURL = 'https://automationintesting.online';
    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 5000);
  } else if (env == 'prod') {
    config.baseURL = 'https://prod-api.example.com';
    karate.configure('ssl', true);
  }
  return config;
}