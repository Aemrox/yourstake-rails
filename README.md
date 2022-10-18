# README
### Author Adam May

Below is my submission to YourStake for the coding problem.
My work was split over a few days as time allowed.

In the spirit of full transparency, I did underestimate my time a bit, and writing the readme took me to a bit over the 3 hour mark.

## Dependencies
After reading the prompt, I decided to use Rails as it's very quick
to setup and something I have experience in.  I used a scaffold to set up a quick app over a SQL DB. So the big dependencies for this are Ruby, Bundler, Postgres OR Docker. Everything else is handled by bundler.

## Setup

I have given two options to set this up - one for if you have postgres, ruby, and bundler ready to go as an environment. The other if you'd prefer not to set all that up and just use Docker.

### Docker
The docker setup is certianly easier. To get started, checkout the correct branch:
`git checkout docker-attempt-2`

To get started run:
`docker compose up`

This will build the app and all it's dependencies using ruby and postgres images from Docker. It will take 2-5 minutes depending on your computer, but obviates the need for any other setup.

Once build process has run and the app is running - open another terminal window and run the following commands one at a time:

```
docker-compose run web rake db:create

docker-compose run web rake db:migrate

docker-compose run web rake db_seed:read_company_exclusion_csv
```

These commands will create the database, run the migrations, and read the given CSV into the database. The last rake task was written by me, and can be found in `lib/tasks/seed.rake`. It's a fairly straightforward process to read through a CSV and create db records.

From there, the site should be available on `https://http://localhost:3000/` as the app should already be running from docker.

The biggest downside to docker is it is a bit slower in rending larger pieces of HTML, so when the full table is visible, the app will respond a bit slower than it would if it were running natively.

### Without Docker

I won't include a process for how to install Ruby, Postgres, or Bundle as it differs too greatly between OS - and is very difficult on Windows. That said, if those services happen to be installed on your machine I can walkthrough a setup process.

Make sure you are using Ruby 3.1.2 then run: `bundle install`. This should take care of most of the dependencies.

Before setting up the DB, the following env variables are set up to be used with the docker configurations from the yaml file:

```
 ENV["PGS_HOST"] { "db" }
 ENV["PGS_USER"] { "postgres" }
 ENV["PGS_PASS"] { "password" }
```

You'll want to swap out these values with the values for your own postgres setup here in the file `.env.sample` and then run `source .env.sample` in your terminal before running the below.

Then, to set up the db run:

```
bin/rake db:setup

bin/rake db:migrate

bin/rake db_seed:read_company_exclusion_csv
```

This will setup the db in a similar way to docker.

Finally, run `rails s` which will start the server and allow you to access the app from `https://http://localhost:3000/`

## Design Choices

As I mentioned, I chose rails mostly for ease of setup - however, another reason is the evolution of the rails front-end platform. Rails 7, along with Turbo, Stimulus and Hotwire have made for very easy and rapid front-end JS development on par with React. It also plays nice with Bootstrap for quick styling.

I was able to quickly set up a responsive SPA that uses asyncronous calls on input to quickly reload the table in the main app.

The outline of the app is pretty simple:

### Front-end

Turbo allows you to make asyncronous calls to the back end, which then replace targeted pieces of the DOM. This made the front-end pretty straightforward to write.

The 3 important html templates are:
 - app/views/index.html.erb: Main page, and search sidebar
 - app/views/_companies.html.erb: The table of companies, and sorting links
 - app/views/_company.html.erb: rendered for each row in the table

The table has some sorting links in the company name and ticker symbol header, which make an API call with the column to sort and the direction to sort in. They make use of a couple of methods in the CompaniesHelper('app/helpers/companies_helper.rb') to generate the links and icons.

The sidebar has an text input for ticker symbol and company name, which filter the list of companies. There are also select boxes for filtering by the various issue areas. The input boxes and select boxes on typing or changing trigger a method in the stimulus controller (`app/javascript/controllers/search_controller.js`). This method submits the form after a timeout completes, giving the user time to type.

### Back-end
Both the sorting and the sidebar search form submission go to the same endpoint in the CompaniesController called `#filter`. This makes use of the sessions object from the browser to store the parameters as filters. This allows us to "remember" previous filter choices, so that we maintain the sorting preferences when we add in some additional criteria and visa versa.

The controller utilizes some class methods on the Company model to search the DB using the filters. Those methods are tested in `spec/models/company_spec.rb`.

### Other considerations cut for time

Defintiely took some shortcuts for time, primarily around testing (which I outlined in the commit history below).

Some ther things I would have loved to do with more time:
- Would have used view components to componentize the rails partials. This would have allowed for greater re-usability of those partials, and easier testability of the front-end
- Would have abstracted the sidebar search into a component or partial, making use of the _form partial pattern in rails.
- Would have take a bit more time to refine the parameter pattern that resulted in passing blank default arguments in to the model class methods
- Would have leveraged the model factory for some fuzzier less deterministic testin testing
- Would have tried to do a bit more styling - there are some leftover bugs from the hasty bootstrap implementation, sometimes the styling dissappears from the bottom upon search.
- Would have done some more QA around the interactions between sorting and filtering.

## Commit History

Below is the commit history for a quick summary of build and decision history:

- First commit create rails scaffold for company, run migrations, create a seeding rake task to import the csv, convert /companies to a table, and import bootstrap for basic styling

- add feature where each company tracks the number of problem areas

    Satisfy requirement where each company listed also lists the number of
    problem areas it is exposed to. Add a method on the model, and display
    on the company table via the partial and index page

- add visual sidebar on companies page

- Finish the filter and ordering features

    This commit completes the feature list by adding the ability to filter
    and sort the companies table.

    I first installed Stimulus, a javascript frontend tool that compliments
    turbo. This allows us to write javascript controllers for actions on the
    front end.

    I then took the companies table I wrote on the index page
    and refactored it into it's own partial template, as I am planning
    to re-render that table from a new endpoint. I also took the opportunity
    to wrap the table in a turbo-frame, which leverages the Turbo framework.
    That framework intercepts all calls made from within the element and
    makes them async calls to the backend. It also provides a target in the
    DOM to re-render with the response from that async call.

    I then added the ability to sort by ticker symbol and company name by
    using the CompaniesHelper (a view helper for methods used when rendering
    templates) to generate links for the table headers. These links make a
    call to a new 'filter' endpoint using the parameters 'column' and
    'direction', which will return a sorted list of companies to re-render
    in the company table partial asyncronously via Turbo.

    Next I filled out the search sidebar, with a form - adding text input
    fields for company name and ticker, and select boxes for each issue area.
    When submitted, this form goes to the same filter endpoint, this time
    using the submitted form to filter the company table to the companies
    that match the criteria. I then wrote an endpoint on my stimulus JS
    controller - it is a method that when called, resets a 200ms timer, and
    when that timer finishes submits the form. This method gets called on
    each text input into the text box and each selection in the select boxes.
    The 200 ms timer is to ensure that we don't make a call every time someone
    types, and gives us enough time to get the full entry.

    The select box was not my first choice, I first used radio switches,
    but soon realized that there are three states, not two (True, False, no
    preference), so I swtiched to a select box which gave me that ability.

    Both the search and filter mechanics were added to the company model as
    class methods, both for ensuring correct separation of concerns, and
    to allow for more simple testability.

    As a note, all filter parameters are saved to the session so that multiple
    calls remember each other (i.e. if you sorted the table, and then
    filtered it, it would remember the sort). All filter params in the session
    are cleared on the initial load of the index page.

    Some other small additions include:
    - node module for bootstrap icons, so I could use little directional
    caret svgs as icons to indicate sort direction.
    - Fixed a bug in the company model which counted the issue areas inversely
    - Fixed the strong params (and added a new one for filters) from earlier bad naming for company attributes
- Delete Rails bloat

    Delete extra bloat from rails generator, extra CRUD methods in the
    controller, extra views, and extra routes.

- Added model testing for Company

    Would have loved to do a true TDD and write tests for the controller,
    views, and helpers but didn't in the interest of time.

    Just tested some core search methods on the company model - as well as
    wrote a factory and installed rspec. Found a couple of bugs - lack of
    default arguments for the methods led to some bugs. Parameters always
    came in fully populated (even with blank strings) so it never came up.

    Some testing things I would have done differently with more time:
      - Forgot to start with rspec in the initial generator and didn't
      realize until it was too late
      - Would have leveraged the factory to do more fuzzy testing for the
      model
      - Wouldn't have done count testing for filtering, shortcut for time
      - don't love blank default arguments like I have in the company model
- add index back in after accidentally and overzealously deleting it

- Dockerize app (new Dockerfile and docker compose Yaml), switch to Postgres, and ensure the app can listen on any ip (For Docker)

