use v6.d;

use DBIish;
use Monad::Result :subs;
use Env::Dotenv :load;

unit module App::Librehouse::Database;

dotenv_load;

sub db is export {
    state $db = DBIish.connect('Pg',
                               :host<localhost>,
                               :port(5432),
                               :database<librehouse>,
                               user => %*ENV<POSTGRES_USER>,
                               password => %*ENV<POSTGRES_PASSWORD>);
    $db;
}

sub exec-raw-sql(Str:D $sql) is export { 
    try {
        CATCH {
            default {
                return error($_);
            }
        }

        db.execute($sql);
 
        return ok(Nil);
    } 
}

sub exec-sql(Str:D $sql, *@args --> Monad::Result:D) is export {
    try {
        CATCH {
            default {
                return error($_);
            }
        }

        my $stmt = db.prepare($sql);
        $stmt.execute(|@args);
 
        return ok($stmt.all-rows(:array-of-hash));
    }
}

