Freshtrack is used to automatically create time entries in FreshBooks.

It presently depends on punch, the gem by Ara T. Howard, and any arguments given to 
freshtrack are passed along to punch as if freshtrack were an alias for 'punch list'.

For example

  freshtrack proj --after 2008-01-16 --before 2008-02-01

would get time data for the second half of January 2008 by using the command

  punch list proj --after 2008-01-16 --before 2008-02-01


Freshtrack requires a configuration file, ~/.freshtrack.yml, that looks something like

  --- 
  company: Company Name
  token: API Token
  project_task_mapping:
    project_name:
      :project: FreshBooks Project Name
      :task: FreshBooks Task Name

The 'Company Name' is the XXX in 'XXX.freshbooks.com'. The 'project_name' is the XXX in 'punch list XXX'


NOTE: As of this writing, punch (0.0.1) specifically requires attributes version 5.0.0 even though 5.0.1 is out.
Because of the way gems work, punch will not work if both are installed. Make sure the specific installed version 
of attributes is 5.0.0.