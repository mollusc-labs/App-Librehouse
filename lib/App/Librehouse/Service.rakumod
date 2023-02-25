use v6.d;

use App::Librehouse::Database;

unit module App::Librehouse::Service;

# Example of a find
sub find-user(Str:D $id --> Monad::Result:D) is export {
    exec-sql('SELECT * FROM usr WHERE id = ?', $id);
}
