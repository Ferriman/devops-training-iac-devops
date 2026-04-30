terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Red Docker aislada
resource "docker_network" "iac_network" {
  name = "iac-network"
}

# Contenedor de base de datos
resource "docker_container" "db" {
  name  = "db"
  image = "postgres:15"

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
  ]

  networks_advanced {
    name = docker_network.iac_network.name
  }

  restart = "unless-stopped"
}

# Contenedor de aplicación
resource "docker_container" "app" {
  name  = "app"
  image = "eclipse-temurin:17-jdk-jammy"

  command = [
    "sh", "-c",
    <<-CMD
      mkdir -p /app && \
      cat > /app/Server.java << 'JAVA'
      import com.sun.net.httpserver.*;
      import java.io.*;
      import java.net.*;
      public class Server {
        public static void main(String[] args) throws Exception {
          HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
          server.createContext("/", exchange -> {
            String body = "<html><body><h1>Aplicacion activa</h1><p>Base de datos: ${var.db_name}</p></body></html>";
            byte[] bytes = body.getBytes();
            exchange.sendResponseHeaders(200, bytes.length);
            exchange.getResponseBody().write(bytes);
            exchange.getResponseBody().close();
          });
          server.start();
        }
      }
      JAVA
      cd /app && javac Server.java && java Server
    CMD
  ]

  networks_advanced {
    name = docker_network.iac_network.name
  }

  depends_on = [docker_container.db]
  restart    = "unless-stopped"
}

# Volumen para la configuración de Nginx
resource "docker_volume" "nginx_conf" {
  name = "nginx_conf"
}

# Contenedor proxy
resource "docker_container" "proxy" {
  name  = "proxy"
  image = "nginx:alpine"

  ports {
    internal = 80
    external = var.proxy_port
  }

  volumes {
    host_path      = abspath("${path.module}/nginx.conf")
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.iac_network.name
  }

  depends_on = [docker_container.app]
  restart    = "unless-stopped"
}
