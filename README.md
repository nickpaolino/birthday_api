# README

## Overview

Given a date, this API returns the celebrities who have that birthday. The API
is written in Ruby on Rails and uses Nokogiri to scrape IMDB for the results.
The response includes the following fields:

* Name
* Photo URL
* Profile URL
* Most Known Work:
  * Title
  * URL
  * Rating
  * Director

## Usage

To use this API, change the params for the date in the URL.

https://birthday-api.herokuapp.com/birthday?q=02-02

You can add an optional results param to return results in increments of 50. If
you do not specify a results param, the default results value is 50.

https://birthday-api.herokuapp.com/birthday?q=02-02&results=100

## Technology

This API uses Ruby on Rails and is deployed via Heroku. There are two main
features of the API. There's a controller action which is responsible for
receiving the input params and sending that request over to the Adapter module
to get the necessary info. When this is complete, the data is rendered in json
via the same controller action.

The Adapter module is where most of the app logic occurs. The IMDB class uses
Nokogiri to scrape the pages listing celebrities who were born on a certain day.
The class is instantiated with a date and results field and the method
scrape_pages is called. This is the only public method in the class. The rest of
the logic responsible for scraping the pages are kept in private helper methods
that are each given a specific task.

Each page on IMDB has 50 results. When the page is scraped, all of the necessary
information pertaining to each of the 50 celebrity entries is extracted via
Nokogiri's helper methods to find certain classes and simple string procedures
to remove the necessary text. For each celebrity entry, the URL for their most
distinguishable movie is extracted and a separate request is made to retrieve
the rating and director from that link. For 50 results, there are 100 pages to
be scraped.

Oftentimes a page's HTML cannot be loaded properly into the Nokogiri object. To
remedy this, I created a begin/rescue loop to retry the request up to 3 times. I
also wrote logic for each field that's scraped to ensure that the program does
not break if the desired field is empty. The API is capable of requesting the
maximum number of entries for a date without any problems. The only drawback is
the amount of time it takes to scrape those pages.
