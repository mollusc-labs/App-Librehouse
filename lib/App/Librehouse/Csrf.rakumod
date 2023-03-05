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
my Lock $lock .= new;

sub validate-csrf(Str:D $csrf) {
    is-uuid-v4($csrf) && (%csrf-tokens{$csrf}:exists);
}

sub start-csrf-service is export {
    my &code = {
        start {
            loop {
                if %csrf-tokens.elems >= 50 {
                    await Promise.in(1);
                    next;
                }
                
                my $csrf = App::Librehouse::Csrf.new(token => uuid-v4);        
                $lock.protect({ %csrf-tokens{$csrf.token} = $csrf });
                $csrf-stream.send: $csrf.token;
            }
        }

        start {
            loop {
                for %csrf-tokens.pairs -> $csrf {
                    if (DateTime.now - $csrf.value.age) >= 3600 {
                        $lock.protect({
                            $csrf-stream = Channel.new;
                            %csrf-tokens{$csrf.value.token}:delete;
                        });
                    }
                }
                await Promise.in(2);
            }
        }

        react {
            whenever $validation-stream {
                my $result = validate-csrf($_);
                $lock.protect({ %csrf-tokens{$_}:delete if %csrf-tokens{$_}:exists });
                $validation-result-stream.send: $_ => $result;
            }
        }
    }

    Thread.new(:&code).run;
}

sub validate-token(Str:D $token) is export {
    $validation-stream.send: $token;
    $validation-result-stream;
}

sub csrf-token is export {
    $csrf-stream;
}
