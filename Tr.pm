package Regex::Tr;

use 5.008;
use strict;
use warnings;
use Carp;

# The default string for the initial value
use constant DEF_STRING => "foo";

our $VERSION = "0.01";
our @last = (
	     DEF_STRING, 
	     DEF_STRING, 
	     "",
	     Regex::Tr->new(DEF_STRING, DEF_STRING)
	     );

# This method creates a new instance of the object
sub new($$$;$) {
    (my($class,$from,$to,$mods) = @_);
    $mods = "" unless(defined($mods));  # Fixes warning
    
    # Efficiency kludge for loops
    if(($from eq $last[0]) and
       ($to   eq $last[1]) and
       ($mods eq $last[2]) ) 
    {
	return $last[3];
    } else {
	my $subref = eval '
	sub(\$) {
	    my $ref = shift;
	    return ${$ref} =~ tr/'.$from.'/'.$to.'/'.$mods.';
	};';
	carp 'Bad tr///:'.$@ if $@;
	@last = ($from,$to,$mods,bless($subref,$class));
	return $last[3];
    }
}

# Performs the actual tr/// operation set up by the object.
sub bind($$) {
    my($self,$ref) = @_;
    my $reftype = ref($ref);
    unless($ref) {
	carp "No reference passed to Regex::Tr object";
    } elsif(!$reftype) {
	carp "Parameter to Regex::Tr object not a reference";
    } elsif($reftype ne "SCALAR") {
	carp "Parameter to Regex::Tr object not a scalar reference";
    }
    return &{$self}($ref);
}

# Performs the tr/// operation on a scalar passed to the object.
sub trans($$) {
    my($self,$val) = @_;
    my $cnt = $self->bind(\$val);
    return wantarray ? ($val, $cnt) : $val;
}

return 1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Regex::Tr - Run-time-compiled tr/// objects.

=head1 SYNOPSIS

  use Regex::Tr;
  my $trier = Regex::Tr->new("a-z","z-a");
  my $swapped = "foobar";
  $trier->bind(\$swapped);                  # $swapped is now "ullyzi"
  my $tred = $trier->trans("barfoo");       # $tred is "yziull"

=head1 ABSTRACT

  Solves the problem requiring compile-time knowledge of tr/// constructs by 
  generating the tr/// at run-time and storing it as an object.

=head1 DESCRIPTION

  One very useful ability of Perl is to do relatively cheap transliteration via the
  tr/// regex operator.  Unfortunately, Perl requires tr/// to be known at compile-time.
  The common solution has been to put an eval around any dynamic tr/// operations, but
  that is very expensive to be used often (for instance, within a loop).  This module
  solves that problem by compiling the tr/// a single time and allowing the user to 
  use it repeatedly and delete it when it it no longer useful.  The last instance to be created is stored for ease of recreation (for instance, within a loop).

=head1 METHODS

=head2 CLASS->new(FROMSTRING,TOSTRING,[MODIFIERS])

  This creates a new instance of this object.  FROMSTRING is the precursor string for
  the tr///, TOSTRING is the succsessor string for the tr///, and the optional MODIFIERS 
  is a string containing any modifiers to the tr///.

=head2 $obj->bind(SCALARREF)

  This binds the given SCALARREF and then performs the object's tr/// operation, returning
  what the tr/// operation will return.  Note that this method does not create the reference.

=head2 $obj->trans(SCALAR)

  This takes a scalar, performs the tr/// operation, and returns the tr///ed string in
  scalar context, or a list consisting of the tr///ed string and the tr/// return value
  in list context.

=head1 SEE ALSO

  * perlop - Provides a definition of the tr/// operator.
  * perlre - Provides more information on the operator.
    
=head1 AUTHOR

Robert Fischer, E<lt>chia@corradiation.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Robert Fischer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
