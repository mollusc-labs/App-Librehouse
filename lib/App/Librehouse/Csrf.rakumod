use v6.d;

use App::Librehouse::Database;

use UUID::V4;

unit class App::Librehouse::Csrf;

has Str:D $.token is required;
has DateTime:D $.age = DateTime.now;

my %csrf-tokens;
my $csrf-stream = Channel.new;
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
                my $clear-stream = False;
                for %csrf-tokens.pairs -> $csrf {
                    if (DateTime.now - $csrf.value.age) >= 3600 {
                        $lock.protect({
                            %csrf-tokens{$csrf.value.token}:delete;
                        });
                        $clear-stream = True;
                    }
                }
                $lock.protect({ $csrf-stream = Channel.new }) if $clear-stream;
                await Promise.in(2);
            }
        }
    }

    Thread.new(:&code).run;
}

sub validate-token(Str:D $token) is export {
    my $result = validate-csrf($token);
    $lock.protect({ %csrf-tokens{$token}:delete }) if $result;
    return $result;
}

sub csrf-token is export {
    $csrf-stream;
}
