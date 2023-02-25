use v6.d;

use DBIish;
use Monad::Result;
use Env::Dotenv :load;

unit module App::Librehouse::Database;

sub get-db is export {
    state $db = DBIish.connect('Pg',
                               :host<localhost>,
                               :port(5432),
                               :database<librehouse>,
                               user => %*ENV<POSTGRES_USER>,
                               password => %*ENV<POSTGRES_PASSWORD>);
    $db;
}

multi sub exec-sql(&query) is export {
    try {
        CATCH {
            return error($!);
        }
        my $result = &query();
        return ok($result);
    }
}
multi sub exec-sql(Str:D $query) is export {
    try {
        CATCH {
            return error($!);
        }

        my $result = get-db.exec($query);
        return ok($result);
    }
}

sub EXPORT(|) is export {
    dotenv_load;

    Map.new(
        :get-db(&get-db)
    );
}
