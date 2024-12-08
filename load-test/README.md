# k6 Setup

## Linux (Ubuntu/Debian)

```
sudo apt update
sudo apt install -y gnupg2
curl -s https://dl.k6.io/key.gpg | sudo apt-key add -
echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt update
sudo apt install k6
```

## For macOS (using Homebrew)

```
brew install k6
```

## For Windows (using Chocolatey)

```
choco install k6
```

# Usage 

locally
```
./perform-load-test.sh
```

locally, cloud result aggregation
```
./perform-load-test.sh "--out cloud"
```

run on cloud
```
./perform-load-test.sh cloud
```