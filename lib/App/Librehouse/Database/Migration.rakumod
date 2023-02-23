use v6.d;
use SQL::Slang;

unit module App::Librehouse::Database::Migration;

our class Migration {
    has $.Up;
    has $.Down;
}
