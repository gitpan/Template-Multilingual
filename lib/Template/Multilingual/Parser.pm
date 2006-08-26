package Template::Multilingual::Parser;

use strict;
use base qw(Template::Parser);

our $VERSION = '0.07';

sub new
{
    my ($class, $options) = @_;
    my $self = $class->SUPER::new($options);
    $self->{_sections} = [];
    $self->{_langvar} = $options->{LANGUAGE_VAR} || 'language';

    my $style = $self->{ STYLE }->[-1];
    @$self{ qw(_start _end) } = @$style{ qw( START_TAG END_TAG  ) };
    for (qw( _start _end )) {
        $self->{$_} =~ s/\\([^\\])/$1/g;
    }

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
        if ($section->{nolang}) {
            $text .= $section->{nolang};
        }
        elsif (my $t = $section->{lang}) {
            $text .= "$self->{_start} SWITCH $self->{_langvar} $self->{_end}";
            for my $lang (keys %$t) {
                $text .= "$self->{_start} CASE '$lang' $self->{_end}" . $t->{$lang};
            }
            $text .= "$self->{_start} END $self->{_end}";
        }
    }
    return $self->SUPER::parse ($text);
}

sub _tokenize
{
    my ($self, $text) = @_;

    # extract all sections from the text
    $self->{_sections} = [];
    my @tokens = split m!<t>(.*?)</t>!s, $text;
    my $i = 0;
    for my $t (@tokens) {
        if ($i) {             # <t>...</t> multilingual section
            my %section;
            while ($t =~ m!<(\w+)>(.*?)</\1>!gs) {
                $section{$1} = $2;
            }
            push @{$self->{_sections}}, { lang => \%section }
                if %section;
        }
        else {                # bare text
            push @{$self->{_sections}}, { nolang => $t } if $t;
        }
        $i = 1 - $i;
    }
}
sub sections { $_[0]->{_sections} }

=head1 NAME

Template::Multilingual::Parser - Multilingual template parser

=head1 SYNOPSIS

    use Template;
    use Template::Multilingual::Parser;
  
    my $parser = Template::Multilingual::Parser->new();
    my $template = Template->new(PARSER => $parser);
    $template->process('example.ttml', { language => 'en'});

=head1 DESCRIPTION

This subclass of Template Toolkit's C<Template::Parser> parses multilingual
templates: templates that contain text in several languages.

    <t>
      <en>Hello!</en>
      <fr>Bonjour !</fr>
    </t>

Use this module directly if you have subclassed C<Template>, otherwise you
may find it easier to use C<Template::Multilingual>.

Language codes can be any string that matches C<\w+>, but we suggest
sticking to ISO-639 which provides 2-letter codes for common languages
and 3-letter codes for many others.

=head1 METHODS

=head2 new(\%params)

The new() constructor creates and returns a reference to a new
parser object. A reference to a hash may be supplied as a
parameter to provide configuration values.

Parser objects are typically provided as the C<PARSER> option
to the C<Template> constructor.

Configuration values are all valid C<Template::Parser> superclass
options, and one specific to this class:

=over

=item LANGUAGE_VAR

The LANGUAGE_VAR option can be used to set the name of the template
variable which contains the current language. Defaults to
I<language>.

  my $parser = Template::Multilingual::Parser->new({
     LANGUAGE_VAR => 'global.language',
  });

You will need to set this variable with the current language value
at request time, usually in your C<Template> subclass' C<process()>
method.

=back

=head2 parse($text)

parse() is called by the Template Toolkit. It parses multilingual
sections from the input text and translates them to Template Toolkit
directives. The result is then passed to the C<Template::Parser> superclass.

=head2 sections

Returns a reference to an array of tokenized sections. Each section is a
reference to hash with either a C<nolang> key or a C<lang> key.

A C<nolang> key denotes text outside of any multilingual sections. The value
is the text itself.

A C<lang> key denotes text inside a multilingual section. The value is a
reference to a hash, whose keys are language codes and values the corresponding
text. For example, the following multilingual template:

  foo <t><fr>bonjour</fr><en>Hello</en></t> bar

will parse to the following sections:

  [ { nolang => 'foo ' },
    {   lang => { fr => 'bonjour', en => 'hello' } },
    { nolang => ' bar' },
  ]

=head1 BUGS

Multilingual text sections cannot be used inside TT directives.
The following is illegal and will trigger a TT syntax error:

    [% title = "<t><fr>Bonjour</fr><en>Hello</en></t>" %]

Use this instead:

    [% title = BLOCK %]<t><fr>Bonjour</fr><en>Hello</en></t>[% END %]


The TAG_STYLE, START_TAG and END_TAG directives are supported, but the
TAGS directive is not.

Please report any bugs or feature requests to
C<bug-template-multilingual@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Multilingual>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

L<Template::Multilingual>

ISO 639-2 Codes for the Representation of Names of Languages:
http://www.loc.gov/standards/iso639-2/langcodes.html

=head1 COPYRIGHT & LICENSE

Copyright 2005 Eric Cholet, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Template::Multilingual::Parser
