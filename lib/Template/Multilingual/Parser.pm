package Template::Multilingual::Parser;

use strict;
use base qw(Template::Parser);
use constant LANG_RE => qr{<(\w+)>(.*?)</\1>}s;

our $VERSION = '0.03';

sub new
{
    my ($class, $options) = @_;
    my $self = $class->SUPER::new($options);
    $self->{_sections} = [];
    $self->{_langvar} = $options->{LANGUAGE_VAR} || 'language';
    return $self;
}

sub parse
{
    my ($self, $text) = @_;

    # isolate multilingual sections
    $self->_tokenize($text);

    # replace multilingual sections with TT directives
    $text = '';
    for my $section (@{$self->{_sections}}) {
        my $translated = $section->{text};
        if ($section->{lang}) {
            $translated =~ s/@{[LANG_RE]}/\[% CASE '$1' %\]$2/gs;
            $text .= "[% SWITCH $self->{_langvar} %]".$translated.'[% END %]';
        }
        else {
            $text .= $translated;
        }
    }
    return $self->SUPER::parse ($text);
}

sub _tokenize
{
    my ($self, $text) = @_;

    # extract all sections from the text
    $self->{_sections} = [];
    while ($text =~ s!
           ^(.*?)             # $1 - start of line up to start tag
            (?:
                <t>           # start of tag
                (.*?)         # $2 - tag contents
                </t>          # end of tag
            )
            !!sx
          )
    {
        push @{$self->{_sections}}, { text => $1 } if $1;
        push @{$self->{_sections}}, { lang => 1, text => $2 }
            if $2;
    }
    push @{$self->{_sections}}, { text => $text } if $text;
}
sub sections { $_[0]->{_sections} }

1;

__END__

=head1 SYNOPSIS

    use Template;
    use Template::Multilingual::Parser;
  
    my $parser = Template::Multilingual::Parser->new();
    my $template = Template->new(PARSER => $parser);
    $template->process('example.ttml', { language => 'en'});

=head1 NAME

Template::Multilingual::Parser - Multilingual template parser

=head1 DESCRIPTION

A subclass of L<Template::Parser> that parses multilingual text
sections. This module is used internally by L<Template::Multilingual>.

=head1 METHODS

=head2 new(\%params)

The new() constructor creates and returns a reference to a new
parser object. A reference to a hash may be supplied as a
parameter to provide configuration values.

Configuration values are all valid L<Template::Parser> superclass
options, and one specific to this class:

=over

=item LANGUAGE_VAR

The LANGUAGE_VAR option can be used to set the name of the template
variable which contains the current language. Defaults to
I<language>.

  my $parser = Template::Multilingual::Parser->new({
     LANGUAGE_VAR => 'global.language',
  });

=back

=head2 parse($text)

The parse() method parses multilingual sections from the input
text and translates them to Template Toolkit directives. The
result is then passed to the L<Template::Parser> superclass.

=cut
