#
#===============================================================================
#
#         FILE: BenchData.pm
#
#  DESCRIPTION: Data after compressions of infile
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Florian Bigard, florian.bigard@gmail.com
#      VERSION: 0.1
#      CREATED: 19/04/2014 22:26:59
#     REVISION: ---
#===============================================================================

package BenchData;

use strict;
use warnings;

use Carp;

# Constructor,
# @param infile File/dir to test
sub new {
    my ( $class, $args ) = @_;

    $class = ref($class) || $class;

    my $this = {};

    bless( $this, $class );

    for my $attr (qw/ infile /) {
        unless ( defined $args->{$attr} ) {
            croak("[Warning] $attr attribute is missing\n");
        }
    }

    $this->{_INFILE} = $args->{infile};
    $this->{BENCHS}  = [];

    return $this;
}

# Add compression result
# @param outfile File/dir after compression
# @param compression Name of the compression method
# @param execution_time Execution time of the compression
# @param sizefile Hash which contains :
#      - before Size before compression
#      - after Size after compression
sub addBench {
    my ( $this, $args ) = @_;

    for my $attr (qw/ outfile compression_method execution_time sizefile /) {
        unless ( defined $args->{$attr} ) {
            croak("[Warning] $attr attribute is missing\n");
        }
    }

    push @{ $this->{BENCHS} },
      {
        outfile            => $args->{outfile},
        compression_method => $args->{compression_method},
        execution_time     => $args->{execution_time},
        sizefile           => {
            before => $args->{sizefile}->{before},
            after  => $args->{sizefile}->{after}
        }
      };


    return;
}

sub getInfile {
    my $this = shift;

    return $this->{_INFILE};
}

sub getBenchs {
    my ($this) = shift;

    return $this->{BENCHS};
}

# Get info from all the benchs (compression_method, sizefile...)
my $p_getBenchsInfos = sub {
    my ( $this, $info ) = @_;

    croak("[Warning] info param is missing\n") unless ( defined $info );

    my @infos = ();

    for ( @{ $this->{BENCHS} } ) {
        push @infos, $_->{$info};
    }

    return @infos;
};

# Get an array of the compression methods
sub getCompressionMethods {
    my ($this) = shift;

    return $this->$p_getBenchsInfos("compression_method");
}

# Get hash sizefile
sub getSizefiles {
    my $this = shift;

    return $this->$p_getBenchsInfos("sizefile");
}

# Get an array of the reduction of the files (kb)
sub getSizefilesReduced {
    my $this = shift;

    my @sizefiles = ();

    for my $bench ( @{ $this->{BENCH} } ) {
        push @sizefiles,
          int (( $bench->{sizefile}{after} - $bench->{sizefile}{before} ) / 1000);
    }

    return @sizefiles;
}

# Get an array of sizefiles before compression (kb)
sub getSizefilesBefore {
    my $this = shift;

    my @sizefiles = ();

    for my $bench ( @{ $this->{BENCHS} } ) {
        push @sizefiles, int($bench->{sizefile}{before} / 1000);
    }

    return @sizefiles;
}

# Get an array of sizefiles after compression (kb)
sub getSizefilesAfter {
    my $this = shift;

    my @sizefiles = ();

    for my $bench ( @{ $this->{BENCHS} } ) {
        push @sizefiles, int($bench->{sizefile}{after} / 1000);
    }

    return @sizefiles;
}

# Get an array of path of outfiles
sub getOutfiles {
    my $this = shift;

    return $this->$p_getBenchsInfos("outfile");
}

# Get an array of execution times
sub getExecutionTimes {
    my $this = shift;

    return map { $_ = int($_) } $this->$p_getBenchsInfos("execution_time");
}

# Get an array of efficiencies (size reduced / execution time)
sub getEfficiencies {
    my $this = shift;

    my @efficiencies = ();

    for my $bench ( @{ $this->{BENCHS} } ) {
        my $coeff = ($bench->{sizefile}{before} - $bench->{sizefile}{after})/1000;

        if ( $bench->{execution_time} != 0 ) {
            $coeff /= $bench->{execution_time};
        }

        push @efficiencies, int($coeff);
    }

    return @efficiencies;
}

