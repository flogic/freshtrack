= freshtrack

== DESCRIPTION:

Freshtrack is used to automatically create time entries in FreshBooks from your own tracked time.

== FEATURES/PROBLEMS:

* Simple and easy to use

* Modular time-collector system

== SYNOPSIS:

  $ freshtrack proj
  
  or
  
  $ freshtrack proj --before 2008-08-16
  
  or! (if you really want)
  
  require 'freshtrack'
  
  Freshtrack.init
  Freshtrack.track('proj', :before => Time.parse('2008-08-16'))

== REQUIREMENTS:

* a time collector (see below)
* freshbooks (gem)
* A FreshBooks account
* a configuration file located at ~/.freshtrack.yml and looking like

  --- 
  collector: one_inch_punch
  company: Company Name
  token: API Token
  project_task_mapping:
    project_name:
      :project: FreshBooks Project Name
      :task: FreshBooks Task Name

(The 'Company Name' is the XXX in 'XXX.freshbooks.com'. The 'project_name' is the XXX in 'punch list XXX'.)

The 'collector' is what freshtrack will use to gather the time data that will end up as FreshBooks time entries.
Freshtrack ships with two collectors: 'punch' and 'one_inch_punch'. These are both gems that can be installed (by `gem install [collector name]`) and used without much effort. If these time-tracking tools aren't to your liking, you are free to write your own collector. Further documentation on that is forthcoming, but for now just take a look at the two collectors that already exist.

Collector requirements:

* It needs to be a class in the FreshTrack::TimeCollector namespace
* The file needs to exist in the freshtrack/time_collectors directory
* The class name should match the file name like Punch -> punch.rb or OneInchPunch -> one_inch_punch.rb
* It needs an initializer that takes an options argument (which will be a hash possibly having :before and :after keys with Date values)
* It needs a get_time_data instance method which takes a project name argument
* The get_time_data method needs to return an array of hashes like { 'date' => date_object, 'hours' => number_of_hours_as_float, 'notes' => notes_string }

== INSTALL:

* gem install freshtrack

== THANKS:

  * Kevin Barnes and Rick Bradley, for giving me a reason to track time and invoice people for it
  * The FreshBooks team, for making invoicing easy
