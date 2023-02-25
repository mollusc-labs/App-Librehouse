use v6.d;

use App::Librehouse::Service;
use App::Librehouse::Render;

use Humming-Bird::Core;
use Humming-Bird::Middleware;
use Humming-Bird::Advice;

unit module App::Librehouse;

advice(&advice-logger);

sub index-handler(Request:D $request, Response:D $response) {
    $response.html(App::Librehouse::Render('index', 'Librehouse.net', foo => 'bar'));
}

get('/', &index-handler, [ &middleware-logger ]);

our sub start(Int:D $port) is export {
    listen($port);
}
