# Copyright (c) 2007, Dagur Valberg Johannsson
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Lesser General Public License for more details.
#
# You should have received a copy of the Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This is a crawler for Searchdaimon search engine used for crawling Mantis bug
# tracker systems.

use strict;
use warnings;
use Carp;
use Data::Dumper;
use WWW::Mechanize;
use Date::Parse qw(str2time);

our $BASE_URL = undef;
our $USERNAME = undef;
our $PASSWORD = undef;

use Crawler;
our @ISA = qw(Crawler);

sub crawl_update {
  my (undef, $self, $opt) = @_;

  $BASE_URL = $opt->{url};
  $USERNAME = $opt->{username};
  $PASSWORD = $opt->{password};

  die "Username missing"
  unless defined $USERNAME;
  die "Password missing"
  unless defined $PASSWORD;
  die "Mantis URL missing"
  unless defined $BASE_URL;
  die "Mantis url must end with /"
  unless $BASE_URL =~ /\/$/;


  $|=1;

  my $mech = WWW::Mechanize->new;
  log_in($mech);
  my $bug_url_tpl = $BASE_URL . "view.php?id=";
  my @keep_attributes = (
    'status', 'reporter', 'assigned to', 'category', 'id'
  );

  for my $bug_ref (get_bug_list($mech)) {
    my $url = $bug_url_tpl . $bug_ref->{id};
    $mech->get($url);
    if (!$mech->success) {
      warn "Unable to crawl url " . $url->url;
      next;
    }
    print "Adding bug " . $mech->title . "\n";

    my $last_modified = str2time($bug_ref->{updated});

    next if $self->document_exists($url, $last_modified, length $mech->content);

    my %attributes = map {
    ($_ => $bug_ref->{$_})
    } @keep_attributes;

    $self->add_document(
      url => $url,
      title => $mech->title,
      content => $mech->content,
      last_modified => $last_modified,
      type => 'html',
      acl_allow => 'Everyone',
      attributes => \%attributes
  );
}
}

sub path_access { 1; }

sub log_in {
  my $mech = shift;
  $mech->get($BASE_URL . "login_page.php");
  croak "Unable to fetch login page"
  unless $mech->success();

  $mech->submit_form(
    form_name => 'login_form',
    fields => {
      username => $USERNAME,
      password => $PASSWORD
    },
  );

  croak "Error logging in"
  unless $mech->success();

  croak "Invalid login credentials"
  if $mech->content =~ /Your account may be disabled/;
}

sub parse_csv_export {
  my $content = shift;

  my @raw_lines = split "\n", $content;
  my @attributes = map { lc } split ",", shift @raw_lines;

  my @buglist;

  for my $bug (@raw_lines) {
    my %bug_attr;
    @bug_attr{@attributes} = split q{,}, $bug;
    push @buglist, \%bug_attr;
  }

  return @buglist;
}

sub get_bug_list {
  my $mech = shift;

  # Fetch the "AllPages" page
  $mech->get($BASE_URL . "csv_export.php");
  croak "Unable to fetch article list"
  unless $mech->success();

  my @bugs = parse_csv_export($mech->content);

  return @bugs;
}
