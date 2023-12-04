addEventListener(
    "fetch",event => {
        let url=new URL(event.request.url);
        url.protocol="https";
        url.hostname="domain.eu.org";
        url.port="443";
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
