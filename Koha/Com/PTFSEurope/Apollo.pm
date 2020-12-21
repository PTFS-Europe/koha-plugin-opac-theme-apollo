package Koha::Plugin::Com::PTFSEurope::Apollo;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

use JavaScript::Minifier qw(minify);

## Here we set our plugin version
our $VERSION         = "{VERSION}";
our $MINIMUM_VERSION = "{MINIMUM_VERSION}";

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'Apollo Theme',
    author          => 'Martin Renvoize',
    date_authored   => '2020-12-18',
    date_updated    => "1900-01-01",
    minimum_version => $MINIMUM_VERSION,
    maximum_version => undef,
    version         => $VERSION,
    description     => 'The Apollo theme by PTFS Europe'
};

sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

sub install {
    my ( $self, $args ) = @_;

    return 1;
}

sub uninstall {
    my ( $self, $args ) = @_;

    return 1;
}

sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    unless ( $cgi->param('save') ) {
        my $template = $self->get_template( { file => 'configure.tt' } );

        $template->param( enable => $self->retrieve_data('enable'), );

        $self->output_html( $template->output() );
    }
    else {
        $self->store_data(
            {
                enable => $cgi->param('enable'),
            }
        );
        $self->build_js();
        $self->build_css();
        $self->go_home();
    }
}

sub build_js {
    my ( $self, $data ) = @_;

    my $template = $self->get_template( { file => 'apollojs.tt' } );
    $template->param(%$data);

    my $apollo_js = $template->output();

    #$apollo_js = minify( input => $apollo_js );
    $self->store_data( { apollo_js => $apollo_js } );
}

sub build_css {
    my ( $self, $data ) = @_;

    my $template = $self->get_template( { file => 'apollocss.tt' } );
    $template->param(%$data);

    my $apollo_css = $template->output();

    #$apollo_css = minify( input => $apollo_css );
    $self->store_data( { apollo_css => $apollo_css } );
}

sub opac_js {
    my ($self) = @_;
    my $js = $self->retrieve_data('apollo_js');
    return "<script>" . $js . "</script>" if $js;
}

sub opac_head {
    my ($self) = @_;
    my $css = $self->retrieve_data('apollo_css') // "";
    return "<style>" . $css . "</style>" if $css;
}

1;
