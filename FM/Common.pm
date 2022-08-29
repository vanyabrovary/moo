package Plugin::FM::Common;

use Moose;
use Method::Signatures;

use Plugin::FM::Parser;
use Plugin::FM::Cart;
use Plugin::FM::AuthKey;
use Plugin::FM::Pay;
use Plugin::FM::Order;
use Plugin::FM::Schema;

with 'Plugin::FM::Parser', 'Plugin::FM::Cart', 'Plugin::FM::Pay', 'Plugin::FM::AuthKey', 'Plugin::FM::Order', 'Plugin::FM::Schema';

use namespace::autoclean;

has 'app'  => ( is => 'ro',  required => 1 );
has 'rd'   => ( is => 'ro',  builder  => '_rd' );

method _rd { $self->app->myredis('fm:cart'); }

__PACKAGE__->meta->make_immutable;

1;
