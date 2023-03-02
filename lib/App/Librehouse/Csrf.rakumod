use v6.d;

use App::Librehouse::Database;

use UUID::V4;

unit class App::Librehouse::Csrf;

has Str:D $.token is required;
has DateTime:D $.age = DateTime.now;

my %csrf-tokens;
my $csrf-stream = Channel.new;
my $validation-stream = Channel.new;
my $validation-result-stream = Supplier.new;

sub validate-csrf(Str:D $csrf) {
    is-uuid-v4($csrf) && (%csrf-tokens{$csrf}:exists);
}

sub start-csrf-service is export {
    my &code = {
        start {
            loop {
                if %csrf-tokens.elems >= 50 {
                    sleep 1;
                    next;
                }
                
                my $csrf = App::Librehouse::Csrf.new(token => uuid-v4);        
                Lock.new.protect({ %csrf-tokens{$csrf.token} = $csrf });
                $csrf-stream.send: $csrf.token;
            }
        }

        start {
            loop {
                for %csrf-tokens.pairs -> $csrf {
                    if (DateTime.now - $csrf.value.age) >= 3600 {
                        Lock.new.protect({
                            $csrf-stream = Channel.new;
                            %csrf-tokens{$csrf.value.token}:delete;
                        });
                    }
                }
                sleep 2;
            }
        }

        react {
            whenever $validation-stream {
                my $result = validate-csrf($_);
                Lock.new.protect({ %csrf-tokens{$_}:delete }) if $result;
                $validation-result-stream.send: ($_, $result);
            }
        }
    }

    Thread.new(:&code).run;
}

sub validate-token(Str:D $token) is export {
    $validation-stream.send: $token;
}

sub csrf-token is export {
    $csrf-stream;
}

sub validation-result-stream is export {
    $validation-result-stream;
}
