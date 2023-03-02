use v6.d;
use strict;

use Template6;

unit class App::Librehouse::Render is export;

constant $templater = Template6.new;

$templater.add-path: 'templates';

submethod CALL-ME(Str:D $tmpl, Str:D $title, *%args) {
    %args<scripts>.push: 'librehouse.js';
    %args<styles>.push:  'librehouse.css';
    %args<render-date> = DateTime.now.utc;
    %args<os> = "$*DISTRO $*KERNEL";

    # Hacks
    %args<meta> = Hash.new without %args<meta>;
    %args<toast> = Nil without %args<toast>;

    $templater.process: $tmpl, :$title, |%args;
}

sub render(Str:D $tmpl, Str:D $title, *%args) is export(:subs) {
    App::Librehouse::Render($tmpl, $title, |%args);
}
