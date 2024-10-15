# Use the official Node.js 14 image as a parent image
FROM node:lts

# Set the working directory inside the container
WORKDIR /app

# Copy only the server.js file into the working directory
COPY server.js .

# The application uses environment variables for configuration
# Set default values for environment variables if necessary
ENV APP_NAME DefaultAppName
ENV PORT 3000


# Define the command to run the app
CMD [ "node", "server.js" ]