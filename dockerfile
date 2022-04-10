FROM alpine
#curl -sSL https://raw.githubusercontent.com/ssolifd/x/master/ssr | docker build -t solidfd/ssr - &&docker push solidfd/ssr
# RUN apk --update add --no-cache  openssh py-pip python libsodium unbound  tzdata   \
ENV kcptun_releases="https://api.github.com/repos/xtaci/kcptun/releases/latest" \ 
    kcptun_api_filename="/tmp/kcptun_api_file.txt"   
RUN apk --update add --no-cache  openssh   libsodium  rng-tools tzdata  \
  && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && addgroup -g 1000 security \
  && adduser -D -H -G security -s /bin/false -u 1000 test \
  && rm -rf /var/cache/apk/* \
 # &&  echo "RSAAuthentication yes" >> /etc/ssh/sshd_config \
  && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config  \
  && mkdir -p /root/.ssh  /config /shared \
  && echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQDVO218Ifkxrc++Ifmu1d+LL7PiB3H2IvpvbbuaVyhcWLRFRQi1eq0LrcMkZl0t2pPUIZrYbkA/kYnIY2B48Ashc94rsa0S3+V42jw0yz4eZGubuGBsJoUzs0AkaGXaptc4oHF2vUYwPJI92tAHxkp10I0RL4gOPPmw2w0/iwcLiJHKZqurahjZf2VfK2SSIhfe/iHRAvy/uA3szl3m4Ll4Z7DFWywA67ihfm03r9tpbkAi8HM+PBcLEd30eEdfsSb4PDe4lojTjYJpzXzdG8GA4+jxVoy5Qb8u0vpEX9q2B6i67JTnLhP7XY5qso4/tvoRcvaf5us5oBlTHmk1myxyYQmFySeWa/Soc8wONzANx2tf0jlar21Ylu5Iu3H+m32w2rQfmzHbI9YyyBlNMww+lNv/1oH7DKsyt4B4AKno744QxAyRBf8cV6Xx8Vy5i5yYPJdjrd/VoDMcJaokHzy/bEHwv3zAXeHmbzijgmJ6JcYirez5NFE3Ygqf6EOv+REQtrYlHaqsPYSFvS5S6dEv8+4olA1dAhKN73wlIgfU5Di6sEX+lnDDCRawd7wNF+jhBQPREhsnAp3+cZf6GES6E/C1ej7OTjtZ1ksBFHsAQF62ntghHNpU1p8OpGkjb91ZNiWur5izXamsE5ArI5XHEpXtBlIbky4TbM6HuOQxpGI9SpCRC6IdPJlxQB3+J/9i+xWe0SbQJq5fm+JBkYa47bn+sdonkNwjfpF5UEz6Mk5pBhy0qFRgSUEykcGpXO2sOrO81KIg1CAmob8+8YxS7UtsSraj6m2VYT3kFUzn6OIKXwGI5B2L2NzMHqQ0gA/AMY+2a+diydCcZfp2F3Sn9U+vReRmu5TgQQ4IToTvGM7seMxoEJN5oqss5AeIIRqbW5HNWaJYCzsMcXwIjfhvSqTyhlwg7nIRsusf2nT0EX6Ji5LnRB47sZa3wFOdV2cm4BlmHWRBR5/GPRo9UdueIlSUeWlZ/AelzPojsCs90vdegyiuv/cJ2Fr99m0UxohSRnLIzbZdpB/BdDhWT8MG3zOIlVkhwXStNaqu3HX+xgj16eK1LpB1oSuM0vdRowjVgYysIqkvji41JO4WmFzC8Uk76wQKDABNBKIKRXh8RNjwrkf4I50RlSzkP83ycaGZnJT2tKtTnYTPZp/9mXcDD9shk+f1UD3lzXHVyF4Q9HaMAHv9n+hBCJZuOJiXYGVULu81ft66FJidex4opipl3O+/5kABtVD4DZrY3use9RJDi7JbZWFScXhXNZrwZIJ8X51RbRclSLBmhhv6xkI8aBYvIQXLTjOwJX/fgyCT4AZL7lCr5feuPssMzWxSUvph/TLkrsSuVWHOSU32bcFv ssolifd@student.cccs.edu >/root/.ssh/authorized_keys \
  && chmod 400 /root/.ssh/authorized_keys \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' \ 
  && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
  && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''   \
  && echo "root:admin" | chpasswd   \
  && rm -rf /var/cache/apk/* ~/.cache 
                                                                            
WORKDIR /data/shadowsocks/
RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                git \
                                autoconf \
                                automake \
                                libtool \
                                build-base \
                                libev-dev \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                c-ares-dev  \
                                unzip \
                                curl  \
                                wget \ 
                                tar \

  
    &&  mkdir -p /data/shadowsocks \
   && mkdir -p /tmp/build-shadowsocks-libev \
    && cd /tmp/build-shadowsocks-libev \
    && git clone https://github.com/shadowsocks/shadowsocks-libev.git \
    && cd shadowsocks-libev \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --disable-documentation \
    && make install \
    && ssRunDeps="$( \
            scanelf --needed --nobanner /usr/local/bin/ss-server \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .ss-rundeps $ssRunDeps \
    && cd / \
    && rm -rf /tmp/build-shadowsocks-libev \

    # Build simple-obfs
    && mkdir -p /tmp/build-simple-obfs \
    && cd /tmp/build-simple-obfs \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && cd simple-obfs \
#    && git checkout "$SIMPLE_OBFS_VERSION" \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --disable-documentation \
    && make install \
    && simpleObfsRunDeps="$( \
            scanelf --needed --nobanner /usr/local/bin/obfs-server \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .simple-obfs-rundeps $simpleObfsRunDeps \
    && cd / \
    && rm -rf /tmp/build-simple-obfs \
    # Delete dependencies
    && apk del .build-deps \
    && echo [supervisord] > /etc/supervisord.conf \
    && echo nodaemon=true >> /etc/supervisord.conf \
    && echo [program:sshd] >> /etc/supervisord.conf \
    && echo command=/usr/sbin/sshd -D >> /etc/supervisord.conf \
    && echo [program:shadowsocks-libev] >> /etc/supervisord.conf \  
    && echo command=ss-server -s 0.0.0.0 -s ::  -p 189 -k yO6AEnfZ -m chacha20-ietf-poly1305 -t 60 -d 8.8.8.8 --plugin obfs-server --plugin-opts obfs=http -u  --fast-open   --reuse-port >> /etc/supervisord.conf \ 
   && echo [program:crond] >> /etc/supervisord.conf \
   && echo command=crond -f -L 15 >> /etc/supervisord.conf 
 #  && sed -i '3d'   /etc/supervisord.conf 

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8080
ENV METHOD      chacha20-ietf-poly1305
ENV PASSWORD yO6AEnfZ
ENV TIMEOUT     60
ENV DNS_ADDR    8.8.8.8

EXPOSE $SERVER_PORT/tcp
EXPOSE $SERVER_PORT/udp

CMD /usr/sbin/sshd -D & ss-server -s "$SERVER_ADDR" \
              -p "$SERVER_PORT" \
              -m "$METHOD"      \
              -k "$PASSWORD"    \
              -t "$TIMEOUT"     \
              -d "$DNS_ADDR"    \
              --plugin obfs-server \
              --plugin-opts obfs=http \
              -u                \
              --fast-open $OPTIONS
