#
#===============================================================================
#
#         FILE: BenchPrintGraph.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Florian Bigard, florian.bigard@gmail.com
#      VERSION: 0.1
#      CREATED: 19/04/2014 23:13:03
#     REVISION: ---
#===============================================================================

package BenchPrintGraph;

use strict;
use warnings;
 
use Carp;

use BenchData;

use GD::Graph::bars;
use Data::Dumper;

# Constructor,
sub new {
    my ($class, $args) = @_;

    $class = ref($class) || $class;

    my $this = {};

    bless ($this, $class);

    if(defined ($args->{bench_data})){
        $this->{BENCH_DATA} = $args->{bench_data};
    }
    
    return $this;
}

# Get the bench data to print
sub getBenchData {
    my $this = shift;

    return $this->{BENCH_DATA};
}

# Set the bench data to print
sub setBenchData {
    my ($this, $bench_data) = @_;

    if(defined($bench_data)) {
        $this->{BENCH_DATA} = $bench_data;
    }

    return;
}

# Create a graph
my $p_printResult = sub {
    my ( $this, $graph_config ) = @_;

    # Get data (axis)
    my @data = ( $graph_config->{axis}{horizontal}{data}, $graph_config->{axis}{vertical}{data} );

    # Get the maxval of the vertical axis
    my $max_val = (sort ( { $b <=> $a } @{ $graph_config->{axis}{vertical}{data} } ))[0];

    # Construct a new bar chart
    my $graph = GD::Graph::bars->new( 500, 400 );

    # Set the graph
    $graph->set(
        x_label      => $graph_config->{axis}{horizontal}{title},
        y_label      => $graph_config->{axis}{vertical}{title},
        title        => $graph_config->{title},
        y_max_value  => $max_val + $max_val / 10,
        y_label_skip => 2,
        y_tick_number => 8,
        transparent  => 0
    ) or die $graph->error;

    # Open the image, write and close
    open( my $img, ">", $graph_config->{filename} ) or die $!;
    binmode $img;

    print $img $graph->plot( \@data )->png;

    close $img;

    return;
};


# According to the execution time
sub benchByTime {
    my ($this, $filename) = @_;

    $this->$p_printResult({
        axis => { 
            horizontal => {
                title => "Compression",
                data => [ $this->{BENCH_DATA}->getCompressionMethods ]
            }, 
            vertical => {
                title => "Execution time (ms)",
                data => [ $this->{BENCH_DATA}->getExecutionTimes ]
            } 
        },
        filename => $filename,
        title => "Bench on " . $this->{BENCH_DATA}->getInfile . " (execution time)"
    });
}


# According to the sizefile after compression
sub benchBySizeAfter {
    my ($this, $filename) = @_;
 
    $this->$p_printResult({
        axis => { 
            horizontal => {
                title => "Compression",
                data => [ $this->{BENCH_DATA}->getCompressionMethods ]
            }, 
            vertical => {
                title => "kb",
                data => [ $this->{BENCH_DATA}->getSizefilesAfter ]
            } 
        },
        filename => $filename,
        title => "Bench on " . $this->{BENCH_DATA}->getInfile . " (size after compression)"
    });
}


# According to the size reduced
sub benchBySizeReduced {
    my ($this, $filename) = @_;
    
    my @before = $this->{BENCH_DATA}->getSizefilesBefore;
    my @after = $this->{BENCH_DATA}->getSizefilesAfter;
    my @reduced = ();

    for (my $i = 0; $i < @after; $i++) {
        $reduced[$i] = $before[$i] - $after[$i];
    }
    

    $this->$p_printResult({
        axis => { 
            horizontal => {
                title => "Compression",
                data => [ $this->{BENCH_DATA}->getCompressionMethods ]
            }, 
            vertical => {
                title => "kb reduced",
                data => \@reduced
            } 
        },
        filename => $filename,
        title => "Bench on " . $this->{BENCH_DATA}->getInfile . " (size reduced after compression)"
    });

}

# According to the efficiency
sub benchByEfficiency {
    my ($this, $filename) = @_;

    $this->$p_printResult({
        axis => { 
            horizontal => {
                title => "Compression",
                data => [ $this->{BENCH_DATA}->getCompressionMethods ]
            }, 
            vertical => {
                title => "Efficiency (kb reduced per ms)",
                data => [ $this->{BENCH_DATA}->getEfficiencies ]
            } 
        },
        filename => $filename,
        title => "Bench on " . $this->{BENCH_DATA}->getInfile . " (efficiency)"
    });
}

