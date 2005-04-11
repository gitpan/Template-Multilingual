#!perl -w

use strict;

my @templates = (
    { in  => '',
      out => '',
      sections => [ ],
    },
    { in  => 'foo',
      out => 'foo',
      sections => [ { text => 'foo' } ],
    },
    { in  => '<t></t>',
      out => '',
      sections => [ ],
    },
    {
      in  => '<t><fr>foo</fr></t>',
      out => 'foo',
      sections => [ { text => '<fr>foo</fr>', lang => 1 } ],
    },
    {
      in  => '<t><en>foo</en></t>',
      out => '',
      sections => [ { text => '<en>foo</en>', lang => 1 } ],
    },
    {
      in  => "<t><fr>foo</fr>\n<en>bar</en></t>",
      out => "foo\n",
      sections => [ { text => "<fr>foo</fr>\n<en>bar</en>", lang => 1 } ],
    },
    {
      lang =>'en',
      in  => '<t><fr>foo</fr></t>',
      out => '',
      sections => [ { text => '<fr>foo</fr>', lang => 1 } ],
    },
    {
      lang => 'en',
      in  => '<t><en>foo</en></t>',
      out => 'foo',
      sections => [ { text => '<en>foo</en>', lang => 1 } ],
    },
    {
      lang => 'eng',
      in  => "<t><fra>foo</fra>\n<eng>bar</eng></t>",
      out => 'bar',
      sections => [ { text => "<fra>foo</fra>\n<eng>bar</eng>", lang => 1 } ],
    },
    {
      in => "[% SWITCH language; CASE 'en'; 'foo'; CASE 'fr'; 'bar'; END %]",
      out =>'bar',
      sections => [ { text => "[% SWITCH language; CASE 'en'; 'foo'; CASE 'fr'; 'bar'; END %]" } ],
    },
    { # sections
      in  => "A<t><fr>foo</fr></t>B<t><en>bar</en></t>C",
      out => 'AfooBC',
      sections => [ { text => 'A' },
                    { text => '<fr>foo</fr>', lang => 1 },
                    { text => 'B' },
                    { text => '<en>bar</en>', lang => 1 },
                    { text => 'C' },
                  ],
    },
);
use Test::More;
plan tests => 2 + 4 * @templates;

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

__END__
