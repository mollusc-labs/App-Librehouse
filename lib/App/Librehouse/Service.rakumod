use v6.d;

use Monad::Result :subs;
use Digest::SHA2;

use App::Librehouse::Database;

unit module App::Librehouse::Service;

# Example of a find
sub find-user(Str:D $id --> Monad::Result:D) is export {
    exec-sql('SELECT * FROM usr WHERE id = ?', $id);
}

sub find-user-by-name-and-password(Str:D $name, Str:D $password --> Monad::Result:D) {
    my $password-hash = sha256($password);
    find-one(q:to/SQL/, $name, $password-hash);
    SELECT * FROM usr
    WHERE name = ? AND password = ?
    SQL
}

sub validate-user(%user --> Map:D) {
    my %errors;
    %errors;
}

# Logs the user in
sub login(%content --> Monad::Result:D) is export {
    given %content {
        when :(:$name, :$password) {
            return ok(Nil);
        }
        default {
            return error(Nil);
        }
    }
}
