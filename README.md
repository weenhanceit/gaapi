# Google Analytics for Ruby
`gaapi` provides a command line executable program to retrieve data from Google Analytics (GA). It doesn't try to do a lot more than can be done with `curl` or `wget`, but it does try to make querying GA easier than with those tools.

`gaapi` takes the user's GA request, specified in JSON format, and sends it to GA. It outputs the result of the request in JSON or comma-separated values (CSV) format.

`gaapi` supports two ways of providing credentials. One way is more useful while testing scripts or doing ad-hoc queries. The other is more appropriate for unattended script usage.

Google provides a Ruby client library that builds queries by constructing them from Ruby objects. `gaapi` allows you to express queries as JSON. If you prefer the JSON format, you may prefer to use `gaapi`. If you want to deal with Ruby objects (which are likely more verbose than JSON), use the Google gem.

## Usage
```
gaapi [options] VIEW_ID
```
If no query is specified on the command line, `gaapi` tries to read the query from standard input.

The VIEW_ID is what identifies the Google Analytics data (a view of a property). Log in to GA, select the account of interest, select Admin (the gear near the bottom left of the page), and select "View Settings" (on the right of the page).

## Options
```
    -a, --access-token TOKEN         An access token obtained from https://developers.google.com/oauthplayground.
        --csv                        Output result as a csv file.
    -c, --credentials CREDENTIALS    Location of the credentials file. Default: `.gaapi/ga-api-key`.
    -d, --debug                      Print debugging information.
    -e, --end-date END_DATE          Report including END_DATE.
    -n, --dry-run                    Don't actually send the query to Google.
    -q, --query-file QUERYFILE       File containing the query. Default STDIN.
    -s, --start-date START_DATE      Report including START_DATE.
```

## Installation

```
gem install gaapi --no-doc
```

## Example
Get the number of visitors to a site for January, 2018, with credentials previously obtained and stored in `./credentials.json`:
```
gaapi -c ./credentials.json VIEW_ID
{
  "reportRequests": [{
      "viewId": "VIEW_ID",
      "dimensions": [{"name": "ga:date"}],
      "dateRanges": [{
        "startDate": "2017-10-01",
        "endDate": "2017-10-31"
      }],
      "metrics": [{
          "expression": "ga:users"
      }],
      "includeEmptyRows": true,
      "hideTotals": false,
      "hideValueRanges": true
    }]
}
```

## Queries
`gaapi` uses the Google Analytics Reporting API v4 (https://developers.google.com/analytics/devguides/reporting/core/v4/). An introduction to querying for GA data is here: https://developers.google.com/analytics/devguides/reporting/core/v4/basics.
A very useful reference of the dimensions and metrics available is at: https://developers.google.com/analytics/devguides/reporting/core/dimsmets.

A query to find basic visit data for a web site is:
```
{
  "reportRequests": [{
      "viewId": "VIEW_ID",
      "dimensions": [{"name": "ga:date"}],
      "dateRanges": [{
        "startDate": "2017-10-01",
        "endDate": "2017-10-31"
      }],
      "metrics": [{
          "expression": "ga:avgSessionDuration"
        },
        {
          "expression": "ga:pageviewsPerSession"
        },
        {
          "expression": "ga:sessions"
        },
        {
          "expression": "ga:users"
        }
      ],
      "includeEmptyRows": true,
      "hideTotals": false,
      "hideValueRanges": true
    },
    {
      "viewId": "VIEW_ID",
      "dimensions": [{"name": "ga:date"}],
      "dateRanges": [{
        "startDate": "2017-10-01",
        "endDate": "2017-10-31"
      }],
      "metrics": [{
          "expression": "ga:goal1Completions"
        },
        {
          "expression": "ga:goal2Completions"
        },
        {
          "expression": "ga:goal6Completions"
        },
        {
          "expression": "ga:goal8Completions"
        },
        {
          "expression": "ga:goal9Completions"
        },
        {
          "expression": "ga:goal11Completions"
        },
        {
          "expression": "ga:goal13Completions"
        },
        {
          "expression": "ga:goal14Completions"
        },
        {
          "expression": "ga:goal16Completions"
        },
        {
          "expression": "ga:goalCompletionsAll"
        }
      ],
      "includeEmptyRows": true,
      "hideTotals": false,
      "hideValueRanges": true
    },
    {
      "viewId": "VIEW_ID",
      "dimensions": [{"name": "ga:date"}],
      "dateRanges": [{
        "startDate": "2017-10-01",
        "endDate": "2017-10-31"
      }],
      "metrics": [{
          "expression": "ga:avgSessionDuration"
        },
        {
          "expression": "ga:pageviewsPerSession"
        },
        {
          "expression": "ga:sessions"
        },
        {
          "expression": "ga:users"
        }
      ],
      "includeEmptyRows": true,
      "hideTotals": false,
      "hideValueRanges": true
    }
  ]
}
```

## Authentication
[The introduction to authentication for Google products is here: https://developers.google.com/analytics/devguides/reporting/core/v4/authorization.]

### Testing and Ad-Hoc Usage
This method involves cutting and pasting an access token obtained from https://developers.google.com/oauthplayground onto the command line. The access token is simply a long string of characters generated by Google. The access token expires after an hour, so the user has to return to the Google URL to get a new token.

### Unattended Running
This method obtains a file of secure credentials from Google. It's very important that these credentials be kept secure, as whoever has a copy of the file, has access to the Google Analytics data for the account.

To use this type of credential with `gaapi`:

1. Follow the instructions at: https://developers.google.com/identity/protocols/OAuth2ServiceAccount, choose a JSON format file, and when you're prompted to save a file, save it
2. Immediately change the permissions of the file to make it readable only by you. On Linux, Unix, OSX that's `chmod 600 filename`.
3. Give the file name in the `--credentials` option when you run `gaapi`
