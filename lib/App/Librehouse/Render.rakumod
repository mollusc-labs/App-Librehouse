use v6.d;
use strict;

use Template::Mustache;

unit class App::Librehouse::Render;

my $templater = Template::Mustache.new(:from('templates'));

submethod CALL-ME(Str:D $tmpl, Str:D $title, *%args --> Str:D) {
    %args<scripts>.push: 'librehouse.js';
    %args<styles>.push:  'librehouse.css';
    %args<render-date> = ~DateTime.now.utc;
    %args<os> = "$*DISTRO $*KERNEL";

    # Hacks
    %args<meta> = Hash.new without %args<meta>;
    %args<toast> = Nil without %args<toast>;

    $templater.render($tmpl, { :$title, |%args });
}

sub render(Str:D $tmpl, Str:D $title, *%args) is export(:subs) {
    App::Librehouse::Render($tmpl, $title, |%args);
}
