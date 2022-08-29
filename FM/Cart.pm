package Plugin::FM::Cart;

use Moose::Role;
use Method::Signatures;

method cart($arg?) {

    ## save data to redis if present.
    $self->rd->data(cart => $arg) if defined $arg;

    ## set expier for auth key
    if(exists $arg->{expires}){

        ## parse expireat from FM order info
        my $d = $self->date_parser->parse_datetime($arg->{'expires'});

        ## set expireat for current key fm:cart:xx-xx-xx-xx
        $self->rd->redis->expireat( $self->rd->_key, $d->epoch ) if $d->epoch > 0;
    }

    ## return cart data
    return $self->rd->data('cart');
}

method cart_data($arg?) {
    $self->cart_parser->execute( $self->cart( $arg ) );
}

method cart_data_clean {
    $self->rd->del;
}

method cart_data_items {
    my $items = $self->cart_data;
    my @b; push @b, $items->{item}->{$_} for ( keys %{ $items->{item} } );
    return \@b;
}

method cart_item_delete($id?) {
    Api->new(
        {   uri     => 'DeletePlaceFromCartCommand',
            is_post => '1',
            client  => 'fm',
            arg     => { orderItem => $id }
        }
    )->cmd;
}

1;
