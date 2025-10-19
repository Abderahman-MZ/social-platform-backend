#!/bin/bash

echo "🔧 Complete Fix for Social Platform Project..."

cd ~/dev-setup/social-platform-backend

# Clean everything
echo "🧹 Cleaning project..."
mvn clean > /dev/null 2>&1
rm -rf */target
rm -rf */.mvn

# Update POM files
echo "📝 Updating POM files..."

# Update user-service POM
cat > user-service/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>com.socialplatform</groupId>
        <artifactId>backend</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>
    <artifactId>user-service</artifactId>
    <name>user-service</name>
    <description>User management microservice</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

echo "✅ Updated user-service POM"

# Download dependencies
echo "📥 Downloading dependencies..."
mvn dependency:resolve > /dev/null 2>&1

# Test compilation
echo "🔨 Testing compilation..."
mvn compile -q

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful!"
    
    # Test packaging
    echo "📦 Testing packaging..."
    mvn package -DskipTests -q
    if [ $? -eq 0 ]; then
        echo "✅ Packaging successful!"
        echo "🎉 Project is ready to run!"
    else
        echo "❌ Packaging failed"
    fi
else
    echo "❌ Compilation failed. Checking individual modules..."
    
    cd user-service
    mvn compile -q && echo "✅ User service compiled" || echo "❌ User service failed"
    cd ..
    
    if [ -d "post-service" ]; then
        cd post-service
        mvn compile -q && echo "✅ Post service compiled" || echo "❌ Post service failed"
        cd ..
    fi
    
    if [ -d "gateway-service" ]; then
        cd gateway-service
        mvn compile -q && echo "✅ Gateway service compiled" || echo "❌ Gateway service failed"
        cd ..
    fi
fi

echo "🚀 You can now try starting the services:"
echo "   cd user-service && mvn spring-boot:run"
echo "   cd post-service && mvn spring-boot:run"
echo "   cd gateway-service && mvn spring-boot:run"