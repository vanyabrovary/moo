package Plugin::FM::Parser;

use modules qw( DateTime::Format::Strptime Api::FM::Parse Api::Pay::Parse );

use Moose::Role;
use Method::Signatures;

has 'cart_parser'  => ( is => 'ro',  default  => sub { Api::FM::Parse->instantiate('fmcart'); } );
has 'order_parser' => ( is => 'ro',  default  => sub { Api::FM::Parse->instantiate('fmorder'); } );
has 'wfp_parser'   => ( is => 'ro',  default  => sub { Api::Pay::Parse->instantiate('purchase'); } );
has 'date_parser'  => ( is => 'ro',  default  => sub { DateTime::Format::Strptime->new( pattern => '%d.%m.%Y %T', time_zone => 'local' ); } );

1;
