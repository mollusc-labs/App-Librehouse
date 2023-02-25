use v6.d;
use Slang::SQL;
use Monad::Result;

use App::Librehouse::Database;

unit module App::Librehouse::Service;

my $*DB = get-db;

sub find-user(Str:D $id --> Map:D) {
    return exec-sql(sql select * from usr where usr.id = ?; with ($id));
}
