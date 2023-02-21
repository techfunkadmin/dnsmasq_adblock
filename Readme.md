# dnsmasq with public AdBlock and SpamBlock lists
to get started you can use docker as described below

    docker build -t adblocked-dnsmasq .\
    docker container run -d --name adblocked-dnsmasq -p 53:5353/tcp -p 53:5353/udp adblocked-dnsmasq

## Licence disclaimer
You can do whatever it is you want with this. 

**BUT** be advised that some of the used lists use GPLv3 as their licence.\
So consider the restriction that comes whith that. 
I disclose my source according to GPLv3,\
since no one was able to explain to me whats right in my case.\
You are responsible for what you do with this.