use v6.d;

use DBIish;

unit module App::Librehouse::Database;

our $*DB;

sub initialize-database is export {
    $*DB = DBIish.connect('Pg',
                          :host<localhost>,
                          :port(5432),
                          :database<librehouse>,
                          user => %*ENV<POSTGRES_USER>,
                          password => %*ENV<POSTGRES_PASSWORD>);
}

sub perform-query(&query) is export {
    &query();    
}
