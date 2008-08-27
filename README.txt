= freshtrack

== DESCRIPTION:

Freshtrack is used to automatically create time entries in FreshBooks from your own tracked time.

== FEATURES/PROBLEMS:

* Simple and easy to use

* Only works with data from one_inch_punch

== SYNOPSIS:

  $ freshtrack proj
  
  or
  
  $ freshtrack proj --before 2008-08-16
  
  or! (if you really want)
  
  require 'freshtrack'
  
  Freshtrack.init
  Freshtrack.track('proj', :before => Time.parse('2008-08-16'))

== REQUIREMENTS:

* one_inch_punch (gem)
* freshbooks (gem)
* A FreshBooks account
* a configuration file located at ~/.freshtrack.yml and looking like

  --- 
  company: Company Name
  token: API Token
  project_task_mapping:
    project_name:
      :project: FreshBooks Project Name
      :task: FreshBooks Task Name

(The 'Company Name' is the XXX in 'XXX.freshbooks.com'. The 'project_name' is the XXX in 'punch list XXX'.)

== INSTALL:

* gem install freshtrack

== THANKS:

  * Kevin Barnes and Rick Bradley, for giving me a reason to track time and invoice people for it
  * The FreshBooks team, for making invoicing easy
