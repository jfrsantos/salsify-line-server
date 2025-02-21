# salsify-line-server

This small project is an implementation of the code challenge provided https://salsify.github.io/line-server.html.

## How to run the application

The application was developed using Ruby on Rails 8.0.1 and Ruby 3.3.7, is dockerized and there are separate scripts to build and run the application, as well as run the tests. To run the scripts Docker must be installed on the system. 

### Build command
In the root of the repo run the command `./build.sh`.
If using a docker command is preferable `LINE_SERVER_FILE=./sample.txt docker compose build`

### Run the application
Run the command `./run.sh <filepath>` where `filepath` is the path of the file you wish to be served by the application (i.e. `./run.sh ./sample.txt`).
The docker equivalent is `LINE_SERVER_FILE=./sample.txt docker compose up`

The application is served on `localhost:3000`. 

To reach the lines endpoint simply do a GET request to 
`http://localhost:3000/lines/<line index>` 

Terminate the application with control+C

### Test command
You can run the tests by either running the `./test.sh` command or `LINE_SERVER_FILE="./sample.txt" docker compose run --rm line-server bundle exec rspec`

## How does the system work?

The line server has a text file saved on the `app/assets/files` folder which is read when the line request is made (the docker setup is pointing the file from the LINE_SERVER_FILE env var, to that specific file, so the actual file in the repo is a dummy).

To fetch the correct file, the application first checks if there are cache files related to the file. If there are no cache files, it will first create them. To do this it will iterate through the entire file and divide it into chunks with a predifined size (defined in the configuration as 3 in this exercise). Each chunk will be saved as a separate, named after the original but terminating with `_n` where `n` is the number of the chunk.

If there are already cache files, their generation is skipped and the application simply iterates through the chunk line by line until it reaches the correct one and returns it on the `line` field of a json with a status code 200.

If the entire last chunk is read without reaching the desired line, an error is raised and status code 413 is returned to the user with an error message `OUT OF FILE`. This can only happen on the last chunk.

If the line provided is not an integer, the route returns 404.

No database is used. The path of the endpoint is defined on `routes.rb` and sent to the controller. There the line number is fetched and a call is sent to the file service. The file service will fetch the line of the file. The file service is defined on the controller via dependency injecton using `before_action :load_dependencies`.

## Performance

In terms of the file size of the served file, since the file is read line by line, the entire file does not need to load to memory.

Since the file is subdivided into smaller chunks, reading line by line will not take a big toll in terms of time it takes to retrieve the line.

The first request however will have to create the entire cache so it will take the longest since it iterates through the entire file. This issue can be eliminated by having the cache being created before the application is serving, or having a cronjob that will update the cache.

As for number of concurrent requests, as the file is immutable, only read requests are made and those can be made at the same time.
The bottleneck would be the I/O capacity of the hardware as well as the load balancer (e.g. Nginx). In terms of memory usage, each request would be using the memory required for a single line of the file at a time.

Performance could be further improved by adding a caching layer.

## Documentation

To develop this project, I looked at the following documentation:
- Comparing different read file methods on Ruby: https://tjay.dev/howto-working-efficiently-with-large-files-in-ruby/
- Setting up rspec: https://medium.com/@amliving/my-rails-rspec-set-up-6451269847f9

## Tools used

- Ruby on Rails 8.0.1
- Ruby 3.3.7
- Docker

I chose to use Docker as it allows to easily set up the application to run on almost any system, without the need to install many dependencies. Ruby on Rails was my pick because I was informed that Salsify mostly works with Ruby and I currently use Ruby on Rails in my day to day work.

## Time spent

In total, this project was made in around 5h with the setup included. With more time I would:
- Implement a cronjob that would make the task of creating cache on the first request not needed, making it much faster.
- Add a caching layer that would make requests to the same line not have to research the files again. 
- Save on DB the number of lines of the file, so that there is no need to iterate the entire last chunk to know that the line is outside of the file.
- Add some logs to the application to monitor and debug any possible issues that could arise.

## Critiques

Since the project was generated automatically with a rails command, it has some unnecessary bloat.