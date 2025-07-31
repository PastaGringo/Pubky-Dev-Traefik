# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install git (required for some npm packages)
RUN apk add --no-cache git

# Clone the pubky-app repository
RUN git clone https://github.com/pubky/pubky-app.git .

# Install dependencies
RUN npm install

# Build the application
RUN npm run build

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["npm", "start"]