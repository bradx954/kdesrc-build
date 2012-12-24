package ksb::Debug;

# Debugging routines and constants for use with kdesrc-build

use strict;
use warnings;
use v5.10;

our $VERSION = '0.10';

use Exporter qw(import); # Steal Exporter's import method
our @EXPORT = qw(debug pretending debugging whisper
                 note info warning error pretend);

# Debugging level constants.
use constant {
    DEBUG   => 0,
    WHISPER => 1,
    INFO    => 2,
    NOTE    => 3,
    WARNING => 4,
    ERROR   => 5,
};

my $screenLog;   # Filehandle pointing to the "build log".
my $isPretending = 0;
my $debugLevel = INFO;

# Colors
my ($RED, $GREEN, $YELLOW, $NORMAL, $BOLD) = ("") x 5;

# Subroutine definitions

sub colorize
{
    my $str = shift;

    $str =~ s/g\[/$GREEN/g;
    $str =~ s/]/$NORMAL/g;
    $str =~ s/y\[/$YELLOW/g;
    $str =~ s/r\[/$RED/g;
    $str =~ s/b\[/$BOLD/g;

    return $str;
}

# Subroutine which returns true if pretend mode is on.  Uses the prototype
# feature so you don't need the parentheses to use it.
sub pretending()
{
    return $isPretending;
}

sub setPretending
{
    $isPretending = shift;
}

sub setColorfulOutput
{
    # No colors unless output to a tty.
    return unless -t STDOUT;

    my $useColor = shift;

    if ($useColor) {
        $RED = "\e[31m";
        $GREEN = "\e[32m";
        $YELLOW = "\e[33m";
        $NORMAL = "\e[0m";
        $BOLD = "\e[1m";
    }
    else {
        ($RED, $GREEN, $YELLOW, $NORMAL, $BOLD) = ("") x 5;
    }
}

# Subroutine which returns true if debug mode is on.  Uses the prototype
# feature so you don't need the parentheses to use it.
sub debugging(;$)
{
    my $level = shift // DEBUG;
    return $debugLevel <= $level;
}

sub setDebugLevel
{
    $debugLevel = shift;
}

sub setLogFile
{
    my $fileName = shift;

    return if pretending();
    open ($screenLog, '>', $fileName) or error ("Unable to open log file $fileName!");
}

# The next few subroutines are used to print output at different importance
# levels to allow for e.g. quiet switches, or verbose switches.  The levels are,
# from least to most important:
# debug, whisper, info (default), note (quiet), warning (very-quiet), and error.
#
# You can also use the pretend output subroutine, which is emitted if, and only
# if pretend mode is enabled.
#
# ksb::Debug::colorize is automatically run on the input for all of those
# functions.  Also, the terminal color is automatically reset to normal as
# well so you don't need to manually add the ] to reset.

# Subroutine used to actually display the data, calls ksb::Debug::colorize on each entry first.
sub print_clr(@)
{
    # Leading + prevents Perl from assuming the plain word "colorize" is actually
    # a filehandle or future reserved word.
    print +colorize($_) foreach (@_);
    print +colorize("]\n");

    if (defined $screenLog) {
        my @savedColors = ($RED, $GREEN, $YELLOW, $NORMAL, $BOLD);
        # Remove color but still extract codes
        ($RED, $GREEN, $YELLOW, $NORMAL, $BOLD) = ("") x 5;

        print ($screenLog colorize($_)) foreach (@_);
        print ($screenLog "\n");

        ($RED, $GREEN, $YELLOW, $NORMAL, $BOLD) = @savedColors;
    }
}

sub debug(@)
{
    print_clr(@_) if debugging;
}

sub whisper(@)
{
    print_clr(@_) if $debugLevel <= WHISPER;
}

sub info(@)
{
    print_clr(@_) if $debugLevel <= INFO;
}

sub note(@)
{
    print_clr(@_) if $debugLevel <= NOTE;
}

sub warning(@)
{
    print_clr(@_) if $debugLevel <= WARNING;
}

sub error(@)
{
    print STDERR (colorize $_) foreach (@_);
    print STDERR (colorize "]\n");
}

sub pretend(@)
{
    print_clr(@_) if pretending();
}

1;