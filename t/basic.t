#!perl -w

use strict;

my @templates = (
    { in  => '',
      out => '',
      sections => [ ],
    },
    { in  => 'foo',
      out => 'foo',
      sections => [ { nolang => 'foo' } ],
    },
    { in  => '<t></t>',
      out => '',
      sections => [ ],
    },
    {
      in  => '<t><fr>foo</fr></t>',
      out => 'foo',
      sections => [ { lang => { fr => 'foo' } } ],
    },
    {
      in  => '<t><en>foo</en></t>',
      out => '',
      sections => [ { lang => { en => 'foo' } } ],
    },
    {
      in  => "<t><fr>foo</fr>\n<en>bar</en></t>",
      out => "foo",
      sections => [ { lang => { fr => 'foo', en => 'bar' } } ],
    },
    {
      lang =>'en',
      in  => '<t><fr>foo</fr></t>',
      out => '',
      sections => [ { lang => { fr => 'foo' } } ],
    },
    {
      lang => 'en',
      in  => '<t><en>foo</en></t>',
      out => 'foo',
      sections => [ { lang => { en => 'foo' } } ],
    },
    {
      lang => 'eng',
      in  => "<t><fra>foo</fra>\n<eng>bar</eng></t>",
      out => 'bar',
      sections => [ { lang => { fra => 'foo', eng => 'bar' } } ],
    },
    { # sections
      in  => "A<t><fr>foo</fr></t>B<t><en>bar</en></t>C",
      out => 'AfooBC',
      sections => [ { nolang => 'A' },
                    {   lang => { fr => 'foo' } },
                    { nolang => 'B' },
                    {   lang => { en => 'bar' } },
                    { nolang => 'C' },
                  ],
    },
);
use Test::More;
plan tests => 3 + 7 * @templates;

require_ok('Template::Multilingual');
my $template = Template::Multilingual->new;
ok($template);

for my $t (@templates) {
    my $lang = $t->{lang} || 'fr';
    $template->language($lang);
    is($template->language, $lang, "get/set language");
    my $output;
    ok($template->process(\$t->{in}, {}, \$output), 'process');
    is($output, $t->{out}, 'output');
    is_deeply($template->{PARSER}->sections, $t->{sections}, 'sections');
}

$template = Template::Multilingual->new(LANGUAGE_VAR => 'global.language');
ok($template);

for my $t (@templates) {
    my $lang = $t->{lang} || 'fr';
    my $output;
    ok($template->process(\$t->{in}, { global => { language => $lang }}, \$output), 'process');
    is($output, $t->{out}, 'output');
    is_deeply($template->{PARSER}->sections, $t->{sections}, 'sections');
}

__END__
