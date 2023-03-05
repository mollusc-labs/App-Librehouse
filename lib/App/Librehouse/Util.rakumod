use v6.d;

use Monad::Result :subs;

unit module App::Librehouse::Util;

sub decode-url-encoded(Str:D $urlencoded --> Hash) is export {
    $_ = $urlencoded;
    s:g/^\?/''/;
    try {
        CATCH { default { error($_) } }
        ok(%(|$_.split('&', :skip-empty)>>.split('=', :skip-empty)));
    }
}
