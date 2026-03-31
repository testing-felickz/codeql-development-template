package org.example;

import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.util.Headers;
import java.util.Deque;

public class UndertowExample {
    public static void main(String[] args) {
        Undertow server = Undertow.builder()
                .addHttpListener(8080, "localhost")
                .setHandler(new HttpHandler() {
                    @Override
                    public void handleRequest(final HttpServerExchange exchange) throws Exception {
                        String name = "world";
                        Deque<String> res = exchange.getQueryParameters().get("namex"); // source
                        if (res != null) {
                            name = res.getFirst();
                        }
                        exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/html");
                        exchange.getResponseSender().send("<html><body>Hello " + name + "</body></html>"); // sink: XSS
                    }
                }).build();
        server.start();
    }
}
