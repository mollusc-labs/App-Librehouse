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
    return error(%) without %content<password> && %content<name>;
    given find-one('SELECT id, picture, name, reputation FROM usr WHERE name = ? AND password = ?', %content<name>, %content<password>) {
        when Monad::Result::Ok:D {
            return $_;
        }

        when Monad::Result::Error:D {
            return error(@({ :key<not-found>,
                             :value<Could not find a user with those credentials> }));
        }
    }
}

#| Validates a signup map, returns a map of errors corresponding to
#| the field that has an error.
sub validate-signup(%content --> Map:D) {
    use App::Librehouse::Validator;
    my %errors;
}

sub signup(%content --> Monad::Result:D) is export {
    my @valid-keys = ['password', 'confirm', 'name', 'email'];
    return error(List.new) unless @valid-keys == %content.grep(*.key ne 'csrf')>>.key.List; # Make sure content is what we expect
    my %errors = validate-signup(%content);
}
