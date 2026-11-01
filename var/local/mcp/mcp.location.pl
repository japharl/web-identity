use Mojolicious::Lite -signatures;
use MCP::Server;
use MaxMind::DB::Reader;
use Mojo::JSON;


# 1. Register the ClientIP plugin
plugin 'ClientIP';

my $server = MCP::Server->new(name => 'WebPerlMCP');
$server->state_timeout(10);

# Declare a safe slot to track the active request controller across blocks
our $CURRENT_CONTROLLER;

$server->tool(
    name         => 'location_information',
    description  => 'This tool provides information about the requesting party location information. If the client is in the cloud, the cloud information will be returned, not the users physical location.',
    input_schema => { type => 'object', additionalProperties => Mojo::JSON->false },
    code => sub ($tool, $args) {
        
        # 2. Extract the IP address safely from our controller tracking state
        my $ip;
        if ($CURRENT_CONTROLLER) {
            $ip = $CURRENT_CONTROLLER->client_ip;
        } else {
            return "Error: Inbound HTTP controller request tracking context missing.";
        }
        my $reader = MaxMind::DB::Reader->new(file => '/var/local/ipgeo-community/ipgeo-community.mmdb');
        my $record        = $reader->record_for_address($ip);
        my $cc            = $record->{'country_code'};
        my $timezone      = $record->{'timezone'};
        my $as_org        = $record->{'as_org'};
        my $is_datacenter = $record->{'is_datacenter'};
        
        return("IP: $ip Country Code: $cc Timezone: $timezone Org: $as_org Is Datacenter: $is_datacenter");
    }
);

# 3. Intercept the '/mcp' route to bind the request object explicitly before execution
any '/mcp' => sub ($c) {
    local $CURRENT_CONTROLLER = $c; # Securely tie the active request thread reference
    return $server->to_action->($c);
};

app->start;
