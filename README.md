searchdaimon-mantis
===================

A Searchdaimon (www.searchdaimon.com) crawler to index a Mantis bug tracker (www.mantisbt.org).

== Installing ==

* Create a new connector from the search daimon administration panel. 
* Copy the perl code in crawler.pl.
* Add the following parameters: username, password, url <br>
   The example for the URL can be set as: http://10.0.0.1/mantis/

Attribute support:
To add attribute support, go to "Client Templates" and clone the default template.<br>
In the file "tpl: attribute_blocks.tpl" find the section<br>
    [% BLOCK generic_attributes %]
      
and add the following lines:<br>
    [% PROCESS _attr_row a = attr.status title="Status" IF attr.status %]
    [% PROCESS _attr_row a = attr.reporter title="Reporter" IF attr.reporter %]
    [% k="assigned to"; PROCESS _attr_row a = attr.$k title="Assigned to" IF attr.$k %]
    [% PROCESS _attr_row a = attr.category title="Category" IF attr.category %]
    
== Licensing ==
Licensed under GNU LGPL, see file LICENSE
