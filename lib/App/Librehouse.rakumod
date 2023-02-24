use v6.d;
use MONKEY-TYPING;

#use App::Librehouse::Service;
use App::Librehouse::Database;
use App::Librehouse::Render;
use Humming-Bird::Core;
use Humming-Bird::Middleware;
use Humming-Bird::Advice;

unit module App::Librehouse;

sub index-handler(Request:D $request, Response:D $response) {
    $response.html(App::Librehouse::Render('index', 'Librehouse.net', foo => 'bar'));
}

get('/', &index-handler, [ &middleware-logger ]);

advice(&advice-logger);

our sub start(Int:D $port) is export {
    initialize-database;
    listen($port);
}
