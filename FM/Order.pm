package Plugin::FM::Order;

use Moose::Role;
use Method::Signatures;

use DateTime;

method order {
  return {
    is_post => '1',
    client  => 'fm',
    arg     => {
        login        => $self->app->config->{fm}->{login},
        password     => $self->app->config->{fm}->{password},
    }
  };
}

method order_reserv($cart) {
    my $order = $self->order;

    $order->{uri}           = 'ConfirmOrderCommand';
    $order->{arg}->{order}  = $cart->{order_id};
    $order->{arg}->{status} = 0;
    $order->{arg}->{ignoreEventLimit} = 1;

    return Api->new( $order )->cmd;
}

method order_sold($transact) {
    my $order = $self->order;

    $order->{uri}                 = 'ConfirmOrderCommand';
    $order->{email}               = $transact->{client_email};
    $order->{arg}->{order}        = $transact->{import_id};
    $order->{arg}->{status}       = 1;
    $order->{arg}->{DeliveryType} = 'ETICKET';
    $order->{arg}->{ignoreEventLimit} = 1;

    return Api->new( $order )->cmd;
}

method order_info_id {
    my $order = $self->order;

    $order->{uri}           = 'GetOrderCommand';
    $order->{my_auth_token} = $self->auth_key;

    my $order = Api->new( $order )->cmd;
    return $order->{orderId};
}

method order_info {
    my $order = $self->order;

    $order->{uri}           = 'GetOrderCommand';
    $order->{my_auth_token} = $self->auth_key;

    return Api->new( $order )->cmd;
}

method order_add_place($event_id, $pid) {
    my $order = $self->order;

    $order->{uri}           = 'ChangePlaceCommand';
    $order->{my_auth_token} = $self->auth_key;
    $order->{arg}           = { event => $event_id, pid => $pid, returnStatus => 1 };

    return Api->new( $order )->cmd;
}

method order_clean {
    my $order = $self->order;

    $order->{uri}           = 'ClearCurrentOrderCommand';
    $order->{my_auth_token} = $self->auth_key;

    return Api->new( $order )->cmd;
}

method order_save($transact) {
    my $order = $self->order_parser->execute( $self->order_sold( $transact ) );

    $self->app->auth_from_payment( $transact->{client_email} );

    if ( $order->{status} == 1 ) {

        my $order_model = $self->app->db->resultset('Ord')->create(
            {   id           => $transact->{ord_id},
                import_id    => $order->{import_id},
                client_email => $transact->{client_email},
                solded_at    => DateTime->now->ymd('')
            }
        );

        foreach ( @{ $order->{tickets} }) {

            my $order_positions_model = $order_model->create_related(
                ord_positions => {
                    price     => $_->{price},
                    prod_id   => $_->{prod_id},
                    info      => $_->{info},
                    solded_at => DateTime->now->ymd('')
                }
            );

            $self->app->db->resultset('RefVisitOrdPosition')->create({
                ref_visit_id =>  $transact->{ref_visit_id},
                ord_pos_id   =>  $order_positions_model->id
            }) if ( $transact->{ref_visit_id} );

        }

        $order_model->send_tickets_to_email;
        $self->app->fm->cart_data_clean;
        return $order_model;
    }
    return 0;
}

method order_id {
  return {
    is_post => '1',
    client  => 'fm',
    arg     => {
        login        => $self->app->config->{fm}->{login},
        password     => $self->app->config->{fm}->{password},
    }
  };
}

1;
