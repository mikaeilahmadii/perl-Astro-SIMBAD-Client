package main;

use strict;
use warnings;

use lib qw{ inc };

use Astro::SIMBAD::Client::Test;

access;

load_module qw{ XML::Parser XML::Parser::Lite };
load_data 't/canned.data';

call set => type => 'vo';
call set => parser => 'vo=Parse_VO_Table';

echo <<'EOD';

Test the handling of VO Table data

The following tests use the query (SOAP) interface
EOD

call query => id => 'Arcturus';

count;
test 1, 'query id Arcturus (vo) - count of tables';

# For a long time the following did not work. Because the problem
# appeared to be on the SIMBAD end, they were 'todo'.

deref 0, 'data';
count;
test 1, 'query id arcturus (vo) - count of rows';

deref 0, data => 0, 0, 'value';
test canned( arcturus => 'name' ), 'query id Arcturus (vo) - name';

deref 0, data => 0, 2, 'value';
test canned( arcturus => 'ra' ), 'query id Arcturus (vo) - right ascension';

deref 0, data => 0, 3, 'value';
test canned( arcturus => 'dec' ), 'query id Arcturus (vo) - declination';

deref 0, data => 0, 4, 'value';
test canned( arcturus => 'plx' ), 'query id Arcturus (vo) - parallax';

deref 0, data => 0, 5, 'value';
test canned( arcturus => 'pmra' ),
    'query id Arcturus (vo) - proper motion in right ascension';

deref 0, data => 0, 6, 'value';
test canned( arcturus => 'pmdec' ),
    'query id Arcturus (vo) - proper motion in declination';

deref 0, data => 0, 7, 'value';
test canned( arcturus => 'radial' ),
    'query id Arcturus (vo) - radial velocity';

# For a long time the previous was 'todo'

echo <<'EOD';

The following tests use the script_file interface
EOD

clear;
load_module qw{ XML::Parser XML::Parser::Lite };
call set => parser => 'script=Parse_VO_Table';

call script_file => 't/arcturus.vo';

count;
test 1, 'script_file t/arcturus.vo - count tables';

deref 0, 'data';
count;
test 1, 'script_file t/arcturus.vo - count rows';

deref 0, data => 0, 0, 'value';
test canned( arcturus => 'name' ), 'script_file t/arcturus.vo - name';

deref 0, data => 0, 2, 'value';
test canned( arcturus => 'ra' ), 'script_file t/arcturus.vo - right ascension';

deref 0, data => 0, 3, 'value';
test canned( arcturus => 'dec' ), 'script_file t/arcturus.vo - declination';

deref 0, data => 0, 4, 'value';
test canned( arcturus => 'plx' ), 'script_file t/arcturus.vo - parallax';

deref 0, data => 0, 5, 'value';
test canned( arcturus => 'pmra' ),
    'script_file t/arcturus.vo - proper motion in right ascension';

deref 0, data => 0, 6, 'value';
test canned( arcturus => 'pmdec' ),
    'script_file t/arcturus.vo - proper motion in declination';

deref 0, data => 0, 7, 'value';
test canned( arcturus => 'radial' ),
    'script_file t/arcturus.vo - radial velocity';


echo <<'EOD';

The following tests use the url_query interface
EOD

clear;
load_module qw{ XML::Parser XML::Parser::Lite };
call set => url_args => 'coodisp1=d';

call url_query => id => Ident => 'Arcturus';
count;
test 1, 'url_query id Arcturus (vo) - count of tables';

deref 0, 'data';
count;
test 1, 'url_query id arcturus (vo) - count of rows';

deref 0, data => 0;
find meta => 1, name => 'MAIN_ID';
deref_curr 'value';
test canned( arcturus => 'name' ), 'url_query id Arcturus (vo) - name';

deref 0, data => 0;
find meta => 1, name => 'RA';
deref_curr 'value';
# want 213.9153
# As of about SIMBAD4 1.005 the default became sexagesimal
# As of 1.069 (probably much earlier) you can set coodisp1=d to display
# in decimal. But this seems not to work for VOTable output.
# As of 1.117 (April 9 2009) votable output went back to decimal. The
# coodisp option still seems not to affect it, though.
# want_load arcturus ra_hms
test canned( arcturus => 'ra' ),
    'url_query id Arcturus (vo) - right ascension';

deref 0, data => 0;
find meta => 1, name => 'DEC';
deref_curr 'value';
# want +19.18241027778
# As of about SIMBAD4 1.005 the default became sexigesimal
# As of 1.069 (probably much earlier) you can set coodisp1=d to display
# in decimal. But this seems not to work for VOTable output.
# As of 1.117 (April 9 2009) votable output went back to decimal. The
# coodisp option still seems not to affect it, though.
# want_load arcturus dec_dms
test canned( arcturus => 'dec' ),
    'url_query id Arcturus (vo) - declination';

deref 0, data => 0;
find meta => 1, name => 'PLX_VALUE';
deref_curr 'value';
test canned( arcturus => 'plx' ), 'url_query id Arcturus (vo) - parallax';

deref 0, data => 0;
find meta => 1, name => 'PMRA';
deref_curr 'value';
test canned( arcturus => 'pmra' ),
    'url_query id Arcturus (vo) - proper motion in right ascension';

deref 0, data => 0;
find meta => 1, name => 'PMDEC';
deref_curr 'value';
test canned( arcturus => 'pmdec' ),
    'url_query id Arcturus (vo) - proper motion in declination';

=begin comment

The following is what I want to release, but for internal testing I want
to test what is already released, to see if it changes. So what comes
after the comment is what is used for the nonce.

deref 0, data => 0;
find meta => 1, name => 'RV_VALUE';
deref_curr 'value';
test canned( arcturus => 'radial' ),
    'url_query id Arcturus (vo) - radial velocity';

=end comment

=cut

deref 0, data => 0;
find meta => 1, name => 'oRV:RVel';
deref_curr 'value';
test -5.2, 'url_query id Arcturus (vo) - radial velocity';


end;


1;
__DATA__

