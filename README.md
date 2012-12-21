searchdaimon-mantis
===================

A Searchdaimon (www.searchdaimon.com) crawler to index a Mantis bug tracker (www.mantisbt.org).

Installing
-

* Create a new connector from the search daimon administration panel. 
* Copy the perl code in crawler.pl.
* Add the following parameters: username, password, url <br>
   The example for the URL can be set as: http://10.0.0.1/mantis/

Attribute support:
To add attribute support, go to "Client Templates" and clone the default template.<br>
In the file "tpl: attribute_blocks.tpl" find the section<br>
````
     [% BLOCK generic_attributes %]
````     
      
and add the following lines:<br>
````
     [% PROCESS _attr_row a = attr.status title="Status" IF attr.status %]
     [% PROCESS _attr_row a = attr.reporter title="Reporter" IF attr.reporter %]
     [% k="assigned to"; PROCESS _attr_row a = attr.$k title="Assigned to" IF attr.$k %]
     [% PROCESS _attr_row a = attr.category title="Category" IF attr.category %]
````    

Your Searchdaimon system may or may not have the following required perl modules installed
* WWW::Mechanize;
* Date::Parse

If not, you may have to locate the rpm's for the modules and install them from the administration panel, or install from the root command line.

Running
-
Create a new crawler, add username, password and URL to your mantis installation. That should do it. Note that the user has to have it's mantis language settings set to english. This is because mantis changes the csv-export headings depending on language used.

Licensing
-
Licensed under GNU LGPL, see file LICENSE
