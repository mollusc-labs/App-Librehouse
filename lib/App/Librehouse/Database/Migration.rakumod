use v6.d;

unit class App::Librehouse::Database::Migration is export;

my @used_ids;

has $.id is required;
has &.up is required;
has &.down is required;

method TWEAK {
    die "Your id is aleady in use" if @used_ids.first: * eq $!id;
    @used_ids.push($!id);
}

