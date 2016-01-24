cd ..
sbt dist
cd docker

cp ../target/universal/essential-futures-1.0-SNAPSHOT.zip .

tag=essential-futures:1.0

docker build -t ${tag} .

docker run -d -p 9000:9000 ${tag}