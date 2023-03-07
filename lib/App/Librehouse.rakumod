use v6.d;

use Humming-Bird::Core;
use Humming-Bird::Middleware;
use Humming-Bird::Advice;
use Monad::Result;

use App::Librehouse::Service;
use App::Librehouse::Render;
use App::Librehouse::Csrf;
use App::Librehouse::Util;

unit module App::Librehouse;

advice(&advice-logger);

my $router = Router.new(root => '/');

# Blocks post requests without a CSRF
sub csrf-middleware(Request:D $request, Response:D $response, &next) {
    return &next() if $request.method !== POST;
    return $response.status(400).html('<h1>400 Bad Request</h1>') without $request.content.<csrf>;
    
    if validate-token($request.content.<csrf>) {
        &next();
    } else {
        $response.status(400).html('<h1>400 Bad Request</h1>');
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
    given login($request.content) {
        when Monad::Result::Ok:D {
            # User is logged in.
            $response.redirect('/');
        }

        when Monad::Result::Error:D {
            my %errors = .value;
            # If there are any errors logging the user in
            my $csrf = await csrf-token;
            say %errors.raku;
            $response.html(App::Librehouse::Render('login', 'Login', :$csrf, :%errors));
        }
    }
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
