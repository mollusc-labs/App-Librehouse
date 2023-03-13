use v6.d;

use Email::Valid;
use Monad::Result;
use Digest::SHA256::Native;

use App::Librehouse::Database;

unit module App::Librehouse::Validator;

my $email-validator = Email::Valid.new(:simple);

sub validate-email-unique(Str:D $email --> Bool:D) is export {
    my $encrypted-email = sha256-hex($email);
    given find-one('SELECT email FROM usr WHERE email = ?', $encrypted-email) {
        when Monad::Result::Error:D { return True }
        when Monad::Result::Ok:D { return False }
    }
}

sub validate-email(Str:D $email --> Bool:D) is export {
    $email-validator.validate($email);
}

sub validate-name-unique(Str:D $name --> Bool:D) is export {
    given find-one('SELECT name FROM usr WHERE name = ?', $name) {
        when Monad::Result::Error:D { return True } # If the user isn't found
        when Monad::Result::Ok:D { return False } # If the user is found
    }
}

sub validate-name(Str:D $name --> Bool:D) is export {
    !$name.NFC.grep(* > 128).elems && so ($name ~~ /^\w+$/);
}
