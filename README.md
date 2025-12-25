# terraform-portfolio-project
# Project Objectives
1. Deploy a Next.js website on AWS
2. Implement Infrastructure as Code using Terraform
3. Configure global content delivery with AWS CloudFront
4. Apply security and performance best practices
5. Host all project files and code on GitHub

# Step 1: Prepare the Next.js Application

## Clone the Next.js Portfolio Starter Kit
Clone the Portfolio Starter Kit:  
`npx create-next-app@latest nextjs-blog --use-npm --example "https://github.com/vercel/next-learn/tree/main/basics/learn-starter"`

Navigate to the project directory and start the development server:  
`cd nextjs-blog`  
`npm run dev`  
Access your Next.js application at http://localhost:3000/

## Create Configuration File
1. In the root of your project folder, create a new file called next.config.js
2. Paste the following code into the file:
```
/**
 * @type {import('next').NextConfig}
 */
const nextConfig = {
  output: 'export',
}

module.exports = nextConfig
```

## Build Your Project  
After setting up the configuration, run the build command:  
`npm run build`  
This will generate a static export of your Next.js application in the out directory, which can be deployed to any static hosting service.  
<img width="269" height="92" alt="image" src="https://github.com/user-attachments/assets/edbd4d60-f038-4657-b950-96c3c65065cc" />
