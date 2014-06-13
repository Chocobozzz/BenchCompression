#
#===============================================================================
#
#         FILE: BenchConfig.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Florian Bigard, florian.bigard@gmail.com
#      VERSION: 0.1
#      CREATED: 19/04/2014 21:23:49
#     REVISION: ---
#===============================================================================

package BenchConfig;

use strict;
use warnings;

use Carp;
use YAML::AppConfig;

# Constructor
# @param yaml YAML::AppConfig object
sub new {
    my ( $class, $args ) = @_;

    $class = ref($class) || $class;

    my $this = {};

    bless( $this, $class );

    for my $attr (qw/ yaml /) {
        unless ( defined $args->{$attr} ) {
            croak("[Warning] $attr attribute is missing\n");
        }
    }

    my $config = YAML::AppConfig->new( file => $args->{yaml} );

    $this->{FILES} = $config->get_to_test
      || croak("[Warning] to_test is missing in the configuration file\n");
    $this->{COMPRESSION_METHODS} = $config->get_compressions
      || croak("[Warning] compressions is missing in the configuration file\n");
    $this->{OUTPUT_DIR} = $config->get_outdir || "res/";

    mkdir $this->{OUTPUT_DIR} if not -d $this->{OUTPUT_DIR};

    return $this;
}

# Get files to test
sub getFiles {
    my $this = shift;

    return @{ $this->{FILES} };
}

# Get the dir where to put compressed entries
sub getOutputDir {
    my $this = shift;

    return $this->{OUTPUT_DIR};
}

# Get an array of compression methods
sub getCompressionMethods {
    my $this = shift;

    return keys( %{ $this->{COMPRESSION_METHODS} } );
}

# Get the command according to a compression method
sub getCommand {
    my ( $this, $compression ) = @_;

    unless ( defined($compression) ) {
        croak("[Warning] compression param is missing\n");
    }

    return $this->{COMPRESSION_METHODS}{$compression}{command};
}

# Get the extension of the outfile according to a compression method
sub getOutExtension {
    my ( $this, $compression ) = @_;

    unless ( defined($compression) ) {
        croak("[Warning] compression param is missing\n");
    }

    return $this->{COMPRESSION_METHODS}{$compression}{out};
}

# Get path of the output according to an infile and a compression method
sub getOutput {
    my ( $this, $infile, $compression ) = @_;

    croak("[Warning] infile param is missing\n") unless ( defined($infile) );
    croak("[Warning] compression param is missing\n")
      unless ( defined($compression) );

    return $this->{OUTPUT_DIR} . "/" . $infile . "."
      . $this->getOutExtension($compression);
}

1;

__END__

