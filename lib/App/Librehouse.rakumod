use v6.d;

use App::Librehouse::Service;
use App::Librehouse::Render;
use App::Librehouse::Csrf;
use App::Librehouse::Util;

use Humming-Bird::Core;
use Humming-Bird::Middleware;
use Humming-Bird::Advice;

unit module App::Librehouse;

advice(&advice-logger);

my $router = Router.new(root => '/');

# Blocks post requests without a CSRF
sub csrf-middleware(Request:D $request, Response:D $response, &next) {
    say $request.content.raku;
    return &next() if $request.method !== POST;
    return $response.status(400).html('<h1>400 Bad Request</h1>') without $request.content.<csrf>;

    react {
        whenever validate-token($request.content.<csrf>) {
            return $response.html('<h1>400 Bad Request</h1>') unless (.key eq $request.content.<csrf>) && .value;
            &next();
        }

        # Very generous 5 second wait
        whenever Promise.in(5) {
            return $response.html('<h1>400 Bad Request</h1>');
        }
    }
}

$router.middleware(&middleware-logger);
$router.middleware(&csrf-middleware);

sub index-handler(Request:D $request, Response:D $response) {
    $response.html(App::Librehouse::Render('index', 'Librehouse.net'));
}
$router.get(&index-handler);

sub login-index-handler(Request:D $request, Response:D $response) {
    my $csrf = await csrf-token;
    my $toast = $request.query('toast');
    $response.html(App::Librehouse::Render('login', 'Login', :$csrf, :$toast));
}
$router.get('/login', &login-index-handler);

sub login-handler(Request:D $request, Response:D $response) {
    say 'TODO: Implement login';

    $response.redirect('/');
}
$router.post('/login', &login-handler);

sub signup-index-handler(Request:D $request, Response:D $response) {
    my $csrf = await csrf-token;
    $response.html(App::Librehouse::Render('signup', 'Sign-Up', :$csrf));
}
$router.get('/signup', &signup-index-handler);

sub signup-handler(Request:D $request, Response:D $response) {
    say 'TODO: Implement sign up';
    $response.redirect('/login?toast=success');
}
$router.post('/signup', &signup-handler);

our sub start(Int:D $port) is export {
    start-csrf-service;
    listen($port);
}
