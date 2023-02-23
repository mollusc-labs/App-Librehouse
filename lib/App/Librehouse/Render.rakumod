use v6.d;

use Template6;

unit class App::Librehouse::Render is export;

constant $templater = Template6.new;

$templater.add-path: 'templates';

submethod CALL-ME(Str:D $tmpl, Str:D $title, *%args) {
    %args<scripts>.push: 'librehouse.js';
    %args<styles>.push:  'librehouse.css';
    
    $templater.process: $tmpl, :$title, |%args;
}
