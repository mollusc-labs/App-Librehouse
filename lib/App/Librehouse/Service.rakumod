use v6.d;

use Monad::Result :subs;
use Digest::SHA2;

use App::Librehouse::Database;

unit module App::Librehouse::Service;

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

# Example of a find-one
sub find-user-by-id(Str:D $id --> Monad::Result:D) is export {
    find-one('SELECT * FROM usr WHERE id = ?', $id);
}

# Logs the user in
sub login(%content --> Monad::Result:D) is export {
    return error(%) unless %content<password>:exists && %content<name>;
    given find-one('SELECT id, picture, name, reputation FROM usr WHERE name = ? AND password = ?', %content<name>, %content<password>) {
        when Monad::Result::Ok:D {
            return $_;
        }

        when Monad::Result::Error:D {
            return error(Map.new('not-found', 'Could not find a user with those credentials'));
        }
    }
}
