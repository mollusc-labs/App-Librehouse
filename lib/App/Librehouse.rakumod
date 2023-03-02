use v6.d;

use App::Librehouse::Service;
use App::Librehouse::Render;
use App::Librehouse::Csrf;

use Humming-Bird::Core;
use Humming-Bird::Middleware;
use Humming-Bird::Advice;

unit module App::Librehouse;

advice(&advice-logger);

my $router = Router.new(root => '/');
$router.middleware(&middleware-logger);

sub index-handler(Request:D $request, Response:D $response) {
    $response.html(App::Librehouse::Render('index', 'Librehouse.net'));
}
$router.get(&index-handler);

sub login-index-handler(Request:D $request, Response:D $response) {
    my $csrf = await csrf-token;
    $response.html(App::Librehouse::Render('login', 'Login', :$csrf));
}
$router.get('/login', &login-index-handler);

sub login-handler(Request:D $request, Response:D $response) {
    $response.html('TODO: Decode URL-Encoded!');
}
$router.post('/login', &login-handler);

sub signup-index-handler(Request:D $request, Response:D $response) {
    my $csrf = await csrf-token;
    $response.html(App::Librehouse::Render('signup', 'Sign-Up', :$csrf));
}
$router.get('/signup', &signup-index-handler);

sub signup-handler(Request:D $request, Response:D $response) {
    say 'TODO: Implement sign up';
    $response.redirect('/login', :permanent, method => GET);
}
$router.post('/signup', &signup-handler);

our sub start(Int:D $port) is export {
    start-csrf-service;
    listen($port);
}
