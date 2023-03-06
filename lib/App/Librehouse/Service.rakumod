use v6.d;

use Monad::Result;
use Digest::SHA2;

use App::Librehouse::Database;

unit module App::Librehouse::Service;

sub find-one(Str:D $query, *@args --> Monad::Result:D) {
    exec-sql($query, |@args) >>= -> @rows { rows.elems ?? ok(@rows[0]) !! error(@rows) };
}

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
sub login(Request:D $request --> Monad::Result:D) {
    
}
