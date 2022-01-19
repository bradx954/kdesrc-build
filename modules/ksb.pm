package ksb;

# Enables default boilerplate Perl standards used by kdesrc-build, including minimum Perl version,
# strictness, warnings, etc.
#
# See also: Modern::Perl
#
# Use by including 'use ksb;' at the beginning of each kdesrc-build source file.

use v5.26;

# These are imported to make *this* pragma strict and enable warnings. We will
# then re-import these into our caller's namespace in our own sub import.
use strict;
use warnings;

# These are made available but not imported. They are only here so we can
# re-import them into the caller's namespace. We can rely on these to be
# present even on minimal Perl.
# NOTE: If we cannot rely on this, these need to be optional!
require feature;

my $REQUIRED_PERL_FEATURES = ':5.26';
my @EXPERIMENTAL_FEATURES = qw(signatures);

sub import
{
    warnings->import;
    strict->import;

    # Enable features we use everywhere
    feature->import($REQUIRED_PERL_FEATURES, @EXPERIMENTAL_FEATURES);

    # Disable warnings for experimental features we're deliberately using.
    warnings->unimport(map { "experimental::$_" } @EXPERIMENTAL_FEATURES);

    # Manually disable experimental::smartmatch warnings which corresponds to a
    # different named feature, 'switch', pulled in as part of the version
    # feature flag.
    warnings->unimport('experimental::smartmatch');
}

1;