package main;

use strict;
use warnings;

use lib qw{ inc };

use Astro::SIMBAD::Client::Test;

access;

call set => type => 'txt';
call set => format => 'txt=FORMAT_TXT_SIMPLE_BASIC';
call set => parser => 'txt=Parse_TXT_Simple';

load_module 'SOAP::Lite';
load_data 't/canned.data';

echo <<'EOD';

Test the handling of simple text

The following tests use the query (SOAP) interface
EOD

silent hidden 'SOAP::Lite';
call query => id => 'Arcturus';
silent 0;
count;
test 1, 'query id Arcturus (txt) - number of objects returned';

deref 0, 'name';
test canned( arcturus => 'name' ), 'query id Arcturus (txt) - name';

deref 0, 'ra';
test canned( arcturus => 'ra' ), 'query id Arcturus (txt) - right ascension';

deref 0, 'dec';
test canned( arcturus => 'dec' ), 'query id Arcturus (txt) - declination';

deref 0, 'plx';
test canned( arcturus => 'plx' ), 'query id Arcturus (txt) - parallax';

deref 0, 'pmra';
test canned( arcturus => 'pmra' ),
    'query id Arcturus (txt) - proper motion in right ascension';

deref 0, 'pmdec';
test canned( arcturus => 'pmdec' ),
    'query id Arcturus (txt) - proper motion in declination';

deref 0, 'radial';
test canned( arcturus => 'radial' ),
    'query id Arcturus (txt) - radial velocity in recession';


clear;
call set => parser => 'script=Parse_TXT_Simple';

echo <<'EOD';

The following tests use the script interface
EOD

call script => <<'EOD';
format obj "---\nname: %idlist(NAME|1)\ntype: %otype\nlong: %otypelist\nra: %coord(d;A)\ndec: %coord(d;D)\nplx: %plx(V)\npmra: %pm(A)\npmdec: %pm(D)\nradial: %rv(V)\nredshift: %rv(Z)\nspec: %sptype(S)\nbmag: %fluxlist(B)[%flux(F)]\nvmag: %fluxlist(V)[%flux(F)]\nident: %idlist[%*,]\n"
query id arcturus
EOD

count;
test 1, q{script 'query id arcturus' - number of objects returned};

deref 0, 'name';
test canned( arcturus => 'name' ), q{script 'query id arcturus' - name};

deref 0, 'ra';
test canned( arcturus => 'ra' ),
    q{script 'query id arcturus' - right ascension};

deref 0, 'dec';
test canned( arcturus => 'dec' ),
    q{script 'query id arcturus' - declination};

deref 0, 'plx';
test canned( arcturus => 'plx' ), q{script 'query id arcturus' - parallax};

deref 0, 'pmra';
test canned( arcturus => 'pmra' ),
    q{script 'query id arcturus' - proper motion in right ascension};

deref 0, 'pmdec';
test canned( arcturus => 'pmdec' ),
    q{script 'query id arcturus' - proper motion in declination};

deref 0, 'radial';
test canned( arcturus => 'radial' ),
    q{script 'query id arcturus' - radial velocity in recession};


clear;
echo <<'EOD';

The following tests use the script_file interface
EOD

call script_file => 't/arcturus.simple';

count;
test 1, 'script_file t/arcturus.simple - number of objects returned';

deref 0, 'name';
test canned( arcturus => 'name' ), 'script_file t/arcturus.simple - name';

deref 0, 'ra';
test canned( arcturus => 'ra' ),
    'script_file t/arcturus.simple - right ascension';

deref 0, 'dec';
test canned( arcturus => 'dec' ),
    'script_file t/arcturus.simple - declination';

deref 0, 'plx';
test canned( arcturus => 'plx' ), 'script_file t/arcturus.simple - parallax';

deref 0, 'pmra';
test canned( arcturus => 'pmra' ),
    'script_file t/arcturus.simple - proper motion in right ascension';

deref 0, 'pmdec';
test canned( arcturus => 'pmdec' ),
    'script_file t/arcturus.simple - proper motion in declination';

deref 0, 'radial';
test canned( arcturus => 'radial' ),
    'script_file t/arcturus.simple - radial velocity in recession';


end;

1;
