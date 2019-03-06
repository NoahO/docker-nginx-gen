FROM jwilder/docker-gen

#ADD https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl /etc/docker-gen/templates/nginx.tmpl

# Work around https://github.com/jwilder/nginx-proxy/issues/1237
# Remove default _ section at end of file
COPY nginx.tmpl /etc/docker-gen/templates/nginx.tmpl

#Cipher beefing up

# First I thought:
#   Remove all 128bit AES ciphers from Mozilla-Modern
#   (All browsers support 256bit, NFI why this is still in TLS 1.3. IOT I guess.. but even ESP32 can do 256bit, so I dunno..)
# Then I realized:
#   Valid reasons are, performance hit of about 30%. (even with AES NI), but only really relevant for huge transfers across gigabit links
#   Also, AES 256 has some problems, might be worse than 128-bit, because of bad key schedule.
#   https://www.schneier.com/blog/archives/2009/07/another_new_aes.html
#   Then, I learned this is only related keys
#   See: https://blog.1password.com/guess-why-were-moving-to-256-bit-aes-keys/
#   " One of the two reasons why I reject Schneier’s advice is that the issue with the AES 256-bit key schedule only opens up the possibility of a related key attack. Related key attacks depend on things being encrypted with keys that are related to each other in specific ways. Imagine if a system encrypts some stuff with a key, k1 and encrypts some other stuff with a different key, k2. The attacker doesn’t know what either k1 or k2 are, but she does know the difference between those two keys are. If knowing the relationship between keys (without knowing the keys) gives the attacker some advantage in discovering the keys or decrypting material encrypted with those keys, then we have a related key attack."
#   So I thought, I'm going to remove everything that's not 256bit AES, to reduce attack surface of my server (NOT encryption)(Why enable old protocols that will never be used?)
#   But then, I can't do that for TLS 1.3 yet, due to nginx not supporting it, but I will when I can. No point hacking openssl when it will use 256 by default, and there are no known downgrade bugs

# Nginx can't select TLS13 ciphers at the moment, and is just going with defaults, so anything that suggests TLS13.x cipher lists is plain wrong.
#    https://trac.nginx.org/nginx/ticket/1529
# I can't change this. Only recompiling nginx with a different openssl (and options) would help.

#So for now:
#	ssl_protocols TLSv1.2 TLSv1.3;
#	ssl_ciphers 'ECDHE-RSA-AES256-GCM-SHA384';
#   ssl_ecdh_curve secp384r1;
#       Gives better scores, apparently stronger than ed255*

#TODO: Find some way to audit server SSL status periodically, and highlight changes.
# When iOS 12.2/MacOS/newer Android comes out I can disable TLS 1.2.
# Disable extra TLS1.3 protocols when nginx supports it.
