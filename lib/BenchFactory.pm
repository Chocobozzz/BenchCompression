#
#===============================================================================
#
#         FILE: BenchFactory.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Florian Bigard, florian.bigard@gmail.com
#      VERSION: 0.1
#      CREATED: 19/04/2014 22:10:42
#     REVISION: ---
#===============================================================================

package BenchFactory;

use strict;
use warnings;

use Carp;

use BenchData;

sub new {
    my ( $class, $args ) = @_;

    $class = ref($class) || $class;

    my $this = {};

    bless( $this, $class );

    for my $attr (qw/ config_bench /) {
        unless ( defined $args->{$attr} ) {
            croak("[Warning] $attr attribute is missing\n");
        }
    }

    $this->{_CONFIG_BENCH} = $args->{config_bench};
    $this->{BENCHS_DATA}   = [];

    return $this;
}

# Construct the command according to the config command, the infile and the outfile
my $p_computeCommand = sub {
    my ( $this, $command, $infile, $outfile ) = @_;

    $command =~ s/:outfile:/$outfile/g;
    $command =~ s/:infile:/$infile/g;

    return $command;
};

# Execute a command shell and return the execution time (s)
my $p_executeCommand = sub {
    my ( $this, $command ) = @_;

    my $begin = time;
    `$command`;
    my $execution_time = int( ( time - $begin ) * 1000 );

    return $execution_time;
};

# Get size of dir
my $p_dirsize;
$p_dirsize = sub {
    my ( $this, $dir ) = @_;
    my $dir_size = 0;

    return ( stat($dir) )[7] if -f $dir;

    for ( <$dir/*>, <$dir/.*> ) {
        next if (/\/.{1,2}$/);

        if (-f) {
            my $size = ( stat($_) )[7];
            $dir_size += $size;
        }
        elsif (-d) {
            $dir_size += $this->$p_dirsize($_);
        }
    }

    return $dir_size;
};

# Benchs executions
sub exec {
    my ($this) = shift;

    # For all files/dir to compress
    for my $infile ( $this->{_CONFIG_BENCH}->getFiles ) {

        my $bench_data = new BenchData( { infile => $infile } );

        # For all compression method
        for my $compression ( $this->{_CONFIG_BENCH}->getCompressionMethods ) {
            my $outfile =
              $this->{_CONFIG_BENCH}->getOutput( $infile, $compression );

            # Construct the shell command
            my $command =
              $this->$p_computeCommand(
                $this->{_CONFIG_BENCH}->getCommand($compression),
                $infile, $outfile );

            # Execution of the program
            my $execution_time = $this->$p_executeCommand($command);

            # Add bench
            $bench_data->addBench(
                {
                    outfile            => $outfile,
                    compression_method => $compression,
                    execution_time     => $execution_time,
                    sizefile           => {
                        before => $this->$p_dirsize($infile),
                        after  => $this->$p_dirsize($outfile)
                    }
                }
            );
        }

        # Add the new bench of the file
        push @{ $this->{BENCHS_DATA} }, $bench_data;
    }
}

# Return an array of benchs data
sub getResults {
    my $this = shift;

    return @{ $this->{BENCHS_DATA} };
}

1;

__END__

