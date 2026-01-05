import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class SmartDeviceSimulator {

    private static boolean isPowerOn = false; 
    private static int temperature = 24;   

    public static void main(String[] args) throws IOException {
       
        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        System.out.println(">>> [SİSTEM] Akıllı Cihaz Simülatörü Başlatılıyor...");
        System.out.println(">>> [AĞ] Port dinleniyor: " + port);

        server.createContext("/status", new StatusHandler());
        
        server.createContext("/control", new ControlHandler());

        server.setExecutor(null); 
        server.start();
        System.out.println(">>> [HAZIR] Cihaz komut bekliyor.");
    }

    static class StatusHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {

            String jsonResponse = String.format("{\"power\": %b, \"temp\": %d}", isPowerOn, temperature);
            
            
            sendResponse(exchange, jsonResponse);
        }
    }

    static class ControlHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
               
                isPowerOn = !isPowerOn;
                
                String message = isPowerOn ? "Cihaz AÇILDI" : "Cihaz KAPATILDI";
                System.out.println(">>> [KOMUT ALINDI] " + message);
                
            
                String jsonResponse = String.format("{\"message\": \"%s\", \"newState\": %b}", message, isPowerOn);
                sendResponse(exchange, jsonResponse);
            } else {
               
                String error = "{\"error\": \"Sadece POST isteği atılabilir.\"}";
                exchange.sendResponseHeaders(405, error.length());
                OutputStream os = exchange.getResponseBody();
                os.write(error.getBytes());
                os.close();
            }
        }
    }

    private static void sendResponse(HttpExchange exchange, String response) throws IOException {
        byte[] bytes = response.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
        exchange.sendResponseHeaders(200, bytes.length);
        OutputStream os = exchange.getResponseBody();
        os.write(bytes);
        os.close();
    }
}