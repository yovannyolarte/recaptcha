use strict;
use warnings;
use Test::More tests => 14;
use Captcha::reCAPTCHA::Mailhide;

use constant PUBKEY  => 'UcV0oq5XNVM01AyYmMNRqvRA==';
use constant PRIVKEY => 'E542D5DB870FF2D2B9D01070FF04F0C8';

ok my $captcha = Captcha::reCAPTCHA::Mailhide->new, "create ok";
isa_ok $captcha, 'Captcha::reCAPTCHA::Mailhide';

my $mh_url
  = $captcha->mailhide_url( PUBKEY, PRIVKEY, 'someone@example.com' );
is $mh_url,
  'http://mailhide.recaptcha.net/d?c=4jBBJ29mAjTuEk81neCXmYlMeLR6'
  . 'FAqNTe_fq72Tkq4%3d&k=UcV0oq5XNVM01AyYmMNRqvRA%3d%3d', 'url OK';

# Call it twice for coverage of HTML::Tiny caching
for ( 1 .. 2 ) {
    {
        my $mh_html = $captcha->mailhide_html( PUBKEY, PRIVKEY,
            'someone@example.com' );
        $mh_html =~ s/&#39;/&apos;/g;
        is $mh_html,
          'some<a href="http://mailhide.recaptcha.net/d?c=4jBBJ29mAjTuEk'
          . '81neCXmYlMeLR6FAqNTe_fq72Tkq4%3d&amp;k=UcV0oq5XNVM01AyYmMNR'
          . 'qvRA%3d%3d" onclick="window.open(&apos;http://mailhide.reca'
          . 'ptcha.net/d?c=4jBBJ29mAjTuEk81neCXmYlMeLR6FAqNTe_fq72Tkq4%3'
          . 'd&amp;k=UcV0oq5XNVM01AyYmMNRqvRA%3d%3d&apos;, &apos;&apos;,'
          . ' &apos;height=300,location=0,menubar=0,resizable=0,scrollba'
          . 'rs=0,statusbar=0,toolbar=0,width=500&apos;); return false;"'
          . ' title="Reveal this e-mail address">...</a>@example.com',
          'HTML OK';
    }
    {
        my $mh_html = $captcha->mailhide_html( PUBKEY, PRIVKEY,
            'someone@anunusuallylongexampledomainname.com' );
        $mh_html =~ s/&#39;/&apos;/g;
        is $mh_html,
          'some<a href="http://mailhide.recaptcha.net/d?c=RzIcpJ1vtIDYCX'
          . '80j3xeJ0FygSDlzFFixr7D9J0s659NqfN9q7BrF_NRgOEsGIyJ&amp;k=Uc'
          . 'V0oq5XNVM01AyYmMNRqvRA%3d%3d" onclick="window.open(&apos;ht'
          . 'tp://mailhide.recaptcha.net/d?c=RzIcpJ1vtIDYCX80j3xeJ0FygSD'
          . 'lzFFixr7D9J0s659NqfN9q7BrF_NRgOEsGIyJ&amp;k=UcV0oq5XNVM01Ay'
          . 'YmMNRqvRA%3d%3d&apos;, &apos;&apos;, &apos;height=300,locat'
          . 'ion=0,menubar=0,resizable=0,scrollbars=0,statusbar=0,toolba'
          . 'r=0,width=500&apos;); return false;" title="Reveal this e-m'
          . 'ail address">...</a>@anunusuallylongexampledomainname.com',
          'HTML OK';
    }
}

my @addr = (
    'someone@example.com', [ 'some', '...', '@', 'example.com' ],
    'someon@example.com',  [ 'som',  '...', '@', 'example.com' ],
    'someo@example.com',   [ 'som',  '...', '@', 'example.com' ],
    'some@example.com',    [ 's',    '...', '@', 'example.com' ],
    'som@example.com',     [ 's',    '...', '@', 'example.com' ],
    'so@example.com',      [ 's',    '...', '@', 'example.com' ],
    's@example.com',       [ 's',    '...', '@', 'example.com' ],
);

while ( my ( $em, $want ) = splice @addr, 0, 2 ) {
    my @parts = Captcha::reCAPTCHA::Mailhide::_email_parts( $em );
    is_deeply \@parts, $want, "$em: parts ok";
}
