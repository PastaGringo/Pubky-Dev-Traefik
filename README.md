```
██████╗ ██╗   ██╗██████╗ ██╗  ██╗██╗   ██╗    ████████╗██████╗  █████╗ ███████╗███████╗██╗██╗  ██╗
██╔══██╗██║   ██║██╔══██╗██║ ██╔╝╚██╗ ██╔╝    ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║██║ ██╔╝
██████╔╝██║   ██║██████╔╝█████╔╝  ╚████╔╝        ██║   ██████╔╝███████║█████╗  █████╗  ██║█████╔╝ 
██╔═══╝ ██║   ██║██╔══██╗██╔═██╗   ╚██╔╝         ██║   ██╔══██╗██╔══██║██╔══╝  ██╔══╝  ██║██╔═██╗ 
██║     ╚██████╔╝██████╔╝██║  ██╗   ██║          ██║   ██║  ██║██║  ██║███████╗██║     ██║██║  ██╗
╚═╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝
```

# Pubky-Dev-Traefik

A comprehensive Docker Compose setup for deploying Pubky applications with Traefik reverse proxy, automatic SSL certificates, and development tools.

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- A domain name pointing to your server
- Ports 80 and 443 available

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/PastaGringo/Pubky-Dev-Traefik.git
   cd Pubky-Dev-Traefik
   ```

2. **Run the interactive setup:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   The script will guide you through:
   - Domain configuration
   - SSL certificate setup
   - Admin credentials
   - Network configuration

3. **Start the services:**
   ```bash
   docker-compose up -d
   ```

## 📋 Manual Configuration

If you prefer manual setup, copy `.env.example` to `.env` and configure:

```bash
# Domain Configuration
DOMAIN=your-domain.com
SUBDOMAIN_APP=app
SUBDOMAIN_HOMESERVER=homeserver

# SSL Configuration
SSL_EMAIL=your-email@domain.com

# Homeserver Configuration
HOMESERVER_PUBLIC_IP=your.server.ip.address
HOMESERVER_ADMIN_PASSWORD=admin

# Network Configuration
DOCKER_NETWORK=pubky-network
```

## 🏗️ Architecture

### Services

- **Traefik**: Reverse proxy with automatic SSL certificates
- **Pubky App**: Main application interface
- **Pubky Homeserver**: Core homeserver functionality

### Network Structure

```
Internet → Traefik (Port 80/443) → Services
├── app.your-domain.com → Pubky App (Port 3000)
└── homeserver.your-domain.com → Pubky Homeserver (Port 8080)
```

## 🔧 Configuration Files

### Environment Variables (.env)

The `.env` file contains all configuration variables:

- `DOMAIN`: Your main domain
- `SUBDOMAIN_APP`: Subdomain for the app (default: app)
- `SUBDOMAIN_HOMESERVER`: Subdomain for homeserver (default: homeserver)
- `SSL_EMAIL`: Email for Let's Encrypt certificates
- `HOMESERVER_PUBLIC_IP`: Your server's public IP address
- `HOMESERVER_ADMIN_PASSWORD`: Admin password for homeserver
- `DOCKER_NETWORK`: Docker network name

### Homeserver Configuration

The homeserver configuration is located in `pubky-homeserver/config/homeserver.config.toml`:

```toml
[server]
bind = "0.0.0.0:8080"
public_ip = "your.server.ip.address"

[auth]
admin_password = "admin"

[storage]
data_dir = "/data"
```

## 🛠️ Management Commands

### Generate Signup Token

```bash
./generate_signup_token.sh
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f pubky-app
docker-compose logs -f pubky-homeserver
docker-compose logs -f traefik
```

### Restart Services

```bash
# All services
docker-compose restart

# Specific service
docker-compose restart pubky-app
```

### Update Services

```bash
docker-compose pull
docker-compose up -d
```

## 🔒 Security

- SSL certificates are automatically managed by Traefik and Let's Encrypt
- Admin credentials are configurable via environment variables
- Services run in isolated Docker containers
- Network access is controlled through Traefik routing

## 🐛 Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Ensure your domain points to the server
   - Check that ports 80 and 443 are open
   - Verify the email address in SSL_EMAIL

2. **Service Connection Issues**
   - Check service logs: `docker-compose logs [service-name]`
   - Verify network connectivity: `docker network ls`
   - Ensure all services are running: `docker-compose ps`

3. **Configuration Issues**
   - Validate `.env` file syntax
   - Check homeserver configuration in `pubky-homeserver/config/`
   - Verify file permissions on configuration files

### Debug Mode

Enable debug logging by adding to your `.env`:

```bash
LOG_LEVEL=DEBUG
```

## 📚 Documentation

- [Pubky Protocol Documentation](https://pubky.org)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review the logs for error messages
3. Open an issue on GitHub with detailed information about your setup and the problem

---

**Note**: This setup is designed for development and testing. For production deployments, consider additional security measures and monitoring solutions.