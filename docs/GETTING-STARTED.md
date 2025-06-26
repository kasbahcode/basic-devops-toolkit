# 🚀 Getting Started with Basic DevOps Toolkit

Welcome! This guide will get you from zero to deployed in under 5 minutes.

## 📋 What You Need

- **Computer**: Mac, Linux, or Windows
- **Internet**: For downloading tools
- **5 minutes**: That's it!

## ⚡ Quick Start

### Step 1: Setup (2 minutes)

```bash
# Clone the toolkit
git clone https://github.com/kasbahcode/basic-devops-toolkit.git
cd basic-devops-toolkit

# Run setup (installs Docker & Node.js)
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Step 2: Create Your First App (30 seconds)

```bash
# Create a new app
./scripts/create-app.sh my-first-app
```

### Step 3: Start Your App (30 seconds)

```bash
# Go to your app
cd my-first-app

# Start it with Docker
docker-compose up -d

# 🎉 Your app is running!
```

### Step 4: Check It Works

Open your browser: http://localhost:3000

You should see:
```json
{
  "message": "Welcome to my-first-app!",
  "version": "1.0.0",
  "environment": "development"
}
```

## 🎯 What You Just Built

Your app includes:
- ✅ **Node.js API** with Express
- ✅ **Docker container** for easy deployment
- ✅ **Health check** endpoint
- ✅ **Production-ready** configuration

## 📊 Useful Commands

```bash
# Check if your app is healthy
curl http://localhost:3000/health

# View app info
curl http://localhost:3000/api/info

# View logs
docker-compose logs -f

# Stop the app
docker-compose down

# Restart the app
docker-compose restart
```

## 🚀 Deploy to a Server

Have a server? Deploy in 1 minute:

```bash
# From your app directory
../basic-devops-toolkit/scripts/deploy.sh -s your-server.com -a my-first-app
```

**Requirements**: SSH access to your server

## 📊 Monitor Your App

Check app health anytime:

```bash
# Basic health check
../basic-devops-toolkit/monitoring/health-check.sh

# Check specific URL
../basic-devops-toolkit/monitoring/health-check.sh -u http://your-server.com:3000
```

## 🔧 Customize Your App

Your app is in these files:
- `index.js` - Main application code
- `package.json` - Dependencies and scripts
- `Dockerfile` - Container configuration
- `docker-compose.yml` - Local development setup

## 🎓 Learn More

### Basic Concepts You Just Used:
- **Containerization** - Your app runs in Docker
- **Health Checks** - Automatic monitoring
- **Environment Variables** - Configuration
- **API Design** - RESTful endpoints

### Next Steps:
1. **Modify** `index.js` to add your own features
2. **Add** environment variables in `.env`
3. **Deploy** to a real server
4. **Monitor** with health checks

## 🚀 Ready for More?

The Basic DevOps Toolkit is perfect for:
- ✅ Learning DevOps
- ✅ Personal projects
- ✅ Simple deployments
- ✅ Prototypes

**Need production features?**

| Feature | Basic (Free) | Enterprise |
|---------|-------------|------------|
| **Databases** | ❌ | ✅ PostgreSQL, Redis |
| **Monitoring** | Basic | ✅ Grafana, Prometheus |
| **Security** | ❌ | ✅ Vulnerability scanning |
| **CI/CD** | ❌ | ✅ GitHub Actions |
| **Cloud Deploy** | ❌ | ✅ AWS, Azure, GCP |
| **Load Testing** | ❌ | ✅ Performance testing |

**Upgrade to [Enterprise DevOps Toolkit](https://github.com/kasbahcode/devops-toolkit)**

## 🆘 Need Help?

- **Issues**: [Report a problem](https://github.com/kasbahcode/basic-devops-toolkit/issues)
- **Questions**: [Ask the community](https://github.com/kasbahcode/basic-devops-toolkit/discussions)
- **Email**: devops@kasbahcode.com

## 🎉 You Did It!

You now have:
- ✅ Professional app running in Docker
- ✅ Health monitoring
- ✅ Deployment capability
- ✅ Production-ready foundation

**Keep building!** 🚀

---

*Start simple, scale when ready. The Basic DevOps Toolkit gets you started. The Enterprise DevOps Toolkit gets you to production.* 