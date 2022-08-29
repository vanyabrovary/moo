package Plugin::FM::AuthKey;

use Api;
use Carp;
use Moose::Role;
use Method::Signatures;

method auth_key {

    # unless key exists in memory
    unless (exists $self->{auth_key}) {

        # take a key from redis fm:cart:xx-xx-xx-xx { auth_key => '' } and save it to memory
        $self->{auth_key} = $self->rd->data('auth_key');

        ## take an auth_key from FM if not exists at redis fm:cart:xx-xx-xx-xx { auth_key => '' }
        unless( $self->{auth_key} ) {

            ## make request to FM
            $self->{auth_key} = Api->new({client => 'fm', uri => '', arg => {} })->cmd_auth or croak 'No auth_key';

            ## save auth_key to redis
            $self->rd->data( auth_key => $self->{auth_key} );

            ## set ttl 900 sec
            $self->rd->redis->expire( $self->rd->_key, '900' );
        }
    }

    return $self->{auth_key};
}

method auth_key_ttl {
    $self->rd->redis->ttl( $self->rd->_key );
}

1;
