package Template::Multilingual;

use strict;
use base qw(Template);
use Template::Multilingual::Parser;

our $VERSION = '0.02';

sub _init
{
    my ($self, $options) = @_;

    $options->{PARSER} = Template::Multilingual::Parser->new($options);
    $self->{PARSER} = $options->{PARSER};
    $self->SUPER::_init($options)
}
sub language
{
    my $self = shift;
    @_ ? $self->{language} = shift
       : $self->{language};
}
sub process
{
    my ($self, $filename, $vars, @args) = @_;
    $vars ||= {};
    $vars->{language} = $self->{language};
    $self->SUPER::process($filename, $vars, @args);
}

=head1 NAME

Template::Multilingual - Multilingual templates for Template Toolkit

=head1 SYNOPSIS

This subclass of Template Toolkit supports multilingual templates: templates that
contain text in several languages.

    <t>
      <en>Hello!</en>
      <fr>Bonjour !</fr>
    </t>

Then specify the language to use when processing a template:

    use Template::Multilingual;

    my $template = Template::Multilingual->new();
    $template->language('en');
    $template->process('example.ttml');

=head1 METHODS

=head2 language($lcode)

Specify the language to be used when processing the template. Any string that
matches C<\w+> is fine, but we suggest sticking to ISO-639 which provides
2-letter codes for common languages and 3-letter codes for many others.

=head1 AUTHOR

Eric Cholet, C<< <cholet@logilune.com> >>

=head1 BUGS

Multilingual text sections cannot be used inside TT directives.
The following is illegal and will trigger a TT syntax error:

    [% title = "<t><fr>Bonjour</fr><en>Hello</en></t>" %]

Use this instead:

    [% title = BLOCK %]<t><fr>Bonjour</fr><en>Hello</en></t>[% END %]

Please report any bugs or feature requests to
C<bug-template-multilingual@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Multilingual>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

ISO 639-2 Codes for the Representation of Names of Languages:
http://www.loc.gov/standards/iso639-2/langcodes.html

=head1 COPYRIGHT & LICENSE

Copyright 2005 Eric Cholet, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Template::Multilingual
