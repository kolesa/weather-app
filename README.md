# Weather App

URL: http://weather-app-alb-1716341525.us-west-2.elb.amazonaws.com/

## Scope

- Use Ruby On Rails.

- Accept a zip code as input.

- Retrieve forecast data for the given zip. This should include, at minimum, the current, high and low temperatures.

- Display the requested forecast details to the user.

- Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator in result is pulled from cache.

## Setup

#### Install dependencies

```bash
$ bundle install
```

#### Create .env file

```bash 
cp .env.example .env
```

#### Activate cache

```bash
$ rails dev:cache
```

#### Start server

```bash
$ rails s
```


## Details

- The app uses the [OpenWeatherMap API](https://openweathermap.org/api) to retrieve the forecast data.
- The app uses Bootstrap for styling.
- The app uses Rspec for testing.

### Caching

- For caching, the app uses the Rails built-in caching mechanism.
- The cache is activated by running the command `rails dev:cache`.
- For real applications, I would use a more robust caching mechanism like Redis or Memcached.

### Testing

Implemented initial tests.

Command to run tests:
```bash
rspec
```

## CI 
CI implemented with Github Actions. Tests are run on push to github repo.


## Deployment

- Implemented initial Terraform to create  AWS ECS and infrastructure around. 
- Implemented initial Github Actions to deploy the app to AWS ECS.

## Improvements

- Use a more robust caching mechanism like Redis or Memcached.
- Add functional tests, such as for flash messages, error messages, the search form, the API reachability, etc.
- Add internationalitzation/localization for messages and temperature units.
- Use some JS framework to make the app more interactive.
- Add more filters to the search form, such as temperature units, language, etc.
