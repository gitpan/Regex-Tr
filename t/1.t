# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
use lib qw(. .. ../.. );
BEGIN { use_ok( "Regex::Tr" ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# Test "CLASS->new"
my $trier = Regex::Tr->new("a-z","b-za");
ok( defined $trier, "Object created." );
ok( $trier->isa('Regex::Tr'), "Object is of correct type." );

# Test repitition of "CLASS->new"
$trier = undef;
$trier = Regex::Tr->new("a-z","b-za");
ok( defined $trier, "Object recreated." );
ok( $trier->isa('Regex::Tr'), "Recreated object is of correct type." );

# Test "$obj->bind"
{
    my $swapped1 = "foobar";
    my $swapped2 = $swapped1;
    $trier->bind(\$swapped1);
    $swapped2 =~ tr/a-z/b-za/;
    ok( $swapped1 eq $swapped2, "The bind method worked" );
}

# Test "$obj->trans"
{
    my $tred = $trier->trans("barfoo");
    my $manual = "barfoo";
    $manual =~ tr/a-z/b-za/;
    ok( $tred eq $manual, "The trans method worked");
}
