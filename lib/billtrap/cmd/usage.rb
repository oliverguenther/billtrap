module BillTrap
  module CLI
    def usage 
      <<-EOF

Billtrap - Manage invoices, import time slices from Timetrap

Usage: bt COMMAND [OPTIONS] [ARGS...]

COMMAND can be abbreviated. For example `bt edit --delete 1` and `bt e -d 1` are equivalent.

COMMAND is one of:

  * configure - Write out a YAML config file to HOME/.billtrap.yml.
    usage: bt configure

  * client - Manage clients (adding, deleting and connecting to current invoice)
    usage: bt client [--add] [--delete [ID]] [--set [ID]]
    -a, --add         Manually add a client, reads from STDIN
    -d, --delete      Delete a client. If no ID is given, prints all clients.
                      Note: Clients cannot be deleted if a non-archived invoiced is linked to it.

  * entry - Edit the active invoice, adding or deleting invoice entries manually 
    usage: bt edit [--add] [--delete [ID]]
    -a, --add         Manually add an invoice entry (timeslice or product), reads from STDIN
    -d, --delete      Delete an invoice entry. If no ID is given, prints all entries and asks for an ID.

  * export - Export active invoice, using the default adapter (Serenity)
    -a, --adapter     Override the default adapter

  * in - Switch to another invoice, making it active for edits
    usage: bt in [ID | NAME]

  * import - Import data from Timetrap. Sets invoice title to the sheet name and description to notes
    usage: bt import [--clear] [--sheet NAME] [--entry ID [ID ..]]
    -c, --clear       Clears ALL invoice entries before import
    -e, --entry       Import the given entries.
    -s, --sheet       Import all entries from the given sheet. 

  * new - Create a new invoice, activating it for edits
    usage: bt new [--name NAME] [--date DATE] [--client ID | NAME]
    -c, --client      Tie the invoice to a client
    -d, --date        Set to override invoice date (defaults to today)
    -n, --name        Set invoice reference name

  * payment - add, remove payments to current id
    usage: bt payment [--add AMOUNT ['NOTES']] [--delete ID]
    -a, --add         Add a payment to current invoice
    -d, --delete      Delete a payment by ID from current invoice

  * set - Set variables on the current invoice
    usage: bt set TOKEN [VALUE]
    Where TOKEN is one of
      client          Set a client by id or surname
      date            Set the `created on` date (YYYY-MM-DD), leave empty for today
      name            Set name of current invoice
      sent            Set the `sent on` date (YYYY-MM-DD), leave empty for today
      other           Add { 'other' => VALUE } to the invoice's custom attributes.
                      Use this to set attributes for populating templates

  * show - Display a list invoices. Shows pending invoices by default (open or unpaid)
    usage: bt show [--details ID | NAME] [--completed]
    -d, --detail      Show details (including entries) of a particular invoice
    -c, --completed   Show only completed (i.e., sent and paid) invoices

  GLOBAL OPTIONS
  Use global options by prepending them before any command.
  --debug         Display stack traces for errors.
  usage: bt --debug COMMAND [ARGS]

  OTHER OPTIONS
  -h, --help      Display this help.

  EXAMPLES

  Please submit bugs and feature requests to http://github.com/oliverguenther/billtrap/issues
      EOF
    end
  end
end