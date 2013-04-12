# Billtrap


Billtrap is a command line invoice management tool in ruby.
It allows creation and monitoring of invoices and exporting data using template formatters.

Billtrap is based on the time tracking tool [Timetrap](https://github.com/samg/timetrap) by Sam Goldstein, and allows importing time entries from Timetrap into invoices.
However, Billtrap can be used to create invoices manually without data from Timetrap.



## Installation
To install, use rubygems:

	gem install billtrap

This will place the Billtrap executable `bt` in your path.

## Usage

If you call Billtrap without any argument (or using --help) will
display usage information:

	$ bt --help

### Configuring BillTrap

Use `bt configure` to write a config file to `HOME/.billtrap/billtrap.yml` (Override by setting BILLTRAP_HOME in env)

The following options are supported

- **database**: Sequel Databsae identifier, defaults to `sqlite://<BILLTRAP_HOME>/.billtrap.db`
- **timetrap_database**: Timetrap database, used to import Entries
- **round_in_seconds** => 900,
- **currency**: Currency to use (see [RubyMoney.format](http://rubydoc.info/gems/money/Money/Formatting:format) for options)
- **default_rate**: Default rate in the above currency
- **invoice_number_format**: Invoice numbering format. Expands [Date.strftime directives](http://ruby-doc.org/stdlib-2.0/libdoc/date/rdoc/Date.html#method-i-strftime) and `%{invoice_id}`, `%{client_id}` upon export of the invoice (e.g., `%Y%m%d_%{invoice_id}`)
- **currency_format**: Money formatter, see <http://rubydoc.info/gems/money/Money/Formatting> for output options
- **date_format**: date format
- **billtrap_archive**: Output path for exported invoices
- **serenity_template**: OOffice adapter: Path to invoice template

### Adding invoices

Add a **new** invoice with the title *Some important project* to Billtrap and activate it:

	$ bt new --name 'Some important project'

You can also specify a certain date (using [Chronic keywords](https://github.com/mojombo/chronic)) to use with the invoice:

	# Adds an unnamed invoice, dated yesterday
	$ bt new --date yesterday

### Switching between invoices

To display the current set of open invoices, use `bt show`.

	$ bt show
	Showing open invoices
	 ID    Name        				Client          Created         Payments / Total
	 1     Some important project     -             2013-04-12      0,00 EUR / 0,00 EUR
	 >>2    -  				          -             2013-04-11      0.00 USD / 0.00 USD

Billtrap manages a set of invoices, and allows you to focus on one invoice at a time.
The "**>>**" marks the current active invoice (ID 2), which we just added with `--date yesterday`.

To switch between invoices, use the `in` comand with the ID of the invoice to switch to.
Now, to switch to the 'Some important project' invoice, enter:

	$ bt in 1
	Activating invoice #1

The active invoice is persisted between calls, i.e., you always
edit the latest invoice until `bt in` or `bt new` is called.

### Editing the active invoice
Let's add some entries to the important project by executing
`bt entry --add`. This will read the entry from STDIN.

	$ bt entry --add
	Entry title: Programming
	Entry date (YYYY-MM-DD): 2013-04-10
	Displayed unit (Defaults to 'h' for hours):
	Quantity (Numeric): 2.5
	Price in USD per unit (Numeric): 20
	Optional Notes: (Multiline input, type Ctrl-D or insert END and return to exit)
	^D

	Added entry (#1) to current invoice (ID 1)

Lets check the values we entered with `bt show --detail 1`,
which displays details for the invoice with ID 1.

	$ bt show --detail 1

	Invoice:    Some important project (#1)
	Created on: 2013-04-13
	----------------------
	Invoice entries
	  Title          Date        Quantity    Price       Notes
	  Programming    2013-04-10  2.5h        50.00 USD   

### Importing data from Timetrap
If you manage your time using Timetrap, you can use the `import` command to import entries to the current invoice.

Assume you have a sheet called *test* with three entries.
	
	$ t display test
    Day                Start      End        Duration   Notes
    Sat Oct 29, 2011   22:42:36 - 23:13:02   0:30:26    Foo
                                             0:30:26
    Sat Nov 17, 2012   23:13:57 - 23:14:07  24:00:10    Bar
                                            24:00:10
    Sun Nov 18, 2012   22:26:00 - 22:31:20   0:05:20    Moo

You can import the whole sheet into BillTrap using the following command:

	$ dbt impoort --sheet test

	Imported 0.51 hours from sheet test as entry #2
	Imported 0.09 hours from sheet test as entry #3
	Imported 24.0 hours from sheet test as entry #4

You could also import single IDs into the current invoice:

	$ dbt import --entry 1 2
	Imported 0.51 hours from sheet test as entry #5
	Imported 0.09 hours from sheet test as entry #6


If you wish to clear all entries *prior* to the import,
use the `--clear` flag:

	$ dbt import --entry 1 2
	Imported 0.51 hours from sheet test as entry #1
	Imported 0.09 hours from sheet test as entry #2

**Beware:** Using the `--clear` flag does not ask for confirmation prior to deleting all entries of the current invoice.


### Setting a client

BillTrap allows you to add and manage clients.
**Note**: This feature is still rudimentary and subject to change.

Use `bt client --add` to add a client from STDIN:

	$ bt client --add
	First name: John
	Surname: Doe
	Company: Doemasters Inc.
	Address: (Multiline input, type Ctrl-D or insert END and return to exit)
	Somestreet 12  
	12345 Sometown^D
	Mail: mail@example.com
	Hourly rate: 25
	Use non-standard Currency? [Leave empty for USD]: EUR

	Client John Doe was created with id 1

Let's set *John Doe* as the client for our important project.

	# Equivalent to 'bt set client 1'
	$ bt set client Doe

	SET client to John Doe (#1)

**Note**: The client currency setting overrides BillTrap's default setting, thus the currency for all entries of invoice #1
have changed to EUR.

### Exporting invoices
Let's review our changes to the Invoice #1:

	$ bt show
	Showing open invoices
	 ID    Name                      Client                  Created         Payments / Total
	 >>1   Some important project    John Doe                2013-04-13      0,00 EUR / 50,00 EUR
	 2      -                         -                      2013-04-12      0.00 USD / 0.00 USD

To export the invoice:

	$ bt export

	Generated invoice has been output to: /Users/oliver/Documents/billtrap/invoices/2013/4/13/1.odt

Currently, the only working adapter uses the [serenity gem](https://github.com/kremso/serenity) to populate a Open/LibreOffice template of your choosing and renders an ODT.

**Note**: Have a look at the config (see *configuring BillTrap*) to change invoice numbering, output paths et cetera.

I'm working on creating more adapters. If you want to participate in the discussion, I suggest opening an issue on the [Github tracker](http://github.com/oliverguenther/Billtrap/issues).

### Abbreviating commands
All commands and their paremeters can be abbreviated.
For example, instead of `bt new --date yesterday`, you could also enter with same result:

	$ bt n -d yesterday

BillTrap warns you about ambiguous command abbreviations, e.g.,

	$ bt s
	Error: Ambiguous command 's'
	Matching commands are: set, show

## Special Thanks

I'd like to thank Sam Goldstein for his work on Timetrap, which motivated me to improve on my time management and to start this project.

Billtrap intentionally borrows heavily from Timetrap, which is available at <https://github.com/samg/timetrap>.

--------

## Bugs and Feature Requests

Billtrap is still under heavy development.

If you have feature requests or found a bug, please file an issue on the Github tracker:

<http://github.com/oliverguenther/Billtrap/issues>
