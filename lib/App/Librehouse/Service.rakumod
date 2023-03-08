use v6.d;

use Monad::Result :subs;
use Digest::SHA256::Native;
use UUID::V4;

use App::Librehouse::Database;

unit module App::Librehouse::Service;

# Example of a find-one
sub find-user-by-id(Str:D $id --> Monad::Result:D) is export {
    find-one('SELECT * FROM usr_view WHERE id = ?', $id);
}

sub find-user-by-name-and-password(Str:D $name, Str:D $password --> Monad::Result:D) {
    my $password-hash = sha256-hex($password);
    find-one(q:to/SQL/, $name, $password-hash);
    SELECT * FROM usr
    WHERE name = ? AND password = ?
    SQL
}

sub update-last-login(Str:D $id) {
    exec-sql('UPDATE usr SET last_login = CURRENT_TIMESTAMP WHERE id = ?', $id);
}

# Logs the user in
sub login(%content --> Monad::Result:D) is export {
    return error(%) without %content<password> && %content<name>;
    given find-user-by-name-and-password(%content<name>, %content<password>) {
        when Monad::Result::Ok:D {
            update-last-login($_.value<id>);
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
sub validate-signup(%content --> List:D) {
    use App::Librehouse::Validator;
    my %errors;
    %errors<email>            = 'Your email is invalid.' unless validate-email(%content<email>);
    %errors<email-unique>     = 'That email is already in use.' unless validate-email-unique(%content<email>);
    %errors<name-short>       = 'Your username is too short.' if %content<name>.chars < 2;
    %errors<name-long>        = 'Your username is too long.' if %content<name>.chars > 30;
    %errors<name-unique>      = 'That name is already in use.' unless validate-name-unique(%content<name>);
    %errors<name>             = 'Your name may only contain ascii characters.' unless validate-name(%content<name>);
    %errors<password-short>   = 'Your password is too short.' if %content<password>.chars < 8;
    %errors<password-long>    = 'Your password is WAY to long.' if %content<password>.chars > 5000;
    %errors<confirm>          = 'Your passwords did not match.' if %content<confirm> ne %content<password>;
    %errors.pairs.map({ Map.new: 'key', $_.key, 'value', $_.value }).List;
}

sub create-user(%user --> Monad::Result:D) {
    say %user.raku;
    my $email = sha256-hex(%user<email>);
    my $password = sha256-hex(%user<password>);
    exec-sql(q:to/SQL/, uuid-v4(), %user<name>, $email, $password);
    INSERT INTO usr (id, name, email, password)
    VALUES (?, ?, ?, ?)
    SQL
}

sub signup(%content --> Monad::Result:D) is export {
    my $valid-keys = ('password', 'confirm', 'name', 'email');
    return error(@({ :key('400'), :value('Bad Request') })) unless $valid-keys =~= %content.grep(*.key ne 'csrf')>>.key.List; # Make sure content is what we expect
    
    my $errors = validate-signup(%content);
    if $errors.elems {
        return error($errors);
    } else {
        create-user(%content);
    }
}
